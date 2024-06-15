`include "svunit_defines.svh"

module step_definitions_unit_test;
  import svunit_pkg::svunit_testcase;
  import bathtub_pkg::step_nurture;

  typedef class hello_world_vseq;
  `include "step_definitions.svh"

  string name = "step_definitions_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  hello_world_vseq my_hello_world_vseq;
  hello_parameters_vseq my_hello_parameters_vseq;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */
    my_hello_world_vseq = hello_world_vseq::type_id::create("my_hello_world_vseq");
    my_hello_parameters_vseq = hello_parameters_vseq::type_id::create("my_hello_parameters_vseq");
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
      my_hello_world_vseq.body();
      `FAIL_UNLESS(1'b1)
    `SVTEST_END

    `SVTEST(Hello_world_start)
      // =====================
      my_hello_world_vseq.start(null);
      `FAIL_UNLESS(1'b1)
    `SVTEST_END

    `SVTEST(Hello_parameters)
      // ====================
      bathtub_pkg::step_nurture step_attributes;
			step_attributes = step_nurture::type_id::create("step_attributes");
			step_attributes.set_runtime_keyword("Given");
			step_attributes.set_text(hello_parameters_vseq::magic_step_text);
			step_attributes.set_argument(null);
			step_attributes.set_static_attributes(my_hello_parameters_vseq.get_step_static_attributes());
			step_attributes.set_current_feature_sequence(null);
			step_attributes.set_current_scenario_sequence(null);
			my_hello_parameters_vseq.set_step_attributes(step_attributes);

      my_hello_parameters_vseq.start(null);
      `FAIL_UNLESS(1'b1)
    `SVTEST_END


  `SVUNIT_TESTS_END

endmodule
