`include "svunit_defines.svh"
  import bathtub_pkg::gherkin_parser;
  import bathtub_pkg::gherkin_doc_bundle;

module gherkin_parser_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "gherkin_parser_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  gherkin_parser parser;


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

    parser = new("parser");
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

  `SVTEST(Task_parse_feature_lines_should_parse_a_minimal_feature_array)
  // ===================================================================
  string feature[];
  gherkin_doc_bundle actual_doc_bundle;
	string actual_file_name, expected_file_name;
  gherkin_pkg::feature actual_feature;
  gherkin_pkg::scenario actual_scenario;
  gherkin_pkg::step actual_step;

  feature = {
    "Feature: This is a feature",
    "Scenario: This is a scenario",
    "* This is a step"
  };

  parser.parse_feature_lines(feature, actual_doc_bundle);
  `FAIL_UNLESS(actual_doc_bundle)

  actual_file_name = actual_doc_bundle.file_name;
  expected_file_name = "";
  `FAIL_UNLESS_STR_EQUAL(actual_file_name, expected_file_name)
  
  actual_feature = actual_doc_bundle.document.get_as_value().feature;
  `FAIL_UNLESS_STR_EQUAL(actual_feature.get_as_value().keyword, "Feature")
  `FAIL_UNLESS_STR_EQUAL(actual_feature.get_as_value().feature_name, "This is a feature")
  
  `FAIL_UNLESS_EQUAL(actual_feature.get_as_value().scenario_definitions.size(), 1)
  `FAIL_UNLESS($cast(actual_scenario, actual_feature.get_as_value().scenario_definitions[0]))

  `FAIL_UNLESS_STR_EQUAL(actual_scenario.get_as_value().base.keyword, "Scenario")
  `FAIL_UNLESS_STR_EQUAL(actual_scenario.get_as_value().base.scenario_definition_name, "This is a scenario")
  `FAIL_UNLESS_EQUAL(actual_scenario.get_as_value().base.steps.size(), 1)
  
  actual_step = actual_scenario.get_as_value().base.steps[0];
  `FAIL_UNLESS_STR_EQUAL(actual_step.get_as_value().keyword, "*")
  `FAIL_UNLESS_STR_EQUAL(actual_step.get_as_value().text, "This is a step")
	
  `SVTEST_END

  `SVTEST(Task_parse_feature_string_should_parse_a_minimal_feature_string)
  // =====================================================================
  string feature;
  gherkin_doc_bundle actual_doc_bundle;
	string actual_file_name, expected_file_name;
  gherkin_pkg::feature actual_feature;
  gherkin_pkg::scenario actual_scenario;
  gherkin_pkg::step actual_step;

  feature = {
    "Feature: This is a feature\n",
    "Scenario: This is a scenario\n",
    "* This is a step"
  };

  parser.parse_feature_string(feature, actual_doc_bundle);
  `FAIL_UNLESS(actual_doc_bundle)

  actual_file_name = actual_doc_bundle.file_name;
  expected_file_name = "";
  `FAIL_UNLESS_STR_EQUAL(actual_file_name, expected_file_name)
  
  actual_feature = actual_doc_bundle.document.get_as_value().feature;
  `FAIL_UNLESS_STR_EQUAL(actual_feature.get_as_value().keyword, "Feature")
  `FAIL_UNLESS_STR_EQUAL(actual_feature.get_as_value().feature_name, "This is a feature")
  
  `FAIL_UNLESS_EQUAL(actual_feature.get_as_value().scenario_definitions.size(), 1)
  `FAIL_UNLESS($cast(actual_scenario, actual_feature.get_as_value().scenario_definitions[0]))

  `FAIL_UNLESS_STR_EQUAL(actual_scenario.get_as_value().base.keyword, "Scenario")
  `FAIL_UNLESS_STR_EQUAL(actual_scenario.get_as_value().base.scenario_definition_name, "This is a scenario")
  `FAIL_UNLESS_EQUAL(actual_scenario.get_as_value().base.steps.size(), 1)
  
  actual_step = actual_scenario.get_as_value().base.steps[0];
  `FAIL_UNLESS_STR_EQUAL(actual_step.get_as_value().keyword, "*")
  `FAIL_UNLESS_STR_EQUAL(actual_step.get_as_value().text, "This is a step")
	
  `SVTEST_END


  `SVUNIT_TESTS_END

endmodule
