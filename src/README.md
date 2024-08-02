# src
Contains the source code for Bathtub.
Bathtub is delivered as source code.
This is the code the user must compile and include in their UVM testbench to use Bathtub.

To simulate with Bathtub, add either `-f bathtub_vip.f` or `-F bathtub_vip_rel.f` to your simulator command line.
The difference is that `bathtub_vip.f` contains absolute paths to the source files by means of the `$BATHTUB_VIP_DIR` environment variable;
`bathtub_vip_rel.f` contains relative paths, relative to the file itself.
They both set up your include search directories and read the source files for the required SystemVerilog packages, `bathtub_pkg` and `gherkin_pkg`.

## Contents
| Name              | Description |
| ----------------- | ----------- |
| bathtub_pkg/      | Source files for the `bathtub_pkg` SystemVerilog package. |
| gherkin_pkg/      | Source files for the `gherkin_pkg` SystemVerilog package. |
| README.md         | This file. |
| bathtub_macros.sv | Bathtub macro definitions. |
| bathtub_vip.f     | Simulator options file with absolute paths to source files by means of `$BATHTUB_VIP_DIR` environment variable. For use with the simulator `-f` option, e.g., `<simulator> <simulator_opts> -f $BATHTUB_VIP_DIR/bathtub_vip.f`.|
| bathtub_vip_rel.f | Simulator options file with relative paths to source files relative to this file. For use with the simulator `-F` option, e.g., `<simulator> <simulator_opts> -F $BATHTUB_VIP_DIR/bathtub_vip_rel.f`. |
