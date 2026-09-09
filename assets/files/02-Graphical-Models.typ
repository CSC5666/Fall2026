#import "wdf.typ": *

#show: template.with(
  title: [Graphical Models],
  title-short: none,
  authors: "CSC 5666: Advanced Machine Learning, Fall 2026",
  authors-short: none,
  title-extra: [Professor Austin P. Wright: Course Notes],
  date: none,
  toc: false,
  full: false,
  header-content: none,
  abstract: [Introduction to the language of Probabilistic Graphical Models including Directed, undirected, and conditional graphical models as representations of factorization and conditional independence. Closely follows Chapter 4 of the textbook.],
  bib: none,
  serif: true,
  exam: false,
)

#sidenote(dy: 1.15em, numbered: false)[#outline(depth: 1)]


= Introduction
#sidenote(numbered: false)[Textbook: Chapter 4, pp. 143–218.]


In general, a probabilistic model over the random variables $X_(1:D)$ is a joint distribution $p(x_(1:D))$. This is our fundamental object of analysis, since from a joint distribution any marginal or conditional distribution can be derived. However, in general, the parameters needed to represent a full joint distribution in it's entirety is combinatorially large.

However, if we know something about the domain, and thus the conditional independence of the different variables, we can save an enormous amount of space by _factoring_ the joint distribution in terms of conditional distributions.  Probabilistic Graphical Models gives us a _language for specifying a conditional factorization structure of the joint distribution_.


#discussion(vspace: 0em)[
  Consider an unstructured joint distribution for $D$ categorical variables with $K$ states.

  + How many parameters are required in order to represent the distribution in a table?#sidenote()[Answer: $K^D - 1$]
  + How many parameters does the unstructured joint need for $D = 20$ binary variables?#sidenote()[Answer: 1,048,575]
  + If we knew that all $D$ variables were _independent_, how many parameters are required in order to represent the distribution in a table?#sidenote()[Answer: $D*(K-1)$]
]

A *probabilistic graphical model* (PGM) uses a graph whose nodes are random variables and whose edges encode conditional-independence (CI) assumptions.#sidenote()[In different ways for different kinds of PGMs. Nontheless, in some respects a more descriptive name would be an _independence diagram_.] The graph provides:

- a compact representation of a high-dimensional distribution
- CI statements that can be read off the graph without inspecting parameters
- local components that can be specified, learned, and reused separately
- a computational scaffold for sampling and inference


However, remember that determining the structure of a PGM is a _modeling choice_ that enables real world problem solving. Since *all models are wrong, but some are useful*, we must very carefully interrogate these simplifications and weigh their utility and justification together.

= Directed Graphical Models: Bayesian Networks
#sidenote(numbered: false)[Textbook: §4.2, pp. 143–164]

A *Bayesian network* (also belief network, directed PGM, or DPGM) is a directed acyclic graph (DAG) whose nodes are random variables. Each node $X_i$ carries a conditional probability distribution (CPD) $p(x_i mid(|) x_("pa"(i)))$ given its parents.

While the name Bayes Network would seem to imply this is only a Bayesian method, in fact that is not required and there are frequentist versions of the same thing. Nonetheless, since this class is Bayesian the name suffices.

== Representing the Joint Distribution
#sidenote(numbered: false)[Textbook: §4.2.1, pp. 143–144]

Because the graph is acyclic, we can define a *topological order*: every parent precedes its children. For any such order, the chain rule of probability gives
$
  p(x_(1:D)) = product_(i=1)^D p(x_i mid(|) x_(1:i-1)).
$
The central assumption of asserting a particular network are the independences in the joint of the *ordered Markov property* over the network which states
$
  X_i tack.tt X_("pred"(i) without "pa"(i)) mid(|) X_("pa"(i)),
$
That is each variable is conditionally independent of all of it's predecessorss, conditioned on its parents. The joint then factorizes as
$
  p(x_(1:D)) = product_(i=1)^D p(x_i mid(|) x_("pa"(i))).
$
Root nodes have no parents, so their factors are marginal distributions.

#discussion(vspace: 0em)[
  Why are we only worried about dependence on predecessors in the topological order and ignoring successors?
]

#def(term: "Bayesian network")[A Bayesian network or Bayes Net consits of a pair $(G, Theta)$ which includes a DAG $G = (V, E)$, and one conditional probability distribution ( $p(x_i mid(|) x_("pa"(i)); theta_i)$ ) per node. It represents the factorized joint distribution as
$
  p(x_(1:D) mid(|) Theta) = product_(i=1)^D p(x_i mid(|) x_("pa"(i)); theta_i).
$

We use $theta \/ Theta$ to represent the parametrization of the conditional distributions.]

#discussion(vspace: 0em)[
  Consider an unstructured joint distribution for $D$ categorical variables with $K$ states. Let us then assume the distribution is modeled using some Bayes Net where each node has at most $m$ parents.
  In order to represent the joint distribution fully with conditional probability tables (CPTs), how many parameters would be required?#sidenote()[Answer: $D$ tables each with $K^m$ rows and $K - 1$ free entries per row, so $D(K^m)(K-1)$ parameters.]
]

#discussion(vspace: 0em)[
  Consider the following Bayes Net:
  #figure(
  diagram(
    edge-stroke: 0.8pt,
    node-corner-radius: 8pt,
    node-stroke: 0.8pt,
    edge-corner-radius: 6pt,
    node((0, 0), [$X_1$], name: <x1>),
    node((1, 0), [$X_2$], name: <x2>),
    node((2, 0), [$X_3$], name: <x3>),
    node((3, 0), [$X_4$], name: <x4>),
    node((4, 0), [$X_5$], name: <x5>),
    edge(<x1>, <x2>, "->"),
    edge(<x2>, <x3>, "->"),
    edge(<x3>, <x4>, "->"),
    edge(<x2>, <x5>, "->", bend: 25deg)))

  Let $G$ be the DAG $X_1 arrow.r X_2 arrow.r X_3 arrow.r X_4$ with a fifth node $X_5$ and edge $X_2 arrow.r X_5$.

  + Using the topological order $1, 2, 3, 4, 5$, write the ordered-Markov factorization of $p(x_(1:5))$, and name the CI assumption that removes each dropped conditioning variable.
  + The order $1, 2, 5, 3, 4$ is also topological. Show that it yields the *same* factorization, and explain why every topological order of a DAG must.
  + Is $2, 1, 3, 4, 5$ topological? If you applied the chain rule in that order and then deleted non-parents, which CI statement would you be asserting, and why is it false in general?
]

#discussion(vspace: 0em)[

Consider an example of a Bayes net with the random variables:
- $B$ : Representing if a burglary occurs
- $E$ : Representing if an earthquake occurs
- $F$ : Representing if a fire occurs
- $S$ : Representing if a smoke occurs
- $A$ : Representing if a the alarm goes off
- $J$ : Representing if Jeff calls 911
- $M$ : Representing if Musty calls 911

#figure(diagram(
  edge-stroke: 0.75pt,
  node-corner-radius: 10pt,
  node-stroke: 1pt,
  edge-corner-radius: 10pt,
  node((-1, -0.5), [$B$], name: <b>),
  node((-2, 0.5), [$F$], name: <f>),
  node((-1, 0.5), [$S$], name: <s>),
  node((0, 0), [$A$], name: <a>),
  node((1, -0.5), [$J$], name: <j>),
  node((1, 0.5), [$M$], name: <m>),
  node((2, 0), [$E$], name: <e>),

  edge(<b>, <a>, "->"),
  edge(<f>, <s>, "->"),
  edge(<s>, <a>, "->"),
  edge(<a>, <j>, "->"),
  edge(<a>, <m>, "->"),
  edge(<e>, <m>, "->"),
  edge(<e>, <j>, "->"),
  edge(<e>, <a>, "->"),
))
  + Write out the joint distribution using the chain rule in a topological order of the network.
  + Then simplify the distribution in terms of the conditional distributions given by the Bayes Net. Note the CI assumptions being used with each step
  + Assuming all variables are binary, what is the difference in the total number of parameters needed to represent the full joint distribution without assumptions as opposed to with the assumptions of the network.
  + Consider $A arrow.r E$ in isolation as a two-node model. Show that the reversed model $E arrow.r A$ can represent exactly the same set of joints. Then explain why, embedded in the full network, reversing this edge would change the implied independence model.
]


== Gaussian Bayesian Networks
#sidenote(numbered: false)[Textbook: §4.2.3, pp. 148–149]
Since we frequently want to work with variables that are continuous cannot be enumerated in a CPT, we generally have to make additional assumptions about the conditional distributions in a Bayes net.

The most common CPD is a *linear Gaussian*:
$
  p(x_i mid(|) x_("pa"(i))) = cal(N)(x_i mid(|) mu_i + w_i^T (x_("pa"(i)) - mu_("pa"(i))), sigma_i^2).
$
Collecting the coefficients into a matrix $W$ with $W_(i j) = 0$ whenever $j$ is not a parent of $i$, and writing $S = "diag"(sigma_1, ..., sigma_D)$, the system is
$
  bold(x) - bold(mu) = W(bold(x) - bold(mu)) + S bold(epsilon.alt), quad bold(epsilon.alt) tilde cal(N)(bold(0), I).
$
In a topological order $W$ is strictly lower triangular, so $I - W$ is invertible. Solving,
$
  bold(x) tilde cal(N)(bold(mu), Sigma), quad Sigma = U thin S^2 thin U^T, quad U = (I - W)^(-1).
$
A missing directed edge is a *zero in the regression matrix $W$*. It does not in general imply a zero in the covariance $Sigma$.

#discussion(vspace: 25em)[
  Let $X_1 tilde cal(N)(0, 1)$ and $X_2 mid(|) X_1 = x_1 tilde cal(N)(2 x_1, 3)$.

  + Write the model in the form $bold(x) = W bold(x) + S bold(epsilon.alt)$ (assume $bold(mu) = bold(0)$), giving $W$ and $S$ explicitly.
  + Compute $EE[bold(X)]$, $"Var"[X_1]$, $"Var"[X_2]$, and $"Cov"(X_1, X_2)$ using $Sigma = U S^2 U^T$.
  + Is $X_1 tack.tt X_2$? Which entry of which graphical-model matrix answers the _structural_ question, and why is that different from checking that $"Cov"(X_1, X_2) = 0$?
  + Now add $X_3 mid(|) X_2 = x_2 tilde cal(N)(x_2, 1)$. Compute $Sigma$ and its inverse $Lambda$. Verify that $Lambda_(1 3) = 0$ while $Sigma_(1 3) eq.not 0$, and state the CI meaning of each.
]

== Conditional Independence and D-Separation
#sidenote(numbered: false)[Textbook: §4.2.4, pp. 149–154]

D-separation (direct separation) is the process by which we can query the structure of a Bayes Net to answer questions about the conditional independence between arbitrary variables given arbitrary variables. Note that while the topology of the graph can communicate when _variables must be conditionally independent_, it does not enforce the other direction. It is possible that variables which the network considers possibly dependent may be, in reality, conditionally independent.

=== Common Structures (Triples)
While there is only two kinds of two variable relationships in a network (connected or disconnected), we can categorize a larger set of three node structures that will help us understand what we are looking at in a Bayes Net.

#figure(
  caption: [Causal Chain Structure],
  diagram(
    edge-stroke: 1pt,
    node-corner-radius: 10pt,
    node-stroke: 1pt,
    edge-corner-radius: 10pt,
    node((0, 0), [$X_1$], name: <x1>),
    node((1, 0), [$X_2$], name: <x2>),
    node((2, 0), [$X_3$], name: <x3>),

    edge(<x1>, <x2>, "->"),
    edge(<x2>, <x3>, "->"),

    // node((0, 1), [$X_1$], name: <ox1>),
    // node((1, 1), [$X_2$], name: <ox2>, fill: gray.lighten(70%)),
    // node((2, 1), [$X_3$], name: <ox3>),

    // edge(<ox1>, <ox2>, "->"),
    // edge(<ox2>, <ox3>, "->"),
  ),
)

#figure(
  caption: [Common Cause Structure],
  diagram(
    edge-stroke: 1pt,
    node-corner-radius: 10pt,
    node-stroke: 1pt,
    edge-corner-radius: 10pt,
    node((0, 0), [$X_1$], name: <x1>),
    node((1, -0.35), [$X_2$], name: <x2>),
    node((1, 0.35), [$X_3$], name: <x3>),

    edge(<x1>, <x2>, "->"),
    edge(<x1>, <x3>, "->"),

    // node((2, 0), [$X_1$], name: <ox1>, fill: gray.lighten(70%)),
    // node((3, -0.5), [$X_2$], name: <ox2>),
    // node((3, 0.5), [$X_3$], name: <ox3>),

    // edge(<ox1>, <ox2>, "->"),
    // edge(<ox1>, <ox3>, "->"),
  ),
)

#figure(
  caption: [Common Effect Structure],
  diagram(
    edge-stroke: 1pt,
    node-corner-radius: 10pt,
    node-stroke: 1pt,
    edge-corner-radius: 10pt,
    node((1, 0), [$X_1$], name: <x1>),
    node((0, -0.35), [$X_2$], name: <x2>),
    node((0, 0.35), [$X_3$], name: <x3>),

    edge(<x1>, <x2>, "<-"),
    edge(<x1>, <x3>, "<-"),

    // node((3, 0), [$X_1$], name: <ox1>, fill: gray.lighten(70%)),
    // node((2, -0.5), [$X_2$], name: <ox2>),
    // node((2, 0.5), [$X_3$], name: <ox3>),

    // edge(<ox1>, <ox2>, "<-"),
    // edge(<ox1>, <ox3>, "<-"),

    node((3, 0), [$X_3$], name: <gx1>),
    node((4.5, 0), [$X_4$], name: <gx4>),
    node((2, -0.35), [$X_1$], name: <gx2>),
    node((2, 0.35), [$X_2$], name: <gx3>),

    edge(<gx1>, <gx2>, "<-"),
    edge(<gx1>, <gx3>, "<-"),
    edge(<gx1>, <gx4>, "-->"),
  ),
)



