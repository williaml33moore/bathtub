https://edaplayground.com/x/Prp5

Bathtub is described in my paper "Gherkin Implementation in SystemVerilog Brings Agile Behavior-Driven Development to UVM" at DVCon U.S. 2024.
The purpose of this playground is to validate the code samples included in the paper.
It's a very minimal test bench for a simple ALU.
The test runs and passes.

File `testbench.sv` is just that, the test bench.
It contains:
* Test class `bathtub_test` as included in the paper
* Environment class `alu_env` as briefly described in the paper
* Virtual sequencer `alu_sequencer` as mentioned in the paper
* Virtual sequence base class `alu_base_vsequence` as mentioned in the paper

File `alu_division.feature` is the Gherkin feature file featured in the paper.

File `alu_step_definition.svh` contains all four step definitions required for the feature file, two of which are included in the paper.

---
https://github.com/williaml33moore/bathtub/commit/c666c807ca38988f1370ca9f4591161104a126a0