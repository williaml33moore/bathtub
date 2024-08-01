Feature: This is another feature

    Rule: This is a rule

        Scenario: Store an integer in the scenario integer pool
            Given I store the value "24" in an item called "i" in the "scenario" "integer" pool
            When I read item "i" from the "scenario" "integer" pool
            Then the returned "integer" value should be "24"

        Scenario: Store an integer in the test integer pool
            Given I store the value "2002" in an item called "grand" in the "test" "integer" pool
            When I read item "grand" from the "test" "integer" pool
            Then the returned "integer" value should be "2002"

        Scenario: A previous feature should have left a value in the test string pool
            When I read item "feature" from the "test" "string" pool
            Then the returned "string" value should be "step_definition_interface_0.feature"

        Scenario: Store a string in the test string pool for a subsequent feature file to read
            Given I store the value "step_definition_interface_1.feature" in an item called "feature" in the "test" "string" pool
            When I read item "feature" from the "test" "string" pool
            Then the returned "string" value should be "step_definition_interface_1.feature"

        Scenario Outline: Store values in every pool
            Given I store the value "<value>" in an item called "<name>" in the "<context>" "<type>" pool
            When I read item "<name>" from the "<context>" "<type>" pool
            Then the returned "<type>" value should be "<value>"

            Examples: Integers
                | context  | type    | name | value |
                | scenario | integer | ii   | 321   |
                | rule     | integer | ii   | 432   |
                | feature  | integer | ii   | 543   |
                | test     | integer | ii   | 654   |

            Examples: Strings
                | context  | type   | name | value |
                | scenario | string | ss   | CBA   |
                | rule     | string | ss   | DCB   |
                | feature  | string | ss   | EDC   |
                | test     | string | ss   | FED   |
