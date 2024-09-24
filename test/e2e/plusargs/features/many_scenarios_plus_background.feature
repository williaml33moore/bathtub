Feature: A feature file with many scenarios and a background

Use +bathtub_start and +bathtub_stop to run a subset of scenarios by index.
The background should not count as a scenario.

Background:
* background

Scenario: 0
* 0

Scenario: 1
* 10

Scenario: 2
* 20

Scenario: 3
* 30

Scenario: 4
* 40
