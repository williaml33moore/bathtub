Feature: Step parameters

            Step definitions have step expression strings, which are parameterized regular expressions that indicate which feature file step strings the step definition will match.
            The step expression strings are given inside the step definition with macros. E.g.:

            ```sv
            class receive_decimal_argument extends receive_integer_argument;
            `When("a step definition interprets decimal integer %d as a %s")
            ```

            In this example, the macro `` `When()`` defines an expression string--"a step definition interprets decimal integer %d as a %s"--which has two parameters: a decimal integer ("%d") and a string ("%s").
            In this context a "%s" string is a sequence of non-whitespace characters, i.e., a word or token.

            Bathtub supports several integer format specifiers in an expression string:

            | Format Specifier | Description                                  |
            | ---------------- | -------------------------------------------- |
            | %b               | Matches a binary number.                     |
            | %o               | Matches an octal number.                     |
            | %d               | Matches an optionally signed decimal number. |
            | %h, %x           | Matches a hexadecimal number.                |

    The format specifiers tell Bathtub how to interpret the argument.
    Bathtub treats the argument as a binary, octal, decimal, or hexadecimal integer, and converts the argument into an integer value.
    Bathtub only converts the actual digits of the number, not any leading prefixes like the "8'b" in "8'b1100_10010" or the "0x" in "0xfeed_bead".
    In fact, those prefixes will cause the expression string not to match.
    The proper way to include a prefix in the step definition expression string is before the format specifier:
    > `When("a step definition interprets hexadecimal integer 0x%x as a %s")

    The examples in this feature file illustrate how integers with different bases can be passed to step definitions.
    Note that the _When_ steps here explicitly use format names and sometimes prefixes to distinguish among the different types:

    > When a step definition interprets decimal integer <argument> as a <type>
    > When a step definition interprets hexadecimal integer 0x<argument> as a <type>
    > When a step definition interprets binary integer 32'b<argument> as a <type>

    Rule: Step definitions can receive integer arguments in a variety of formats.

        Scenario Outline: Decimal integers
            When a step definition interprets decimal integer <argument> as a <type>
            Then the resulting integer value should be <expected_value>

            Examples: Decimal
                | type | argument | expected_value | notes           |
                | int  | 123      | 123            |                 |
                | int  | 0        | 0              |                 |
                | int  | -42      | -42            | Negative number |
                | int  | _4_5_6_  | 456            | Underscores     |

        Scenario Outline: Hexadecimal integers prefixed by "32'h"
            The "32'h" prefix is not part of the argument.

            When a step definition interprets hexadecimal integer 32'h<argument> as a <type>
            Then the resulting integer value should be <expected_value>

            Examples: Hexadecimal
                | type | argument | expected_value | notes       |
                | int  | abc      | 2748           |             |
                | int  | 0        | 0              |             |
                | int  | _1_2_3_4 | 4660           | Underscores |

        Scenario Outline: Hexadecimal integers prefixed by "0x"
            The "0x" prefix is not part of the argument.

            When a step definition interprets hexadecimal integer 0x<argument> as a <type>
            Then the resulting integer value should be <expected_value>

            Examples: Hexadecimal
                | type | argument | expected_value | notes       |
                | int  | cba      | 3258           |             |
                | int  | 0        | 0              |             |
                | int  | _4_3_2_1 | 17185          | Underscores |

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

        Scenario Outline: Octal integers prefixed by "0"
            SystemVerilog should simply ignore the leading 0.

            When a step definition interprets octal integer <argument> as a <type>
            Then the resulting integer value should be <expected_value>

            Examples: Octal
                | type | argument | expected_value |
                | int  | 04412    | 2314           |
                | int  | 04472    | 2362           |
                | int  | 037_07   | 1991           |
                | int  | 05323    | 2771           |
                | int  | 01317    | 719            |

        Scenario Outline: Binary integers prefixed by "0b"
            The "0b" prefix is not part of the argument.

            When a step definition interprets binary integer 0b<argument> as a <type>
            Then the resulting integer value should be <expected_value>

            Examples: Octal
                | type | argument  | expected_value |
                | int  | 10011000  | 152            |
                | int  | 01101101  | 109            |
                | int  | 1110_0101 | 229            |
                | int  | 00101011  | 43             |
                | int  | 11011110  | 222            |

        Scenario Outline: Binary integers prefixed by "32'b"
            The "32'b" prefix is not part of the argument.

            When a step definition interprets binary integer 32'b<argument> as a <type>
            Then the resulting integer value should be <expected_value>

            Examples: Octal
                | type | argument | expected_value |
                | int  | 10011000 | 152            |
                | int  | 01101101 | 109            |
                | int  | 11100101 | 229            |
                | int  | 00101011 | 43             |
                | int  | 11011110 | 222            |