=== D-separation Algorithm
+ Shade all observed nodes ${Z_1,…Z_k}$ in the graph.
+ Enumerate all undirected paths from $X$ to $Y$.
+ For each path:
  + Decompose the path into triples.
  + If all triples are open, the path d-connects $X$ to $Y$.
+ If no path d-connects $X$ and $Y$, then $X tack.tt Y|{Z_1,…Z_k}$#sidenote(dy: -25em)[You can also derive these triples from the rules where a path is closed if either:
    + The arrows on the path meet either head-to-tail or tail-to-tail at a colored node
    + The arrows meet head-to-head at the node, and neither the node, nor any of its descendants is colored.].

#sidenote(dy:-15em,numbered:false)[
  #discussion(vspace:0em)[
  Consider the set of open and closed triples. Notice how we show no triples containing multiple observed nodes. Explain conceptually why it must be the case that any triple containing multiple observed nodes is closed.
  ]
]

#wideblock()[

  #figure(
    caption: [Open Triples],
    diagram(
      edge-stroke: 0.75pt,
      node-corner-radius: 10pt,
      node-stroke: 1pt,
      edge-corner-radius: 10pt,
      node((0, 1), [#h(2pt)], name: <x1>),
      node((1, 1), [#h(2pt)], name: <x2>),
      node((2, 1), [#h(2pt)], name: <x3>),

      edge(<x1>, <x2>, "->"),
      edge(<x2>, <x3>, "->"),

      node((3, 1), [#h(2pt)], name: <x4>),
      node((4, 0.75), [#h(2pt)], name: <x5>),
      node((4, 1.25), [#h(2pt)], name: <x6>),

      edge(<x4>, <x5>, "->"),
      edge(<x4>, <x6>, "->"),

      node((6, 1), [#h(2pt)], name: <x7>, fill: luma(85%)),
      node((5, 0.75), [#h(2pt)], name: <x8>),
      node((5, 1.25), [#h(2pt)], name: <x9>),

      edge(<x8>, <x7>, "->"),
      edge(<x9>, <x7>, "->"),

      node((8, 1), [#h(2pt)], name: <x10>),
      node((9.25, 1), [#h(2pt)], name: <x11>, fill: luma(85%)),

      node((7, 0.75), [#h(2pt)], name: <x12>),
      node((7, 1.25), [#h(2pt)], name: <x13>),

      edge(<x12>, <x10>, "->"),
      edge(<x13>, <x10>, "->"),
      edge(<x10>, <x11>, "-->"),
    ),
  )


  #figure(
    caption: [Closed Triples],
    diagram(
      edge-stroke: 0.75pt,
      node-corner-radius: 10pt,
      node-stroke: 1pt,
      edge-corner-radius: 10pt,
      node((0, 1), [#h(2pt)], name: <x1>),
      node((1, 1), [#h(2pt)], name: <x2>, fill: luma(85%)),
      node((2, 1), [#h(2pt)], name: <x3>),

      edge(<x1>, <x2>, "->"),
      edge(<x2>, <x3>, "->"),

      node((3, 1), [#h(2pt)], name: <x4>, fill: luma(85%)),
      node((4, 0.75), [#h(2pt)], name: <x5>),
      node((4, 1.25), [#h(2pt)], name: <x6>),

      edge(<x4>, <x5>, "->"),
      edge(<x4>, <x6>, "->"),

      node((6, 1), [#h(2pt)], name: <x7>),
      node((5, 0.75), [#h(2pt)], name: <x8>),
      node((5, 1.25), [#h(2pt)], name: <x9>),

      edge(<x8>, <x7>, "->"),
      edge(<x9>, <x7>, "->"),
    ),
  )

]


#discussion()[
  #figure(
    diagram(
      edge-stroke: 0.75pt,
      node-corner-radius: 10pt,
      node-stroke: 1pt,
      edge-corner-radius: 10pt,

      node((0, 0), [$A$], name: <a>),
      node((0, 1), [$B$], name: <b>),
      node((-1, 2), [$C$], name: <c>),
      node((1, 2), [$D$], name: <d>),
      node((2, 1), [$E$], name: <e>),
      node((1, 3), [$F$], name: <f>),
      node((0, 3), [$G$], name: <g>),

      edge(<a>, <b>, "->"),
      edge(<b>, <c>, "->"),
      edge(<b>, <d>, "->"),
      edge(<e>, <d>, "->"),
      edge(<d>, <f>, "->"),
      edge(<d>, <g>, "->"),
      edge(<c>, <g>, "->"),
    ),
  )
  For the provided BayesNet, which of the following conditional independences _must_ hold?

  $
    & A tack.tt F | D \
    & A tack.tt E \
    & A tack.tt E | D \
    & A tack.tt E | F \
    & A tack.tt E | D , B \
    & A tack.tt E | D , B \
    & C tack.tt D \
    & C tack.tt D | B \
    & C tack.tt D | B, G \
  $
]


=== Explaining Away and Sample Bias
In a common effect structure ($X arrow.r Z arrow.l Y$) with competing causes, conditioning on the common effect $Z$ induces a _negative dependence_ between the causes: evidence for one _reduces_ the posterior for the other. Conditioning on a descendant of a collider, such as a selection indicator, has the same effect and produces *selection bias*. Two illustrations:

- Toss two fair coins repeatedly but record a trial only if at least one shows heads. Among recorded trials, "coin 1 is tails" forces "coin 2 is heads": a spurious correlation created entirely by conditioning on the recording decision, a common effect.
- Gaussian DPGM $X arrow.r Z arrow.l Y$ with $Z = X + Y + "noise"$: $X$ and $Y$ are uncorrelated marginally, but strongly (negatively) correlated in the subpopulation $Z > c$.


#discussion(vspace: 6em)[
  A graduate program admits applicants on research strength $R$ and grades $G$, modeled as $R arrow.r A arrow.l G$ with $R tack.tt G$ in the applicant pool.

  + Are $R$ and $G$ dependent in the full applicant population (That is, with no conditioning)? Explain how you can derive your answer using d-separation.
  + Among admitted students ($A = 1$), does learning that a student has weak grades change the expected research strength? Identify the active path.
  + Add a scholarship node $A arrow.r C$ (only admitted students can receive one). A researcher analyzes a dataset containing *only scholarship recipients*. How might this bias results?
]

Using the properties of the Bayes net and the process of d-separation, we can also define in general the smallest set of variables to condition upon to ensure any given node is conditionally independent of all other notes in the network, that is to _isolate_ the relevant information for any individual node. We call this set the *Markov Blanket*.
#discussion(vspace: 2em)[
  Why is the Markov blanket _not_ just the parents of a node?
]

#def(term: "Markov blanket (DPGM)")[The Markov blanket of node $i$ is
$
  "mb"(i) = "pa"(i) union "ch"(i) union "copa"(i),
$
its parents, children, and children's other parents ("co-parents"). Conditioned on its blanket, $X_i$ is independent of all other variables, and its full conditional is#sidenote()[This full conditional is used by Gibbs sampling and mean-field variational inference.]
$
  p(x_i mid(|) x_(j != i)) prop p(x_i mid(|) x_("pa"(i))) product_(k in "ch"(i)) p(x_k mid(|) x_("pa"(k))).
$
]

#figure(
  caption: [The directed Markov blanket of $X$: parents $P_j$, children $C_j$, and co-parents $S_j$. After textbook Figure 4.7.],
  diagram(
    edge-stroke: 0.85pt,
    node-corner-radius: 8pt,
    node-stroke: 0.85pt,
    edge-corner-radius: 8pt,
    node((0, 0), [$X$], name: <x>, fill: luma(85%)),
    node((-1, -1), [$P_1$], name: <p1>), node((1, -1), [$P_2$], name: <p2>),
    node((-1, 1), [$C_1$], name: <c1>), node((1, 1), [$C_2$], name: <c2>),
    node((-2, 0), [$S_1$], name: <s1>), node((2, 0), [$S_2$], name: <s2>),
    edge(<p1>, <x>, "->"), edge(<p2>, <x>, "->"),
    edge(<x>, <c1>, "->"), edge(<x>, <c2>, "->"),
    edge(<s1>, <c1>, "->"), edge(<s2>, <c2>, "->"),
  ),
)


== Generation by Ancestral Sampling
#sidenote(numbered: false)[Textbook: §4.2.5, pp. 154–155]

In addition to providing information about the joint, a Bayes net gives us a generative procedure for _sampling from the joint_. Visiting the nodes in topological order and drawing
$
  x_i tilde p(x_i mid(|) x_("pa"(i)))
$
produces an exact iid sample from the joint, because the product of the local sampling probabilities is exactly the represented joint. This is *ancestral sampling*. We can then use the _empirical distribution_ given by repeated samples of the joint to do various forms of inference.#sidenote()[Although we will find there will be scaling problems that will necessitate more clever sampling procedures.]

== Inference
#sidenote(numbered: false)[Textbook: §4.2.6, p. 155]

Given query variables $X_Q$, evidence $X_E = e$, and hidden variables $X_H$, standard tasks are:

- Calculating posterior marginals $p(x_Q mid(|) e)$ and expectations $EE[g(X_Q) mid(|) e]$;
- Finding the marginal MAP $arg max_(x_Q) p(x_Q mid(|) e)$ and joint MAP $arg max_(x_Q, x_H) p(x_Q, x_H mid(|) e)$;
- the evidence (marginal likelihood) $p(e)$.

We can derive the posterior exactly as
$
  p(x_Q mid(|) e) = 1 / p(e) sum_(x_H) product_i p(x_i mid(|) x_("pa"(i))),
$
with integration replacing summation for continuous hidden variables. Exact inference is NP-hard in general, but for certain strucutres can be made to be polynomial using Variable Elimination. Otherwise variational and Monte Carlo approximations are used. These algorithms will be introduced later on.

== Learning Parameters
#sidenote(numbered: false)[Textbook: §4.2.7, pp. 155–161]

In the analysis context where we want to learn parameters of the distributions, the structural assumptions of the network allow us to reduce the amount of data needed.#sidenote()[However note that this does not help us _learn the actual graph strucutre_, which requires a different class of learning algorithm.] For a fixed graph with parameters $theta$ that are _global_ over every data point, the MAP can be decomposed:
$
  hat(theta) &= limits("argmax")_theta product_i^N p(theta_i)p(cal(D)_i | theta_i)
$
This decomposition works when we observe every variable, however when there are unobserved latent variables or incomplete data we can no longer decompose over nodes, and thus must resort to optimization methods covered later.

== Plate Notation
#sidenote(numbered: false)[Textbook: §4.2.8, pp. 161–164]

A frequent enough scenario in probabilistic modeling is the assumption of independent and identically distributed (IID) variables. As we showed with de-Finetti's theorem, we prefer the assumption of _exchangability_ as being more useful and often more justified while covering essentially the same contexts. The assumption of exchangability is frequent enough (and helps our visual representations enough) that it has a specialized notation in PGMs called a *plate*.

A plate is just a box drawn around a repeated subgraph, labeled with its replication count or index set. Nodes outside a plate are shared, while nodes inside have one instance per index (and since the index number has no effect on the CPD, this is equivalent to exchangability).

$
  p(theta, x_(1:N)) = p(theta) product_(n=1)^N p(x_n mid(|) theta),
$

A plate is syntactic sugar that asserts repetition *and parameter sharing*. While it is the most frequent notation for repetition, note that not all abstractions over repetitive models can be represented with just plates (e.g.\ an HMM).

#figure(
  caption: [Left: $N$ explicit iid observations sharing a parameter $theta$. Right: the same model in plate notation. After textbook Figure 4.11.],
  diagram(
    edge-stroke: 0.85pt,
    node-corner-radius: 8pt,
    node-stroke: 0.85pt,
    node((0, 0), [$theta$], name: <t1>),
    node((-0.9, 1), [$x_1$], name: <x1>, fill: luma(85%)),
    node((0, 1), [$dots.c$], stroke: none),
    node((0.9, 1), [$x_N$], name: <xN>, fill: luma(85%)),
    edge(<t1>, <x1>, "->"), edge(<t1>, <xN>, "->"),
    node((3, 0), [$theta$], name: <t2>),
    node((3, 1), [$x_n$], name: <xn>, fill: luma(85%)),
    edge(<t2>, <xn>, "->"),
    node(enclose: (<xn>,), inset: 16pt, stroke: 0.6pt, corner-radius: 4pt, name: <plate>),
    node((3.62, 1.62), text(0.8em)[$N$], stroke: none, fill: white, inset: 1pt),
  ),
)
#sidenote(numbered: false,dy:-10em)[
#figure(
  caption: [Naive Bayes classifier as a DPGM augmented with plate notation. After textbook Figure 4.13.],
  diagram(
    edge-stroke: 0.85pt,
    node-corner-radius: 8pt,
    node-stroke: 0.85pt,
    node((0, 0), [$pi$], name: <pi>),
    node((0, 1), [$y_n$], name: <y>, fill: luma(85%)),
    node((0, 2), [$x_n$], name: <x>, fill: luma(85%)),
    node((0, 3.5), [$theta_(d c)$], name: <theta>),

    edge(<pi>,<y>,"->"),
    edge(<y>,<x>,"->"),
    edge(<theta>,<x>,"->"),

    node((0.4,2.3),[$N$],stroke: none,name:<N>),
    node(enclose: (<x>,<y>), inset: 15pt, stroke: 0.6pt, corner-radius: 5pt, name: <plate>),

    node((0.4,3.8),[$C$],stroke: none,name:<C>),
    node(enclose: (<theta>), stroke: 0.6pt, inset: 15pt, corner-radius: 5pt, name: <plate_C>),

    node((0.8,4.1),[$D$],stroke: none,name:<D>),
    node(enclose: ((-1.25,1.5),<D>), stroke: 0.6pt, corner-radius: 5pt, name: <plate_D>),
  ),
)
]

#discussion(vspace: 0em)[
  Draw plate diagrams, for the following models:

  + Bayesian linear regression with observed inputs $bold(x)_n$ and observed targets $y_n$, with global parameters of and linear gaussian CPDs.
  + Factor analysis of observed data $bold(x)_n$, a vector of unobserved latent factors $bold(z)_n$, and global parameters of and linear gaussian CPDs.
  + How are the two models different?
]

#discussion(vspace: 0em)[
  Consider the plate notation for a Naive Bayes classifier shown above. Attempt to draw what the network would look like without plate notation.
]


= Undirected Graphical Models: Markov Random Fields
#sidenote(numbered: false)[Textbook: §4.3, pp. 164–186]

A *Markov random field* (MRF), *Markov network*, or *undirected PGM* (UPGM) uses an undirected graph. It is natural when dependence is symmetric (spatial or relational data) or when no convenient generative order exists. Forcing directions onto such a domain, for example a 2d image lattice written as a DAG, yields awkward CI properties. Relative to DPGMs, UPGMs are more symmetric and, in discriminative form, often more accurate, but their parameters are less modular and more expensive to fit.
#wideblock()[
#figure(
  caption: [Left: a 2d lattice represented as a DAG, where the Markov blanket of $X_8$ includes its parents (blue), children (green), and co-parents (orange). Right: the same lattice as an undirected PGM, where the Markov blanket is just the four neighboring nodes (blue). After textbook Figure 4.15.],
  diagram(
    spacing: (1.5em, 2.7em),
    edge-stroke: 0.75pt,
    node-stroke: none,
    node-fill: white,
    node-inset: 3pt,

    // Directed lattice (Markov mesh).
    node((0, 0), [$X_1$], name: <d1>), node((1, 0), [$X_2$], name: <d2>),
    node((2, 0), [$X_3$], name: <d3>, radius: 13pt, stroke: blue.darken(10%) + 1pt),
    node((3, 0), [$X_4$], name: <d4>, radius: 13pt, stroke: orange.darken(10%) + 1pt),
    node((4, 0), [$X_5$], name: <d5>),
    node((0, 1), [$X_6$], name: <d6>),
    node((1, 1), [$X_7$], name: <d7>, radius: 13pt, stroke: blue.darken(10%) + 1pt),
    node((2, 1), [$X_8$], name: <d8>, radius: 13pt, stroke: (paint: red, thickness: 1pt, dash: "dotted")),
    node((3, 1), [$X_9$], name: <d9>, radius: 13pt, stroke: green.darken(15%) + 1pt),
    node((4, 1), [$X_10$], name: <d10>),
    node((0, 2), [$X_11$], name: <d11>),
    node((1, 2), [$X_12$], name: <d12>, radius: 13pt, stroke: orange.darken(10%) + 1pt),
    node((2, 2), [$X_13$], name: <d13>, radius: 13pt, stroke: green.darken(15%) + 1pt),
    node((3, 2), [$X_14$], name: <d14>), node((4, 2), [$X_15$], name: <d15>),
    node((0, 3), [$X_16$], name: <d16>), node((1, 3), [$X_17$], name: <d17>),
    node((2, 3), [$X_18$], name: <d18>), node((3, 3), [$X_19$], name: <d19>),
    node((4, 3), [$X_20$], name: <d20>),

    edge(<d1>, <d2>, "->"), edge(<d2>, <d3>, "->"), edge(<d3>, <d4>, "->"), edge(<d4>, <d5>, "->"),
    edge(<d6>, <d7>, "->"), edge(<d7>, <d8>, "->"), edge(<d8>, <d9>, "->"), edge(<d9>, <d10>, "->"),
    edge(<d11>, <d12>, "->"), edge(<d12>, <d13>, "->"), edge(<d13>, <d14>, "->"), edge(<d14>, <d15>, "->"),
    edge(<d16>, <d17>, "->"), edge(<d17>, <d18>, "->"), edge(<d18>, <d19>, "->"), edge(<d19>, <d20>, "->"),
    edge(<d1>, <d6>, "->"), edge(<d6>, <d11>, "->"), edge(<d11>, <d16>, "->"),
    edge(<d2>, <d7>, "->"), edge(<d7>, <d12>, "->"), edge(<d12>, <d17>, "->"),
    edge(<d3>, <d8>, "->"), edge(<d8>, <d13>, "->"), edge(<d13>, <d18>, "->"),
    edge(<d4>, <d9>, "->"), edge(<d9>, <d14>, "->"), edge(<d14>, <d19>, "->"),
    edge(<d5>, <d10>, "->"), edge(<d10>, <d15>, "->"), edge(<d15>, <d20>, "->"),

    // Undirected lattice.
    node((6.5, 0), [$X_1$], name: <u1>), node((7.5, 0), [$X_2$], name: <u2>),
    node((8.5, 0), [$X_3$], name: <u3>, radius: 13pt, stroke: blue.darken(10%) + 1pt),
    node((9.5, 0), [$X_4$], name: <u4>), node((10.5, 0), [$X_5$], name: <u5>),
    node((6.5, 1), [$X_6$], name: <u6>),
    node((7.5, 1), [$X_7$], name: <u7>, radius: 13pt, stroke: blue.darken(10%) + 1pt),
    node((8.5, 1), [$X_8$], name: <u8>, radius: 13pt, stroke: (paint: red, thickness: 1pt, dash: "dotted")),
    node((9.5, 1), [$X_9$], name: <u9>, radius: 13pt, stroke: blue.darken(10%) + 1pt),
    node((10.5, 1), [$X_10$], name: <u10>),
    node((6.5, 2), [$X_11$], name: <u11>), node((7.5, 2), [$X_12$], name: <u12>),
    node((8.5, 2), [$X_13$], name: <u13>, radius: 13pt, stroke: blue.darken(10%) + 1pt),
    node((9.5, 2), [$X_14$], name: <u14>), node((10.5, 2), [$X_15$], name: <u15>),
    node((6.5, 3), [$X_16$], name: <u16>), node((7.5, 3), [$X_17$], name: <u17>),
    node((8.5, 3), [$X_18$], name: <u18>), node((9.5, 3), [$X_19$], name: <u19>),
    node((10.5, 3), [$X_20$], name: <u20>),

    edge(<u1>, <u2>, "-"), edge(<u2>, <u3>, "-"), edge(<u3>, <u4>, "-"), edge(<u4>, <u5>, "-"),
    edge(<u6>, <u7>, "-"), edge(<u7>, <u8>, "-"), edge(<u8>, <u9>, "-"), edge(<u9>, <u10>, "-"),
    edge(<u11>, <u12>, "-"), edge(<u12>, <u13>, "-"), edge(<u13>, <u14>, "-"), edge(<u14>, <u15>, "-"),
    edge(<u16>, <u17>, "-"), edge(<u17>, <u18>, "-"), edge(<u18>, <u19>, "-"), edge(<u19>, <u20>, "-"),
    edge(<u1>, <u6>, "-"), edge(<u6>, <u11>, "-"), edge(<u11>, <u16>, "-"),
    edge(<u2>, <u7>, "-"), edge(<u7>, <u12>, "-"), edge(<u12>, <u17>, "-"),
    edge(<u3>, <u8>, "-"), edge(<u8>, <u13>, "-"), edge(<u13>, <u18>, "-"),
    edge(<u4>, <u9>, "-"), edge(<u9>, <u14>, "-"), edge(<u14>, <u19>, "-"),
    edge(<u5>, <u10>, "-"), edge(<u10>, <u15>, "-"), edge(<u15>, <u20>, "-"),

    node((2, 3.7), text(0.85em)[(a) directed lattice], stroke: none),
    node((8.5, 3.7), text(0.85em)[(b) undirected lattice], stroke: none),
  ),
)
]

== Representing the Joint Distribution
#sidenote(numbered: false)[Textbook: §4.3.1, pp. 165–166]

With no topological order there is no chain rule to invoke to allow application of the CI assumptions of the network. As long as the joint is _strictly positive_#sidenote()[Since hard zeros, which are just _deterministic_ constraints, can create independences not visible in the graph.], we can apply the Hammersley–Clifford theorem to write the joint, which states that we can associate a nonnegative *potential* (factor) $psi_c(x_c; theta_c)$ with each maximal clique#sidenote()[A clique is a set of nodes that are all neighbors of each other. A maximal clique is a clique which cannot be
made any larger without losing the clique property] $c$ in a set $cal(C)$, usually the maximal cliques. The joint is#sidenote()[We call $Z$ the *partition function*.The letter $Z$ is used from the German word #emph[Zustandssumme], meaning "sum over states". This reflects the fact that a lot of pioneering working on MRFs was done by German (and Austrian) physicists, such as
Boltzmann.]
$
  p(x mid(|) theta) = 1 / Z(theta) product_(c in cal(C)) psi_(c)(x_c; theta_c), quad
  Z(theta) = sum_x product_(c in cal(C)) psi_(c)(x_c; theta_c),
$

We can also write the distribution as
$
  p(x | theta) = 1 / Z(theta) exp(-cal(E)(x; theta))
$
Where $cal(E) > 0 $ is called the *energy* of the state x, defined over cliques $c$ as
$
  cal(E)(x; theta) = sum_c cal(E)(x_c).
$

We can see that _low energy_ is associated with _high probability_. This kind of distribution is called the *Gibbs distribution*, and this kind of model is called an *energy-based model*. This kind of model is very common in some domains such as physics and biochemistry, as well as in machine learning to define certain kinds of generative models which we will cover later in the course.

=== Simple Example

#figure(
  caption: [A pairwise MRF on a 4-cycle. Its maximal cliques are the four edges.],
  diagram(
    edge-stroke: 0.85pt,
    node-corner-radius: 8pt,
    node-stroke: 0.85pt,
    node((0, 0), [$X_1$], name: <x1>), node((1.4, 0), [$X_2$], name: <x2>),
    node((0, 1.2), [$X_3$], name: <x3>), node((1.4, 1.2), [$X_4$], name: <x4>),
    edge(<x1>, <x2>, "--"), edge(<x1>, <x3>, "--"),
    edge(<x2>, <x4>, "--"), edge(<x3>, <x4>, "--"),
  ),
)

For this graph one valid pairwise factorization is
$
  p(x_(1:4)) = 1 / Z thin psi_(12)(x_1, x_2) thin psi_(13)(x_1, x_3) thin psi_(24)(x_2, x_4) thin psi_(34)(x_3, x_4).
$

#discussion(vspace: 20em)[
  Consider a strictly positive $p(x_1, x_2, x_3)$ that satisfies exactly $X_1 tack.tt X_3 mid(|) X_2$ and no other CI statement.

  + Draw the minimal undirected graph. What are its maximal cliques?
  + By Hammersley–Clifford, write the most general factorization $p$ can take. How many free parameters if each variable is binary, and how does this compare with the unstructured joint?
  + Come up with a *non-positive* joint on three binary variables that obeys the graph separation statement $X_1 tack.tt X_3 mid(|) X_2$ but does *not* factorize as $psi_(12) psi_(23) \/ Z$. (Hint: _use a deterministic constraint._)
]

== Ising Models
#sidenote(numbered: false)[Textbook: §4.3.2, pp. 166–172]

In this section, we discuss some MRFs for 2d grids, that are used in statistical physics and computer vision. We then discuss extensions to other graph structures, which are useful for biological modeling and pattern completion.

Consider the 2d lattice introduced earlier. We can represent the joint distributions follows:
$
  p(x) = 1 / Z product_(i ~ j) psi_(i j)(x_i,x_j;theta)
$
Where $i~j$ represents $i$ and $j$ being neighbors in the graph. This is a 2d lattice model. An *Ising model* is a spacial case of a 2d lattice model where the variables $x_i$ are binary. This is frequently used in material science to represent atoms with spin as $x_i in \{-1, +1\}$. In some systems nearby atoms prefer to have matching spins, while in other systems nearby atoms prefer to have opposite spins. We can capture this with:
$
  psi_(i j)(x_i,x_j;theta) = cases(e^(J_(i j)) "if" x_i = x_j,e^(-J_(i j)) "if" x_i != x_j)
$
Where $J_(i j)$ is the _coupling strength_ between nodes $i$ and $j$. For all nodes not connected in the graph we set $J_(i j) =0$. Since our model is undirected, we assume the matrix is symmetric and $J_(i j) = J_(j i) $. Frequently we simplify by assigning all edges the same strength $J_(i j) = J$ for each nonzero edge. This reduces to
$
  psi_(i j)(x_i,x_j;theta) = cases(e^(J) "if" x_i = x_j,e^(-J) "if" x_i != x_j)
$
Most frequently an Ising model is defined as an energy based model where

$
  p(x) &= 1 / Z(J) exp( -cal(E)(x;J) ) \
  cal(E)(x) &= - J sum_(i~j) x_(i)x_(j)
$

where $cal(E)(x; J)$ is the energy, and where we exploited the fact that $x_(i)x_(j)=−1$ if $x_i!= x_j$, and $x_i x_j = +1$
if $x_i = x_j$. The magnitude of $J$ controls the degree of coupling strength between neighboring sites. We can scale the coupling coefficient $J$ by a temperature term $T$ to get $J′= J/T$, so colder means more tightly coupled (larger $J$), and hotter means less tightly coupled (smaller $J$).

If all of the weights are negative, $J <0$, then the spins want to be different from their neighbors. This is called an _antiferromagnetic_ system, and results in a frustrated system, since it is not possible for all neighbors to be different from each other in a 2d lattice (resulting in a checkerboard on an infinite lattice).

If all the edge weights are positive,$ J > 0$, then neighboring spins are likely to be in the same
state, since if $x_i = x_j$, the energy term gets a contribution of$−J <0$, and lower energy corresponds to higher probability. In the machine learning literature, this is called an associative Markov network. In the physics literature, this is called a _ferromagnetic_ model.

If $J = 1$, the corresponding probability distribution will have two modes, corresponding to the all +1 state and the all -1 state. These are called the ground states of the system.

#wideblock()[
#figure(image("Figures/textbook-ising.png",width:85%),
  caption: [Samples from an associative Ising model with varying J > 0. From textbook figure 4.17])
]

This model can be extended in a wide range of ways, such as adding _unary terms_ in addition to pairwise terms, which in physics would be called an external field, or by extending the variables from binary to larger dimensional categorical variables, which is called a _Potts model_, which is also used in a huge range of scientific applications such as protein structure prediction.

=== Hopfield Networks
One particularly special kind of Ising model is the _Hopfield Network_. A Hopfield network is a _fully connected_ Ising model with symmetric weights $W = W^T$. Its energy function has the form (where $x in {-1,+1}$)
$
  cal(E)(x) = -1/2 x^T W x
$

Hopfield networks are mainly used for the problem of _associative memory_. The problem goes as follows: suppose we train on a set of fully observed bit vectors, corresponding to patterns we want to memorize. Then, at test time, we present a _partial_ pattern to the network. We would like to estimate the missing variables; this is called _pattern completion_, by calculating
$
  limits("argmin")_(x) #h(0.25em) cal(E)(x)
$
We can solve this optimization problem using _iterative conditional modes_ (ICM), in which we variable to its most likely state given its neighbors, which amounts to applying the iterative update:
$
  x_(t+1) = "sign"(W x_t)
$


#figure(
  caption: [Left: an Ising / Potts model on a 2d lattice (pairwise edges only). Right: a Hopfield network is the fully connected case.],
  diagram(
    edge-stroke: 0.8pt,
    node-corner-radius: 6pt,
    node-stroke: 0.8pt,
    node((0,0), [$x_1$], name: <a>), node((1,0), [$x_2$], name: <b>), node((2,0), [$x_3$], name: <c>),
    node((0,1), [$x_4$], name: <d>), node((1,1), [$x_5$], name: <e>), node((2,1), [$x_6$], name: <f>),
    edge(<a>,<b>,"--"), edge(<b>,<c>,"--"), edge(<d>,<e>,"--"), edge(<e>,<f>,"--"),
    edge(<a>,<d>,"--"), edge(<b>,<e>,"--"), edge(<c>,<f>,"--"),
    node((4.2,0.5), [$x_1$], name: <h1>), node((5.4,0.0), [$x_2$], name: <h2>),
    node((5.9,1.0), [$x_3$], name: <h3>), node((4.6,1.4), [$x_4$], name: <h4>),
    edge(<h1>,<h2>,"--"), edge(<h1>,<h3>,"--"), edge(<h1>,<h4>,"--"),
    edge(<h2>,<h3>,"--"), edge(<h2>,<h4>,"--"), edge(<h3>,<h4>,"--"),
  ),
)

== Boltzmann Machines
#sidenote(numbered: false)[Textbook: §4.3.3, pp. 172–174]

While MRFs where every variable is visible are useful, in this class we are generally more interested in learning _latent representations_ that can represent high dimensional joint distributions in discrete space. One kind of such model is a *Boltzmann machine*, which is an Ising-type energy model with states in $\{0, 1\}$ as opposed to ${-1,+1}$, an arbitrary graph as opposed to a lattice, and the nodes partitioned into visible $arrow(v)$ and hidden $arrow(h)$.

However, in this general case inference is intractable, and even approximate inference methods can be very non-performant. Because of this we generally add in the restriction to the graph structure that it must be _bipartite between visible and hidden nodes_, that is there are no internal edges between either hidden or visible nodes, only connected from hidden to visible. This, appropriately, is called a *restricted Boltzmann machine (RBM)*#sidenote()[Also sometimes called a *harmonium*]. This structure makes approximate inference efficient by making the hidden nodes all conditionally independent given the visible nodes#sidenote()[Note this is in contrast to a directed two-layer models, where the explaining away effect causes the latent variables to become “entangled” in the posterior even if they are independent in the prior.] (and vice versa). That is we can factorize as such

$
  p(arrow(z)|arrow(x)) = product_k p(z_k | arrow(x)) #h(2em)"and" #h(2em)
  p(arrow(x)|arrow(z)) = product_d p(x_d | arrow(z))

$

Typically, the hidden and visible nodes in an RBM are binary#sidenote()[However variations of RBMs for Gaussian or Categorical variables in either the hidden or visible layers have been defined as well], so the energy terms have the form
$w_(d k) x_(d) z_(k)$. If $z_k = 1$, then the $k^"th"$ hidden unit adds a term of the form $w^(top)_(k) x$ to the energy. This can be thought of as a “soft constraint”. If $z_k = 0$, the hidden unit is not active. By turning on different combinations of constraints, we can create complex distributions on the visible data. This is an example of a _product of experts_ since we have a factorization of the form
$
  p(arrow(x)|arrow(z)) prop product_{k | z_k =1} exp(w^(top)_(k) arrow(x))
$

Which can be thought of as a very large mixture model with an _exponential_ number of hidden components, corresponding to the $2^H$ settings of $arrow(z)$. That is $arrow(z)$ is a _distributed representation_, where a standard mixture model uses a _local representation_ of $z in {1,..,K}$, and each value corresponds to a complete prototype or exemplar of $arrow(x)$, $arrow(w)_k$, with a model of the form $
  p(arrow(x)|z = k) prop exp(w^(top)_(k) arrow(x))
$

#discussion()[
  Notice how the models of a _local representation_ and a _distributed representation_ look very similar. Explain, in plain language, what is different between the two kinds of model, and which parts of the equations for the generative distributions correspond to those differences.
]

#figure(
  caption: [Left: Example of a general Boltzmann machine with arbitrary structure. Right: Example of a restricted Boltzmann machine with a bipartite structure and no intra-layer edges. After textbook Figure 4.20.],
  diagram(
    edge-stroke: 0.8pt,
    node-corner-radius: 6pt,
    node-stroke: 0.8pt,

    node((0,0), [$h_1$], name: <g1>), node((0.75,0.75), [$h_2$], name: <g2>),node((1.5,0), [$h_3$], name: <g3>),
    node((0,1.5), [$v_1$], name: <gv1>, fill: luma(85%)), node((1.5,1.5), [$v_2$], name: <gv2>, fill: luma(85%)),
    edge(<g1>,<g2>,"--"),edge(<g1>,<g3>,"--"),edge(<g2>,<g3>,"--"), edge(<gv1>,<gv2>,"--"),
    edge(<g1>,<gv1>,"--"), edge(<g3>,<gv2>,"--"), edge(<g2>,<gv1>,"--"), edge(<g2>,<gv2>,"--"),
    node((3,0), [$h_1$], name: <r1>), node((4,0), [$h_2$], name: <r2>), node((5,0), [$h_3$], name: <r3>),
    node((3,1.5), [$v_1$], name: <rv1>, fill: luma(85%)), node((4,1.5), [$v_2$], name: <rv2>, fill: luma(85%)), node((5,1.5), [$v_3$], name: <rv3>, fill: luma(85%)),
    edge(<r1>,<rv1>,"--"), edge(<r1>,<rv2>,"--"),
    edge(<r2>,<rv1>,"--"), edge(<r2>,<rv2>,"--"), edge(<r2>,<rv3>,"--"),
    edge(<r3>,<rv2>,"--"), edge(<r3>,<rv3>,"--"),
  ),
)

== Deep Belief Nets
While the layer restriction is what allows RBMs to be tractable, we can slightly loosen the restriction and maintain many of the properties by building networks with non-intra-connecting layers, but instead of only one hidden layer, we can "stack" multiple layers. We call this a *deep Boltzmann machine*. For instance, a two layer model would have the basic form
$
  p(x,z_1,z_2 | theta) = 1/(Z(W_1 W_2)) exp(x^(top)W_(1)z_(1) + z_1^(top)W_(2)z_(2))
$

One important use of a deep Boltzmann machines are in *deep belief networks (DBN)* #sidenote()[This is another example of a confusing name, since a belief network is a _different thing_ and a DBN is not actually a belief network. Thus sometimes you may see these called Deep Boltzmann Networks to clarify but keep the acronym.], which use a deep RBM as a prior over a latent distributed code, and then use a directed model "decoder" to convert this to the observed data, giving the joint the form (for a two layer example as above)
$
  p(x,z_1,z_2 | theta) = p(x|z_1, W_1) 1/Z(W_2) exp(z_1^(top)W_(2)z_(2))
$

DBNs are historically important models, since they can be trained fairly easily and support efficient inference, and were one of the first deep learning models to be successfully trained. They no longer as frequently used due to developments improving ways to train fully supervised neural networks on the one hand, and more relevantly for us more efficient ways to train deep Bayes Nets such as the VAE.


== Conditional Independence in MRFs
#sidenote(numbered: false)[Textbook: §4.3.6, pp. 179–181]

Just as we had to determine the CI assumptions in a Bayes Net in order to construct an appropriate model, similarly we need to understand how MRFs encode CI assumptions. Luckily this algorithm is somewhat simpler than d-separation, defined

#def(term:[Global Markov Property for MRFs])[
  Given three sets of nodes $A, B, C$ in an undirected graphical model $G$.

  We say that $X_A tack.tt X_B | X_C$ iff $C$ separates $A$ from $B$ in the graph $G$. #sidenote(dy:-5em)[
    One interesting property this gives is that, unlike in a directed model, observing a node in an undirected model is _never_ path-opening: undirected CI is _monotonic_ ($A tack.tt B mid(|) C$ implies $A tack.tt B mid(|) (C union D)$).
  ]
]


#discussion(vspace:0em)[
Using the global Markov property, what is the _Markov Blanket_ of a node in a MRF. If you are having trouble, draw some small example graphs and try to apply the property. This result is called the *undirected local Markov property*.
]




From the local Markov property, we can easily show that two nodes are conditionally independent given the rest of the network iff there is no direct edge between them. This is called the *pairwise Markov property*. While it is easy to show how the global property implies the local property, and how the local property implies the pairwise property, it is less clear but true that the pairwise property in turn implies the global property#sidenote(dy:-12em)[With the only provision of requiring strict positive distributions, $p(x)>0$, which is not an onerous or unusual requirement.]. _This means that all three properties are in fact exactly equivalent!_ This helps us since the pairwise property is generally much easier to reason about and empirically asses, and so we can use these properties to construct a model on which the wider class of global attributes are ensured to hold.


#sidenote(numbered:false,dy:-10em)[#discussion(vspace: 0em)[
  Why can we not just simply remove the arrows in a DPGM to convert to an undirected model? Construct a simple example where doing so results in incompatible CI properties.
]]

#sidenote(numbered:false)[
#figure(
  caption: [Directed PGM and its moralized representation.  After textbook Figure 4.23.],
  diagram(
    edge-stroke: 0.8pt,
    node-corner-radius: 6pt,
    node-stroke: 0.8pt,
    spacing:25pt,

    node((0,0), [$A$], name: <da>),
    node((-0.5,1), [$B$], name: <db>),
    node((0.5,1), [$C$], name: <dc>),
    node((0,2), [$D$], name: <dd>),
    node((0.5,3), [$E$], name: <de>),
    node((-0.5,3), [$F$], name: <df>),
    node((0,4), [$G$], name: <dg>),
    edge(<da>,<db>,"->"),
    edge(<da>,<dc>,"->"),
    edge(<db>,<dd>,"->"),
    edge(<dc>,<dd>,"->"),
    edge(<db>,<df>,"->"),
    edge(<dc>,<de>,"->"),
    edge(<dd>,<dg>,"->"),
    edge(<dd>,<de>,"->"),
    edge(<df>,<dg>,"->"),
    edge(<de>,<dg>,"->"),

    node((1.75,0), [$A$], name: <ua>),
    node((1.25,1), [$B$], name: <ub>),
    node((2.25,1), [$C$], name: <uc>),
    node((1.75,2), [$D$], name: <ud>),
    node((2.25,3), [$E$], name: <ue>),
    node((1.25,3), [$F$], name: <uf>),
    node((1.75,4), [$G$], name: <ug>),
    edge(<ua>,<ub>,"--"),
    edge(<ua>,<uc>,"--"),
    edge(<ub>,<ud>,"--"),
    edge(<uc>,<ud>,"--"),
    edge(<ub>,<uf>,"--"),
    edge(<uc>,<ue>,"--"),
    edge(<ud>,<ug>,"--"),
    edge(<ud>,<ue>,"--"),
    edge(<uf>,<ug>,"--"),
    edge(<ue>,<ug>,"--"),

    edge(<ub>,<uc>,"--"),
    edge(<uf>,<ue>,"--"),
    edge(<ud>,<uf>,"--"),
  ),
)
]

Since CI seems to be much easier to work with in undirected models, an alternative to d-separation is to convert a DPGM to an equivalent (with respect to CI) UPGM, and query independence on the UPGM. The conversion process is called *moralization*, and requires us to add edges between all "unmarried parents", that is all parents of a node must be connected, after which we can remove all directions and produce the new undirected graph. Unfortunately, some information is still lost by moralization. While there are no independences implied in the moralized network that are not present in the directed network, the converse is not true as there are some conditional independences present in the directed graph that are not present in the moralized graph.

If we want to be more precise we have to construct different undirected graphs depending on the CI query $A tack.tt B | C$. To do this we have to construct the _ancestral graph_ of $G$ with respect to $U = A union B union C$, which removes all nodes from $G$ that are not either in $U$ or are not ancestors of $U$. We can then moralize the ancestral graph and use the resulting undirected graph to query CI properties which will be equivalent between the original directed graph and the undirected moralized ancestral graph.



== Sampling, Inference, and Learning
#sidenote(numbered: false)[Textbook: §§4.3.7–4.3.9, pp. 181–186]

=== Sampling and Inference
Because UPGMs have no topological order, sampling directly and performing inference can be more difficult and slow. Additionally, we cannot calculate the probability of any configuration without the value of $Z$. Therefore approximation methods such as MCMC or mean field variational inference are used.

=== Learning Parameters
Since computing the likelihood of an MRF is itself very difficult due to the need to deal with the partition function $Z$, when adding the difficulty in computing the full posterior over parameters, $p(theta|cal(D))$, learning in MRFs is sometimes called *doubly intractable*. As a result we generally limit analysis to point estimation methods such as MLE and MAP optimized using gradient methods.

This presents the primary computational cost in learning MRFs, computing the derivative of the (log) partition function which is used to compute the derivative of the log likelihood. We can see why this is difficult #sidenote(dy:-15em)[This utilizes the _log-derivative trick_ based on the fact that
  #math.equation(block: true, numbering: none)[
    $nabla_theta log(p(x;theta)) = 1/(p(x;theta)) nabla_theta p(x;theta)$
  ]
]

$
  nabla_theta log(Z(theta)) &= (nabla_theta Z(theta))/(Z(theta))\
  &= 1/(Z(theta)) nabla_theta integral p(x;theta) d x\
  &= 1/(Z(theta))  integral nabla_theta p(x;theta) d x\
  &= 1/(Z(theta))  integral p(x;theta) nabla_theta log(p(x;theta)) d x \
  &= integral p(x;theta)/(Z(theta)) nabla_theta log(p(x;theta)) d x\
  &= EE_(x~p(x;theta))[nabla_theta log(p(x;theta))]
$

All this is to show that _we need to draw samples from the model at each gradient calculation / training step!_ Since sampling from the model is itself hard for MRFs, often needing its own approximation or optimization process, this poses a substantial issue. Because of this issue there have been devised various efficient sampling methods, as well as alternative estimators that do not use the principle of maximum likelihood.

=== Maximum Pseudolikelihood Estimation

When fitting MRFs, one common alternative to maximizing likelihood is to maximize _pseudoliklihood_. Which is to optimize the product of the full conditionals. #sidenote()[
  Pseudoliklihood can be much faster than full MLE, and is equivalent for Gaussian MRFs (although this is not true in general). Empirically, pseudolikelihood has been shown to work well for Ising models, but performs worse than stochastic approximations on RBMs.
]
$
  cal(l)_(P L)(theta) = 1/N sum_(n=1)^(N) sum_(d=1)^(D) log(p(x_(n d) | {x_(n d') | d' != d}, theta ))
$



#sidenote(numbered:false,dy:-50em)[
#figure(
  caption: [Example MRF (above) and Implicit representation used by pseudolikelihood (below).  After textbook Figure 4.28 .],
  diagram(
    edge-stroke: 0.5pt,
    node-corner-radius: 6pt,
    node-stroke: 0.8pt,
    spacing:20pt,
    node-inset:3pt,

    node((0,0),[$A$], name: <mrf-a>),
    node((2.5,0),[$B$], name: <mrf-b>),
    node((5,0),[$C$], name: <mrf-c>),
    node((0,2.5),[$D$], name: <mrf-d>),
    node((2.5,2.5),[$E$], name: <mrf-e>),
    node((5,2.5),[$F$], name: <mrf-f>),
    node((0,5),[$G$], name: <mrf-g>),
    node((2.5,5),[$H$], name: <mrf-h>),
    node((5,5),[$I$], name: <mrf-i>),

    edge(<mrf-a>,<mrf-b>,"--"),
    edge(<mrf-b>,<mrf-c>,"--"),
    edge(<mrf-d>,<mrf-e>,"--"),
    edge(<mrf-e>,<mrf-f>,"--"),
    edge(<mrf-g>,<mrf-h>,"--"),
    edge(<mrf-h>,<mrf-i>,"--"),
    edge(<mrf-a>,<mrf-d>,"--"),
    edge(<mrf-b>,<mrf-e>,"--"),
    edge(<mrf-c>,<mrf-f>,"--"),
    edge(<mrf-d>,<mrf-g>,"--"),
    edge(<mrf-e>,<mrf-h>,"--"),
    edge(<mrf-f>,<mrf-i>,"--"),



    node((0,7),[$A$], name: <pl-a>),
    node((2.5,7),[$B$], name: <pl-b>),
    node((5,7),[$C$], name: <pl-c>),
    node((0,9.5),[$D$], name: <pl-d>),
    node((2.5,9.5),[$E$], name: <pl-e>),
    node((5,9.5),[$F$], name: <pl-f>),
    node((0,12),[$G$], name: <pl-g>),
    node((2.5,12),[$H$], name: <pl-h>),
    node((5,12),[$I$], name: <pl-i>),

    edge(<pl-a>,"d","--@"),
    edge(<pl-a>,"r","--@"),

    edge(<pl-b>,"d","--@"),
    edge(<pl-b>,"r","--@"),
    edge(<pl-b>,"l","--@"),

    edge(<pl-c>,"d","--@"),
    edge(<pl-c>,"l","--@"),

    edge(<pl-d>,"u","--@"),
    edge(<pl-d>,"d","--@"),
    edge(<pl-d>,"r","--@"),

    edge(<pl-e>,"u","--@"),
    edge(<pl-e>,"d","--@"),
    edge(<pl-e>,"r","--@"),
    edge(<pl-e>,"l","--@"),

    edge(<pl-f>,"u","--@"),
    edge(<pl-f>,"d","--@"),
    edge(<pl-f>,"l","--@"),

    edge(<pl-g>,"u","--@"),
    edge(<pl-g>,"r","--@"),

    edge(<pl-h>,"u","--@"),
    edge(<pl-h>,"r","--@"),
    edge(<pl-h>,"l","--@"),

    edge(<pl-i>,"u","--@"),
    edge(<pl-i>,"l","--@"),


  ),
)
]



= Conditional random fields
#sidenote(numbered: false)[Textbook: §4.4, pp. 186–194]

A *conditional random field* (CRF) is model over structured outputs $bold(y)$ conditioned on inputs $bold(x)$: #sidenote()[Note how the partition function how _depends on the inputs_ $x$ as well as the parameters $theta$]
$
  p(y mid(|) x, theta) = 1 / Z(x, theta) product_c psi_(c)(y_c; x, theta).
$
CRFs are useful because they capture dependencies between outputs, which allows us to perform _structured prediction_, where the output $y in cal(Y)$ we want to predict given an input $x$ exists in a structured space with constraints on valid values of $y$. For example in NLP if we want to parse the grammar of a sentence we require the labels adhere to the rules of the grammar. Additionally constraints can be "soft" such as for image segmentation where we might want to prefer pixels to be classified similarly to their neighbors unless we have a sufficient signal to identify a boundary.

== One-dimensional CRFs
#sidenote(numbered: false,dy:-10em)[Textbook: §4.4.1, pp. 187–190]

#sidenote(numbered:false,dy:-10em)[
#figure(
  caption: [1D CRF Example. After textbook Figure 4.29],
  diagram(
    edge-stroke: 0.8pt,
    node-corner-radius: 8pt,
    node-stroke: 0.8pt,

    node((0,0),[$y_(1)$], name: <y1>),
    node((1,0),[$y_(2)$], name: <y2>),
    node((2,0),[$y_(3)$], name: <y3>),

    node((0,1),[$x_(1)$], name: <x1>,fill:luma(80%)),
    node((1,1),[$x_(2)$], name: <x2>,fill:luma(80%)),
    node((2,1),[$x_(3)$], name: <x3>,fill:luma(80%)),

    edge(<y1>,<y2>,"--"),
    edge(<y3>,<y2>,"--"),
    edge(<y1>,<x1>,"--"),
    edge(<y2>,<x2>,"--"),
    edge(<y3>,<x3>,"--"),
  ),
)
]
#v(-2em)
One of the simplest kinds of structures that are frequently found in structured prediction are one-dimensional sequences, which we can define the CRF #sidenote()[This uses $psi(y_t, x_t; theta)$ to represent the _node potentials_ which are the edges linking $x$ and $y$ at a time $t$, and uses $psi(y_(t-1), y_t; theta)$ to represent the _edge potentials_ which correspond to the edges linking $y$ values at subsequent times. This factorization assumes the independence of the edge potentials from the actual values of $x$, but this assumption is strictly not required.]
$
  p(y_(1:T) mid(|) bold(x)) = 1 / Z(x, theta) product_(t=1)^T psi(y_t, x_t; theta) product_(t=2)^T psi(y_(t-1), y_t; theta)
$

One could consider a directed alternative model which factorizes based on the past history of conditional distributions $p(y_t | y_(t-1), x_t; theta)$ #sidenote()[#discussion(vspace: 0em)[Consider how this is _different_ than a Hidden Markov Model? Draw MEMM and HMM equivalents to the CRF example above to see.]].

This is called a _maximum entropy Markov model_ (MEMM). However, relative to a CRF, there is a subtle difference where a MEMM is _locally normalized_ for each conditional, while a CRF is _globally normalized_ thanks to $Z(x,theta)$. This allows information in a CRF to propagate through the entire sequence which helps enable more complex structures to be learned.

The most widely used area of application for one-dimensional CRFs historically has been natural language processing. Even now, when transformer based pure deep learning approaches dominate, there are many scenarios where we can combine methods to utilize the flexibility of purely data-driven approaches, with knowledge about the true constraints on the output space.


#wideblock()[
  #figure(
    caption: [CRF for joint part of speech (POS) tagging and noun phrase (NP) segmentation. B: Begin NP, I: Within NP, O: Not in NP. N: Noun, ADJ: Adjective, V: Verb, IN: Preposition, DT: Determiner. After textbook Figure 4.30.],
    diagram(
      edge-stroke: 0.8pt,
      node-corner-radius: 8pt,
      node-stroke: 0.8pt,
      spacing:12pt,
      node-inset:5pt,

      node((0, 0.), [B], name: <np1>,),
      node((1, 0.), [I], name: <np2>,),
      node((2, 0.), [O], name: <np3>,),
      node((3, 0.), [B], name: <np4>,),
      node((4, 0.), [I], name: <np5>,),
      node((5, 0.), [I], name: <np6>,),
      node((6, 0.), [O], name: <np7>,),
      node((7, 0.), [B], name: <np8>,),
      node((8, 0.), [I], name: <np9>,),

      node((0, 1.), [ADJ], name: <p1>,),
      node((1, 1.), [N], name: <p2>,),
      node((2, 1.), [V], name: <p3>,),
      node((3, 1.), [DT], name: <p4>,),
      node((4, 1.), [ADJ], name: <p5>,),
      node((5, 1.), [N], name: <p6>,),
      node((6, 1.), [IN], name: <p7>,),
      node((7, 1.), [ADJ], name: <p8>,),
      node((8, 1.), [N], name: <p9>,),

      node((0, 2.),"", name: <x1>,fill:luma(80%)),
      node((1, 2.),"", name: <x2>,fill:luma(80%)),
      node((2, 2.),"", name: <x3>,fill:luma(80%)),
      node((3, 2.),"", name: <x4>,fill:luma(80%)),
      node((4, 2.),"", name: <x5>,fill:luma(80%)),
      node((5, 2.),"", name: <x6>,fill:luma(80%)),
      node((6, 2.),"", name: <x7>,fill:luma(80%)),
      node((7, 2.),"", name: <x8>,fill:luma(80%)),
      node((8, 2.),"", name: <x9>,fill:luma(80%)),

      node((0, 2.75), [American], name: <s1>,stroke:none),
      node((1, 2.75), [Airlines], name: <s2>,stroke:none),
      node((2, 2.75), [announced], name: <s3>,stroke:none),
      node((3, 2.75), [a], name: <s4>,stroke:none),
      node((4, 2.75), [new], name: <s5>,stroke:none),
      node((5, 2.75), [flight], name: <s6>,stroke:none),
      node((6, 2.75), [from], name: <s7>,stroke:none),
      node((7, 2.75), [SBP], name: <s8>,stroke:none),
      node((8, 2.75), [airport.], name: <s9>,stroke:none),

      node((8.75, 0), [NP],stroke:none),
      node((8.75, 1), [POS],stroke:none),

      edge(<x1>, <p1>,"--"),
      edge(<x1>,<np1>,"--",bend:60deg),
      edge(<p1>,<np1>,"--"),

      edge(<x2>, <p2>,"--"),
      edge(<x2>,<np2>,"--",bend:60deg),
      edge(<p2>,<np2>,"--"),

      edge(<x3>, <p3>,"--"),
      edge(<x3>,<np3>,"--",bend:60deg),
      edge(<p3>,<np3>,"--"),

      edge(<x4>, <p4>,"--"),
      edge(<x4>,<np4>,"--",bend:60deg),
      edge(<p4>,<np4>,"--"),

      edge(<x5>, <p5>,"--"),
      edge(<x5>,<np5>,"--",bend:60deg),
      edge(<p5>,<np5>,"--"),

      edge(<x6>, <p6>,"--"),
      edge(<x6>,<np6>,"--",bend:60deg),
      edge(<p6>,<np6>,"--"),

      edge(<x7>, <p7>,"--"),
      edge(<x7>,<np7>,"--",bend:60deg),
      edge(<p7>,<np7>,"--"),

      edge(<x8>, <p8>,"--"),
      edge(<x8>,<np8>,"--",bend:60deg),
      edge(<p8>,<np8>,"--"),

      edge(<x9>, <p9>,"--"),
      edge(<x9>,<np9>,"--",bend:60deg),
      edge(<p9>,<np9>,"--"),

      edge( <p1>, <p2>,"--"),
      edge(<np1>,<np2>,"--"),

      edge( <p2>, <p3>,"--"),
      edge(<np2>,<np3>,"--"),

      edge( <p3>, <p4>,"--"),
      edge(<np3>,<np4>,"--"),

      edge( <p4>, <p5>,"--"),
      edge(<np4>,<np5>,"--"),

      edge( <p5>, <p6>,"--"),
      edge(<np5>,<np6>,"--"),

      edge( <p6>, <p7>,"--"),
      edge(<np6>,<np7>,"--"),

      edge( <p7>, <p8>,"--"),
      edge(<np7>,<np8>,"--"),

      edge( <p8>, <p9>,"--"),
      edge(<np8>,<np9>,"--"),

    ),
  )
]



== Two-dimensional CRFs
#sidenote(numbered: false)[Textbook: §4.4.2, pp. 190–193]

As you might expect, in addition to one-dimensional sequence problems, the other most frequent use case for CRFs is in the other core pillar of applied ML domains, computer vision and thus two-dimensional image lattice data.  #sidenote()[However, do not mistake this as being all that these models can be used for. There exist a wide range of structures beyond images and language both in the lattice style and other configurations for which a CRF may be a useful model to ensure structure to predictions.]

We can write out the conditional model in this case
$
  p(y|x) = 1/Z(x) [sum_(i!=j) psi_(i j)(y_i,y_j)] product_i p(y_i | x_i)
$

Where we can either model a lattice of connecting neighboring nodes, or a _fully connected CRF_ where every node is connected to every other node. This is often done when chaining models such as in image segmentation, where a convolutional neural network may take an input image and produce a score map at a coarse resolution of expected classes, which can then be interpolated to the full resolution and then passed through a fully connected CRF in order to increase the sharpness of the approximate segment boundaries.

Another interesting application of CRFs is in modeling _deformable parts_, that is in contexts such as object detection where instead of modeling the often too large space of complex objects, we can more easily model and detect more simple parts of the objects, and then add in constraints relating to the different ways those parts can be configured together.

#sidenote(numbered:false,dy:-20em)[
#figure(
  caption: [Visualization of deformable parts model for a human pose. Each part corresponds to a node in the CRF whose state space is the location of the part. The edges then represent pairwise spatial constaints (like springs), although note that because a CRF is a conditional model the "spring strength" can be input dependent. Local evidence nodes are omitted. After textbook Figure 4.35],
  diagram(
    edge-stroke: 0.8pt,
    node-corner-radius: 10pt,
    node-stroke: 0.8pt,

    node(enclose: ((-0.25,-0.25), (0.25,0.25)), name: <head>),
    node(enclose: ((-1,1.25), (1,3)), name: <body>),

    node(enclose: ((-2.5,1.25), (-1.75,1.5)), name: <left-bicep>),
    node(enclose: ((2.5,1.25), (1.75,1.5)), name: <right-bicep>),

    node(enclose: ((-2.75,-0.25), (-2.5,0.5)), name: <left-forearm>),
    node(enclose: ((2.75,-0.25), (2.5,0.5)), name: <right-forearm>),


    node(enclose: ((-1,3.75), (-0.5,5)), name: <left-ham>),
    node(enclose: ((1,3.75), (0.5,5)), name: <right-ham>),

    node(enclose: ((-1,5.75), (-0.5,7)), name: <left-shin>),
    node(enclose: ((1,5.75), (0.5,7)), name: <right-shin>),

    edge(<head>,<body>,"wave"),
    edge(<body>,<left-bicep.east>,"wave"),
    edge(<body>,<right-bicep.west>,"wave"),
    edge(<right-forearm.south>,<right-bicep.east>,"wave",bend:50deg),
    edge(<left-forearm.south>,<left-bicep.west>,"wave",bend:-50deg),
    edge(<body>,<left-ham>,"wave"),
    edge(<body>,<right-ham>,"wave"),
    edge(<left-shin>,<left-ham>,"wave"),
    edge(<right-shin>,<right-ham>,"wave"),
  ),
)
]

== Parameter estimation
#sidenote(numbered: false)[Textbook: §§4.4.3–4.4.4, pp. 193–194]

In the general case a CRF can be written as follows
$
  p(y | x; theta) = exp(f(x,y;theta))/Z(x;theta) = exp(f(x,y;theta))/(sum_(y')exp(f(x,y;theta)))
$

Where $f(x,y;theta)$ is a scoring or negative energy function, with high values corresponding to more probable configurations.
We can then take the gradient of the log likelihood when optimizing to learn parameters
$
  nabla_theta cal(l)(theta) = 1/N sum_(n=1)^N nabla_theta f(x_n,y_n;theta) - nabla_theta log(Z(x_n;theta))
$

As long as we can compute the corresponding expectations, this becomes tractable with the additional provision that since the partition function is dependent on the data value it is slower than in the MRF case.

#pagebreak()
= Comparing directed and undirected PGMs
#sidenote(numbered: false)[Textbook: §4.5, pp. 194–202]

We have so far introduced two different languages for expressing probabilistic models. We have already started to see some scenarios where one of these languages may be more natural, but now let us try to formalize some of the differences.

== Independence and factorization

#sidenote(numbered:false)[
  #figure(
    caption: [DPGMs and UPGMs can perfectly represent different sets of distributions. Some distributions can be perfectly represented by either DPGMs or UPGMs; the corresponding graph must be chordal. After textbook Figure 4.36],
    diagram(
      edge-stroke: 0.8pt,
      node-corner-radius: 10pt,
      node-stroke: 0.8pt,
      spacing: (10pt,30pt),

      node(enclose: ((0,0), (4,4)),align(top,[Probabilistic Models])),
      node(enclose: ((0.5,1), (3.5,3.5)),align(top,[Graphical Models])),

      node(enclose: ((1,2), (2.5,2.75)),align(top,[Directed])),

      node(enclose: ((1.5,2.5), (3.25,3.25)),align(bottom,[Undirected])),

      node((2,2.625),[Chordal],stroke:none),


  ))
]

The primary information encoded in any PGM is the set of CI assumptions asserted by the model. Thus we say a PGM is an *$I$-map* of a joint distribution $p$ if the set of all independences asserted by the PGM $I(G)$ is a _subset_ of the independences that are true of the model, that is $I(G) subset.eq I(p)$. However what is even stronger is if the graphical model can represent _all_ (and only) the CI properties of the distribution. Such a PGM would be a *perfect map*, where $I(G) = I(p)$.

It turns out that DPGMs and UPGMs can be perfect maps to intersecting but non-identical sets of distributions. This means that, strictly speaking, neither is more powerful than the other as a representation language.

For example, consider a simple DPGM with only three nodes $X, Y, Z$ in the form of a common effect triple. This model encodes the CI assumptions $\{X tack.tt Y, thin X cancel(tack.tt) Y mid(|) Z\}$, _which no MRF can capture_, because undirected CI is monotonic. Similarly, a chordless cycle of length $gt.eq 4$ has no DAG perfect map; any DAG I-map must add chords and thereby drop some independences.

#wideblock()[
  #discussion(vspace:0em)[
    Show why the following PGMs cannot be translated between directed and undirected representations, both in the specific example attempts shown (produce a counter-example CI disagreement for each), as well as in general (sketch a proof). Finally, produce a graph that _can_ be equivalently represented as both directed and undirected. What is special about this graph?
  ]
  #figure(
    caption: [ A common effect DPGM and MRFs which fail to represent the same independences.
],
    diagram(
      edge-stroke: 0.8pt,
      node-corner-radius: 10pt,
      node-stroke: 0.8pt,
      spacing:15pt,


      node((0,0), [$A$], name: <a1>),
      node((2,0), [$B$], name: <b1>),
      node((1,1), [$C$], name: <c1>),

      edge(<a1>,<c1>,"->"),
      edge(<b1>,<c1>,"->"),

      node((5,0), [$A$], name: <a2>),
      node((7,0), [$B$], name: <b2>),
      node((6,1), [$C$], name: <c2>),

      edge(<a2>,<c2>,"--"),
      edge(<b2>,<c2>,"--"),

      node((10,0), [$A$], name: <a3>),
      node((12,0), [$B$], name: <b3>),
      node((11,1), [$C$], name: <c3>),

      edge(<a3>,<c3>,"--"),
      edge(<b3>,<c3>,"--"),
      edge(<b3>,<a3>,"--"),

    ),
  )

