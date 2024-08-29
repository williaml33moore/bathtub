`include "svunit_defines.svh"

module mock_sequences_unit_test;
  import svunit_pkg::svunit_testcase;

  import bathtub_pkg::bathtub_pkg_metadata;
  `include "mock_step_definition_seqs.svh"

  typedef class mock_object_sequencer;
  `include "mock_sequencers.svh"


  typedef class mock_object_sequence_item;
  `include "mock_sequence_items.svh"

  typedef class mock_step_def_seq;
  `include "mock_step_definition_seqs.svh"

  string name = "mock_step_def_vseq_ut";
  svunit_testcase svunit_ut;


  mock_object_sequencer object_sqr;
  uvm_phase phase;

  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================

  mock_step_def_seq my_step_def_seq;

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    object_sqr = mock_object_sequencer::type_id::create("object_sqr", null);
    phase = new();
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */
    my_step_def_seq = mock_step_def_seq::type_id::create("my_step_def_seq");
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

    `SVTEST(Mock_step_definition_sends_itself)
      // =====================================
      string step_string;
      bathtub_pkg::gherkin_step_bundle step_bundle;
      bathtub_pkg::gherkin_parser parser;
      bathtub_pkg::step_nurture step_attributes;
    
      parser = new("parser");
      parser = parser.configure();
      step_string = $sformatf("%s a step definition with parameters %0d, %f, and %s", "Given", 42, 98.6, "Gherkin");
      parser.parse_step_string(step_string, step_bundle);
			step_attributes = new("step_attributes", step_bundle.step);
			my_step_def_seq.set_step_attributes(step_attributes);
`ifdef UVM_VERSION_1_0
      my_step_def_seq.starting_phase = phase;
`elsif UVM_VERSION_1_1
      my_step_def_seq.starting_phase = phase;
`elsif UVM_POST_VERSION_1_1
			my_step_def_seq.set_starting_phase(phase);
`else
			my_step_def_seq.set_starting_phase(phase);
`endif


      fork
        begin
          // Run the sequence-under-test.
          my_step_def_seq.start(object_sqr);
        end
        begin
          uvm_sequence_item item;
          mock_object_sequence_item obj_item;
          bathtub_pkg::step_definition_interface actual_step_def;

          object_sqr.get_next_item(item);
          object_sqr.item_done();
          `FAIL_UNLESS($cast(obj_item, item))
          `FAIL_UNLESS($cast(actual_step_def, obj_item.get_payload()));
          `FAIL_UNLESS_STR_EQUAL({actual_step_def.get_step_attributes().get_step().get_keyword(), " ", actual_step_def.get_step_attributes().get_step().get_text()},
            $sformatf("%s a step definition with parameters %0d, %f, and %s", "Given", 42, 98.6, "Gherkin"))
        end
      join

    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
