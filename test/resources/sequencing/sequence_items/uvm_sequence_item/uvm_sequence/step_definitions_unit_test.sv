`include "svunit_defines.svh"

module step_definitions_unit_test;
  import svunit_pkg::svunit_testcase;
  import bathtub_pkg::step_nurture;
  import bathtub_pkg::scenario_sequence;

  typedef class hello_world_vseq;
  typedef class hello_parameters_vseq;
  typedef class hello_parameters_pool_vseq;
  typedef class hello_parameters_seq_item_vseq;
  `include "step_definitions.svh"

  string name = "step_definitions_ut";
  svunit_testcase svunit_ut;

  
  uvm_sequencer sequencer;
  bathtub_pkg::step_attributes_pool_t global_step_attributes_pool;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
      sequencer = uvm_sequencer#(uvm_sequence_item)::type_id::create("sequencer", null);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */
    global_step_attributes_pool = bathtub_pkg::step_attributes_pool_t::get_global_pool();
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */

  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END
  //===================================
  `SVUNIT_TESTS_BEGIN

    `SVTEST(Hello_world_run_direct)
      // ==========================
      hello_world_vseq my_hello_world_vseq;

      my_hello_world_vseq = hello_world_vseq::type_id::create("my_hello_world_vseq");

      my_hello_world_vseq.body();

      `FAIL_UNLESS(1'b1)
    `SVTEST_END

    `SVTEST(Hello_world_start)
      // =====================
      hello_world_vseq my_hello_world_vseq;

      my_hello_world_vseq = hello_world_vseq::type_id::create("my_hello_world_vseq");

      my_hello_world_vseq.start(null);

      `FAIL_UNLESS(1'b1)
    `SVTEST_END

    `SVTEST(Hello_parameters)
      // ====================
      hello_parameters_vseq my_hello_parameters_vseq;
      gherkin_pkg::step step;
      bathtub_pkg::step_nurture step_attributes;

      my_hello_parameters_vseq = hello_parameters_vseq::type_id::create("my_hello_parameters_vseq");
      step = new("step", '{"Given", hello_parameters_vseq::magic_step_text, null});
			step_attributes = new("step_attributes", step);
			global_step_attributes_pool.add(my_hello_parameters_vseq, step_attributes);

      my_hello_parameters_vseq.start(null);

      `FAIL_UNLESS(1'b1)
    `SVTEST_END

    `SVTEST(Hello_pool)
      // ==============
      hello_parameters_pool_vseq my_hello_parameters_pool_vseq;
      gherkin_pkg::step step;
      bathtub_pkg::step_nurture step_attributes;
      bathtub_pkg::scenario_sequence pools;
      int actual_i;
      real actual_f;
      string actual_s;
    
      my_hello_parameters_pool_vseq = hello_parameters_pool_vseq::type_id::create("my_hello_parameters_pool_vseq");
      pools = scenario_sequence::type_id::create("pool");
      step = new("step", '{"Given", {hello_parameters_pool_vseq::magic_step_text, "42, 98.6, and Gherkin"}, null});
			step_attributes = new("step_attributes", step, pools);
			global_step_attributes_pool.add(my_hello_parameters_pool_vseq, step_attributes);

      my_hello_parameters_pool_vseq.start(null);
      
      actual_i = pools.get_int_pool().get("i");
      `FAIL_UNLESS_EQUAL(actual_i, 42)

      actual_f = pools.get_real_pool().get("f");
      `FAIL_UNLESS(actual_f * actual_f - 98.6 * 98.6 < 1.0e-6)

      actual_s = pools.get_string_pool().get("s");
      `FAIL_UNLESS_STR_EQUAL(actual_s, "Gherkin")

    `SVTEST_END

    `SVTEST(Hello_pool_from_step_string)
      // ===============================
      string step_string;
      bathtub_pkg::gherkin_step_bundle step_bundle;
      bathtub_pkg::gherkin_parser parser;
      hello_parameters_pool_vseq my_hello_parameters_pool_vseq;
      bathtub_pkg::step_nurture step_attributes;
      bathtub_pkg::scenario_sequence pools;
      int actual_i;
      real actual_f;
      string actual_s;
    
      parser = new("parser");
      parser = parser.configure();
      step_string = {"Given ", hello_parameters_pool_vseq::magic_step_text, "42, 98.6, and Gherkin"};
      parser.parse_step_string(step_string, step_bundle);
      my_hello_parameters_pool_vseq = hello_parameters_pool_vseq::type_id::create("my_hello_parameters_pool_vseq");
      pools = scenario_sequence::type_id::create("pools");
			step_attributes = new("step_attributes", step_bundle.step, pools);
			global_step_attributes_pool.add(my_hello_parameters_pool_vseq, step_attributes);

      my_hello_parameters_pool_vseq.start(null);
      
      actual_i = pools.get_int_pool().get("i");
      `FAIL_UNLESS_EQUAL(actual_i, 42)

      actual_f = pools.get_real_pool().get("f");
      `FAIL_UNLESS(actual_f * actual_f - 98.6 * 98.6 < 1.0e-6)

      actual_s = pools.get_string_pool().get("s");
      `FAIL_UNLESS_STR_EQUAL(actual_s, "Gherkin")

    `SVTEST_END

    `SVTEST(Hello_seq_item_from_step_string)
      // ===================================
      string step_string;
      bathtub_pkg::gherkin_step_bundle step_bundle;
      bathtub_pkg::gherkin_parser parser;
      hello_parameters_seq_item_vseq my_hello_parameters_seq_item_vseq;
      bathtub_pkg::step_nurture step_attributes;
      int actual_i;
      real actual_f;
      string actual_s;
      uvm_sequence_item item;
    
      parser = new("parser");
      parser = parser.configure();
      step_string = {"Given ", hello_parameters_seq_item_vseq::magic_step_text, "42, 98.6, and Gherkin"};
      parser.parse_step_string(step_string, step_bundle);
      my_hello_parameters_seq_item_vseq = hello_parameters_seq_item_vseq::type_id::create("my_hello_parameters_seq_item_vseq");
			step_attributes = new("step_attributes", step_bundle.step);
			global_step_attributes_pool.add(my_hello_parameters_seq_item_vseq, step_attributes);

      fork
        begin
          // Run the sequence-under-test.
          my_hello_parameters_seq_item_vseq.start(sequencer);
        end
        begin
          // The sequencer receives three sequence items from the sequence-under-test.
          // The payload is stored as a string in the name of each sequence item.
          integer code;

          sequencer.get_next_item(item);
          sequencer.item_done();
          code = $sscanf(item.get_name(), "i: %0d", actual_i);
          `FAIL_UNLESS_EQUAL(actual_i, 42)
          
          sequencer.get_next_item(item);
          sequencer.item_done();
          code = $sscanf(item.get_name(), "f: %f", actual_f);
          `FAIL_UNLESS(actual_f * actual_f - 98.6 * 98.6 < 1.0e-6)
          
          sequencer.get_next_item(item);
          sequencer.item_done();
          code = $sscanf(item.get_name(), "s: %s", actual_s);
          `FAIL_UNLESS_STR_EQUAL(actual_s, "Gherkin")
        end
      join

    `SVTEST_END

    `SVTEST(Hello_seq_item_uvm_do)
      // =========================
      string step_string;
      bathtub_pkg::gherkin_step_bundle step_bundle;
      bathtub_pkg::gherkin_parser parser;
      hello_parameters_seq_item_uvm_do_vseq my_sequence;
      bathtub_pkg::step_nurture step_attributes;
      int actual_i;
      real actual_f;
      string actual_s;
      uvm_sequence_item item;
    
      parser = new("parser");
      parser = parser.configure();
      step_string = {"Given ", my_sequence.magic_step_text, "42, 98.6, and Gherkin"};
      parser.parse_step_string(step_string, step_bundle);
      my_sequence = hello_parameters_seq_item_uvm_do_vseq::type_id::create("my_sequence");
			step_attributes = new("step_attributes", step_bundle.step);
			global_step_attributes_pool.add(my_sequence, step_attributes);

      fork
        begin
          // Run the sequence-under-test.
          my_sequence.start(sequencer);
        end
        begin
          // The sequencer receives three sequence items from the sequence-under-test.
          // The payload is stored as a string in the name of each sequence item.
          integer code;

          sequencer.get_next_item(item);
          sequencer.item_done();
          code = $sscanf(item.get_name(), "i: %0d", actual_i);
          `FAIL_UNLESS_EQUAL(actual_i, 42)
          
          sequencer.get_next_item(item);
          sequencer.item_done();
          code = $sscanf(item.get_name(), "f: %f", actual_f);
          `FAIL_UNLESS(actual_f * actual_f - 98.6 * 98.6 < 1.0e-6)
          
          sequencer.get_next_item(item);
          sequencer.item_done();
          code = $sscanf(item.get_name(), "s: %s", actual_s);
          `FAIL_UNLESS_STR_EQUAL(actual_s, "Gherkin")
        end
      join

    `SVTEST_END


  `SVUNIT_TESTS_END

endmodule
