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

  `SVTEST(Parse_a_data_table)
    // ========================
    string feature[];
    gherkin_doc_bundle actual_doc_bundle;
    gherkin_pkg::feature actual_feature;
    gherkin_pkg::scenario actual_scenario;
    gherkin_pkg::step actual_step;
    gherkin_pkg::data_table actual_data_table;

    feature = {
      "Feature: This is a feature",
      "Scenario: This is a scenario",
      "* This is a step",
      "| Alpha | Bravo | Charlie |",
      "| 100   | 200   | 300     |"
    };

    parser.parse_feature_lines(feature, actual_doc_bundle);
    `FAIL_UNLESS(actual_doc_bundle)
    
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

    `FAIL_UNLESS($cast(actual_data_table, actual_step.get_as_value().argument))
    `FAIL_UNLESS_EQUAL(actual_data_table.get_as_value().rows.size(), 2)
    for (int i = 0; i < actual_data_table.get_as_value().rows.size(); i++) begin
      `FAIL_UNLESS_EQUAL(actual_data_table.get_as_value().rows[i].get_as_value().cells.size(), 3)
    end

    `FAIL_UNLESS_STR_EQUAL(actual_data_table.get_as_value().rows[0].get_as_value().cells[0].get_as_value().value, "Alpha")
    `FAIL_UNLESS_STR_EQUAL(actual_data_table.get_as_value().rows[0].get_as_value().cells[1].get_as_value().value, "Bravo")
    `FAIL_UNLESS_STR_EQUAL(actual_data_table.get_as_value().rows[0].get_as_value().cells[2].get_as_value().value, "Charlie")
    `FAIL_UNLESS_STR_EQUAL(actual_data_table.get_as_value().rows[1].get_as_value().cells[0].get_as_value().value, "100")
    `FAIL_UNLESS_STR_EQUAL(actual_data_table.get_as_value().rows[1].get_as_value().cells[1].get_as_value().value, "200")
    `FAIL_UNLESS_STR_EQUAL(actual_data_table.get_as_value().rows[1].get_as_value().cells[2].get_as_value().value, "300")
	
  `SVTEST_END

  `SVTEST(Parse_a_doc_string)
    // ========================
    string feature;
    gherkin_doc_bundle actual_doc_bundle;
    gherkin_pkg::feature actual_feature;
    gherkin_pkg::scenario actual_scenario;
    gherkin_pkg::step actual_step;
    gherkin_pkg::doc_string actual_doc_string;
    localparam string triple_quotes = "\"\"\"\n";

    feature = {
      "Feature: This is a feature\n",
      "Scenario: This is a scenario\n",
      "* This is a step\n",
      triple_quotes,
      "Alpha\n",
      "Bravo\n",
      "Charlie\n",
      triple_quotes
    };

    parser.parse_feature_string(feature, actual_doc_bundle);
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

    `FAIL_UNLESS($cast(actual_doc_string, actual_step.get_as_value().argument))
    `FAIL_UNLESS(actual_doc_string.get_as_value().content.len() > 0)
    `FAIL_UNLESS_STR_EQUAL(actual_doc_string.get_as_value().content_type, "")
    `FAIL_UNLESS_STR_EQUAL(actual_doc_string.get_as_value().content, "Alpha\nBravo\nCharlie\n")
  `SVTEST_END

  `SVTEST(Parse_a_doc_string_that_contains_white_space)
    // ========================
    string feature;
    gherkin_doc_bundle actual_doc_bundle;
    gherkin_pkg::feature actual_feature;
    gherkin_pkg::scenario actual_scenario;
    gherkin_pkg::step actual_step;
    gherkin_pkg::doc_string actual_doc_string;
    localparam string triple_quotes = "\"\"\"\n";

    feature = {
      "Feature: This is a feature\n",
      "Scenario: This is a scenario\n",
      "* This is a step\n",
      triple_quotes,
      "Alpha   \n",
      "   Bravo\n",
      "   \n",
      "\n",
      "Charlie\n",
      triple_quotes
    };

    parser.parse_feature_string(feature, actual_doc_bundle);
    actual_feature = actual_doc_bundle.document.get_as_value().feature;
    void'($cast(actual_scenario, actual_feature.get_as_value().scenario_definitions[0]));
    actual_step = actual_scenario.get_as_value().base.steps[0];
    void'($cast(actual_doc_string, actual_step.get_as_value().argument));
    `FAIL_UNLESS(actual_doc_string.get_as_value().content.len() > 0)
    `FAIL_UNLESS_STR_EQUAL(actual_doc_string.get_as_value().content_type, "")
    `FAIL_UNLESS_STR_EQUAL(actual_doc_string.get_as_value().content, "Alpha   \n   Bravo\n   \n\nCharlie\n")
  `SVTEST_END

  `SVTEST(Parse_a_tag_on_a_feature)
    // ============================
    string feature;
    gherkin_doc_bundle actual_doc_bundle;
    gherkin_pkg::feature actual_feature;
    gherkin_pkg::tag actual_tag;
  
    feature = {
      "@alpha\n",
      "Feature: This is a feature\n",
      "Scenario: This is a scenario\n",
      "* This is a step\n"
    };

    parser.parse_feature_string(feature, actual_doc_bundle);
    actual_feature = actual_doc_bundle.document.get_as_value().feature;
    `FAIL_UNLESS_EQUAL(actual_feature.get_as_value().tags.size(), 1)
    actual_tag = actual_feature.get_as_value().tags[0];
    `FAIL_UNLESS_STR_EQUAL(actual_tag.get_as_value().tag_name, "@alpha")
  `SVTEST_END

  `SVTEST(Parse_multiple_tags_on_a_feature)
    // ============================
    string feature;
    gherkin_doc_bundle actual_doc_bundle;
    gherkin_pkg::feature actual_feature;
  
    feature = {
      "@alpha @bravo   @charlie\n",
      "   @delta\n",
      "Feature: This is a feature\n",
      "Scenario: This is a scenario\n",
      "* This is a step\n"
    };

    parser.parse_feature_string(feature, actual_doc_bundle);
    actual_feature = actual_doc_bundle.document.get_as_value().feature;
    `FAIL_UNLESS_EQUAL(actual_feature.get_as_value().tags.size(), 4)
    `FAIL_UNLESS_STR_EQUAL(actual_feature.get_as_value().tags[0].get_as_value().tag_name, "@alpha")
    `FAIL_UNLESS_STR_EQUAL(actual_feature.get_as_value().tags[1].get_as_value().tag_name, "@bravo")
    `FAIL_UNLESS_STR_EQUAL(actual_feature.get_as_value().tags[2].get_as_value().tag_name, "@charlie")
    `FAIL_UNLESS_STR_EQUAL(actual_feature.get_as_value().tags[3].get_as_value().tag_name, "@delta")
  `SVTEST_END

  `SVTEST(Parse_a_tag_on_a_scenario)
    // =============================
    string feature;
    gherkin_doc_bundle actual_doc_bundle;
    gherkin_pkg::feature actual_feature;
    gherkin_pkg::scenario actual_scenario;
    gherkin_pkg::tag actual_tag;
  
    feature = {
      "Feature: This is a feature\n",
      "@alpha\n",
      "Scenario: This is a scenario\n",
      "* This is a step\n"
    };

    parser.parse_feature_string(feature, actual_doc_bundle);
    actual_feature = actual_doc_bundle.document.get_as_value().feature;
    void'($cast(actual_scenario, actual_feature.get_as_value().scenario_definitions[0]));
    `FAIL_UNLESS_EQUAL(actual_scenario.get_as_value().tags.size(), 1)
    
    actual_tag = actual_scenario.get_as_value().tags[0];
    `FAIL_UNLESS_STR_EQUAL(actual_tag.get_as_value().tag_name, "@alpha")
  `SVTEST_END

  `SVTEST(Parse_multiple_tags_on_a_scenario)
    // =============================
    string feature;
    gherkin_doc_bundle actual_doc_bundle;
    gherkin_pkg::feature actual_feature;
    gherkin_pkg::scenario actual_scenario;
  
    feature = {
      "Feature: This is a feature\n",
      "@alpha @bravo   @charlie\n",
      "   @delta\n",
      "Scenario: This is a scenario\n",
      "* This is a step\n"
    };

    parser.parse_feature_string(feature, actual_doc_bundle);
    actual_feature = actual_doc_bundle.document.get_as_value().feature;
    void'($cast(actual_scenario, actual_feature.get_as_value().scenario_definitions[0]));
    `FAIL_UNLESS_EQUAL(actual_scenario.get_as_value().tags.size(), 4)
    `FAIL_UNLESS_STR_EQUAL(actual_scenario.get_as_value().tags[0].get_as_value().tag_name, "@alpha")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario.get_as_value().tags[1].get_as_value().tag_name, "@bravo")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario.get_as_value().tags[2].get_as_value().tag_name, "@charlie")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario.get_as_value().tags[3].get_as_value().tag_name, "@delta")
  `SVTEST_END

  `SVTEST(Parse_a_tag_on_a_scenario_outline)
    // =============================
    string feature;
    gherkin_doc_bundle actual_doc_bundle;
    gherkin_pkg::feature actual_feature;
    gherkin_pkg::scenario_outline actual_scenario_outline;
    gherkin_pkg::tag actual_tag;
  
    feature = {
      "Feature: This is a feature\n",
      "@alpha\n",
      "Scenario Outline: This is a scenario outline\n",
      "* This is a step\n"
    };

    parser.parse_feature_string(feature, actual_doc_bundle);
    actual_feature = actual_doc_bundle.document.get_as_value().feature;
    void'($cast(actual_scenario_outline, actual_feature.get_as_value().scenario_definitions[0]));
    `FAIL_UNLESS_EQUAL(actual_scenario_outline.get_as_value().tags.size(), 1)
    
    actual_tag = actual_scenario_outline.get_as_value().tags[0];
    `FAIL_UNLESS_STR_EQUAL(actual_tag.get_as_value().tag_name, "@alpha")
  `SVTEST_END

  `SVTEST(Parse_multiple_tags_on_a_scenario_outline)
    // =============================
    string feature;
    gherkin_doc_bundle actual_doc_bundle;
    gherkin_pkg::feature actual_feature;
    gherkin_pkg::scenario_outline actual_scenario_outline;
  
    feature = {
      "Feature: This is a feature\n",
      "@alpha @bravo   @charlie\n",
      "   @delta\n",
      "Scenario Outline: This is a scenario outline\n",
      "* This is a step\n"
    };

    parser.parse_feature_string(feature, actual_doc_bundle);
    actual_feature = actual_doc_bundle.document.get_as_value().feature;
    void'($cast(actual_scenario_outline, actual_feature.get_as_value().scenario_definitions[0]));
    `FAIL_UNLESS_EQUAL(actual_scenario_outline.get_as_value().tags.size(), 4)
    `FAIL_UNLESS_STR_EQUAL(actual_scenario_outline.get_as_value().tags[0].get_as_value().tag_name, "@alpha")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario_outline.get_as_value().tags[1].get_as_value().tag_name, "@bravo")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario_outline.get_as_value().tags[2].get_as_value().tag_name, "@charlie")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario_outline.get_as_value().tags[3].get_as_value().tag_name, "@delta")
  `SVTEST_END

  `SVTEST(Parse_a_tag_on_a_scenario_outline_examples_block)
    // ==============================================
    string feature;
    gherkin_doc_bundle actual_doc_bundle;
    gherkin_pkg::feature actual_feature;
    gherkin_pkg::scenario_outline actual_scenario_outline;
    gherkin_pkg::examples actual_examples;
    gherkin_pkg::tag actual_tag;
  
    feature = {
      "Feature: This is a feature\n",
      "Scenario Outline: This is a scenario outline\n",
      "* This is a <placeholder>\n",
      "@alpha\n",
      "Examples:\n",
      "| placeholder |\n"
    };

    parser.parse_feature_string(feature, actual_doc_bundle);
    `FAIL_UNLESS(actual_doc_bundle)
    
    actual_feature = actual_doc_bundle.document.get_as_value().feature;
    void'($cast(actual_scenario_outline, actual_feature.get_as_value().scenario_definitions[0]));
    `FAIL_UNLESS_EQUAL(actual_scenario_outline.get_as_value().examples.size(), 1)

    actual_examples = actual_scenario_outline.get_as_value().examples[0];
    `FAIL_UNLESS_EQUAL(actual_examples.get_as_value().tags.size(), 1)
    
    actual_tag = actual_examples.get_as_value().tags[0];
    `FAIL_UNLESS_STR_EQUAL(actual_tag.get_as_value().tag_name, "@alpha")
  `SVTEST_END

  `SVTEST(Parse_multiple_tags_on_a_scenario_outline_examples_block)
  // ==============================================================
    string feature;
    gherkin_doc_bundle actual_doc_bundle;
    gherkin_pkg::feature actual_feature;
    gherkin_pkg::scenario_outline actual_scenario_outline;
    gherkin_pkg::examples actual_examples;
  
    feature = {
      "Feature: This is a feature\n",
      "Scenario Outline: This is a scenario outline\n",
      "* This is a <placeholder>\n",
      "@alpha @bravo   @charlie\n",
      "   @delta\n",
      "Examples:\n",
      "| placeholder |\n"
    };

    parser.parse_feature_string(feature, actual_doc_bundle);
    actual_feature = actual_doc_bundle.document.get_as_value().feature;
    void'($cast(actual_scenario_outline, actual_feature.get_as_value().scenario_definitions[0]));
    actual_examples = actual_scenario_outline.get_as_value().examples[0];    
    `FAIL_UNLESS_EQUAL(actual_examples.get_as_value().tags.size(), 4)
    `FAIL_UNLESS_STR_EQUAL(actual_examples.get_as_value().tags[0].get_as_value().tag_name, "@alpha")
    `FAIL_UNLESS_STR_EQUAL(actual_examples.get_as_value().tags[1].get_as_value().tag_name, "@bravo")
    `FAIL_UNLESS_STR_EQUAL(actual_examples.get_as_value().tags[2].get_as_value().tag_name, "@charlie")
    `FAIL_UNLESS_STR_EQUAL(actual_examples.get_as_value().tags[3].get_as_value().tag_name, "@delta")
  `SVTEST_END

  `SVTEST(Test_that_parser_can_handle_comments_anywhere_in_the_document)
  // ===================================================================
    string feature[];
    gherkin_doc_bundle actual_doc_bundle;
    gherkin_pkg::feature actual_feature;

    feature = '{
      "# This is a comment",
      "",
      "@tag_one",
      "@tag_two",
      "Feature: This is a feature",
      "This is a description.",
      "This is more description",
      "",
      "  Background: This is background",
      "    This is a description.",
      "    This is more description.",
      "    Given some initialization",
      "    And some setup",
      "    But no errors",
      "",
      "  @tag_one",
      "  @tag_two",
      "  Scenario: This is a scenario",
      "    This is a description.",
      "    This is more description.",
      "    Given some initial state",
      "    When somebody does something",
      "    Then the system should be in this final state",
      "",
      "  @tag_one",
      "  @tag_two",
      "  Scenario Outline: This is a scenario outline",
      "    This is a description",
      "    Given some <initial> state",
      "    When somebody does <something>",
      "    Then the system should be in this <final> state",
      "",
      "    @tag_one",
      "    @tag_two",
      "    Examples:",
      "      This is a description.",
      "      This is more description.",
      "      | initial   | something  | final    |",
      "      | starting  | stuff      | finished |",
      "      | beginning | procedures | ending   |",
      "",
      "    @tag_one",
      "    @tag_two",
      "    Examples:",
      "      This is a description.",
      "      This is more description.",
      "      | initial   | something  | final    |",
      "      | neutral   | activities | happy    |",
      "      | beginning | procedures | ending   |",
      "",
      "  Scenario: This is another scenario",
      "    This is a description.",
      "    This is more description.",
      "    Given some initial state",
      "    When somebody does something with the following docstring",
      "    ```",
      "    This is the aforementioned docstring.",
      "    This is more docstring.",
      "    ```",
      "    Then the system should be in this final docstringstate",
      "",
      "  Scenario: This is yet another scenario",
      "    This is a description.",
      "    This is more description.",
      "    Given some initial state",
      "    When somebody does something with the following data table",
      "    | A1 | B1 | C1 |",
      "    | A2 | B2 | C2 |",
      "    | A3 | B3 | C3 |",
      "    Then the system should be in this final data table state"
    };

    parser.parse_feature_lines(feature, actual_doc_bundle);
    actual_feature = actual_doc_bundle.document.get_as_value().feature;
    `FAIL_UNLESS(actual_feature)
  `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
