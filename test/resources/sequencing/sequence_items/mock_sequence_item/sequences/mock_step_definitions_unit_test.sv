`include "svunit_defines.svh"

module mock_step_def_vseq_unit_test;
  import svunit_pkg::svunit_testcase;

  import bathtub_pkg::bathtub_pkg_metadata;
  `include "mock_step_definition_seqs.svh"

  typedef class mock_int_sequencer;
  typedef class mock_real_sequencer;
  typedef class mock_string_sequencer;
  typedef class mock_object_sequencer;
  `include "mock_sequencers.svh"

  typedef class mock_vsequencer;
  `include "mock_vsequencer.svh"

  typedef class mock_int_sequence_item;
  typedef class mock_real_sequence_item;
  typedef class mock_string_sequence_item;
  typedef class mock_object_sequence_item;
  `include "mock_sequence_items.svh"

  typedef class mock_step_def_vseq;
  `include "mock_step_definition_vseqs.svh"

  string name = "mock_step_def_vseq_ut";
  svunit_testcase svunit_ut;

  mock_int_sequencer int_sqr;
  mock_real_sequencer real_sqr;
  mock_string_sequencer string_sqr;
  mock_object_sequencer object_sqr;
  mock_vsequencer vsequencer;

  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

      int_sqr = mock_int_sequencer::type_id::create("int_sqr", null);
      real_sqr = mock_real_sequencer::type_id::create("real_sqr", null);
      string_sqr = mock_string_sequencer::type_id::create("string_sqr", null);
      object_sqr = mock_object_sequencer::type_id::create("object_sqr", null);
      vsequencer = mock_vsequencer::type_id::create("vsequencer", null);

      vsequencer.mock_int_sqr = int_sqr;
      vsequencer.mock_real_sqr = real_sqr;
      vsequencer.mock_string_sqr = string_sqr;
      vsequencer.mock_object_sqr = object_sqr;
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
    
      parser = new("parser");
      step_string = $sformatf("%s a step definition with parameters %d, %f, and %s", "Given", 42, 98.6, "Gherkin");
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
          uvm_sequence_item item;
          mock_int_sequence_item int_item;
          int actual_int;

          int_sqr.get_next_item(item);
          int_sqr.item_done();
          `FAIL_UNLESS($cast(int_item, item))
          actual_int = int_item.get_payload();
          `FAIL_UNLESS_EQUAL(actual_int, 42)
        end
        begin
          uvm_sequence_item item;
          mock_real_sequence_item real_item;
          real actual_real;
          
          real_sqr.get_next_item(item);
          real_sqr.item_done();
          `FAIL_UNLESS($cast(real_item, item))
          actual_real = real_item.get_payload();
          `FAIL_UNLESS(actual_real * actual_real - 98.6 * 98.6 < 1.0e-6)
        end
        begin
          uvm_sequence_item item;
          mock_string_sequence_item string_item;
          string actual_string;
          
          string_sqr.get_next_item(item);
          string_sqr.item_done();
          `FAIL_UNLESS($cast(string_item, item))
          actual_string = string_item.get_payload();
          `FAIL_UNLESS_STR_EQUAL(actual_string, "Gherkin")
        end
      join

    `SVTEST_END



    `SVTEST(Mock_step_definition_sends_itself)
      // =====================================
      string step_string;
      bathtub_pkg::gherkin_step_bundle step_bundle;
      bathtub_pkg::gherkin_parser parser;
      mock_step_def_seq my_step_def_seq;
      bathtub_pkg::step_nurture step_attributes;
    
      parser = new("parser");
      step_string = $sformatf("%s a step definition with parameters %0d, %f, and %s", "Given", 42, 98.6, "Gherkin");
      parser.parse_step_string(step_string, step_bundle);
      my_step_def_seq = mock_step_def_seq::type_id::create("my_step_def_seq");
			step_attributes = bathtub_pkg::step_nurture::type_id::create("step_attributes");
      step_attributes.configure(step_bundle.step, my_step_def_seq);
			my_step_def_seq.set_step_attributes(step_attributes);

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
          `FAIL_UNLESS_STR_EQUAL({actual_step_def.get_step_attributes().get_runtime_keyword(), " ", actual_step_def.get_step_attributes().get_text()},
            $sformatf("%s a step definition with parameters %0d, %f, and %s", "Given", 42, 98.6, "Gherkin"))
        end
      join

    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
