#import "wdf.typ": *

#show: template.with(
  title: [
    Course Syllabus
  ],
  title-short: none,
  authors: "CSC 5666: Advanced Machine Learning, Fall 2026",
  authors-short: none,
  title-extra: [Professor Austin P. Wright],
  date: none,
  toc: false,
  full: false,
  header-content: none,
  abstract: none,
  bib: none,
  serif: true,
  exam: false,
)


#sidenote(dy: 1.15em, numbered: false)[#outline(depth: 2)]

= Course Information and Contacts

#colorbox()[
  *Professor*: _Dr. Austin P. Wright_\
  *Email*: `awrigh20@calpoly.edu`\
  *Office Hours (In person at 14-222:)*:
  - Mondays 11-12, and Mondays, Tuesdays, and Wednesdays from 1pm-2pm.
  - By appointment at #link("https://calendly.com/awrigh20-calpoly/30min")[https://calendly.com/awrigh20-calpoly/30min].
]

#colorbox()[
  *Course Homepage*:https://csc5666.github.io/Fall2026/\
  *Gradescope*: https://www.gradescope.com/courses/1355369  |  *Entry Code*: YB3GJJ \
  *Edstem*: https://edstem.org/us/join/nMfdkZ\
]


= Learning Objectives

As an advanced graduate course the ultimate learning object of this course is for you to develop the knowledge and skills to engage with and contribute to contemporary research in machine learning. Of course, as this field is rapidly changing and very large we will cover some of the most important and fundamental approaches of current relevance and interest, while simultaneously developing the research skills to bring yourself up to speed in any other particular sub-area in the future.


= Course Overview

This course will be based structurally around the textbook: _Probabilistic Machine Learning: Advanced Topics, Kevin Murphy, 2023_ #sidenote()[The book can be found for free at: https://probml.github.io/pml-book/book2.html], alongside additional research papers depending on topic.

In your previous encounters with machine learning, it has probably been framed as about mapping inputs to outputs, that is using data to approximate some function $f: cal(X) -> cal(Y)$, frequently with black box models such as with deep learning. This kind of prediction can sometimes dismissed as little more than sophisticated curve fitting. That charge is not entirely fair: once $cal(X)$ and $cal(Y)$ are themselves high-dimensional (images, sentences, graphs, sequences of actions), the intuitions that make "curve fitting" sound simple in one dimension stop applying. But the criticism still points at something real: current approaches are weighted heavily toward predicting observable patterns, and comparatively light on *understanding the latent structure that produces those patterns*.

This class will instead focus primarily on learning to represent those hidden structures to the best degree as is possible. This is required if we want data science to aspire to be like the rest of science, where uncovering root causes and mechanisms#sidenote()[Such as the disease behind the symptoms, or the distribution of minerals behind the spectrogram] is the actual goal, not merely predicting an outcome.

Towards this aim we will focus on _model-based_ methods rather than fitting $f: cal(X) -> cal(Y)$ directly. These methods try to learn parsimonious representations of the underlying _data-generating process_ itself. This mirrors the scientific method, where observations are explained by developing theories, and it is best formalized using *Bayesian inference*.


In the first part of the course we will work to fill out a toolbox of inference methods built on a foundation of Probability Theory, Bayesian Statistics, Information Theory, and the language of Probabilistic Graphical Models. From there the rest of the course will focus on how we can use these methods and the choice of model itself, which depends on the task and domain, the kind and amount of data at hand, and the metric of success.

The first model class we will cover are *predictive models*, which we will formalize as conditional distributions $p(y|x)$, where high dimensional input data $x in cal(X)$ is used to predict low dimensional output data $y in cal(Y)$. This will include discussion  of Bayesian Neural Networks, Gaussian Processes.

The next model class we will cover are *generative models*, formalized as distributions of the high dimensional data space $p(x)$ or $p(x|c)$ if we have some form of conditioning such as captions for image generation. This will include discussion of Variational Auto-encoders, Auto-regressive models, Energy Based Models, Diffusion Models, and Generative Adversarial Networks.

