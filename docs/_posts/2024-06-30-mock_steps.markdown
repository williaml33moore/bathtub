---
layout: post
author: Bill
title: "One Mock Step to Test Them All"
date: 2024-06-30 06:00:00 -0700
tags: 
---
I'm having a good time writing unit tests for the Bathtub Gherkin parser.
Now I'm at the point where I want to use SVUnit to test the Bathtub Gherkin runner.
Specifically, I want unit tests that specify Gherkin feature files as a string, parse and run them, then check the results.
In order to run Gherkin files, I need to provide step definitions.
I don't much like the idea of having to churn out a bunch of step definitions for miscellaneous feature files.
What would they say?
What would they do?
After giving it some thought, I came up with a pithy, catchy concept that solves my problem: a mock step.

In test parlance, a mock is a library, let's say a class, that stands in for another target class.
Your code likely depends on various other classes that provide a rich panoply of services.
However, when you unit test your code, you might not want to go through all the trouble and computational expense of instantiating, configuring, and executing that rich class.
As an alternative, you can replace that production class with a mock, a class that provides the same interfaces as the target class.
The clever thing is that instead of providing the rich panoply of services, for testing purposes it's enough for your mock to log all the messages your code sends to it.
Your unit test can query the mock to make sure the messages it received were as expected.

How do we apply this mock concept to Gherkin step definitions?
Gherkin code is a different animal than regular code because of the parsing and indirect execution that goes on, so we have to broaden our thinking.
Gherkin feature files can't run unless the tool has matching step definitions.
Therefore, we can say the Gherkin runner is dependent on your step definitions.
Since I've decided it's too expensive to create a library of step definitions just for testing, the step definitions are a candidate for mocking.
I need to create a mock step definition, or mock step for short.

My mock step will provide the same interface as a step definition.
That's straightforward: a full step definition is a UVM sequence class that implements the Bathtub `step_definition_interface` interface class.
Therefore, my mock step will also be a UVM sequence class that implements the `step_definition_interface.`
Which is to say, the mock step will in fact _be_ a step definition.
It's not a mock in the traditional sense.
It's more a concrete implementation that provides some special functionality.

A bathtub step definition uses the `Given`, `When`, and `Then` macros to implement the required `step_definition_interface` methods, and to specify the step string that triggers this step.
Since I only want to use one mock step, it needs to match every possible step string.
That's easy with regular expressions:
```sv
    `Given("/^.*$/")
```
Bathtub doesn't distinguish among the "Given/When/Then" keywords, so this one macro line will match every step.
This is the only step definition we need.

So now we have a step definition that will run for every step.
But what will it do?

Recall that step definitions are UVM sequences, and UVM sequences have the ability to send UVM sequence items to a UVM sequencer.
If my Gherkin unit test instantiates its own sequencer, I can use it to catch sequence items thrown by my mock step definition sequence.
I can define my own sequence item class with any payload I like.
The classic use case is a sequence item class that defines something like a packet or bus transfer.
But here's a nifty twist...I can define a sequence item class that sends a UVM sequence instance as payload.
My mock step definition can send _itself_ to the sequencer.

How is this useful?
Thanks to the implemented `step_definition_interface`, the mock step has introspection methods that return the step definition instance's attributes like keyword, regular expression, and step text which might include parameters.
My unit test can receive a mock step definition object from the sequence item, unpack it, and query its attributes to make sure they match expected values.

This is good enough for my purposes.
My unit tests don't really care what the step does.
All the tests care about is that the steps run, and my mock step can confirm that.
If the step I parse and run matches the step the sequencer receives, then all is well and the test passes.

Here is a working version of my mock step and a SVUnit unit test that exercises it.  

[](/Users/wlmoore/Git/bathtub_pages/test/resources/sequencing/sequence_items/mock_sequence_item/sequences/mock_step_definition_seqs.svh)
[](/Users/wlmoore/Git/bathtub_pages/test/resources/sequencing/sequence_items/mock_sequence_item/sequences/mock_step_definition_seqs_unit_test.sv)

```sv
class mock_step_def_seq extends mock_base_seq implements bathtub_pkg::step_definition_interface;
    // Catches every step
    `Given("/^.*$/")

    `uvm_object_utils(mock_step_def_seq)
    function new (string name="mock_step_def_seq");
        super.new(name);
    endfunction : new

    virtual task body();

        req = mock_object_sequence_item::type_id::create("req");
        start_item(req);
        // Sends itself as payload to the sequencer
        req.set_payload(this);
        finish_item(req);
    endtask : body
endclass : mock_step_def_seq
```

The `body()` task simply creates a sequence item, packs the mock step instance, "`this`," into the sequence item, and sends it off to any sequencer that requests it.

The unit test creates a mock step sequence instance from scratch, and configures it with all the attributes we want.
Then the unit test forks off two threads, one for the sequence and one for the sequencer.
The sequence thread starts the sequence, which throws the sequence item.
The sequencer thread catches the thrown sequence item, unpacks the step definition and its attributes, and checks them.

I can use this mock step to verify changes to the Gherkin parser and runner.
An important feature I will add soon is Gherkin rules.
I'll let you know how the mock step works out with this upcoming development.