#figure(
  caption: [A MRF and DPGMs which fail to represent the same independences. After textbook Figure 4.37.],
  diagram(
    edge-stroke: 0.8pt,
    node-corner-radius: 10pt,
    node-stroke: 0.8pt,
    spacing:15pt,


    node((1,0), [$A$], name: <a1>),
    node((0,1), [$B$], name: <b1>),
    node((2,1), [$C$], name: <c1>),
    node((1,2), [$D$], name: <d1>),

    edge(<a1>,<b1>,"--"),
    edge(<a1>,<c1>,"--"),
    edge(<b1>,<d1>,"--"),
    edge(<c1>,<d1>,"--"),

    node((6,0), [$A$], name: <a2>),
    node((5,1), [$B$], name: <b2>),
    node((7,1), [$C$], name: <c2>),
    node((6,2), [$D$], name: <d2>),

    edge(<a2>,<b2>,"->"),
    edge(<a2>,<c2>,"->"),
    edge(<b2>,<d2>,"->"),
    edge(<c2>,<d2>,"->"),


    node((11,0), [$A$], name: <a3>),
    node((10,1), [$B$], name: <b3>),
    node((12,1), [$C$], name: <c3>),
    node((11,2), [$D$], name: <d3>),

    edge(<a3>,<b3>,"<-"),
    edge(<a3>,<c3>,"<-"),
    edge(<b3>,<d3>,"->"),
    edge(<c3>,<d3>,"->"),


  ),
)
]

