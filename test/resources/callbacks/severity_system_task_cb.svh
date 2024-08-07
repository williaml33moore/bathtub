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

`ifndef __SEVERITY_SYSTEM_TASK_CB_SVH
`define __SEVERITY_SYSTEM_TASK_CB_SVH

import uvm_pkg::*;

class severity_system_task_cb extends uvm_report_catcher;
    function new(string name="severity_system_task_cb");
        super.new(name);
    endfunction : new

    function action_e catch();
        if (get_severity() == UVM_ERROR) $error;
        if (get_severity() == UVM_FATAL) begin
        set_action(get_action() & ~UVM_EXIT);
        issue();
        $fatal;
        end
        return THROW;
    endfunction : catch

    (* fluent *)
    static function severity_system_task_cb instantiate(string name="severity_system_task_cb");
        instantiate = new(name);
    endfunction : instantiate
    
    (* fluent *)
    virtual function severity_system_task_cb add(uvm_report_object obj=null);
        uvm_report_cb::add(obj, this);
        return this;
    endfunction : add
endclass : severity_system_task_cb

  `endif // __SEVERITY_SYSTEM_TASK_CB_SVH
