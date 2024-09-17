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

`ifndef __TEST_SEQUENCE_INTERFACE_SVH
`define __TEST_SEQUENCE_INTERFACE_SVH

typedef class bathtub;

`include "bathtub_pkg/pool_provider_interface.svh"

(* doc$markdown = "\
    \ Interface for the test-level context sequence.\n\
    \ \n\
    \ The test-level context sequence implements this interface.\n\
    \ A user step definition sequence can access the test-level context sequence through its `get_current_test_sequence()` function.\n\
    \ "
*)
interface class test_sequence_interface extends pool_provider_interface;
    // =================================================================

    (* doc$markdown = "\
        \ Gets a reference to the Bathtub object.\n\
        \ \n\
        \ The user typically instantiates a `bathtub_pkg::bathtub` object from their test or some other top-level component or module.\n\
        \ The Bathtub object runs the Gherkin test via the context sequences.\n\
        \ A user step definition sequence can retrieve a reference to the Bathtub object with this function, e.g.:\n\
        \ ```sv\n\
        \ bathtub_pkg::bathtub my_bathtub = get_current_test_sequence().get_bathtub_object();\n\
        \ ```\n\
        \ "
    *)
    pure virtual function bathtub get_bathtub_object();
        // --------------------------------------------
endclass : test_sequence_interface

`ifndef __BATHTUB_SVH
`include "bathtub_pkg/bathtub.svh"
`endif // __BATHTUB_SVH

`endif // __TEST_SEQUENCE_INTERFACE_SVH
