	class feature_sequence extends uvm_sequence implements feature_sequence_interface;
		gherkin_pkg::feature feature;
		gherkin_document_runner runner;
		pool_provider pool_prvdr;

		function new(string name="feature_sequence");
			super.new(name);
          	feature = null;
			runner = null;
			pool_prvdr = new();
		endfunction : new

		`uvm_object_utils(feature_sequence)

      virtual function void configure(gherkin_pkg::feature feature, gherkin_document_runner runner);
			this.feature = feature;
			this.runner = runner;
		endfunction : configure

		virtual task body();
			if (feature != null) begin
				feature.accept(runner); // runner.visit_feature(feature)
			end
		endtask : body

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

	endclass : feature_sequence
