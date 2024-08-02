@feature_tag
Feature: Feature with tag

    @rule_tag
    Rule: Rule with tag

        @scenario_tag
        Scenario: Scenario with tag
            * step_100

        @scenario_outline_tag
        Scenario Outline: Scenario outline with tag
            * <step_text>

            @examples_tag
            Examples:
                | step_text |
                | step_200  |
                | step_300  |
