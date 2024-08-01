Feature: This is a feature

    Scenario: A loose scenario outside any rule should not include a rule sequence
        * The sequence path to this step sequence should contain the correct hierarchy without a rule sequence

    Rule: This rule should result in a rule sequence

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

        Scenario Outline: Store values in every pool
            Given I store the value "<value>" in an item called "<name>" in the "<context>" "<type>" pool
            When I read item "<name>" from the "<context>" "<type>" pool
            Then the returned "<type>" value should be "<value>"

            Examples: Integers
                | context  | type    | name | value |
                | scenario | integer | ii   | 123   |
                | rule     | integer | ii   | 234   |
                | feature  | integer | ii   | 345   |
                | test     | integer | ii   | 456   |

            Examples: Strings
                | context  | type   | name | value |
                | scenario | string | ss   | ABC   |
                | rule     | string | ss   | BCD   |
                | feature  | string | ss   | CDE   |
                | test     | string | ss   | DEF   |

    Rule: This other rule should result in a different rule sequence

        Scenario: A scenario inside a rule should include a rule sequence
            * The sequence path to this step sequence should contain the correct hierarchy with a rule sequence

        Scenario Outline: Rule values should be uninitialized, not carried over
            Given I store the value "<value>" in an item called "<name>" in the "<context>" "<type>" pool
            When I read item "<name>" from the "<context>" "<type>" pool
            Then the returned "<type>" value should be "<value>"

            Examples: Integers
                | context  | type    | name | value |
                | rule     | integer | ii   | 0   |

            Examples: Strings
                # Values are empty strings
                | context  | type   | name | value |
                | rule     | string | ss   |    |

        Scenario Outline: Values stored in this scenario should not carry over to the next
            Given I store the value "<value>" in an item called "<name>" in the "<context>" "<type>" pool
            When I read item "<name>" from the "<context>" "<type>" pool
            Then the returned "<type>" value should be "<value>"

            Examples: Integers
                | context  | type    | name | value |
                | scenario | integer | ii   | 99999 |

            Examples: Strings
                # Values are empty strings
                | context  | type   | name | value |
                | scenario | string | ss   | ALPHA |

        Scenario Outline: Scenario values should be uninitialized, not carried over
            When I read item "<name>" from the "<context>" "<type>" pool
            Then the returned "<type>" value should be "<value>"

            Examples: Integers
                | context  | type    | name | value |
                | scenario | integer | ii   | 0   |

            Examples: Strings
                # Values are empty strings
                | context  | type   | name | value |
                | scenario | string | ss   |    |