Finally we will move on the hardest class of machine learning modeling problems in *latent representation models*. These models are formalized as a conditionally factorized joint distribution $p(z,x) = p(z)p(x|z)$, where $z$ is the unobserved latent structure of the data. This will involve the hard task then of "uncovering" the structure by computing $p(z|x)$. This will include discussion of Latent factor models, Latent state space models, Bayesian Nonparametrics, Model Interpretability, and Causal Inference.

One thing you should notice is that this is a huge range of material that all has the possibility of incredible depth. Our goal for this class will thus not be to derive or prove every theorem or mathematical nuance of the topics discussed. Instead we will cover at a rigorous yet relatively high level the models and methods that you will then have the opportunity to do a deeper dive on as they are relevant towards your final project.

#pagebreak()
= Assessment and Grading

Your grade for this course will be based on two kinds of assessment, each accounting for half of your final grade, participation and your final project.

== Participation

In this course there will be many opportunities for interaction, participation, and in class exercises. Your participation in these activities is what makes the class work, not just for you, but also for everyone else in the class. Participation is expected and so a portion of your final grade is dependent on your engagement. Your participation grade does not depend at all on whether you get questions correct or how good your in class activity submissions are, it only depends on how regularly you are able to show up and engage with the material and with the rest of the class. While perfect attendance is not required to earn an A on this assessment#sidenote()[Nor would it be a guarantee as just showing up is not the same thing as participating!], since nobody is immune to the slings and arrows of outrageous fortune, I still expect you to give your best effort to make the class work.

== Final Project

The most interesting single thing you will do in this course will be your final project. In this project you will have substantial freedom to choose what you work on. You will complete the final project in teams of 2-4 students, and so I highly recommend you get to know the other students in the class, find anyone with similar interests, and get started as early as possible. Throughout the course there will be many check-in meetings to help get feedback and keep on pace, as well as intermediate deliverables.


#pagebreak()
#wideblock()[
  = Schedule
  Below is a tentative (and probably too optimistic) schedule of the topics we will cover in the course. As the semester progresses things may change, so pay attention to announcements/notifications/emails.


  #figure()[
    #table(
      columns: 4,
      align: left,
      table.header(
        [*Week*], [*Date*], [*Lecture Topic*], [*Deadlines*]
      ),
      [1],  [Mon, Aug 24],  [Course Introduction], [],
      [1],  [Wed, Aug 26],  [Probability Foundations], [],
      [2],  [Mon, Aug 31],  [Probabilistic Graphical Models], [],
      [2],  [Wed, Sep 2],   [Probabilistic Graphical Models Continued], [],
      [3],  [Wed, Sep 9],   [Information Theory Foundations], [],
      [4],  [Mon, Sep 14],  [Inference], [],
      [4],  [Wed, Sep 16],  [Variational Inference], [],
      [5],  [Mon, Sep 21],  [Monte-Carlo Methods Overview], [],
      [5],  [Wed, Sep 23],  [Markov Chain Monte-Carlo], [],
      [6],  [Mon, Sep 28],  [Bayesian Neural Networks], [Project Proposal],
      [6],  [Wed, Sep 30],  [Gaussian Processes], [],
      [7],  [Mon, Oct 5],   [Generative Models Overview], [],
      [7],  [Wed, Oct 7],   [Variational Auto-encoders], [],
      [8],  [Mon, Oct 12],  [Auto-regressive Models], [],
      [8],  [Wed, Oct 14],  [Energy Based Models], [Literature Review],
      [9],  [Mon, Oct 19],  [Diffusion Models], [],
      [9],  [Wed, Oct 21],  [Generative Adversarial Networks], [],
      [10],  [Mon, Oct 26], [Latent Factor Models], [],
      [10],  [Wed, Oct 28], [Latent State Space Models], [],
      [11],  [Mon, Nov 2],  [Bayesian Nonparametrics], [],
      [11],  [Wed, Nov 4],  [Representation Learning], [Prototype Check-in],
      [12],  [Mon, Nov 9],  [Interpretability], [],
      [12],  [Fri, Nov 13], [Interpretability Continued], [],
      [13],  [Mon, Nov 16], [Causal Inference], [],
      [13],  [Wed, Nov 18], [Causal Inference Continued], [],
      [Fall Break],  [],  [], [],
      [14],  [Wed, Dec 2],  [Special Topics], [],
      [15],  [Mon, Dec 7],  [Final Paper Review], [Final Paper Draft],
      [15],  [Wed, Dec 9],  [Final Project Presentations], [Final Presentation],
      [Finals],  [Fri, Dec 18, 1:00–3:30 PM],  [Retakes], [Final Paper],
    )
  ]
]
#pagebreak()


