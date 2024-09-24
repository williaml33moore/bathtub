/*
MIT License

Copyright (c) 2023 Everactive

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

`ifndef __POOL_PROVIDER_INTERFACE_SVH
`define __POOL_PROVIDER_INTERFACE_SVH

import uvm_pkg::*;

interface class pool_provider_interface;
	pure virtual function uvm_pool#(string, shortint) get_shortint_pool();
	pure virtual function uvm_pool#(string, int) get_int_pool();
	pure virtual function uvm_pool#(string, longint) get_longint_pool();
	pure virtual function uvm_pool#(string, byte) get_byte_pool();
	pure virtual function uvm_pool#(string, integer) get_integer_pool();
	pure virtual function uvm_pool#(string, time) get_time_pool();
	pure virtual function uvm_pool#(string, real) get_real_pool();
	pure virtual function uvm_pool#(string, shortreal) get_shortreal_pool();
	pure virtual function uvm_pool#(string, realtime) get_realtime_pool();
	pure virtual function uvm_pool#(string, string) get_string_pool();
	pure virtual function uvm_pool#(string, uvm_object) get_uvm_object_pool();
endclass : pool_provider_interface

`endif // __POOL_PROVIDER_INTERFACE_SVH