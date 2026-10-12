#import "wdf.typ": *

#show: template.with(
  title: [Final Project],
  title-short: none,
  authors: "CSC 5666: Advanced Machine Learning, Fall 2026",
  authors-short: none,
  title-extra: [Professor Austin P. Wright],
  date: none,
  toc: false,
  full: false,
  header-content: none,
  abstract: [Assignment document for the final project and all intermediate deliverables.],
  bib: none,
  serif: true,
  exam: false,
)

#sidenote(dy: 1.15em, numbered: false)[#outline(depth: 2)]


#v(-3em)

= Overview
Since the objective of this course is to develop machine learning research skills, the primary means of assessment is with a semester scale research project. In order for the project to properly represent real world research, and to enable you to tackle larger and more interesting problems, the project should be completed in groups of between 2-4 people#sidenote()[If you have a particular reason to want to do the project individually that is ok, just make sure to talk with me to enure you are ready for the larger commitment.]. However, because it is the only true graded component of the course, some of the intermediate deliverables and assessments will be completed individually as well.

In particular, the project will involve multiple intermediate artifacts and submissions which will be submitted as a group, however each of these check points will also involve an in person, one-on-one, oral component to asses how well you are able to explain your work and answer critical questions about your choices and implementation.#sidenote()[These kinds of oral exams can sometimes be stressful, I get it. To try and help with that you are free to "retake" any of your previous oral components however many times you want, all I care about it making sure by the end of the semester that you have mastery over at least your own project's material in ways that can be communicated.]

That being said the project itself is extremely open ended, as it is essentially designed to provide a place for you to work on a project of interest and relevance to you outside of this class, be it for a job, other research activity, your thesis, or some other interest.

Your project must adhere to a few hard requirements, within which you have essentially total freedom. So if you are ever in doubt about what may or may not work for your project, you should just talk to me and we will get on the same page. The requirements are that your project must both:
+ Contribute something minimally novel in either your method, domain, or implementation. You cannot just replicate some existing work verbatim. You must either be generalizing or changing some existing method, applying it in a new way or in a new context, or implementing some kind of tool or system that does not already exist.
+ Involve some non-trivial sized data#sidenote()[In principle both real world and synthetic data of some form are allowed, but you will have to make the case that the synthetic data is appropriately novel or interesting or representative.] about which you apply some of the methods (or variants based on the methods) discussed in class. In particular, in alignment with the emphasis of the course on understanding latent structure, your analysis of the data must go meaningfully beyond raw empirical prediction accuracy (or something equivalent) and instead elucidate some non-trivial aspect of the data.


== Deliverables
#figure()[
  #table(
    columns: (2fr, 1.2fr, 0.7fr),
    align: (left, left, right),
    table.header(
      [*Deliverable* #sidenote()[The percentages above are percentages of the project grade; the project is 50% of the course grade. Unless stated otherwise, written artifacts are submitted once per group on Gradescope. Add every team member to the group submission. Monday and Wednesday checkpoints are due before class; the final report is due by 11:59 p.m.]],
      [*Due*],
      [*Weight*],
    ),
    [Project Proposal], [Mon, Sep 28], [15%],
    [Literature Review], [Mon, Oct 19], [15%],
    [Prototype Check-in], [Mon, Nov 9], [5%],
    [Final Report Draft], [Mon, Dec 7], [5%],
    [Final Presentation], [Wed, Dec 9], [25%],
    [Final Report], [Fri, Dec 18], [35%],
  )
]

= Project Proposal
Your project proposal should help get early feedback to make sure what you are doing the rest of the semester makes sense. It is due before class on 9/28 and is worth 15% of your final project grade.

== Deliverable
You must submit a brief (1-3 page) outline of what you are trying to do. the contains the following sections#sidenote()[These sections are loosley based on the famous Heilmeier Catechism for research proposals]:
=== Proposal
You should start by briefly and simply stating answering "What are you trying to do?". You should be able to articulate your objectives as clearly and simply as possible.

=== Problem, motivation, and novelty
In this section you should explain more about what the problem is that your proposal addresses, as well as why it is interesting or important. Additionally you should explain how the work you are proposing is different from existing approaches.

=== Dataset
In this section you should go over your dataset if you already have it, or your plan to get access to the relevant dataset if you do not yet have access. You should include basic scale and summary statistics to justify that this dataset can support nontrivial analysis.

=== Evaluation
In this section you should briefly describe the means by which you will be evaluating whether or not the project was a success.


=== Timeline
In this section you should prepare a basic timeline of all of the different components of the project that need to be completed, as well as adding associated checkpoints and ways to make sure the project is going according to plan.

=== Team Coordination Plan
Finally you should prepare an explicit team coordination plan including various roles as well as an agreed understanding of the amount of time and effort you all are willing to devote to this project relative to your other responsibilities.

== Oral Examination
- 10 minutes, all team members present.
- Based on the submitted proposal: defend the feasibility of the overall project, novelty of the proposed method, and timeline.


#pagebreak()
= Literature Review
The literature review is due before class on *Monday, October 19*. Its purpose is to locate your question within existing scholarship and sharpen the claim your project can actually make.

