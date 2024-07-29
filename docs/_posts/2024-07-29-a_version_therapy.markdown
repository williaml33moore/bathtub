---
layout: post
author: Bill
title: "A Version Therapy"
date: 2024-07-29 06:00:00 -0700
tags: simulator uvm systemverilog
---
When I first started developing Bathtub in 2022, our silicon team at Everactive was still using UVM 1.2.
Having been released in 2014, version 1.2 was several years old by then.
Several, newer versions of IEEE 1800.2 were available, but we stuck with 1.2 because all of our legacy testbench code was based on it.
My colleague Andy Shih made a heroic effort to update our entire environment to 1800.2, but we hit a bug in both the reference implementation and the vendor's library that broke our tests.
Andy had a workaround, but the bug made me nervous so I decided we shouldn't make the switch until the vendor fixed the bug.
That never happened.
Sorry, Andy.

Now that I'm effectively a VIP provider, the shoe is on the other foot.
It's up to me to ensure that Bathtub works with as many UVM versions as possible, not just 1.2.
Challenge accepted.

First, I downloaded all the publicly available UVM releases from [Accellera](https://www.accellera.org/downloads/standards/uvm).
Then, I made a list of all the UVM implementations bundled with our current simulator installations.
I put them all together in a fancy YAML configuration file, with sections for Xcelium and Questa, and the vendor-independent reference implementations from Accellera.
This file isn't checked into GitHub because its contents only make sense in my local filesystem.
The variables you see in \[BRACKETS\] are redacted absolute paths to my local directories.
Anyone wanting to run my Bathtub tests on a different host in a different environment would need to create their own config file, specific to them.

```yaml
- name: Xcelium
  home: [TOOLS_DIR]/xcelium/2109
  uvm_versions:
  - [TOOLS_DIR]/xcelium/2109/tools.lnx86/methodology/UVM/CDNS-1.1d
  - [TOOLS_DIR]/xcelium/2109/tools.lnx86/methodology/UVM/CDNS-1.2
  - [TOOLS_DIR]/xcelium/2109/tools.lnx86/methodology/UVM/CDNS-1.2-ML
  - [TOOLS_DIR]/xcelium/2109/tools.lnx86/methodology/UVM/CDNS-IEEE

- name: Questa
  home: [TOOLS_DIR]/questa/2022.1/questasim
  uvm_versions:
  - [TOOLS_DIR]/questa/2022.1/questasim/verilog_src/uvm-1.1c
  - [TOOLS_DIR]/questa/2022.1/questasim/verilog_src/uvm-1.1d
  - [TOOLS_DIR]/questa/2022.1/questasim/verilog_src/uvm-1.2

uvm_versions:
- [LIBRARIES_DIR]/uvm/uvm-1.0p1
- [LIBRARIES_DIR]/uvm/uvm-1.1a
- [LIBRARIES_DIR]/uvm/uvm-1.1b
- [LIBRARIES_DIR]/uvm/uvm-1.1c
- [LIBRARIES_DIR]/uvm/uvm-1.1d
- [LIBRARIES_DIR]/uvm/uvm-1.2
- [LIBRARIES_DIR]/uvm/1800.2-2017-0.9
- [LIBRARIES_DIR]/uvm/1800.2-2017-1.0
- [LIBRARIES_DIR]/uvm/1800.2-2017-1.1
- [LIBRARIES_DIR]/uvm/1800.2-2020-1.0
- [LIBRARIES_DIR]/uvm/1800.2-2020-1.1
- [LIBRARIES_DIR]/uvm/1800.2-2020-2.0
- [LIBRARIES_DIR]/uvm/1800.2-2020.3.0
```
This structure is a little complicated, but it enables me to write `pytest` Python tests that iterate over all valid combinations of simulator and UVM version, and run end-to-end Bathtub tests on them. That's 33 combinations, a real meat grinder of a test suite.

```
[Xcelium.uvm_versions] + [Questa.uvm_versions] + [Xcelium, Questa] × [uvm_versions] = [test combinations]

                     4 +                     3 +                 2 ×             13 =                  33
```

Given Andy's earlier experience converting to IEEE 1800.2, I was afraid there would be major roadblocks porting Bathtub to all these different versions.
Happily it went much smoother than expected.

The biggest issue was one I already knew about.
UVM 1.2 introduced message trace macros.
They allow you to print nicely formatted displays of different types of variables conveniently.
For example:
```sv
`uvm_info_begin("MY_ID", "This is my message...", UVM_LOW)
    `uvm_message_add_tag("my_color", "red")
    `uvm_message_add_int(my_int, UVM_DEC)
    `uvm_message_add_string(my_string)
    `uvm_message_add_object(my_obj)
`uvm_info_end
```
I use them a lot in Bathtub.
These macros don't exist in UVM 1.1d and earlier, so Bathtub can't compile with them.
My fix is a hack, but it works.
I simply define my own versions of these macros if they are not already defined.
They don't print as pretty as the official UVM 1.2 macros, but they work and print _something_, and that's good enough for now.
It's the Agile way.

The next issue is similar.
UVM 1.2 introduced function `uvm_report_object::uvm_get_report_object()` and I use it, so Bathtub fails to compile with UVM 1.1d and earlier.
My fix for this issue is a little different.
I replace the function call with my own macro, which calls `uvm_get_report_object()` or a suitably equivalent alternative conditionally based on the UVM version macros.

UVM 1.2 introduced function `uvm_sequence_base::set_starting_phase()`.
I use it as a formality, so to compile with UVM 1.1d and earlier, I simply omit that function call and it works fine.

Lastly, going way back to UVM 1.0, sequences can't have negative priority, so Bathub fails to compile with UVM 1.0 because I use a UVM 1.2-style priority of -1.
The fix is simple: conditionally set the sequence priority to 100, a positive number, if needed.

It was a fair amount of work to duplicate the message trace macros because there are several of them, but overall with this small number of changes, I was able to compile and run with every version of UVM prior and up to 1.2 with no major headaches.

Then I moved on to the modern era: compiling Bathtub with IEEE 1800.2 2017 and newer.

The first issue is comical to me.
1800.2-2020 changed the name of function `uvm_split_string()` to `uvm_string_split()`.

Seriously?!

Easy fix:
```sv
`ifdef UVM_VERSION_POST_2017
            uvm_string_split(plusarg_values[i], ",", split_values);
`else
            uvm_split_string(plusarg_values[i], ",", split_values);
`endif
```

The final issue I hit is quite gratifying.
UVM 1800.2-2020 1.0 doesn't compile with Xcelium.
I don't mean Bathtub doesn't compile, I mean UVM 1800.2-2020 1.0 _itself_ doesn't compile with Xcelium.
It turns out this is a known issue, and indeed, this is the sole reason for the existence of the UVM 1800.2-2020 _1.1_ hotfix.
From the README:
> # Bug Fixes
>
> The following bugs were fixed in 1.1.
>
> The only Update in 1.1 is,  if XCELIUM is defined then define UVM_USE_PROCESS_CONTAINER is added.

Sure enough, since 1.0 does not define that `UVM_USE_PROCESS_CONTAINER` macro, all I have to do is define it myself on the command line with `+define+UVM_USE_PROCESS_CONTAINER`, and then Bathtub compiles and runs and passes with UVM 1800.2-2020 1.0.
Since I caught that bug which was previously unknown to me, I feel pretty good about my meat grinder of a test suite.

As much as we would all enjoy staying up to date with the latest and greatest versions of tools and libraries, the reality is there are often legacy concerns and other hurdles that hold us back.
My commitment is to make sure that Bathtub passes at least a sanity check with as many versions as reasonable, in order to support as many users as possible.