=== Chordal Models
However, despite the difference between languages in general, we have also seen that some distributions can be perfectly modeled by either a DPGM or UPGM. We call these distributions *chordal* or *decomposable*. Roughly speaking, this means the following: if we collapse together all the variables in each maximal clique, to make “mega-variables”, the resulting graph will be a tree. Of course, if the graph is already a tree (which includes chains as a special case), it will already be chordal. Another, equivalent but for us less useful, definition is that a chordal graph is one in which all cycles of four or more vertices have a chord, which is an edge that is not part of the cycle but connects two vertices of the cycle.


#sidenote(numbered:false,dy:-13em)[
    #figure(
      caption: [Chordal graph with combined clique nodes],
      diagram(
        edge-stroke: 0.8pt,
        node-corner-radius: 8pt,
        node-stroke: 0.8pt,
        spacing: (10pt,30pt),

        node((0,0), [$A$], name: <a1>),
        node((1,0), [$B$], name: <b1>),
        node((2,0), [$C$], name: <c1>),
        node((0,1), [$D$], name: <d1>),
        node((2,1), [$E$], name: <e1>),
        node((0,2), [$F$], name: <f1>),
        node((1,2), [$G$], name: <g1>),
        node((2,2), [$H$], name: <h1>),

        edge(<a1>,<b1>,"--"),
        edge(<a1>,<d1>,"--"),
        edge(<c1>,<b1>,"--"),
        edge(<e1>,<b1>,"--"),
        edge(<d1>,<b1>,"--"),
        edge(<g1>,<b1>,"--"),
        edge(<c1>,<e1>,"--"),
        edge(<d1>,<f1>,"--"),
        edge(<d1>,<g1>,"--"),
        edge(<f1>,<g1>,"--"),
        edge(<h1>,<g1>,"--"),
        edge(<g1>,<e1>,"--"),
        edge(<e1>,<h1>,"--"),

        node((0,3),     [${A,B,D}$], name: <abd>, stroke:none),
        node((0,4),     [${D,F,G}$], name: <dfg>, stroke:none),
        node((0.5,3.5), [${B,D,G}$], name: <bdg>, stroke:none),
        node((1.5,3.5), [${B,E,G}$], name: <beg>, stroke:none),
        node((2,3),     [${B,E,C}$], name: <bec>, stroke:none),
        node((2,4),     [${E,G,H}$], name: <egh>, stroke:none),


        edge(<abd>,<bdg>,"-"),
        edge(<dfg>,<bdg>,"-"),
        edge(<beg>,<bdg>,"-"),
        edge(<beg>,<bec>,"-"),
        edge(<beg>,<egh>,"-"),


      ),
    )
]


