`include "svunit_defines.svh"

module mock_step_def_vseq_unit_test;
  import svunit_pkg::svunit_testcase;

  import bathtub_pkg::bathtub_pkg_metadata;
  `include "mock_step_definitions.svh"

  typedef class mock_vsequencer;
  `include "mock_vsequencer.svh"

  string name = "mock_step_def_vseq_ut";
  svunit_testcase svunit_ut;

  mock_vsequencer vsequencer;

  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  mock_step_def_vseq my_mock_step_def_vseq;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

      vsequencer = mock_vsequencer::type_id::create("vsequencer", null);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */

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



    `SVTEST(Bring_up_mock_step_definition)
      // =================================
      string step_string;
      bathtub_pkg::gherkin_step_bundle step_bundle;
      bathtub_pkg::gherkin_parser parser;
      mock_step_def_vseq my_step_def_vseq;
      bathtub_pkg::step_nurture step_attributes;
      int actual_i;
      real actual_f;
      string actual_s;
      uvm_sequence_item item;
    
      parser = new("parser");
      step_string = {"Given a step"};
      parser.parse_step_string(step_string, step_bundle);
      my_step_def_vseq = mock_step_def_vseq::type_id::create("my_step_def_vseq");
			step_attributes = bathtub_pkg::step_nurture::type_id::create("step_attributes");
      step_attributes.configure(step_bundle.step, my_step_def_vseq);
			my_step_def_vseq.set_step_attributes(step_attributes);

      fork
        begin
          // Run the sequence-under-test.
          my_step_def_vseq.start(vsequencer);
        end
        begin
          `FAIL_UNLESS(1'b0)
        end
      join

    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
