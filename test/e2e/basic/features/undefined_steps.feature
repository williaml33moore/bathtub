Feature: This is a feature

    Rule: This is a rule

        Scenario: This is a scenario
            Given I store the value "42" in an item called "i" in the "scenario" "integer" pool
            When I read item "i" from the "scenario" "integer" pool
            Then the returned "integer" value should be "42"

        Scenario: Expect these undefined steps to fail and produce snippets
            Given an immovable object
            When an irresistable force is applied
            Then hilarity should ensue
