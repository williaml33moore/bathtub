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

`ifndef __CONTEXT_SEQUENCE_SVH
`define __CONTEXT_SEQUENCE_SVH

typedef class pool_provider;
`include "bathtub_pkg/pool_provider.svh"

virtual class context_sequence extends uvm_sequence implements pool_provider_interface;
	pool_provider pool_prvdr;

	function new(string name="context_sequence");
		super.new(name);
		pool_prvdr = new();
	endfunction : new

	virtual function uvm_pool#(string, shortint) get_shortint_pool();
		return pool_prvdr.get_shortint_pool();
	endfunction : get_shortint_pool

	virtual function uvm_pool#(string, int) get_int_pool();
		return pool_prvdr.get_int_pool();
	endfunction : get_int_pool
	
	virtual function uvm_pool#(string, longint) get_longint_pool();
		return pool_prvdr.get_longint_pool();
	endfunction : get_longint_pool
	
	virtual function uvm_pool#(string, byte) get_byte_pool();
		return pool_prvdr.get_byte_pool();
	endfunction : get_byte_pool
	
	virtual function uvm_pool#(string, integer) get_integer_pool();
		return pool_prvdr.get_integer_pool();
	endfunction : get_integer_pool
	
	virtual function uvm_pool#(string, time) get_time_pool();
		return pool_prvdr.get_time_pool();
	endfunction : get_time_pool
	
	virtual function uvm_pool#(string, real) get_real_pool();
		return pool_prvdr.get_real_pool();
	endfunction : get_real_pool
	
	virtual function uvm_pool#(string, shortreal) get_shortreal_pool();
		return pool_prvdr.get_shortreal_pool();
	endfunction : get_shortreal_pool
	
	virtual function uvm_pool#(string, realtime) get_realtime_pool();
		return pool_prvdr.get_realtime_pool();
	endfunction : get_realtime_pool
	
	virtual function uvm_pool#(string, string) get_string_pool();
		return pool_prvdr.get_string_pool();
	endfunction : get_string_pool
	
	virtual function uvm_pool#(string, uvm_object) get_uvm_object_pool();
		return pool_prvdr.get_uvm_object_pool();
	endfunction : get_uvm_object_pool

endclass : context_sequence

`endif // __CONTEXT_SEQUENCE_SVH
