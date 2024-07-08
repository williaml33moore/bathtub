---
layout: post
author: Bill
title: "Keeping It Real"
date: 2024-04-26 06:00:00 -0700
tags: verification soc
---
So far the only working Bathtub code I have shared is for my arithmetic logic unit (ALU) example.
I've gotten a lot of mileage out of it.
It's in the DVCon paper and presentation, it's publicly available at [EDA Playground](https://edaplayground.com/x/Prp5), and parts of it are even sprinkled around this web site.
It's a reasonable introduction to BDD and Bathtub, but it's dead simple.

I created the ALU example specifically for the DVCon paper, so it had to be simple because I was under tight space and time constraints.
The design under test is a basic calculator that performs mathematical calculations on two integers, `A` and `B`:
```
A + B
A - B
A * B
A / B
```
No clocks, no resets, no state machines...just combinational arithmetic.

I do have a more involved example which I haven't shared yet, which I call "calculator."
Here's a snippet:

```gherkin
Feature: Cash register calculator

    This calculator stores item names and unit prices.
    It calculates a subtotal when given an item and quantity.
    
    Background:
        Given the calculator is reset

    Scenario: Perform a simple successful calculation
        When I load item apples at 105 cents each
        And I calculate the subtotal for 7 apples
        Then the subtotal should be 7.35 USD
        And the error flag should be deasserted

    Scenario: Try a calculation with a nonexistent item, get an error
        * I load item apples at 105 cents each
        * I calculate the subtotal for 3 oranges
        * the error flag should be asserted
```
I've been using it to exercise Bathtub's Gherkin parser, so the feature file uses more of the language.
For example, this snippet introduces the `Background` keyword, and uses asterisks instead of `Given/When/Then` for some of the steps.
It goes on to include a `Scenario Outline:` (not shown), which is the fanciest feature in Gherkin.
My first version of Bathtub could parse the entire Gherkin language, but the code was a mess (I had to prioritize working software over clean code) so I started rewriting the parser last year, following better design principles.
It's still a work in progress, so as I flush out the parser, the calculator example will get a little richer to match.

All the same, the DUT is still super simple.
As you can see--thanks to the expressive power of Gherkin--I can load a unit price for retail items, and the calculator figures the subtotal for a given quantity.
That's pretty much it.
It can't even sum up the grand total.

Toy examples like this serve a purpose.
Mine help me bring up and illustrate Bathtub.
But ASICs are much more complicated than these one-page designs, so it's fair of you to wonder: can Bathtub scale up and be useful on a multi-million gate chip?

To be honest, I don't know the answer, and I'm pretty curious about that myself.
I don't know about a _whole_ ASIC, but from my limited experience, I can assert that Bathtub works great for reasonably-partitioned portions of a design.

## Two Case Studies

![EAS]({{ site.baseurl }}/assets/posts/2024/04/2024-04-26.png)Everactive self-powered SoC[^citation]

[^citation]: C. J. Lukas et al., “15.2 A 2.19µW Self-Powered SoC with Integrated Multimodal Energy Harvesting, Dual-Channel up to −92dBm WRX and Energy-Aware Subsystem,” 2023 IEEE International Solid-State Circuits Conference (ISSCC), San Francisco, CA, USA, 2023, pp. 238-240, doi: 10.1109/ISSCC42615.2023.10067337.

When I first created Bathtub at Everactive, I tried it out on two blocks in the SoC we were working on at the time.
I'll give a high-level report of how Bathtub worked out on an actual ASIC project.

### Energy Aware Subsystem

The first block was the controller for our Energy Aware Subsystem (EAS).
Our chip had to be able to function in environments where sources of energy were scarce (it was kind of our [thing](https://everactive.com/batteryless-technology/)), so the EAS helped us prolong run-time.
The EAS collected from other blocks in the chip relevant data like available energy, energy usage, and temperature, and used that information to put the chip in various power modes ranging from running full-bore to being in deep sleep.
The EAS had a block of registers so the ARM core could program it and read its status.

The EAS was my first candidate for Bathtub.
This was not a complete BDD flow.
I worked largely alone and used the RTL and my pre-existing verification components and sequences as a vehicle to bring up Bathtub.
Even so I was able to build up a nice collection of Gherkin scenarios that were genuinely useful in documenting and demonstrating the behavior of the EAS.
For example the EAS had a mode register that determined what power states to put the ARM core and the RAMs in.
I had a scenario for each EAS mode.
There was one particularly tricky combination of states that had me confused.
Once I straightened it out with the RTL designer, I added a scenario that explicitly described it, and referred to that scenario often as definitive documentation.

The EAS contained some large counters so it could gather statistical power data over long periods, for example, to track what time of day or even what day of the week power would be likely to be plentiful or scant.
Clearly we can't simulate virtual _days_ so I added plusargs that sped up the counters by orders of magnitude.
I added comments to the Gherkin file to remind myself which plusargs were required.
This is a good use of Gherkin comments; they weren't about the behavior of the RTL, they were meta-information about the scenarios themselves.

In any sort of testing, a test that has a side-effect that alters the outcome of subsequent tests is an anti-pattern.
To avoid that situation, you want to make sure each test starts with a clean slate.
Bathtub runs its scenarios one after another so I decided to add a background step that did a hard-reset and effective reboot of the RTL before every scenario. Something like this:

```gherkin
Background:
  Given the chip is powered up and reset
```

All these additional resets made the tests run longer, but it was important that the RTL be in a consistent state for each scenario.

Bathtub worked and the tests ran and passed.
I added them to the regression suite where they stood guard against any introduced bugs.

### Encryption

The other block was an AES encryption/decryption peripheral.
It also had registers for the ARM core to initialize the encryption key and provide plaintext data to be encrypted into ciphertext, and vice versa.

The AES standard includes an Algorithm Validation Suite (AESAVS) with "known answer tests" (KATs)--concrete examples (!) of keys, plaintext, and ciphertext.
I stored those KAT values as literals in the testbench.
The KAT data sets are pretty large, too large to put into a feature file.
No one wants to read a Gherkin file that goes on like this for pages and pages:

```gherkin
    Given the plaintext is AF 89 5D 39 32 0F CC 45 2C A9 96 ...
```

So instead I just referenced the KATs by name in the Gherkin file.

```gherkin
    Given the known answer test is KNOWN_ANSWER_TEST_KEYSIZE
```

Sometimes you have to keep the Gherkin file high-level and readable by pushing the low-level complexity into the step definition.
In this case, the step definition knew how to map the named KATs to literal data in the testbench.

## It's Real

I didn't try to tackle the entire ASIC with Bathtub.
Rather I introduced it in two blocks I happened to be working on.
The important thing is to find a partition of RTL that's just the right size to fit into a reasonable feature file.
Remember you can have as many feature files as you need, so if a feature starts to look too big, that might be a indication it needs to be broken up.

My ALU example is of course too small to be of significant value in the real world, but the EAS and AES showed that Bathtub can do real work. 

---