= Policies

== Classroom Conduct

Our classroom and lab are to be places of learning and inclusion. Students of all ages, abilities, background, race, sexual orientations, beliefs, religious affiliations, gender identities, and origins are to be treated with dignity and respect as contributors to our scholarly environment. Recognizing the following points is a non-negotiable prerequisite to participate in this course:

- _*We recognize that every single student in the class belongs here*_. We all have different backgrounds and experiences and we are not snobs about which backgrounds do or don't count.
- After our work is complete, we prioritize the education of others and actively offer to help, explain, debug, etc. in order to support one another’s learning. We do not share our working solution, but explain the logic/thinking behind our solution and help others recognize errors in their implementation when invited to do so.
- We consistently make the effort to recognize and validate multiple types of contributions to a positive classroom environment.



== Attendance
My goal is for lectures to be interactive which only works when people show up. There will be frequent small group discussions, and I am also likely to call on individual students. If I call on you, it’s totally okay to get an answer wrong or to not know the answer#sidenote()[Indeed, this is probably a sign that I have moved too quickly or been unclear about something. But I can only learn that and make adjustments if people are in class and able to speak up.]. However, if being called on is likely to be uncomfortable or disruptive for you, let me know.

I don’t allow the use of laptops during lecture sessions without special dispensation. There is plenty of evidence that suggests that laptops and other devices are distracting not only to the student using them, but also to those around them. Additionally, taking handwritten notes tends to lead to better learning outcomes#sidenote()[https://journals.sagepub.com/doi/abs/10.1177/0956797614524581]. If you need a laptop to take notes in class, please talk to me. You will have the opportunity to use your computer to work during specifically set aside time.

== Course Notes
My goal is to make my course/lecture notes and/or slides available to you as a study resource. They will be able to be uploaded after class and available on the course website. However, it is essential that you realize that these are not complete or sufficient to replace taking your own notes, but rather they may help you structure your notes and studying.

The primary purpose of the course notes and slides is to help _me_ structure and keep on track in lecture, but of course _I already know the material_ and so what I need to have written in order to lecture is very different than what you need to write to internalize the material for the first time. You are still responsible for the content actually covered in lecture.


== GenAI/LLM Use

The goals for this course are for _you_ to master the material, which can only be done if _you_ are the one doing the work. Therefore I must emphasize that for this class *_you cannot use Generative AI or Large Language Models for any aspects of writing or design_*. This class is meant to develop your research and analysis skills, and as such I want to see _your_ research and analysis. If it is clear through the oral components of the class that the work you are submitting is not your own, this will have consequences on your grade and may result in academic integrity violations.

That being said, this course does not have a learning objective of teaching you how to code#sidenote()[This is assumed as a prerequisite for the course]. Therefore use of AI development tools for writing code and implementation is allowed. However, be very careful, as you will still be completely responsible for everything you submit and it is a very slippery slope. We learn best by struggling and surmounting challenges. Uncritical reliance on GenAI tools will short-circuit this process. Sure, you will get an answer quickly, but the answer is not our objective; our objective is the process that gets us there. (Just like the goal of lifting weights in the gym is not just to have the weights in the air.)

If you do use AI assistants to help you study, you’re encouraged to put them in “study mode” first. Different companies have different names for this:

- “Study mode” in ChatGPT
- “Learning mode” in Claude
- “Guided learning” in Google Gemini

These “modes” nominally do not jump straight to an answer, but try to lead you to an answer while helping you build your understanding. Even still, be very wary of these tools even in a guard-railed state. Think very hard about how, if you do not develop the fundamental skills and you need such tools in order to succeed, what your ultimate value is after graduation.
