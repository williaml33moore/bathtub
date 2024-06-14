`include "svunit_defines.svh"
  import bathtub_pkg::gherkin_parser;
  import bathtub_pkg::gherkin_doc_bundle;
  import bathtub_pkg::gherkin_step_bundle;

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
    
    actual_feature = actual_doc_bundle.document.feature;
    `FAIL_UNLESS_STR_EQUAL(actual_feature.keyword, "Feature")
    `FAIL_UNLESS_STR_EQUAL(actual_feature.feature_name, "This is a feature")
    
    `FAIL_UNLESS_EQUAL(actual_feature.scenario_definitions.size(), 1)
    `FAIL_UNLESS($cast(actual_scenario, actual_feature.scenario_definitions[0]))

    `FAIL_UNLESS_STR_EQUAL(actual_scenario.keyword, "Scenario")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario.scenario_definition_name, "This is a scenario")
    `FAIL_UNLESS_EQUAL(actual_scenario.steps.size(), 1)
    
    actual_step = actual_scenario.steps[0];
    `FAIL_UNLESS_STR_EQUAL(actual_step.keyword, "*")
    `FAIL_UNLESS_STR_EQUAL(actual_step.text, "This is a step")
	
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
    
    actual_feature = actual_doc_bundle.document.feature;
    `FAIL_UNLESS_STR_EQUAL(actual_feature.keyword, "Feature")
    `FAIL_UNLESS_STR_EQUAL(actual_feature.feature_name, "This is a feature")
    
    `FAIL_UNLESS_EQUAL(actual_feature.scenario_definitions.size(), 1)
    `FAIL_UNLESS($cast(actual_scenario, actual_feature.scenario_definitions[0]))

    `FAIL_UNLESS_STR_EQUAL(actual_scenario.keyword, "Scenario")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario.scenario_definition_name, "This is a scenario")
    `FAIL_UNLESS_EQUAL(actual_scenario.steps.size(), 1)
    
    actual_step = actual_scenario.steps[0];
    `FAIL_UNLESS_STR_EQUAL(actual_step.keyword, "*")
    `FAIL_UNLESS_STR_EQUAL(actual_step.text, "This is a step")
	
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
    
    actual_feature = actual_doc_bundle.document.feature;
    `FAIL_UNLESS_STR_EQUAL(actual_feature.keyword, "Feature")
    `FAIL_UNLESS_STR_EQUAL(actual_feature.feature_name, "This is a feature")
    
    `FAIL_UNLESS_EQUAL(actual_feature.scenario_definitions.size(), 1)
    `FAIL_UNLESS($cast(actual_scenario, actual_feature.scenario_definitions[0]))

    `FAIL_UNLESS_STR_EQUAL(actual_scenario.keyword, "Scenario")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario.scenario_definition_name, "This is a scenario")
    `FAIL_UNLESS_EQUAL(actual_scenario.steps.size(), 1)
    
    actual_step = actual_scenario.steps[0];
    `FAIL_UNLESS_STR_EQUAL(actual_step.keyword, "*")
    `FAIL_UNLESS_STR_EQUAL(actual_step.text, "This is a step")

    `FAIL_UNLESS($cast(actual_data_table, actual_step.argument))
    `FAIL_UNLESS_EQUAL(actual_data_table.rows.size(), 2)
    for (int i = 0; i < actual_data_table.rows.size(); i++) begin
      `FAIL_UNLESS_EQUAL(actual_data_table.rows[i].cells.size(), 3)
    end

    `FAIL_UNLESS_STR_EQUAL(actual_data_table.rows[0].cells[0].value, "Alpha")
    `FAIL_UNLESS_STR_EQUAL(actual_data_table.rows[0].cells[1].value, "Bravo")
    `FAIL_UNLESS_STR_EQUAL(actual_data_table.rows[0].cells[2].value, "Charlie")
    `FAIL_UNLESS_STR_EQUAL(actual_data_table.rows[1].cells[0].value, "100")
    `FAIL_UNLESS_STR_EQUAL(actual_data_table.rows[1].cells[1].value, "200")
    `FAIL_UNLESS_STR_EQUAL(actual_data_table.rows[1].cells[2].value, "300")
	
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
    actual_feature = actual_doc_bundle.document.feature;
    `FAIL_UNLESS_STR_EQUAL(actual_feature.keyword, "Feature")
    `FAIL_UNLESS_STR_EQUAL(actual_feature.feature_name, "This is a feature")
    
    `FAIL_UNLESS_EQUAL(actual_feature.scenario_definitions.size(), 1)
    `FAIL_UNLESS($cast(actual_scenario, actual_feature.scenario_definitions[0]))

    `FAIL_UNLESS_STR_EQUAL(actual_scenario.keyword, "Scenario")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario.scenario_definition_name, "This is a scenario")
    `FAIL_UNLESS_EQUAL(actual_scenario.steps.size(), 1)
    
    actual_step = actual_scenario.steps[0];
    `FAIL_UNLESS_STR_EQUAL(actual_step.keyword, "*")
    `FAIL_UNLESS_STR_EQUAL(actual_step.text, "This is a step")

    `FAIL_UNLESS($cast(actual_doc_string, actual_step.argument))
    `FAIL_UNLESS(actual_doc_string.content.len() > 0)
    `FAIL_UNLESS_STR_EQUAL(actual_doc_string.content_type, "")
    `FAIL_UNLESS_STR_EQUAL(actual_doc_string.content, "Alpha\nBravo\nCharlie\n")
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
    actual_feature = actual_doc_bundle.document.feature;
    void'($cast(actual_scenario, actual_feature.scenario_definitions[0]));
    actual_step = actual_scenario.steps[0];
    void'($cast(actual_doc_string, actual_step.argument));
    `FAIL_UNLESS(actual_doc_string.content.len() > 0)
    `FAIL_UNLESS_STR_EQUAL(actual_doc_string.content_type, "")
    `FAIL_UNLESS_STR_EQUAL(actual_doc_string.content, "Alpha   \n   Bravo\n   \n\nCharlie\n")
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
    actual_feature = actual_doc_bundle.document.feature;
    `FAIL_UNLESS_EQUAL(actual_feature.tags.size(), 1)
    actual_tag = actual_feature.tags[0];
    `FAIL_UNLESS_STR_EQUAL(actual_tag.tag_name, "@alpha")
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
    actual_feature = actual_doc_bundle.document.feature;
    `FAIL_UNLESS_EQUAL(actual_feature.tags.size(), 4)
    `FAIL_UNLESS_STR_EQUAL(actual_feature.tags[0].tag_name, "@alpha")
    `FAIL_UNLESS_STR_EQUAL(actual_feature.tags[1].tag_name, "@bravo")
    `FAIL_UNLESS_STR_EQUAL(actual_feature.tags[2].tag_name, "@charlie")
    `FAIL_UNLESS_STR_EQUAL(actual_feature.tags[3].tag_name, "@delta")
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
    actual_feature = actual_doc_bundle.document.feature;
    void'($cast(actual_scenario, actual_feature.scenario_definitions[0]));
    `FAIL_UNLESS_EQUAL(actual_scenario.tags.size(), 1)
    
    actual_tag = actual_scenario.tags[0];
    `FAIL_UNLESS_STR_EQUAL(actual_tag.tag_name, "@alpha")
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
    actual_feature = actual_doc_bundle.document.feature;
    void'($cast(actual_scenario, actual_feature.scenario_definitions[0]));
    `FAIL_UNLESS_EQUAL(actual_scenario.tags.size(), 4)
    `FAIL_UNLESS_STR_EQUAL(actual_scenario.tags[0].tag_name, "@alpha")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario.tags[1].tag_name, "@bravo")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario.tags[2].tag_name, "@charlie")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario.tags[3].tag_name, "@delta")
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
    actual_feature = actual_doc_bundle.document.feature;
    void'($cast(actual_scenario_outline, actual_feature.scenario_definitions[0]));
    `FAIL_UNLESS_EQUAL(actual_scenario_outline.tags.size(), 1)
    
    actual_tag = actual_scenario_outline.tags[0];
    `FAIL_UNLESS_STR_EQUAL(actual_tag.tag_name, "@alpha")
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
    actual_feature = actual_doc_bundle.document.feature;
    void'($cast(actual_scenario_outline, actual_feature.scenario_definitions[0]));
    `FAIL_UNLESS_EQUAL(actual_scenario_outline.tags.size(), 4)
    `FAIL_UNLESS_STR_EQUAL(actual_scenario_outline.tags[0].tag_name, "@alpha")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario_outline.tags[1].tag_name, "@bravo")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario_outline.tags[2].tag_name, "@charlie")
    `FAIL_UNLESS_STR_EQUAL(actual_scenario_outline.tags[3].tag_name, "@delta")
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
    
    actual_feature = actual_doc_bundle.document.feature;
    void'($cast(actual_scenario_outline, actual_feature.scenario_definitions[0]));
    `FAIL_UNLESS_EQUAL(actual_scenario_outline.examples.size(), 1)

    actual_examples = actual_scenario_outline.examples[0];
    `FAIL_UNLESS_EQUAL(actual_examples.tags.size(), 1)
    
    actual_tag = actual_examples.tags[0];
    `FAIL_UNLESS_STR_EQUAL(actual_tag.tag_name, "@alpha")
  `SVTEST_END

  `SVTEST(Parse_multiple_tags_on_a_scenario_outline_examples_block)
    // ============================================================
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
    actual_feature = actual_doc_bundle.document.feature;
    void'($cast(actual_scenario_outline, actual_feature.scenario_definitions[0]));
    actual_examples = actual_scenario_outline.examples[0];    
    `FAIL_UNLESS_EQUAL(actual_examples.tags.size(), 4)
    `FAIL_UNLESS_STR_EQUAL(actual_examples.tags[0].tag_name, "@alpha")
    `FAIL_UNLESS_STR_EQUAL(actual_examples.tags[1].tag_name, "@bravo")
    `FAIL_UNLESS_STR_EQUAL(actual_examples.tags[2].tag_name, "@charlie")
    `FAIL_UNLESS_STR_EQUAL(actual_examples.tags[3].tag_name, "@delta")
  `SVTEST_END

  `SVTEST(Test_that_parser_can_handle_comments_anywhere_in_the_document)
    // =================================================================
    string feature[];
    gherkin_doc_bundle actual_doc_bundle;
    gherkin_pkg::feature actual_feature;
    string comment;

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
      "  @tag_three",
      "  @tag_four",
      "  Scenario: This is a scenario",
      "    This is a description.",
      "    This is more description.",
      "    Given some initial state",
      "    When somebody does something",
      "    Then the system should be in this final state",
      "",
      "  @tag_five",
      "  @tag_six",
      "  Scenario Outline: This is a scenario outline",
      "    This is a description",
      "    Given some <initial> state",
      "    When somebody does <something>",
      "    Then the system should be in this <final> state",
      "",
      "    @tag_seven",
      "    @tag_eight",
      "    Examples:",
      "      This is a description.",
      "      This is more description.",
      "      | initial   | something  | final    |",
      "      | starting  | stuff      | finished |",
      "      | beginning | procedures | ending   |",
      "",
      "    @tag_nine",
      "    @tag_ten",
      "    Examples:",
      "      This is a description.",
      "      This is more description.",
      "      | initial   | something  | final    |",
      "      | neutral   | activities | happy    |",
      "      | beginning | procedures | ending   |",
      "",
      "  @tag_eleven",
      "  @tag_twelve",
      "  Scenario: This is another scenario",
      "    This is a description.",
      "    This is more description.",
      "    Given some initial state",
      "    When somebody does something with the following docstring",
      "    ```",
      "    This is the aforementioned docstring.",
      "    This is more docstring.",
      "    ```",
      "    Then the system should be in this final docstring state",
      "",
      "  @tag_thirteen",
      "  @tag_fourteen",
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

    comment = feature[0];

    foreach (feature[i]) begin : loop
      // Ripple the comment through every line in the document.
      if (i > 0) begin
        feature[i - 1] = feature[i];
      end
      feature[i] = comment;

      // $info($sformatf("DEBUG %0d", i));
      // foreach (feature[j]) begin
      //   $display("%2d %s", j, feature[j]);
      // end

      parser.parse_feature_lines(feature, actual_doc_bundle);
      actual_feature = actual_doc_bundle.document.feature;
      `FAIL_UNLESS(actual_feature)
    end
  `SVTEST_END

  `SVTEST(Parse_a_simple_step_string)
    // ==============================
    string step;
    gherkin_step_bundle actual_step_bndl;
    string actual_file_name, expected_file_name;
    gherkin_pkg::step actual_step;

    step = "Given a simple step string";
    parser.parse_step_string(step, actual_step_bndl);
    `FAIL_UNLESS(actual_step_bndl)

    actual_file_name = actual_step_bndl.file_name;
    expected_file_name = "";
    `FAIL_UNLESS_STR_EQUAL(actual_file_name, expected_file_name)

    actual_step = actual_step_bndl.step;
    `FAIL_UNLESS_STR_EQUAL(actual_step.keyword, "Given")
    `FAIL_UNLESS_STR_EQUAL(actual_step.text, "a simple step string")
    `FAIL_UNLESS_EQUAL(actual_step.argument, null)
  `SVTEST_END

  `SVTEST(Parse_a_step_string_with_a_data_table)
    // =========================================
    string step;
    gherkin_step_bundle actual_step_bndl;
    gherkin_pkg::step actual_step;
    gherkin_pkg::data_table actual_data_table;
    gherkin_pkg::table_cell actual_cell;

    step = {
      "When a step string has a data table\n",
      "# And a comment\n",
      "| A1 | B1 | C1 |\n",
      "| A2 | B2 | C2 |\n"
    };

    parser.parse_step_string(step, actual_step_bndl);
    
    actual_step = actual_step_bndl.step;
    `FAIL_UNLESS($cast(actual_data_table, actual_step.argument))
    `FAIL_UNLESS_EQUAL(actual_data_table.rows.size(), 2)
    `FAIL_UNLESS_EQUAL(actual_data_table.rows[1].cells.size(), 3)
    
    actual_cell = actual_data_table.rows[1].cells[2];
    `FAIL_UNLESS_STR_EQUAL(actual_cell.value, "C2")
  `SVTEST_END

  `SVTEST(Parse_a_step_string_with_a_doc_string)
    // =========================================
    string step;
    gherkin_step_bundle actual_step_bndl;
    gherkin_pkg::step actual_step;
    gherkin_pkg::doc_string actual_doc_string;

    step = {
      "Then the step string doc string should follow\n",
      "\"\"\"markdown\n",
      "This is a _doc string_\n",
      "\"\"\"\n",
      "# This comment marks the end of the step\n"
    };

    parser.parse_step_string(step, actual_step_bndl);
    
    actual_step = actual_step_bndl.step;
    `FAIL_UNLESS($cast(actual_doc_string, actual_step.argument))
    `FAIL_UNLESS_STR_EQUAL(actual_doc_string.content_type, "markdown")
    `FAIL_UNLESS_STR_EQUAL(actual_doc_string.content, "This is a _doc string_\n")
  `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
