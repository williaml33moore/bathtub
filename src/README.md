# src
Contains the source code for Bathtub.

## Contents
| Name | Description |
| --- | --- |
| bathtub_pkg/ | Source files for the `bathtub_pkg` SystemVerilog package. |
| gherkin_pkg/ | Source files for the `gherkin_pkg` SystemVerilog package. |
| bathtub_macros.sv | Bathtub macro definitions. |
| bathtub_vip.f | Simulator options file with absolute paths to source files by means of `$BATHTUB_VIP_DIR` environment variable. For use with the simulator `-f` option. |
| bathtub_vip_rel.f | Simulator options file with relative paths to source files relative to this directory. For use with the simulator `-F` option. |