== Translating PGMs
#sidenote(numbered: false)[Textbook: §4.5.2, pp. 196–197]

Even for non-chordal graphs, we may sometimes be ok with "lossy conversion" between representations where the resulting converted graph encodes _fewer_ CI assumptions than the original. Such a conversion does not introduce anything false, it simply does not encode the full expressive power of the original. However, there still may be reasons to not mind this loss, and so we may wish to do such a conversion nonetheless.


=== Converting a DPGM to a UPGM

We have already seen the process of _moralization_, which takes a directed PGM and adds edges to connect all "unmarried parents", and then drops the arrows.  One nice property of moralized models are that all of the potentials are _locally normalized_, since they result from conditional distributions, which means that there is no need for a global normalization value ($Z = 1$).

=== Converting from UPGM to DPGM

We can also convert between an UPGM to a DPGM by means of the creation of _dummy nodes_. For each clique / potential $psi_(c)(x_c;theta_c)$, we create a new node, call it $Y_c$ which is "clamped" to a special fixed value $y^*_c$. We then define the conditional distribution
$
  p(Y_c = y^*_c | x_c) = psi_(c)(x_c;theta_c)
$

This "local evidence" CPD encodes the same factor as in the UPGM. This gives the overall joint of the form $p_("undirected")(x) prop p_("directed")(x,y^*)$. By conditioning on the observed dummy state about which all nodes in a clique are parents, this forms repeated common effect triples which ensure the required dependencies.

