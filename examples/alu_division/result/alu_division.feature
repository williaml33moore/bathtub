# This Gherkin feature file's name is alu_division.feature

Feature: Arithmetic Logic Unit division operations

    The arithmetic logic unit performs integer division.

    Scenario: In integer division, the remainder is discarded
        Given operand A is 15 and operand B is 4
        When the ALU performs the division operation
        Then the result should be 3
        And the DIV_BY_ZERO flag should be clear

    Scenario: Attempting to divide by zero results in an error
        Given operand A is 10 and operand B is 0
        When the ALU performs the division operation
        Then the DIV_BY_ZERO flag should be raised

