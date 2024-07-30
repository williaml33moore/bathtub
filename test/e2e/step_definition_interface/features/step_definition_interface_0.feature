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
