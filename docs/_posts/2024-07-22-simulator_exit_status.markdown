---
layout: post
author: Bill
title: "No Exit...Status"
date: 2024-07-22 06:00:00 -0700
tags: simulator testing pytest python shell
---
I'm enjoying using [`pytest`](https://pytest.org/) to test Bathtub.
Yes, `pytest` is a Python testing framework, but the trick is to write thin Python scripts that launch SystemVerilog simulations as a [subprocess](https://docs.python.org/3/library/subprocess.html).
`Pytest` is my chosen VIP regression management engine, so of course it's crucial in the name of test automation that `pytest` be able to  detect and report accurately when simulations fail.
I had worked out a scheme for `pytest` to use the simulator's exit status to detect failures, so imagine my horror when I discovered recently that my scheme didn't work all the time.
I was getting false positives.

Yikes!

A Unix/Linux command always quietly returns an integer code that represents its exit status.
By convention, if a command succeeds it exits with code 0, otherwise it exits with a nonzero code.
Shell scripts can easily determine a command's exit status by testing the `$?` variable.
With Python's `subprocess` library, subprocesses return a [`CompletedProcess`](https://docs.python.org/3/library/subprocess.html#subprocess.CompletedProcess) object that contains the return code in a member called `returncode`.
My sim-launching Python scripts simply use that `returncode` value to check if a simulation passed or failed.

It turns out there are two huge problems with that.

First, UVM macros `` `uvm_error()`` and `` `uvm_fatal()`` do not cause simulators to exit with nonzero status.
When my tests call those macros, the simulator still exits with 0, resulting in a false positive.

Second, Questa does not exit with nonzero status when I call SystemVerilog severity tasks `$error()` and `$fatal()`.
Xcelium does, but one of the two simulators I'm testing with gives me additional false positives.
That's not good.

I run Xcelium as `xrun` and Questa as `qrun`.
This table summarizes different ways simulations can exit, and their exit status with the two tools.

| Event             | Xcelium Exit Status | Questa Exit Status | Desired Status |
| :---------------- | ------------------: | -----------------: | -------------: |
| Compile error     | nonzero             | nonzero            | nonzero        |
| `` `uvm_fatal()`` | 0                   | 0                  | nonzero        |
| `` `uvm_error()`` | 0                   | 0                  | nonzero        |
| `$fatal()`        | nonzero             | 0                  | nonzero        |
| `$error()`        | nonzero             | 0                  | nonzero        |
| Assertion failure | nonzero             | 0                  | nonzero        |
| Simulation passes | 0                   | 0                  | 0              |

There are a lot of mismatches between what I desired to happen and my actual results, and that's a problem.

Both `xrun` and `qrun` take care of compiling, elaborating, and running SystemVerilog code in one convenient command.
If there's a compilation error, both tools throw a nonzero exit status to alert me to the problem, and that's great.
Likewise, if the simulation builds and runs and passes, both tools return with status code 0, indicating success.
Those results matched my expectations and I think that lulled me into a false sense of security that the tools were exiting the way I want in all circumstances.

Naturally, in my UVM testbenches I use `` `uvm_error()`` and `` `uvm_fatal()`` a lot to flag problems in self-checking code.
When running simulations, I know to inspect manually the report summary at the end of the log file to make sure there are zero UVM error and fatality messages.
Unfortunately, out of the box, neither simulator natively catches those messages nor reflects them in the exit status.
There are several strategies to remedy this, such as post-processing the log file to check for errors.
I suspect that's the most prevalent method.
For Bathtub, however, I decided to adopt a more UVM-ish solution.

I created and installed in my [tests](https://github.com/williaml33moore/bathtub/blob/main/test/simulators/test_uvm_error.sv) a simple `uvm_report_catcher` object called [`severity_system_task_cb`](https://github.com/williaml33moore/bathtub/blob/main/test/resources/callbacks/severity_system_task_cb.svh) which catches all UVM messages with severity `UVM_ERROR` and `UVM_FATAL`.
If the message is `UVM_ERROR`, the report catcher calls `$error()`, redundantly backstopping the `` `uvm_error()`` call, belt-and-suspenders style.
If the message is `UVM_FATAL`, the report catcher calls `$fatal()`, which immediately ends the simulation.

This report catcher approach has the drawback that I have to remember to install it in every report object in my testbench.
But if I do that, it just works, right?

Well...half right.

As the table shows, `$error()` and `$fatal()` exit with the status I want only with Xcelium, not with Questa.
That's a bummer.
More work is needed.

After digging around my log files, I noticed that Questa simulations produce a secondary log file called `qrun.out/stats_log`.
I inferred that `stats_log` summarizes the results from compilation and simulation and reports any errors.
For a successful end-to-end run, the file looks like this:
```
vlog: Errors: 0, Warnings: 0
vopt: Errors: 0, Warnings: 0
qrun: Errors: 0, Warnings: 0
vsim: Errors: 0, Warnings: 0
```
If there are errors, they are counted in the log as "Errors."
So for Questa, I wrote a simple Perl script called [qrun_result.pl](https://github.com/williaml33moore/bathtub/blob/main/test/scripts/qrun_result.pl) that post-processes `stats_log` and indicates success (exit status 0!) if and only if the file exists and positively records zero errors in each step.
Otherwise, the Perl script dies with a nonzero exit code.
My `pytest` Python configuration [helper module](https://github.com/williaml33moore/bathtub/blob/main/test/conftest.py) runs the Perl script after every Questa simulation, and catches all my errors and fatalities.

Yes, this is pretty complex.
If I call `` `uvm_error()`` in a `qrun` job, it gets caught by a UVM report catcher which calls `$error()` which gets logged in `stats_log` which gets post-processed by `qrun_result.pl` which returns a nonzero exit status to my Python subprocess which triggers an assertion in my test subroutine which causes the `pytest` regression to fail.
Whew.
It's a lot, but such is the life of a verification engineer.
We live and die by test automation, so we do what we have to do.

The table above contains a row for assertion errors.
I like to use SystemVerilog immediate assertions in my procedural blocks, e.g.:
```sv
check_value : assert (actualValue === expectedValue);
```
When such an assertion fails, simulators treat it a lot like a `$error()` system call in terms of exit status and error logging.
I haven't tried it, but I expect the same goes for concurrent SystemVerilog assertions (SVA) as well.


