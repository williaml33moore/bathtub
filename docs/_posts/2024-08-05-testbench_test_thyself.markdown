---
layout: post
author: Bill
title: "Testbench, Test Thyself"
date: 2024-08-05 06:00:00 -0700
tags: livingdocs bathtub github testing
---
My friends, we have achieved a momentous milestone.
Bathtub is finally testing itself.

I knew this day was destined to come.
Bathtub is a tool for developing and testing code.
Bathtub _is_ code.
Therefore, it was inevitable that Bathtub would be used for testing itself.

I can think of many colorful terms and metaphors for this happy state.
Meta-testing.
Ouroboros.
Recursion.
[Strange loop](https://www.goodreads.com/book/show/123471.I_Am_a_Strange_Loop).
The truth is I love things that are self-referential, like this sentence.
They give us a glimpse of the infinite.

So what are we testing?
With Bathtub, steps in a Gherkin feature file are mapped to and executed as UVM sequences.
For a while now, Bathtub has created two ancestor sequences for the step sequences: one for the feature, and one for the scenario containing the step.
These ancestor sequences provide context so steps can share [state](https://cucumber.io/docs/cucumber/state/?lang=java) among themselves.
This week I made some enhancements where I added two more context sequences to the hierarchy: a [test-level sequence](https://github.com/williaml33moore/bathtub/pull/80) and a [rule-level sequence](https://github.com/williaml33moore/bathtub/pull/83).

The idea of the test-level context sequence is that from Bathtub's perspective, it is the top-level sequence.
If Bathtub reads multiple feature files, that one test-level sequence should persist across the feature files.
How do I test this?
Naturally, by creating two feature files that use the test-level context to pass information from one to the next.

Here's an excerpt from the first feature file, [step_definition_interface_0.feature](https://github.com/williaml33moore/bathtub/blob/2026a8fabea8cedb0f78de91202624850e056a6d/test/e2e/step_definition_interface/features/step_definition_interface_0.feature).
```gherkin
Feature: This is a feature

    Rule: This is a rule

        Scenario: An uninitialized string item should be the empty string
            When I read item "feature" from the "test" "string" pool
            Then the returned "string" value should be ""

        Scenario: Store a string in the test string pool for a subsequent feature file to read
            Given I store the value "step_definition_interface_0.feature" in an item called "feature" in the "test" "string" pool
            When I read item "feature" from the "test" "string" pool
            Then the returned "string" value should be "step_definition_interface_0.feature"
```

And here's an excerpt from the second, [step_definition_interface_1.feature](https://github.com/williaml33moore/bathtub/blob/2026a8fabea8cedb0f78de91202624850e056a6d/test/e2e/step_definition_interface/features/step_definition_interface_1.feature).
```gherkin
Feature: This is another feature

    Rule: This is a rule

        Scenario: A previous feature should have left a value in the test string pool
            When I read item "feature" from the "test" "string" pool
            Then the returned "string" value should be "step_definition_interface_0.feature"
```

As you can tell from the plain English behavior descriptions, the first feature file stores its own filename in a string called "feature" in the test-level pool of strings, and the second feature retrieves that same string and checks that it is correct.
I wrote step definitions to implement all these steps, and everything runs and passes.

Why didn't I use Bathtub on itself sooner?
I wanted to, but it wasn't really necessary until now.
After all, BDD is primarily a collaboration aid, but since I'm currently working solo on this project, collaboration wasn't a priority.
Feature files are also valuable as living documentation, but to-date comments and GitHub are serving me well as documentation vehicles for posterity.
Self-testing requires the whole flow to work and I do have some nice end-to-end tests that exercise Bathtub from feature file to log file, but those feature files are about make-believe behavior or the [ALU Division](https://github.com/williaml33moore/bathtub/wiki/alu_division) example, not about Bathtub itself.
These test-level context sequence feature files are different.
They are describing their own behavior.

It is interesting to note that this idea of the tool testing itself is part of BDD's genesis.
Dan North wrote in his seminal 2006 article, [Introducing BDD](https://dannorth.net/introducing-bdd/), that he used his first BDD tool, JBehave, to bootstrap itself while he was developing it.
This practice revealed another benefit of BDD: it guided him to each next incremental change he needed to make, and provided a way for him to capture and verify that increment.

> My first milestone was to make JBehave self-verifying. I only added behaviour that would enable it to run itself. I was able to migrate all the JUnit tests to JBehave behaviours and get the same immediate feedback as with JUnit.
>
>  ...
>
> Given that I had the target in mind of making JBehave self-hosting, I found that a really useful way to stay focused was to ask: What’s the next most important thing the system doesn’t do?
>
> This question requires you to identify the value of the features you haven’t yet implemented and to prioritize them.

I instinctively wrote the above feature files using the first person, i.e., "Given I store the value..." and "When I read... ."
That's a controversial practice and normally I would advise against it.
It can be unclear and imprecise who the "I" in the scenario is.
In this case, though, it seemed natural.
I was developing this new feature and I was testing it, so I was the user.
I was basically talking to myself in realtime, like writing a journal.
However, in retrospect, there's another interpretation.
Perhaps the "I" in the scenario is Bathtub itself, exploring its emerging self-awareness through contemplation of its own behavior.
I behave, therefore I am.

Strange loop, indeed.
 