#sidenote(numbered:false, dy:-25em)[
    #figure(
      caption: [An undirected graphical model and directed equivalent using an observed dummy node. After textbook Figure 4.39],
      diagram(
        edge-stroke: 0.8pt,
        node-corner-radius: 8pt,
        node-stroke: 0.8pt,

        node((1,0), [$A$], name: <a1>),
        node((0,1), [$B$], name: <b1>),
        node((2,1), [$C$], name: <c1>),
        node((1,2), [$D$], name: <d1>),

        edge(<a1>,<b1>,"--"),
        edge(<a1>,<c1>,"--"),
        edge(<a1>,<d1>,"--"),
        edge(<b1>,<d1>,"--"),
        edge(<c1>,<d1>,"--"),
        edge(<c1>,<b1>,"--"),


        node((1,3), [$A$], name: <a2>),
        node((0,4), [$B$], name: <b2>),
        node((2,4), [$C$], name: <c2>),
        node((1,5), [$D$], name: <d2>),
        node((1,4), [$E$], name: <e2>,fill:luma(80%)),


        edge(<a2>,<e2>,"->"),
        edge(<b2>,<e2>,"->"),
        edge(<c2>,<e2>,"->"),
        edge(<d2>,<e2>,"->"),

      ),
    )
]

#wideblock()[
#discussion(vspace:0em)[
  Consider the following (conditional) undirected and directed graphical models.
  #figure(
    caption: [An undirected 1D CRF  (left), and a directed MEMM (right). After textbook Figure 4.40],
    diagram(
      edge-stroke: 0.8pt,
      node-corner-radius: 8pt,
      node-stroke: 0.8pt,
      spacing: (25pt,15pt),
      node((0,0),[$y_(1)$], name: <y1>),
      node((1,0),[$y_(2)$], name: <y2>),
      node((2,0),[$y_(3)$], name: <y3>),

      node((0,1),[$x_(1)$], name: <x1>,fill:luma(80%)),
      node((1,1),[$x_(2)$], name: <x2>,fill:luma(80%)),
      node((2,1),[$x_(3)$], name: <x3>,fill:luma(80%)),

      edge(<y1>,<y2>,"--"),
      edge(<y3>,<y2>,"--"),
      edge(<y1>,<x1>,"--"),
      edge(<y2>,<x2>,"--"),
      edge(<y3>,<x3>,"--"),


      node((4,0),[$y_(1)$], name: <dy1>),
      node((5,0),[$y_(2)$], name: <dy2>),
      node((6,0),[$y_(3)$], name: <dy3>),

      node((4,1),[$x_(1)$], name: <dx1>,fill:luma(80%)),
      node((5,1),[$x_(2)$], name: <dx2>,fill:luma(80%)),
      node((6,1),[$x_(3)$], name: <dx3>,fill:luma(80%)),

      edge(<dy1>,<dy2>,"->"),
      edge(<dy3>,<dy2>,"<-"),
      edge(<dy1>,<dx1>,"<-"),
      edge(<dy2>,<dx2>,"<-"),
      edge(<dy3>,<dx3>,"<-"),
    ),
  )

  + Momentarily, consider the MEMM graph without the conditional requirement. Draw the moralized conversion to a UPGM for this generalized MEMM. How does this differ from the CRF, both in graph structure and in terms of CI properties.
  + Consider the problem of using a CRF for structured prediction of grammatical sentences. What properties of the CRF, relative to the MEMM, would make this problem easier? _Hint: Consider the direction of dependence/information propagation required to determine if a noun is the subject or object of a sentence._
  + On the other hand, what computational properties of the MEMM may make it more appropriate for modeling long sentences or online/streaming data?
]
]


