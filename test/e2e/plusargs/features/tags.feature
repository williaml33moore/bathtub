@feature_tag
Feature: Feature with tag

    @scenario_tag
    Scenario: Scenario with tag
        * scenario_tag

    @scenario_outline_tag
    Scenario Outline: Scenario outline with tag
        * <tag_text>

        @examples_tag
        Examples:
            | tag_text     |
            | examples_tag |
