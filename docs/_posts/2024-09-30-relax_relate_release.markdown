---
layout: post
author: Bill
title: "Relax, Relate, Release!"
date: 2024-09-30 06:00:00 -0700
tags: bathtub github livingdocs systemverilog uvm wiki pytest
---
Back in the spring of this year, I formulated a plan to spend the summer working hard on Bathtub, with the goal of creating a 1.0.0 release before the fall.
My [digital almanac](https://www.timeanddate.com/calendar/seasons.html) informed me that in my neck of the woods, autumn started on Sunday, September 22 at 5:43 am, so I circled the date in my mind and got to grinding.

Three weeks before the golden day, things were going great, but I decided to sabotage myself by embarking on a new little side project.
(It's under wraps for now, but I'll share more when I can.)
I spent a couple weeks on that, put it to bed, then got back in the 'tub for the last seven days of summer.

The code was in good shape by then, so my primary focus was on documentation.
The [Semantic Versioning](https://semver.org/) convention states that software MUST (emphasis theirs) declare a public API, so I took that quite literally and documented all my highest-priority user-facing interfaces.
They're all up on the [Bathtub Wiki](https://github.com/williaml33moore/bathtub/wiki) and I'm pleased with how they turned out.
Don't worry, I added some cool Living Documentation features, such as embedding the method documentation in the source code and building the Wiki with automation.
As Cyrille Martraire says, the goal is to make documentation as fun as coding.
That aside, documentation is actually the reason why I haven't written a blog post in a while.
I wrote so much Bathtub documentation during the final 30-day push that I didn't have it in me to pen a post.
I figured words is words.
Wiki or blog; it didn't matter where they went.

The final weekend arrived, the regression tests were passing, the documentation was good enough.
Then something funny and utterly predictable happened.
In the course of documenting my code, I came up with not one but two great ideas to improve it.
Two teeny, tiny changes that were user-facing so they really needed to go in the code now.
In the real world, this would be a cautionary tale about scope creep and last-minute change requests and the havoc they can wreak.
But, my friends, this whole Bathtub journey has been utterly magical.
This isn't the real world, it's Neverland, and I'm Peter Pan with a laptop.
So with the clock ticking down, I ripped into the code and started making it more elegant.

Nothing too drastic.
I noticed that when user step definitions extracted parameter values from the run-time step attributes, the definition didn't have access to the raw argument text.
If the feature file had an argument that was "42" but you extracted it as an integer, the step definition got the integer 42, but lost the string "42."
So I added a method to the step parameter object to retrieve that raw text.
I'm TDD'ed up so it was straightforward to write a test, watch it fail, then make it pass.
Boom. Done.
Almost...

I'm also automated-testing'ed-up, so when I ran my regression suite, I learned that IEEE UVM phased out UVM field macro parameter `UVM_NOSET` and replaced it with `UVM_READONLY`.
Who knew? (I didn't.)
It took a while to navigate the maze of UVM version macros but I teased out the ones I wanted, and got the regression clean.
Push. Pull. Merge. Next!

The next idea was delectable.
All along I've been running Bathtub by instantiating a `bathtub` object, giving it sequencer details with `configure()`, then running it with `run_test()`.
The only catch was that I had to disable any default sequences from running on my virtual sequencer.
That turned out to be a little tricky when I gave the [UVM codec](https://github.com/williaml33moore/bathtub/wiki/UVM-Codec) example the Bathtub treatment.
My new idea was to run Bathtub as if it _were_ the sequence.
I created a new `bathtub` method, `as_sequence()`, that returns a sequence object that's a facade for Bathtub.
[Design patterns](https://en.wikipedia.org/wiki/Facade_pattern) for the win.
I can start that sequence just like any other, even make it a default sequence, and it takes care of configuring and running Bathtub automatically.
This is a much more UVM-esque solution, and feels more seamless.

But then, of course, there was a hiccup.
I knew from earlier experience that the whole business of launching sequences was sensitive to which version of UVM I was using, so I wanted to be sure to cross these new tests against every version.
It was kind of a pain to do that, so I tweaked my Pytest helper modules to simplify the task.

And it didn't work.

Midnight was fast approaching on the last partial day of summer, and I couldn't even get my tests to run.
I had a workaround, but I'm Peter Pan.
I wanted to root-cause this bug to the hilt.
Midnight came and went, but I did finally figure it out.
I hadn't marked a Pytest helper function correctly, so it was re-using the same object between tests, resulting in data leakage.
Problem solved, tests passing.
It was past midnight, now September 23, but I came up with a primo piece of rationalization.
Autumn started at 5:43 AM on September 22, which means the first full day of autumn didn't end until 5:43 AM on September _23_.

Let's go!!!

Ahem.
I think you can guess what happened next.

There was just one, itty bitty little change I wanted to make.
Completely inconsequential.
I like interface classes.
I like what they represent, and I like their semantics.
As I said earlier, for Semantic Versioning I wanted to document and publish my APIs, and a very clean way to do that is by capturing them as interface classes.
I had not created an interface class for the `bathtub` object, so I decided that would be the last change I slipped in before 5:43 AM Monday morning.
Very simple...just copy `bathtub.svh` into a new `bathtub_interface.svh` class, strip out the actual method code leaving only pure virtual prototypes, and be done.
Of course I had to include this new `bathtub_interface.svh` file so my tests could compile.

They didn't compile.

The simulator complained about `` `include `` loops.
I went around and around the code, but couldn't figure out how to break the loop.
5:43 AM came and went.
It was now unequivocably the second day of autumn.
I felt a little bad about that, but in truth the deadline was artificial, and I would have felt worse about releasing code I wasn't completely happy with.
So I got a little rest, and came back to the problem refreshed.
I meticulously hand-drew a node-and-edge graph of my `` `include `` file dependencies, and found the root of problem, and a very satisfying fix.

I had a file, `bathtub_pkg.svh`, in which I had thrown a handful of `typedef`s for Bathtub.
`typedef`s are all little one-liners, so it just seemed right to keep them all together.
The problem is that one of the `typedef`s was dependent on class `step_nurture`, so my `bathtub_pkg.svh` was forced to include that class' source file, `step_nurture.svh`.
That's what kicked off the infinite loop.
`step_nurture.svh` started a chain of `` `include ``s that wrapped back around to `bathtub_pkg.svh`, which hadn't finished loading yet, so the compilation failed.
`bathtub_interface.svh` had nothing to do with `step_nurture`, but it was forced to pick up that troublesome `` `include `` all the same.
After some more noodling, I came up with a solution that wasn't immediately obvious, but which is eminently satisfying.
I moved that one `typedef` that depended on `step_nurture` into its own include file.
`bathtub_pkg.svh` no longer had to include anything else, so any source file that included it could do so safely.
Only one file actually needed that `step_nurture` `typedef`, and that one file was able to include the `typedef` loop-free.
The problem was solved, I developed a technique to debug these problems in the future, and I learned a valuable lesson.
Elements like `typedef`s are small and seem like they belong together, but they come with their own dependencies, just like full-fledged classes, and are subject to their own separations of concerns.

All issues were resolved.
The tag and release process went smoothly, and [Bathtub v1.0.0](https://github.com/williaml33moore/bathtub/releases/tag/v1.0.0) was born September 23, 2024, at 5:57 PM, over a day and half into the fall.
1.5 days out of 150 is only one percent over schedule. I can live with that.

What a great summer.