== Mixed Models
#sidenote(numbered: false)[Textbook: §§4.5.4–4.5.5, pp. 198–202]

While some problems fit best using DPGMS and others UPGMs, in fact is is possible to define certain kinds of models that utilize _both_ directed and undirected edges.

=== Chain graphs
A *chain graph* (or partially directed acyclic graph, PDAG) is a PGM with both directed and undirected edges, _but without any directed cycles._ A Deep Beleif Net is an example of a chain graph. Such a graph can be decomposed into a directed graph of _chain components_, which are maximal groups of nodes connected to each other only with undirected edges#sidenote()[#discussion(vspace:0em)[How is a chain component different than a maximal clique?]]. We can then define a joint distribution
$
  p(x) = product_(i) p(C_i | "parents"(C_i))
$
Where each $C_i$ is a chain component, and each CPD is a conditional random field.

#discussion(vspace:0em)[
  #figure(caption: [An example chain graph. After textbook Figure 4.42],
    diagram(
      edge-stroke: 0.8pt,
      node-corner-radius: 8pt,
      node-stroke: 0.8pt,
      spacing: (50pt,20pt),

      node((0,0),[$A$], name: <a>),
      node((2,0),[$B$], name: <b>),
      node((0,1),[$C$], name: <c>),
      node((1,1),[$D$], name: <d>),
      node((2,1),[$E$], name: <e>),
      node((0,2),[$F$], name: <f>),
      node((1,2),[$G$], name: <g>),
      node((3,1),[$H$], name: <h>),
      node((2,2),[$I$], name: <i>),

      edge(<a>,<c>,"->"),
      edge(<b>,<e>,"->"),
      edge(<c>,<f>,"->"),
      edge(<d>,<g>,"->"),
      edge(<e>,<i>,"->"),
      edge(<h>,<i>,"->"),
      edge(<c>,<i>,"->"),

      edge(<c>,<d>,"--"),
      edge(<d>,<e>,"--"),
      edge(<f>,<g>,"--"),



    ),
  )

  For the above chain graph:
  + Identify all of the chain components
  + Sketch the reduced directed graph
  + Write out the full factorization of the joint
]

=== Acyclic Directed Mixed Graphs

A common problem that can occur in the analysis of DPGMs with respect to causal inference#sidenote()[A topic covered in more depth later in the course] is that different models with unobserved latent variables as common causes of observed variables can be hard or impossible to distinguish. One technique used to try and address some of this difficulty is the introduction of *acyclic directed mixed graphs (ADMG)*, which are graphs that have unidirectional edges as well as _bidirectional edges_ #sidenote()[It is important to emphasize that these do different work than _undirected_ edges with respect to joint factorization and CI properties.] and no _directed_ cycles. #sidenote()[That is, there are no cycles in the graph composed entirely of directed edges, while bidirectional edges may create cycles].

Conditional independence can be determined for a ADMG using the criterion of _m-separation_, which is a generalization of d-separation that is equivalent to replacing each bidirectional edge $A <-> B$ with a hidden variable such that $A <- H -> B$.

We can then define the *latent projection* of any DPGM to a ADMG with _no hidden variables_ that is observationally equivalent to the original DPGM. The procedure for latent projection is as follows:
+ Initialize the projection ADMG with only nodes corresponding to the non-hidden variables of the DPGM.
+ Add an edge $A -> B$ if there is a directed path from $A$ to $B$ where every intermediate node is latent.
+ Add a bidirectional edge $A <-> B$  if there exists a path between $A$ and $B$ such that all intermediate nodes are latent non-colliders (that is they do not have the common effect form $L_1 -> L_2 <- L_3$), and such that the edge adjacent to $A$ and the edge adjacent to $B$ both have arrowheads at those vertices. For example: $A <-> ... -> B$.

#discussion(vspace:7em)[
  Consider the following DPGM

  #figure(
    caption: [DPGM with latent variables. After textbook Figure 4.43.],
    diagram(
      edge-stroke: 0.8pt,
      node-corner-radius: 8pt,
      node-stroke: 0.8pt,

      node((0,0),[$X_1$], name: <x1>, fill:luma(85%)),
      node((1,0),[$X_2$], name: <x2>, fill:luma(85%)),
      node((2,0),[$X_3$], name: <x3>, fill:luma(85%)),
      node((0,2),[$X_4$], name: <x4>, fill:luma(85%)),
      node((0,1),[$H_1$], name: <h1>),
      node((1,1),[$H_2$], name: <h2>),

      edge(<x1>,<x2>,"->"),
      edge(<x2>,<x3>,"->"),
      edge(<x1>,<h1>,"->"),
      edge(<h1>,<x2>,"->"),
      edge(<h1>,<x4>,"->"),
      edge(<h2>,<x2>,"->"),
      edge(<h2>,<x3>,"->"),
      edge(<h2>,<x4>,"->"),

    ),
  )

  + Draw the latent reduction ADMG for the graph.
  + Verify that the set of CI properties of non-latent variables #sidenote()[Be careful about the distinction, which graphically is somewhat ambiguous, between observed variables in the model and conditioned variables in a CI query.] in the original graph as determined through d-separation are identical to the CI properties of the latent reduction as verified through m-separation.
]


= PGM extensions
#sidenote(numbered: false)[Textbook: §4.6, pp. 202–212]
#v(-1em)
In addition to the mixed methods discussed above, there are many formalizations that carve up joint distribution space using similar graphical languages to PGMs.

== Factor graphs
#sidenote(numbered: false)[Textbook: §4.6.1, pp. 202–205]

A *factor graph* is a graphical representation that unifies directed and undirected models. They come in two common forms, bipartite factor graphs which have nodes for random variables and for factors, and Forney factor graphs which just have nodes for factors where edges represent random variables. Recall that factors are essentially the same as clique potentials, being functions whose product is unnormalized but proportional to the joint distribution.

=== Bipartite Factor Graphs

#sidenote(numbered:false)[
  #discussion(vspace:10em)[
    For the simple UPGM shown in the figure, draw as many other equivalent factor graphs as you can. Think about why in some applications some of these different models might be preferred over others.
  ]
]
#v(-1em)
A bipartite factor graph is an undirected bipartite graph with two kinds of nodes. Round nodes represent random variables in the same way as standard PGMs. Square nodes (often also shaded or fully dark) represent factors with edges connecting each factor with all of the random variables included in it. It is easy to show how factor graphs form a super-set of UPGMs, but can model more distributions by introducing more factors. We can also represent any DPGM by introducing a factor for each CPD.


#figure(
  caption: [Simple UPGM and equivalent factor graphs. After textbook Figure 4.46.],
  diagram(
    edge-stroke: 0.8pt,
    node-stroke: 0.8pt,
    spacing: (15pt,5pt),
    node-inset: 5pt,

    node((0,0), [$A$], name: <a1>),
    node((-1,1),[$B$], name: <b1>),
    node((1,1), [$C$], name: <c1>),
    node((0,2), [$D$], name: <d1>),

    edge(<a1>,<b1>,"--"),
    edge(<a1>,<c1>,"--"),
    edge(<b1>,<c1>,"--"),
    edge(<b1>,<d1>,"--"),
    edge(<c1>,<d1>,"--"),

    node((2,0), [$A$], name: <a2>),
    node((2,1), [$B$], name: <b2>),
    node((3,1), [$C$], name: <c2>),
    node((2,2), [$D$], name: <d2>),
    node((3,0), [$f_(A B C)$], name: <fabc>,shape:shapes.rect,fill:luma(85%)),
    node((3,2), [$f_(B C D)$], name: <fbcd>,shape:shapes.rect,fill:luma(85%)),

    edge(<fabc>,<a2>,"-"),
    edge(<fabc>,<b2>,"-"),
    edge(<fabc>,<c2>,"-"),
    edge(<fbcd>,<b2>,"-"),
    edge(<fbcd>,<c2>,"-"),
    edge(<fbcd>,<d2>,"-"),

    node((4,1), [$A$], name: <a3>),
    node((5,1), [$B$], name: <b3>),
    node((6,1), [$C$], name: <c3>),
    node((7,1), [$D$], name: <d3>),

    node((4.5,2), [$f_(A B)$], name: <fab>,shape:shapes.rect,fill:luma(85%)),
    node((5,0), [$f_(A C)$], name: <fac>,shape:shapes.rect,fill:luma(85%)),
    node((5.5,2), [$f_(B C)$], name: <fbc>,shape:shapes.rect,fill:luma(85%)),
    node((6,0), [$f_(B D)$], name: <fbd>,shape:shapes.rect,fill:luma(85%)),
    node((6.5,2), [$f_(C D)$], name: <fcd>,shape:shapes.rect,fill:luma(85%)),

    edge(<fab>,<a3>,"-"),
    edge(<fab>,<b3>,"-"),
    edge(<fbc>,<b3>,"-"),
    edge(<fbc>,<c3>,"-"),
    edge(<fcd>,<c3>,"-"),
    edge(<fcd>,<d3>,"-"),
    edge(<fac>,<a3>,"-"),
    edge(<fac>,<c3>,"-"),
    edge(<fbd>,<b3>,"-"),
    edge(<fbd>,<d3>,"-"),
))



=== Forney Factor Graphs

