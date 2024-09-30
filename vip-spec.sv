/*
MIT License

Copyright (c) 2024 William L. Moore

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/*****************************************
VIP specification--useful information about the VIP--provided as a packaged static value object.

Usage:
Compile the package and access fields in the value object, e.g., `bathtub_$vip_spec::spec.version`.
*****************************************/

`ifndef BATHTUB__VIP_SPEC_SV
`define BATHTUB__VIP_SPEC_SV

`timescale 1s/1ms

package bathtub_$vip_spec;

    /*
     * Specifier schema
     */
    typedef struct {
        string name, description, version, repository, author, license, bugs,
        homepage, path, incdirs[], files[];
    } spec_schema;
    
    /*
     * VIP specifier
     */
     const var static spec_schema spec = '{
        name: "bathtub",
        description: "BDD for SystemVerilog and UVM",
        version: "1.0.1",
        repository: "https://github.com/williaml33moore/bathtub.git",
        author: "Bill Moore <williaml33moore@gmail.com>",
        license: "MIT",
        bugs: "https://github.com/williaml33moore/bathtub/issues",
        homepage: "https://bathtubbdd.dev",
        path: `__FILE__,
        incdirs: '{
            "src",
            "src/gherkin_pkg",
            "src/bathtub_pkg",
            "src/bathtub_pkg/gherkin_document_printer",
            "src/bathtub_pkg/gherkin_document_runner",
            "src/bathtub_pkg/gherkin_parser"
        },
        files: '{
            "src/gherkin_pkg/gherkin_pkg.sv",
            "src/bathtub_pkg/bathtub_pkg.sv"
        },
        string: ""
    };

endpackage : bathtub_$vip_spec

`endif // BATHTUB__VIP_SPEC_SV
