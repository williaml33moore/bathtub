# codec
The reference implementation libraries for UVM 1.0, 1.1, and 1.2 include a working sample verification environment for a simple parallel-to-serial codec.
This example applies Bathtub to that codec environment.
The goal is to illustrate how you can apply Bathtub to any UVM testbench.
## Overview
In general, these are the steps for applying Bathtub to a UVM testbench.
1. Build a working UVM environment.
   * It should follow standard practices and include a top module, DUT, environment (`uvm_env`), and virtual sequencer.
   * You should have the simulators, scripts, and support files required to run the environment.
2. Create a new Bathtub test (`uvm_test`).
   * Instantiate a Bathtub object (`bathtub_pkg::bathtub`) and configure it with your virtual sequencer.
   * Since Bathtub will provide sequences for some of your sequencers, the test should disable any default sequences for run-time phases that might conflict.
3. Write a Gherkin feature file that describes and exercises the behavior of the DUT.
4. Write step definitions (`uvm_sequence`) for every step in the feature file.
5. Run!

This README walks through the above steps for the codec example.
## Build a UVM Environment
Fortunately this has already been done for you.
Download the UVM 1.2 reference implementation class library code ([uvm-1.2.tar.gz](https://accellera.org/images/downloads/standards/uvm/uvm-1.2.tar.gz)) from Accellera's UVM download page, <https://accellera.org/downloads/standards/uvm>.

Often UVM is installed in a central, shared location protected by restricted permissions.
However, for this codec example, you need your own personal UVM installation with full access permissions.
The UVM 1.2 `README.txt` has instructions for installing the kit.
Follow them to unpack the tarball into a "convenient location," perhaps somewhere under your home directory.
```
Installing the kit
------------------

Installation of UVM requires first unpacking the kit in a convenient
location.

    % mkdir path/to/convenient/location
    % cd path/to/convenient/location
    % gunzip -c path/to/UVM/distribution/tar.gz | tar xvf -
```
It is not necessary to set or override the `UVM_HOME` environment variable; the codec scripts take care of that for you.
It doesn't matter if you typically use a UVM version other than 1.2.
The codec example is self-contained and will compile UVM directly from your personal 1.2 installation.
