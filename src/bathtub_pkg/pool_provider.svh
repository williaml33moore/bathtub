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

`ifndef __POOL_PROVIDER_SVH
`define __POOL_PROVIDER_SVH

`include "pool_provider_interface.svh"

class pool_provider implements pool_provider_interface;
	uvm_pool#(string, shortint) shortint_pool;
	uvm_pool#(string, int) int_pool;
	uvm_pool#(string, longint) longint_pool;
	uvm_pool#(string, byte) byte_pool;
	uvm_pool#(string, integer) integer_pool;
	uvm_pool#(string, time) time_pool;
	uvm_pool#(string, real) real_pool;
	uvm_pool#(string, shortreal) shortreal_pool;
	uvm_pool#(string, realtime) realtime_pool;
	uvm_pool#(string, string) string_pool;
	uvm_pool#(string, uvm_object) uvm_object_pool;

	function new();
		shortint_pool = null;
		int_pool = null;
		longint_pool = null;
		byte_pool = null;
		integer_pool = null;
		time_pool = null;
		real_pool = null;
		shortreal_pool = null;
		realtime_pool = null;
		string_pool = null;
		uvm_object_pool = null;
	endfunction : new

	virtual function uvm_pool#(string, shortint) get_shortint_pool();
		if (!shortint_pool) shortint_pool = new("shortint_pool");
		return shortint_pool;
	endfunction : get_shortint_pool

	virtual function uvm_pool#(string, int) get_int_pool();
		if (!int_pool) int_pool = new("int_pool");
		return int_pool;
	endfunction : get_int_pool

	virtual function uvm_pool#(string, longint) get_longint_pool();
		if (!longint_pool) longint_pool = new("longint_pool");
		return longint_pool;
	endfunction : get_longint_pool

	virtual function uvm_pool#(string, byte) get_byte_pool();
		if (!byte_pool) byte_pool = new("byte_pool");
		return byte_pool;
	endfunction : get_byte_pool

	virtual function uvm_pool#(string, integer) get_integer_pool();
		if (!integer_pool) integer_pool = new("integer_pool");
		return integer_pool;
	endfunction : get_integer_pool

	virtual function uvm_pool#(string, time) get_time_pool();
		if (!time_pool) time_pool = new("time_pool");
		return time_pool;
	endfunction : get_time_pool

	virtual function uvm_pool#(string, real) get_real_pool();
		if (!real_pool) real_pool = new("real_pool");
		return real_pool;
	endfunction : get_real_pool

	virtual function uvm_pool#(string, shortreal) get_shortreal_pool();
		if (!shortreal_pool) shortreal_pool = new("shortreal_pool");
		return shortreal_pool;
	endfunction : get_shortreal_pool

	virtual function uvm_pool#(string, realtime) get_realtime_pool();
		if (!realtime_pool) realtime_pool = new("realtime_pool");
		return realtime_pool;
	endfunction : get_realtime_pool

	virtual function uvm_pool#(string, string) get_string_pool();
		if (!string_pool) string_pool = new("string_pool");
		return string_pool;
	endfunction : get_string_pool

	virtual function uvm_pool#(string, uvm_object) get_uvm_object_pool();
		if (!uvm_object_pool) uvm_object_pool = new("uvm_object_pool");
		return uvm_object_pool;
	endfunction : get_uvm_object_pool

endclass : pool_provider

`endif // __POOL_PROVIDER_SVH
