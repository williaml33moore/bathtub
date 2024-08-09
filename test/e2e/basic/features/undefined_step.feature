Feature: This is a feature

    Rule: This is a rule

        Scenario: This is a scenario
            # Expect this step to fail and produce a snippet
            * There is no step definition for this step
            Given I store the value "42" in an item called "i" in the "scenario" "integer" pool
            When I read item "i" from the "scenario" "integer" pool
            Then the returned "integer" value should be "42"
