Feature: This is a feature

    Rule: This is a rule

        Scenario: Store an integer in the scenario integer pool
            Given I store the value "42" in an item called "i" in the "scenario" "integer" pool
            When I read item "i" from the "scenario" "integer" pool
            Then the returned "integer" value should be "42"

        Scenario: Store an integer in the test integer pool
            Given I store the value "1001" in an item called "grand" in the "test" "integer" pool
            When I read item "grand" from the "test" "integer" pool
            Then the returned "integer" value should be "1001"

        Scenario: An uninitialized string item should be the empty string
            When I read item "feature" from the "test" "string" pool
            Then the returned "string" value should be ""

        Scenario: Store a string in the test string pool for a subsequent feature file to read
            Given I store the value "step_definition_interface_0.feature" in an item called "feature" in the "test" "string" pool
            When I read item "feature" from the "test" "string" pool
            Then the returned "string" value should be "step_definition_interface_0.feature"