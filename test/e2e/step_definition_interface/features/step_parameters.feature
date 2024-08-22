Feature: Step parameters

    Step definitions should be able to extract parameters

    Rule: Integers

        Scenario Outline: Decimal integers
            When a step definition interprets decimal integer <argument> as a <type>
            Then the resulting integer value should be <expected_value>

            Examples: Decimal
                | type | argument | expected_value |
                | int  | 123      | 123            |
                | int  | 0        | 0              |
                | int  | -42      | -42            |
                | int  | _4_5_6_  | 456            |

        Scenario Outline: Hexaecimal integers prefixed by "32'h"
            The "32'h" prefix is not part of the argument.

            When a step definition interprets hexadecimal integer 32'h<argument> as a <type>
            Then the resulting integer value should be <expected_value>

            Examples: Hexadecimal
                | type | argument | expected_value |
                | int  | abc      | 2748           |
                | int  | 0        | 0              |
                | int  | _1_2_3_4 | 4660           |

        Scenario Outline: Hexadecimal integers prefixed by "0x"
            The "0x" prefix is not part of the argument.

            When a step definition interprets hexadecimal integer 0x<argument> as a <type>
            Then the resulting integer value should be <expected_value>

            Examples: Hexadecimal
                | type | argument | expected_value |
                | int  | cba      | 3258           |
                | int  | 0        | 0              |
                | int  | _4_3_2_1 | 17185          |

        Scenario Outline: Octal integers prefixed by "32'o"
            The "32'o" prefix is not part of the argument.

            When a step definition interprets octal integer 32'o<argument> as a <type>
            Then the resulting integer value should be <expected_value>

            Examples: Octal
                | type | argument | expected_value |
                | int  | 4412     | 2314           |
                | int  | 4472     | 2362           |
                | int  | 3707     | 1991           |
                | int  | 5323     | 2771           |
                | int  | 1317     | 719            |
