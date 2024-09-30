---
layout: page
title: Background
permalink: /background/
---
![A pickle glowing when an electric current is passed through it.](https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/Glowing-pickle-elfi-von-fliegenpilz.png/640px-Glowing-pickle-elfi-von-fliegenpilz.png) \
A gherkin glows when an electric current is passed through it.[^electric_gherkin]

[^electric_gherkin]: ["File:Glowing-pickle-elfi-von-fliegenpilz.png"](https://commons.wikimedia.org/wiki/File:Glowing-pickle-elfi-von-fliegenpilz.png) by Elfi von Fliegenpilz is licensed under [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/)

# Description
{% comment %}
# `description` object is defined in _config.yml
{% endcomment %}
{{ site.description }}

What does all that mean?

## Executable Specifications and Living Documentation
Hardware and software development projects rely on documentation to keep teams on the same page.
Detailed specifications let project sponsors, developers, and testers agree on what to create, why to create it, and how to test that it is created correctly.
The problem is that traditional static specifications can get stale.
If anyone changes the spec, the developers have to make sure the changes are reflected in the code.
Likewise if the developers change the code, the spec needs to be brought up-to-date.
If the spec and the code get too far out-of-sync, the tests could be incomplete and a serious bug might slip through to the shipped product.

What's needed is an executable specification--a document which is still written and readable by humans, but which has a little machine-parsable structure to it. Thanks to this structure, the spec becomes a test which the team can run automatically to verify that the spec and the code still agree whenever either of them changes. Such a specification is no longer static; it has become living documentation.

## Integrated Circuit Design and Verification
Integrated circuits (ICs), or computer chips, are the tiny silicon brains inside all the electronic devices and systems we use today, like cell phones, self-driving cars, and submarines.
Being physical, tangible objects, ICs are hardware, yet thanks to electronic design automation (EDA), chip designers can use specialized _register-transfer level_ (RTL) hardware description languages (HDLs) to model circuits as software code, replacing the hand-drawn schematics of old.
Expert engineers use a sophisticated chain of programs and automated manufacturing equipment to fabricate physical hardware chips from the designers' software models.

It costs millions of dollars to produce a line of chips because they're so complex.
If a bug is found late, it's very expensive to fix it and start the fabrication process all over again.
It's much better and cheaper to find and fix all the bugs sooner, while the design is still an RTL software model.
To that end, chip companies utilize teams of talented and good-looking[^1] design verification (DV) engineers, specialists who analyze specifications and designs, then write and run simulations that thoroughly test the RTL models before they're released to manufacturing.

[^1]: I may be biased.

## Agile, BDD, and Gherkin
Just like chip companies, software companies want to be sure their software products (apps, web sites, enterprise software, etc.) are free from defects before they are released to customers, so they too utilize teams of software testing and quality assurance engineers.
But more importantly, the software industry continuously analyzes candidly what works and doesn't work in each generation, and over the years has evolved techniques that help coders increase productivity and quality.
Many of the leading techniques are known together as Agile software development because their biggest benefit is helping teams respond better to change and even turn it to competitive advantage.

Test code can be complex, so software testers, guided by Agile values and principles, figured out ways to write tests in natural language (e.g., plain English) instead and use programs to turn the natural language into code automatically.
The transformational revelation was that comprehensive natural language tests are a great way to describe what a piece of code is supposed to do, i.e., its intended behavior.
Furthermore these descriptions enable teams to have conversations about behavior early in the development cycle, before any code is written, and to include diverse perspectives from non-technical participants.
In short, Agile software developers and testers created a way to collaborate up front on executable specifications that can be run as automated tests that guide development.
When the new code passes these tests, it demonstrates that it does what it's supposed to do, and can be accepted as done.
This Agile flow from collaboration to specification to acceptance is called [behavior-driven development (BDD)](https://dannorth.net/introducing-bdd/).

BDD is an abstract concept put into practice with actual tools. [Cucumber](https://cucumber.io) is a popular BDD tool for turning natural language specifications into executable tests. Recall that executable specifications require a little structure so tools can parse them. Cucumber relies on a de facto standard lightweight programming language called [Gherkin](https://cucumber.io/docs/gherkin/) to provide that structure. The heart of a Gherkin file is a collection of concrete scenarios, phrased in a particular _Given-When-Then_ pattern, that illustrate the behavior of a new feature. Gherkin feature files read like natural language specs, but run like tests.

```gherkin
# This Gherkin feature file's name is alu_division.feature

Feature: Arithmetic Logic Unit division operations

    The arithmetic logic unit performs integer division.

    Scenario: With integer division, the remainder is discarded
        Given operand A is 15 and operand B is 4
        When the ALU performs the division operation
        Then the result should be 3
        And the DIV_BY_ZERO flag should be clear

    Scenario: Attempting to divide by zero results in an error
        Given operand A is 10 and operand B is 0
        When the ALU performs the division operation
        Then the DIV_BY_ZERO flag should be raised
```

## SystemVerilog and UVM
Cucumber works with many popular programming languages like Ruby, Java, and JavaScript. Other BDD tools support even more languages like Python, Perl, and C#.
IC design and verification engineers use a variety of programming languages on a daily basis, but the two most prevalent HDLs for modeling circuits are [SystemVerilog](https://standards.ieee.org/ieee/1800/7743/) and [VHDL](https://standards.ieee.org/ieee/1076/5179/). SystemVerilog and VHDL users require simulators--commercial EDA tools that can compile and execute RTL code and associated test fixtures.

The SystemVerilog language is backward compatible with its predecessor, [Verilog](https://standards.ieee.org/ieee/1364/3641/). Verilog is in the C family of programming languages in that it's procedural, terminates lines with semicolons, and uses familiar keywords and operators like _if_, _then_, _else_, _for_, and _&&_. Verilog also has unique syntax and concepts essential for modeling digital hardware like native _time_ and _wire_ types, four-state variables, and concurrent processes.

SystemVerilog builds on Verilog by adding features verification engineers find useful for testing hardware models. These features include object-oriented programming, constrained random value generation, assertions, and functional coverage.

SystemVerilog gives users a lot of freedom in how to write tests, so inevitably every individual and company developed their own ways of doing things. To bring some coherence to this Tower of Babel, industry leaders got together to develop the [Universal Verification Methodology (UVM)](https://www.accellera.org/activities/working-groups/uvm), now an [IEEE standard](https://standards.ieee.org/ieee/1800.2/7567/) library specification and approach for creating standardized, interoperable verification environments.

BDD was largely unknown in the IC world and sadly no BDD tools supported SystemVerilog and UVM. Until now.

## Bathtub

**B**DD \
**A**utomated \
**T**ests \
**H**elping \
**T**eams \
**U**nderstand \
**B**ehavior

Bathtub is a library written entirely in SystemVerilog that enables BDD for IC projects.
It's built on top of UVM so it integrates seamlessly with existing verification environments.
Users run it in their simulators along with their RTL models; it reads and parses their Gherkin files, and executes them as tests.

Now your entire IC development team can enjoy the full benefits of BDD that software developers have been been receiving for years.
RTL designers, DV engineers, firmware and embedded software coders, system architects, and project managers can collaborate on mapping out upcoming features, complete with examples, at a high level, in a language the whole team understands.
These are invaluable conversations--best held together in real time with index cards, whiteboards, or their digital equivalents--where every colleague contributes to a shared understanding of a feature's behavior.
Two or three participants distill those features into executable Gherkin files for everyone to review and reference.
Then, with Bathtub, DV engineers simulate those feature files as tests, using the automated tools and flows they know best.

A slightly deeper dive for the UVM community.
Assuming you already have a working UVM testbench, you need to do a few things to add Bathtub to it.
First, you need to write UVM virtual sequences that cover every _Given_, _When_, and _Then_ step in your Gherkin file.
These are called step definitions and they effectively map your natural language Gherkin steps to runnable SystemVerilog code.
Bathtub provides macros that simplify step definition creation.
Your _Then_ steps should include assertions or equivalent conditionals so your scenarios can be self-checking.
Then you need to write a new UVM test that's a lot like your existing tests in that it instantiates your UVM environment, but it also instantiates and configures a `bathtub` object from the package `bathtub_pkg`.
When you run your test, e.g., with `+UVM_TESTNAME=bathtub_test`, instead of running a hand-coded default sequence, your test "runs" your `bathtub` object, which reads and parses your Gherkin files at run time, maps its steps to your step definition virtual sequences, then runs them all sequentially on your existing virtual sequencer.

Bathtub supports only SystemVerilog, not VHDL. 

## Open-Source
The Bathtub project, including these web pages, is maintained on GitHub at [https://github.com/williaml33moore/bathtub](https://github.com/williaml33moore/bathtub). The "GitHub" link in the sidebar of these web pages also takes you there.

These easy-to-remember bookmarkable URLs all redirect you here:
* [bathtubBDD.dev](https://bathtubbdd.dev{{ page.url }})
* [bathtubBDD.com](http://bathtubbdd.com{{ page.url }})
* [bathtubBDD.org](http://bathtubbdd.org{{ page.url }})

but you will note from the true URL in your web browser that these pages are served from GitHub at [https://williaml33moore.github.io/bathtub/](https://williaml33moore.github.io/bathtub/).

This QR code takes you to the home page.

![QR code for bathtub pages]({{ site.baseurl }}/assets/about/qrcode_williaml33moore.github.io.png)

These pages present a relatively user-friendly façade for general audiences with content like blog posts, background material, and announcements. The GitHub project is more technical and requires some GitHub familiarity to navigate, but it is the complete single source of truth for Bathtub.

The GitHub repo contains the following:

[Releases](https://github.com/williaml33moore/bathtub/releases)
: Download and try the latest release.
Bathtub is written in SystemVerilog and requires a full-featured SystemVerilog simulator with UVM to run.

[Pages](https://williaml33moore.github.io/bathtub/)
: These web pages, deployed and served from the [`pages`](https://github.com/williaml33moore/bathtub/tree/pages) branch to [https://williaml33moore.github.io/bathtub/](https://williaml33moore.github.io/bathtub/).

[Wiki](https://github.com/williaml33moore/bathtub/wiki)
: For technical documentation and user guides, including a detailed [Getting Started](https://github.com/williaml33moore/bathtub/wiki/Getting-Started) page.

[Discussions](https://github.com/williaml33moore/bathtub/discussions)
: This is currently the preferred forum for community conversation about Bathtub. It requires a free GitHub account. You can sign up [here](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fdiscussions%2Findex&source=header-repo&source_repo=williaml33moore%2Fbathtub_).

[Issues](https://github.com/williaml33moore/bathtub/issues)
: Tasks are tracked and bugs are reported here.

[Source code](https://github.com/williaml33moore/bathtub)
: The Bathtub code is available open-source under the [M.I.T. license](https://github.com/williaml33moore/bathtub/blob/main/LICENSE).
The repo is available for cloning and forking, but I'm not accepting pull requests at this time.

Bathtub is a work-in-progress so everything is incomplete today, but continuously improving!

---
