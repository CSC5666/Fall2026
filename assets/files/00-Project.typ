#import "wdf.typ": *

#show: template.with(
  title: [
    Final Project
  ],
  title-short: none,
  authors: "CSC 5666: Advanced Machine Learning, Fall 2026",
  authors-short: none,
  title-extra: [Professor Austin P. Wright],
  date: none,
  toc: false,
  full: false,
  header-content: none,
  abstract: [Assignment document for the final project and all of the intermediate deliverables.],
  bib: none,
  serif: true,
  exam: false,
)


#sidenote(dy: 1.15em, numbered: false)[#outline(depth: 2)]


= Overview
Since the objective of this course is to develop machine learning research skills, the primary means of assessment is with a semester scale research project. In order for the project to properly represent real world research, and to enable you to tackle larger and more interesting problems, the project should be completed in groups of between 2-4 people#sidenote()[If you have a particular reason to want to do the project individually that is ok, just make sure to talk with me to enure you are ready for the larger commitment.]. However, because it is the only true graded component of the course, some of the intermediate deliverables and assessments will be completed individually as well.

In particular, the project will involve multiple intermediate artifacts and submissions which will be submitted as a group, however each of these check points will also involve an in person, one-on-one, oral component to asses how well you are able to explain your work and answer critical questions about your choices and implementation.#sidenote()[These kinds fo oral exams can sometimes be stressful, I get it. To try and help with that you are free to "retake" any of your previous oral components however many times you want, all I care about it making sure by the end of the semester that you have mastery over at least your own project's material in ways that can be communicated.]

That being said the project itself is extremely open ended, as it is essentially designed to provide a place for you to work on a project of interest and relevance to you outside of this class, be it for a job, other research activity, your thesis, or some other interest.

Your project must adhere to a few hard requirements, within which you have essentially total freedom. So if you are ever in doubt about what may or may not work for your project, you should just talk to me and we will get on the same page. The requirements are that your project must both:
+ Contribute something minimally novel in either your method, domain, or implementation. You cannot just replicate some existing work verbatim. You must either be generalizing or changing some existing method, applying it in a new way or in a new context, or implementing some kind of tool or system that does not already exist.
+ Involve some non-trivial sized data#sidenote()[In principle both real world and synthetic data of some form are allowed, but you will have to make the case that the synthetic data is appropriately novel or interesting or representative.] about which you apply some of the methods (or variants based on the methods) discussed in class. In particular, in alignment with the emphasis of the course on understanding latent structure, your analysis of the data must go meaningfully beyond raw empirical prediction accuracy (or something equivalent) and instead elucidate some non-trivial aspect of the data.


// = Deliverables

// #table(
//   columns: 3,
//   [*Deliverable*], [*Due*], [*Weight*],
//   [Project Proposal], [9/28],   [15%],
//   [Literature Review], [10/14], [15%],
//   [Prototype Check-in], [11/4], [5%],
//   [Final Presentation], [12/9], [25%],
//   [Final Paper], [12/18], [40%],

// )


// All artifacts are due at the start of the lecture period on the date corresponding to the week shown above, submitted via Gradescope, unless noted otherwise below.

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
= Literature Review (15%)
The literature review should help to make sure that you are engaging with contemporary approaches and forms the most singularly valuable research skill in engaging with existing scholarship. It is due before class on 10/14 and is worth 15% of your final project grade.

== Deliverable
Check back soon for more information

= Prototype Check-in (5%)
The prototype check in should help make sure you are on track to complete the overall project by ensuring you have a mostly complete prototype of any large programming or systems component finished soon enough to complete all of the other parts of the project. It is due before class on 11/4 and is worth 5% of your final project grade.

== Deliverable
Check back soon for more information

= Final Presentation
Short research conference talk style presentation. Due 12/9, worth 25% of your final project grade.

== Deliverable
Check back soon for more information


= Final Report
Final completed research paper. Due 12/18, worth 40% of your final project grade.
== Deliverable
Check back soon for more information
