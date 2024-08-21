Feature: Step parameters

    Step definitions should be able to extract parameters

    Rule: Integers

        Scenario Outline: Decimal integers
            In this context, format "int" means decimal.

            When a step definition interprets decimal integer <argument> as a <format>
            Then the resulting integer value should be <expected_value>

            Examples: Decimal
                | format | argument | expected_value |
                | int    | 123      | 123            |
                | int    | 0        | 0              |
                | int    | -42      | -42            |
                | int    | _4_5_6_  | 456            |