#v(-2em)
== Deliverable
Submit a *2-4 page* review, excluding references, based on at least *3 different peer reviewed research papers*#sidenote()[While much work these days seems to be eschewing traditional peer review and publishing work in blog posts, preprints, and press releases; for this class we will have a higher standard and require work to be from reputable peer reviewed venues.], with each team member responsible for at least one paper#sidenote()[If your team has more than three people, the number of papers thus has to scale up. If your team has fewer than three people then the additional paper(s) can be distributed appropriately by the team]. The document should read as a single coherent argument contextualizing your work in the literature rather than a set of individually written summaries.

=== Synthesis of Prior Work
Organize the papers around ideas, assumptions, or methodological choices rather than discussing them one at a time. Explain the common problem setting and notation. Compare the model families, inference procedures, datasets, and evaluation strategies that matter for your project. A compact comparison table is encouraged.

=== Critical Reading
Identify what the papers establish and what they do not establish, identifying both the basis for your work and the opening for novelty. Separate limitations of a methods from a limitations of implementation or dataset.

=== Positioning the Project
End with a revised project statement. Explain precisely how your project relates to the closest work. Update any of your novelty claims, methods, baselines, or evaluation plans. If the original proposal no longer looks useful or feasible, say so and give a revised direction.
#v(-2em)
== Oral Examination
- About 10 minutes, with all team members present.
- Each member should be ready to explain one anchor paper and how it relates to your project.

#v(-3em)
= Prototype Check-in (5%)
The prototype is due before class on *Monday, November 9*. Think of it as a draft of the final project without the major results. By this point the project should run end to end on at least a small but representative slice of the data. The prototype is early enough that choices can still be changed.
The prototype is graded for evidence of a working research process, not for final performance.

== Demonstration and Oral Examination
- About 12 minutes, with all team members present.
- Give a short live demonstration or walk through the produced artifacts.


= Final Presentation
The presentation will take place in class on *Wednesday, December 9*, and the slides are due before class. Treat it as a short research conference talk for an audience that knows machine learning but does not know your application.

== Deliverable
Prepare an *10-minute presentation* followed by approximately *5 minutes of questions*. All team members must meaningfully participate. If the number of teams requires a small timing adjustment, the final limit will be announced well before presentation day.

A useful talk usually does the following:
+ States the research question and why it matters within the first minute.
+ Gives only the model detail needed to understand the contribution.
+ Explains the data, baselines, and evaluation before presenting the main result.
+ Uses a small number of readable figures or tables and interprets them instead of merely showing them.
+ Discusses relevant limitations or negative results

Do not try to compress the entire report into slides. The audience should leave knowing the question, what you did, what evidence you found, and why the evidence is or is not convincing.

== Evaluation
The presentation will be evaluated on technical content, organization, visual communication, timing, and answers to questions. Individual understanding matters: questions may be directed to any team member.


#pagebreak()
= Final Report
The final report is due by *11:59 p.m. on Friday, December 18*.

== Draft Workshop
Submit a functionally complete draft before class on *Monday, December 7*. It should contain every required section and the real figures or tables you expect to use with unfinished parts labeled clearly. Bring the draft to class for peer review.

== Deliverable
Write a *6–8 page* conference-style paper, excluding references and an appendix of at most two pages. Use the current NeurIPS conference style, in LaTeX or Typst, without changing its margins or font size. The exact organization may vary, but most reports should contain the following sections.

=== Abstract and Introduction
State the problem, why it matters, what you did, and the main finding. List the contributions plainly. Do not claim more novelty or generality than the evidence supports.

=== Related Work
Explain how the project relates to previous work. Group papers by their connection to the project and make the closest comparisons explicit. This should be a tighter version of the literature review, not the literature review pasted into the paper.

=== Data and Problem Formulation
Describe where the data came from, how they were processed, and what population or process they represent. Define the observed and latent variables, assumptions, prediction or inferential targets, and any important ethical or privacy constraints.

=== Method
Give a precise account of the model, objective, and inference procedure. Explain what is standard and what your team changed. Include enough mathematics, diagrams, or pseudocode that a classmate could understand and reproduce your implementation choices.

=== Experiments and Results
Use experiments that answer the research question. Compare against meaningful baselines and the closest feasible prior method. Include checks such as ablations, posterior predictive checks, sensitivity analysis, calibration, error analysis, or simulation-based validation when they fit the project. Report variability over hyper-parameters rather than presenting one lucky run.

=== Discussion
Interpret the results. What does the model get wrong, and are the failures systematic? Discuss limitations of the data, model, inference approximation, and evaluation. Negative results are welcome when the analysis explains what was learned.

=== Reproducibility and Contributions
Give a concise account of the software, data access, environment, random seeds, and compute needed to reproduce the main figures. Cite any code used as a starting point. End with a specific statement of each team member’s contribution.

== Evaluation
The report will be evaluated on:
- the importance and clarity of the question
- technical correctness and command of the relevant probabilistic model and inference method
- engagement with prior work
- quality of the experimental design, baselines, and checks
- depth of analysis and insight about the data, especially beyond predictive accuracy
- honest treatment of uncertainty, failures, and limitations
- writing quality, organization, and reproducibility.

Results do not need to beat every baseline. It is more important that the experiments clearly test the question you set out to answer and that the conclusions follow from the evidence.

Submit the paper PDF on Gradescope and include a stable repository link in both the paper and submission. Private repositories must grant the instructor access through the following term. Include the code, environment, and instructions for reproducing the principal results; do not upload data, checkpoints, or other large files unless requested.
