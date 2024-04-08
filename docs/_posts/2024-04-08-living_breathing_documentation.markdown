---
layout: post
author: Bill
title: "Living, Breathing Documentation"
date: 2024-04-08 06:00:00 -0700
tags: eclipse vscode pages wiki livingdocs design dvcon github
---

![dvclub_logo]({{ site.baseurl }}/assets/posts/2024/04/2024-04-08.png)

Today is the [Great American Eclipse](https://www.timeanddate.com/eclipse/solar/2024-april-8), a total solar eclipse crossing the U.S. from Texas to New England.
Ironically, I'm banging this post out in Visual Studio Code.
(IDE humor.)

 My focus this week has been on pulling together content for the Bathtub web site front page, and adding some technical details to the wiki.
 In short, documentation.
 Yet more irony. Bathtub is all about living documentation, but I find myself this week writing pages and pages of the stuff, and it doesn't feel very alive.
 There is method behind the madness, though.

 The web site isn't strictly documentation.
 It's more of a brochure.
 A way to let visitors know what they may find here, and how to learn more if they like what they see.
 It soon became apparent that though I was writing, it wasn't documentation.
 It was design.
 Not "design" as in "circuit design;" more like "design" as in "graphic design" or "interior design." 
 In short: "[design thinking](https://dschool.stanford.edu/executive-education-resource-collections/keep-learning1)."
 That is, finding creative ways to put things in the service of people to meet the people's needs.
 So I put aside the Kanban board and grabbed a pencil and my notebook, and literally sketched out some ideas.

 I'm happy with the [result]({{ site.baseurl }}/) so far.
 The front page has a clever logo (if I may say so myself), an introduction for everyone, a pitch for DV engineers who are my potential users, and a call to action.
 Plus I unapologetically put a strenuous snippet of SystemVerilog code right on the front page.
 If that doesn't scare the reader away, I know they're in the right place.

 In contrast, the wiki _is_ for documentation.
 I added a [new page](https://github.com/williaml33moore/bathtub/wiki/alu_division) with a really long description of the super simple ALU example from my DVCon paper.
 I was concerned that this would would be old-fashioned static documentation, but really I needn't have worried.
 The problem with static documentation is that it can get out-of-date when code or requirements change.
 But happily since this example has already been published, it's never going to change.
 It's basically a release, and I can document it as such.
 This is what Cyrille Martraire calls _stable documentation_ in [_Living Documentation_](https://learning.oreilly.com/library/view/living-documentation-continuous/9780134689418/ch09.xhtml#ch09lev1sec1):

 > Stable knowledge is easy to document because it doesn’t change often. A great benefit of stable knowledge is that you can use any form of documentation for it. Because there will be no need for updating the documents, even traditional forms that I would otherwise avoid, like Microsoft Word documents or wikis, are absolutely fine in this case.

In short, it's an historical record that serves as an appropriate introduction to newcomers.

I'm still learning my way around GitHub and this is my first experience creating a wiki, so publishing my first page has been an instructive experience.
Since GitHub hosts the source code, the web site, and the wiki, all adjacently, I'm already brainstorming ways to create truly living documentation here.
Just being able to hyperlink everything together is a great start.
Beyond that, there are cool opportunities to use automation to remix source and docs and create new ways to communicate knowledge and intent.
That's what this Bathtub project has always been about: facilitating communication.
And now that central motivation is spilling over the rim, out of circuits, into documentation. And into documentation about documentation.

I'm excited. The future's so bright, I have to wear [ISO 12312-2](https://www.iso.org/standard/59289.html) shades.

![eclipse glasses]({{ site.baseurl }}/assets/posts/2024/04/2024-04-08-02.png)