#sidenote(numbered:false)[
  #figure(
    caption: [Example Fourney factor graphs. A normal directed version on top, and a hierarchical abstracted version on bottom. After textbook Figure 4.48.],
    diagram(
      edge-stroke: 0.8pt,
      node-stroke: 0.8pt,
      node-fill: luma(85%),
      node-shape: shapes.rect,
      spacing: 15pt,


      node((0,0),[$f_a$], name: <a>),
      node((1,0),[$f_b$], name: <b>),
      node((2,0),[$f_c$], name: <c>),
      node((2,1),[$f_d$], name: <d>),

      edge(<a>,<b>,[$X_1$],"->"),
      edge(<b>,<c>,[$X_2$],"->"),
      edge(<c>,"r",[$X_3$],"->"),
      edge(<c>,<d>,[$X_4$],"->",label-side:right),
      edge(<d>,"r",[$X_5$],"->"),



      node(enclose:((0,3),(2,3.25)),[$f_("prior")$], name: <prior>),
      node((1,4.5),[$f_("likelihood")$], name: <likelihood>),


      edge(<prior>,"u",[$X_1$],"<-",label-side:right,label-pos:1.0,shift: 40pt),
      edge(<prior>,"u",[$X_2$],"<-",label-side:right,label-pos:1.0,shift: 0pt),
      edge(<prior>,"u",[$X_3$],"<-",label-side:right,label-pos:1.0,shift: -40pt),

      edge(<prior>,<likelihood>,[$X_4$],"->"),
      edge(<likelihood>,"r",[$X_5$],"->"),

  ))
]
#v(-1em)
A *Forney factor graph (FFG)*, also sometimes called a normal factor graph, is a graph in which nodes represent factors and edges represent variables. This kind of visual language may be more familiar to those used to standard neural network diagrams or signal processing diagrams, where signals propagate along
wires are are modified by functions represented as nodes.

Note that in an FFG we may sometimes have a "half-edge" for variables that participate in only one factor.
The directionality associated with the edges is a useful tool if there is a natural order in which the variables are generated, but strictly speaking the direction of the edges does not carry dependence information. In addition, associating directions with each edge allows us to uniquely name “messages” that are sent along each edge, which is useful for some kinds of inference algorithms.
In addition to being more similar to neural network diagrams, FFGs have the advantage over bipartite FGs in that they support hierarchical (compositional) construction, in which a complex dependency structure between variables can be represented as a blackbox, with the input/output interface being represented by edges corresponding to the variables exposed by the blackbox.



We can support variables participating in more than two factors in a FFG by adding _equality constraint nodes_. This is done by adding a factor defined using a Dirac/Kroneker delta function
$
  f_("eq")(x,x_1,x_2) = delta(x-x_1)delta(x-x_2)
$
Intuitively we can think of this factor as acting like a "wire splitter", producing two wires/edges/variables that have the same signal/value. Additionally we can sometimes re-use the same factor expression in multiple locations in the graph, an example of a technique called _parameter tying_.

#wideblock()[
#discussion(vspace:0em)[
  Parameter tying is a useful practice that can help sometimes reduce training and inference costs and encode certain kinds of dependencies. Consider the following two FFGs, one using paramter tying and the other simply connecting multiple ways to the same factor. Explain conceptually what is different between the two models, as well as how the factorizations of the joint differ.

  #figure(
    caption: [Example Fourney factor graphs. A normal directed version on top, and a hierarchical abstracted version on bottom. After textbook Figure 4.48.],
    diagram(
      edge-stroke: 0.8pt,
      node-stroke: 0.8pt,
      node-fill: luma(85%),
      node-shape: shapes.rect,
      spacing: 15pt,


      node((0,0),[$f_a$], name: <a>),
      node((0,1),[$=$], name: <eq>),
      node((-1,2),[$f_b$], name: <b1>),
      node((1,2),[$f_b$], name: <b2>),

      edge(<a>,<eq>,[$X$],"->"),
      edge(<eq>,<b1>,[$X_1$],"->"),
      edge(<eq>,<b2>,[$X_2$],"->"),
      edge(<b1>,"d",[$Y_1$],"->"),
      edge(<b2>,"d",[$Y_2$],"->"),
      edge(<b1>,"l",[$Z_1$],"<-",label-pos:1.0),
      edge(<b2>,"r",[$Z_2$],"<-",label-pos:1.0),



      node((6,0),[$f_a$], name:  <a_merge>),
      node(enclose:((5.5,1),(6.5,1.25)),[$f_b$], name:  <b_merge>),

      edge(<a_merge>,<b_merge>,[$X$],"->"),
      edge(<b_merge>,"d",[$Y_1$],"->",shift:-10pt,label-side:right),
      edge(<b_merge>,"d",[$Y_2$],"->",shift:10pt,label-side:left),
      edge(<b_merge>,"ll",[$Z_1$],"<-",label-pos:1.0),
      edge(<b_merge>,"rr",[$Z_2$],"<-",label-pos:1.0),
  ))
]
]

== Relational PGMs
#sidenote(numbered: false)[Textbook: §§4.6.3–4.6.6, pp. 206–210]

We have seen how plate notation in DPGMs can help represent large repeating structures compactly, however not all repeating structures can be represented using plate notation (for instance a HMM). Many notational extensions to plate notation have been proposed but have not been widely adopted. These extensions are called *Relational Probability Models (RPM)*.

Similar to first order logic, in an RPM we have constant symbols (representing objects), function symbols (mapping one set of constants to another), and predicate symbols (representing relations between objects).
We will assume that each function has a type signature.
Consider a network concerning online book reviews. We can define the predicates
$
  "Honest"(H) : "User" &-> {T, F}\
  "Kindness"(K) : "User" &-> {1,2,3,4,5}\
  "Quality"(Q) : "Book" &-> {1,2,3,4,5}\
  "Rating"(R) : "User" times "Book" &-> {1,2,3,4,5}
$

Let us further state that there are two books $B_1, B_2$ and two users $U_1, U_2$. The *basic random variables* in our model are obtained by instantiating each function with each possible combination of object inputs, (i.e. $H(U_2), R(U_1,B_2),$ etc) to create a set of *ground terms*.

In the directed case we will define our model in terms of a DPGM _template_ which is defined in terms of generic index forms of the variables rather than their specific ground form. These can then be unrolled _as needed_ to the actual variables depending on the specific inference query. Similarly, we could define our template in terms of a UPGM. These methods generally make use of parameter tying, as the parameters of the CPDs or potentials are generally constant in some way across all indexed variables.

#sidenote(dy:-15em,numbered:false)[
  #figure(
    caption: [Template RPM and unrolled form for book review domain. After textbook Figure 4.50.],
    diagram(
      edge-stroke: 0.8pt,
      node-stroke: 0.8pt,
      spacing: (10pt,25pt),
      node-corner-radius: 10pt,


      node((1,0),[$H(U_i)$], name: <h>),
      node((1,1),[$R(U_i,B_i)$], name: <r>),
      node((1,2),[$K(U_i)$], name: <k>),
      node((0,1),[$Q(B_i)$], name: <q>),
      edge(<h>,<r>,"->"),
      edge(<q>,<r>,"->"),
      edge(<k>,<r>,"->"),


      node((0,3), [$H(U_1)$], name: <h1>),
      node((1,3), [$H(U_2)$], name: <h2>),

      node((0,4), [$R(U_1,B_1)$], name: <r11>),
      node((1,4), [$R(U_2,B_1)$], name: <r21>),
      node((0,5), [$R(U_1,B_2)$], name: <r12>),
      node((1,5), [$R(U_2,B_2)$], name: <r22>),

      node((0,6), [$K(U_1)$], name: <k1>),
      node((1,6), [$K(U_1)$], name: <k2>),

      node((-1,4),[$Q(B_1)$], name: <q1>),
      node((-1,5),[$Q(B_2)$], name: <q2>),


      edge(<h1>,<r11>,"->"),
      edge(<k1>,<r11>,"->",bend:-60deg),
      edge(<q1>,<r11>,"->"),


      edge(<h1>,<r12>,"->",bend:60deg),
      edge(<k1>,<r12>,"->"),
      edge(<q2>,<r12>,"->"),


      edge(<h2>,<r21>,"->"),
      edge(<k2>,<r21>,"->",bend:-60deg),
      edge(<q1>,<r21>,"->",bend:30deg),

      edge(<h2>,<r22>,"->",bend:60deg),
      edge(<k2>,<r22>,"->"),
      edge(<q2>,<r22>,"->",bend:30deg),

  ))
]


=== Markov Logic Networks
#sidenote(numbered: false)[Textbook: §§4.6.4.2, pp. 209–211]

#v(-1em)
One expressive way to represent URPMs is to use first order logic (FOL) rather than a standard graphical description. For example, consider a domain with the following rules: "All humans are mortal" and "If a mortal is friends with someone else, they are also mortal" #sidenote()[Immortal beings are notoriously unfriendly.].  We can write this in FOL as
$
  forall H(x) &=> M(x).\
  forall F(x,y) and M(x) &=>  M(y).
$

Let us also say there are two objects (humans) in the world, Socrates ($S$) and Plato ($P$). We can then create the ground set of random variables such as $H(S), M(P), F(S,P),$ etc. Our goal is to define a joint probability distribution over these variables. We can do this be defining a UPGM with the ground variables and adding potential functions to capture each logical rule/constraint. For example to encode the rule $H(x) => M(x)$ we can define the potential and corresponding UPGM
$
  Psi(H(x),M(x)) = cases(1 "if" not H(x) or M(x),0 "if" H(x) and not M(x) )
$

#sidenote(dy:-5em,numbered:false)[
  #figure(
    caption: [Markov logic network ground MRF example. After textbook Figure 4.52.],
    diagram(
      edge-stroke: 0.8pt,
      node-stroke: 0.8pt,
      spacing: (10pt,25pt),
      node-corner-radius: 10pt,


      node((0,1),[$F(S,P)$], name: <fsp>),
      node((0,0),[$F(S,S)$], name: <fss>),
      node((0,2),[$F(P,S)$], name: <fps>),
      node((0,3),[$F(P,P)$], name: <fpp>),

      node((2,1),[$H(S)$], name: <hs>),
      node((2,2),[$H(P)$], name: <hp>),

      node((1,1),[$M(S)$], name: <ms>),
      node((1,2),[$M(P)$], name: <mp>),

      edge(<hs>,<ms>,"--"),
      edge(<hp>,<mp>,"--"),

      edge(<fsp>,<ms>,"--"),
      edge(<fsp>,<mp>,"--"),

      edge(<fps>,<ms>,"--"),
      edge(<fps>,<mp>,"--"),

      edge(<fss>,<ms>,"--"),
      edge(<fpp>,<mp>,"--"),


  ))
]

#v(-2em)
In comparison to purely logic based approaches, this method opens the door for us to be slightly less dogmatic and allow some probability for a rule to be violated. We can do this by changing the potentials from {0,1} valued to exponentially weighted proportional to how hard we want the constraint to be #sidenote()[For instance if we want to leave the door open to immortal vampires being human.]

$
  Psi(H(x),M(x)) = cases(e^w "if" not H(x) or M(x),e^0 "if" H(x) and not M(x) )
$

While the full ground model is frequently prohibitively large to do inference, methods for *lifted inference* exists which only populate relevant components on the fly. Additionally there are methods to increase tractability by converting the discrete components of the model to continuous formulations that are easier to approximate and optimize which is the basis of *hinge-loss MRFs*. The template language for such models is known as *probabilistic soft logic*.

== Open universe Models
#sidenote(numbered: false)[Textbook: §§4.6.5, pp. 211]

In all of the models we have discussed so far we have made at least one essential assumption as part of the problem statement. That is we are trying to represent som joint distribution for a set of random variables. Implicitly this makes what is called the *closed world assumption*, that is that the set of all objects is fixed and specified ahead of time. This is particularly unrealistic in the case of RPM where our actual specification of a template makes no actual statement about the number or specifics of objects. In many domains we want to represent relations between objects about which we do not know ahead of time how many there are. Another common context where such assumptions may not make sense is where we may have some _identification uncertainty_, that is we may have multiple measures but be uncertain whether these measures come from the same or different entities.

In such situations we can use *open-universe probability models (OUPM)* which can generate new objects as well as their properties. Early approaches to OUPM such as BLOG (Bayesian Logic) were general purpose but slow due to using MCMC over all possible worlds. Recently the library #link("https://beanmachine.org/")[*Bean Machine*]#sidenote()[https://beanmachine.org/] supports more efficient OUPMs.



== Probabilistic Programming
#sidenote(numbered: false)[Textbook: §§4.6.6, pp. 211-212]

The methods introduced so far have provided the _language_ for communicating different kinds of probabilistic models. However, of course, these models do need to be computed. Traditionally all of the work to convert between the model specification and the relevant statistical computation was left manually to the developer (and sometimes this remains the case for particularly complex or niche analyses or models). However there exist libraries and domain-specific languages that better support direct representation of models and include to greater or less extents automatic inference or sampling. These are called *probabilistic programming languages (PPL)*, and they will be the main tools that you will likely use in developing your analysis for your final project. They can be more declarative or procedural, depending on their design or host language. Some good examples of PPLs you may want to look into are:
#wideblock()[
  - Pyro (Python, Particularly good Stochastic Variational Inference Support, https://pyro.ai)
  - Bean Machine (Python, https://beanmachine.org/)
  - PyMC (Python, https://www.pymc.io/welcome.html)
  - Turing (Julia, https://turinglang.org/index.html)
  - Gen (Julia, https://www.gen.dev)
  - Fugue (Rust, https://fugue.run/)
  - #link("https://en.wikipedia.org/wiki/Probabilistic_programming#List_of_probabilistic_programming_languages")[And More]
]
