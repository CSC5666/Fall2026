#import "wdf.typ": *
#import "inference-figures.typ": *

#show: template.with(
  title: [Probabilistic Inference],
  title-short: none,
  authors: "CSC 5666: Advanced Machine Learning, Fall 2026",
  authors-short: none,
  title-extra: [Professor Austin P. Wright: Course Notes],
  date: none,
  toc: false,
  full: false,
  header-content: none,
  abstract: [Introduction to exact probabilistic inference with hidden Markov models, variable elimination, and belief propagation, followed by a brief look at loopy belief propagation. See Chapters 7–9 of Murphy's textbook.],
  bib: none,
  serif: true,
  exam: false,
)

#import algorithmic: algorithm-figure, style-algorithm
#show: style-algorithm


#sidenote(dy: 1.15em, numbered: false)[#outline(depth: 2)]

= Inference Overview

We have moved back and forth between models, distributions, and optimization. In a Bayesian model, the uncertain parts of the problem—parameters, predictions, or hidden states—are represented by random variables. The observed data are the values we condition on.

_Inference_ means using Bayes' rule to compute a posterior distribution, or some quantity under that posterior.
$
  p(theta | cal(D)) &= (p(theta) p(cal(D) | theta))/(p(cal(D)))\
  &= (p(theta) p(cal(D) | theta))/(integral p(theta) p(cal(D) | theta) d theta)
$

The numerator is usually easy to evaluate. The difficult part is the normalizing integral over every possible value of $theta$.

If we have the posterior (or as we will see at least a good estimate of it), we can use it to calculate expectations of functions of the parameters or unknown variables
$
  EE[f(theta) | cal(D)] = integral f(theta) p(theta | cal(D)) d theta
$

These functions will correspond to the actual quantities we care about, such as:
- Mean: $f(theta) = theta$
- Covariance: $f(theta) = (theta - EE[theta])(theta - EE[theta])^top$
- Predictions: $f(theta) = p(y_(n+1) | theta)$
- Expected Loss: $f(theta) = cal(L)(theta, a)$


Optimization was built around differentiation; inference is mostly built around summation and integration. Graphical models let us reuse the same inference ideas across many models, as long as the graph and the local factors make those operations manageable. This is the usual idea behind _turning the Bayesian crank_.

#figure(
  caption: [Three common inference patterns. (a) Global hidden variables, the Bayesian discriminative model $p(y_(1:N), theta_y | x_(1:N)) = p(theta_y) product_n p(y_n | x_n; theta_y)$. (b) Local hidden variables with known parameters, $p(x_(1:N), z_(1:N) | theta) = product_n p(z_n | theta_z) p(x_n | z_n, theta_x)$. (c) Local and global hidden variables, $p(x_(1:N), z_(1:N), theta) = p(theta_z) p(theta_x) product_n p(z_n | theta_z) p(x_n | z_n, theta_x)$. Shaded nodes are observed. After textbook Figure 7.1.],
  latent-patterns(),
)

The three pictures cover the common ways hidden variables show up in a model. In (a), one shared parameter $theta_y$ is learned from all of the data. This is the usual Bayesian version of supervised learning: uncertainty about the model is represented by uncertainty about $theta_y$.

In (b), every case has its own hidden variable $z_n$. Once the parameters are fixed, the cases can be handled separately. Mixture models and the E-step of EM have this form. Panel (c) keeps both the shared parameters and the local hidden states. We will return to this pattern in variational inference.


= Message Passing
#sidenote(numbered: false)[Textbook: Chapter 9, pp. 401–438]

A graphical model tells us which calculations are local. On chains, trees, and other low-treewidth graphs, we can arrange those local calculations as a dynamic program and perform exact inference efficiently.

The intermediate result from one part of the graph is sent to the next part as a _message_. A message is a nonnegative function summarizing the evidence on one side of an edge; it need not be a probability distribution. Multiplying the incoming messages and normalizing gives a _belief_. This family of algorithms is therefore called _belief propagation_.


#pagebreak()
== Belief Propagation on Chains
#sidenote(numbered: false)[Textbook: §9.2, pp. 401–412]

One of the simplest graph structures that is still extremely useful in many domains is a _chain_ or _sequence_. Perhaps the most famous version of this structure is the Hidden Markov Model, which defines a sequence of hidden variables connected by a _transition function_, and for each hidden variable in the sequence there is a conditional _observation distribution_ to an observed value. While this structure can be used in generality, we will focus on the illustrative case of discrete hidden and observed variables #sidenote()[This allows us to represent the model with finite transition and observation matrices, which will help make more clear the discussion of performance and scale. Of course, HMM's are frequently used in both discrete and continuous contexts, and in fact have a wide range of extensions and generalizations for different domains.].
#figure(
  caption: [A hidden Markov model as a DPGM. $z_t$ are the hidden states and $y_t$ the observations. After textbook Figure 9.1.],
  hmm-dpgm(),
)

A chain is a good place to start because the graph is simple but the main inference questions are already here: filtering, smoothing, and decoding. Later, variable elimination and belief propagation will recover the same calculations without relying on the special shape of an HMM.

Reading the joint from the graph gives one initial-state term, $T-1$ transition terms, and $T$ observation terms. The graph makes two assumptions. The next state depends on the present state, not the whole past; and each observation depends only on its own hidden state.

Here $pi$ is the initial distribution and $A$ is the transition matrix, with row $i$ giving the next-state distribution from state $i$. The vector $bold(lambda)_t$ is local evidence: $lambda_t (j)$ says how well state $j$ explains the observation $y_t$. It is a likelihood, not a distribution over states, so it need not sum to one. Brute force would inspect $K^T$ hidden paths. The recursions below avoid that enumeration.

$
  p(y_(1:T), z_(1:T)) & = p(z_1) [product_(t=2)^T p(z_t | z_(t-1))] \
                      & quad times [product_(t=1)^T p(y_t | z_t)]
$
$
          pi_j & =p(z_1=j), quad A_(i j)=p(z_t=j|z_(t-1)=i), \
  lambda_t (j) & =p(y_t|z_t=j)
$

=== Example: The Occasionally Dishonest Casino
#sidenote(numbered: false)[Textbook: §9.2.1.1, pp. 402–403]

#figure(
  caption: [Casino HMM state transition diagram. After textbook Figure 9.2, adapted from Durbin et al. 1998, p. 54.],
  casino-states(),
)

The casino usually uses a fair die, but sometimes swaps in a loaded die that rolls a six half the time. We see the rolls but not which die was used. The hidden state is therefore _fair_ or _loaded_, and the observed value is the face of the die.

The large self-transition probabilities matter as much as the emission probabilities. Once the casino picks a die, it tends to keep it: the expected run lengths are $1/(1-0.95)=20$ fair rolls and $1/(1-0.90)=10$ loaded rolls. This lets several ordinary-looking rolls add up to evidence for a loaded stretch.

Try marking the loaded runs from the observation line before reading the hidden line. The first loaded run, rolls 11–14, has no six at all, while the two sixes at 15–16 came from the fair die. One roll is weak evidence; the sequence is the useful part.

$
                        A & = mat(0.95, 0.05; 0.10, 0.90) \
    p(y_t | z_t = "fair") & = "Cat"(1\/6, dots, 1\/6) \
  p(y_t | z_t = "loaded") & = "Cat"(1\/10, dots, 1\/10, 5\/10)
$

#align(center)[
  #set text(size: 6pt, font: "DejaVu Sans Mono")
  #table(
    columns: 2,
    stroke: none,
    align: left,
    [hid:],
    [1111111111222211111111111111111111112222222221222211111111111111111111],

    [obs:],
    [1355534526553366316351551526232112113462221263264265422344645323242361],
  )
]

#figure(
  caption: [Which evidence each query uses, for $T = 5$. The queried state is outlined in red; shaded observations are conditioned on, dashed ones are not.],
  query-chains(),
)

The three queries differ in which state we ask about and how much of the observation sequence we can use. Filtering uses data through time $t$, so it is the answer available to an online system. Smoothing looks back after the whole sequence has arrived. Prediction starts from the filtered belief and pushes it forward without seeing new observations.

For smoothing, split the evidence at $z_t$. Given $z_t$, future observations do not depend on the observations already seen. Bayes' rule then gives a forward term, $p(z_t|y_(1:t))$, times a backward term, $p(y_(t+1:T)|z_t)$. The next two algorithms compute those two pieces.

$
   "filtering:" & quad p(z_t | y_(1:t)) \
   "smoothing:" & quad p(z_t | y_(1:T)) \
  "prediction:" & quad p(z_(t+h) | y_(1:t)), quad h > 0
$
$
  p(z_t = j | y_(1:T)) prop p(z_t = j | y_(1:t)) thin p(y_(t+1:T) | z_t = j)
$

#side-discussion[
  Filtering is causal and smoothing is not. Name an application where you are only ever allowed the filtered distribution, and one where reporting it instead of the smoothed one would be a mistake. (Russell & Norvig, _AIMA_ 4th ed., §14.2)
]

=== The Forwards Algorithm
#sidenote(numbered: false)[Textbook: §9.2.2, pp. 403–404]

#figure(
  caption: [One step of the forwards algorithm on the casino, after two sixes in a row from a uniform start. Predict pushes yesterday's belief through $A$; update multiplies by the local evidence of a six, $bold(lambda) = [1\/6, 1\/2]$ (gray inset); normalizing divides by $Z_2 = p(y_2 | y_1)$.],
  forward-bars(),
)

The forwards algorithm repeats two small operations. First, _predict_: average yesterday's belief through the transition matrix. In the casino figure the loaded probability falls from $0.75$ to about $0.69$, since the loaded die might have been swapped out. Then _update_: multiply by the likelihood of today's roll and normalize. A second six raises the loaded probability to about $0.87$. For the first observation, start with $bold(alpha)_1 prop pi dot.o bold(lambda)_1$.

The normalizer $Z_t$ is useful. It is the predictive probability of the new observation, $p(y_t|y_(1:t-1))$. By the chain rule, the product of these terms is the marginal likelihood, or equivalently $log p(y_(1:T))=sum_t log Z_t$. Normalizing at every step also avoids the rapid underflow of an unnormalized forward joint.

Each predict step is a matrix-vector product, so a dense $K$-state model costs $O(K^2 T)$ rather than enumerating $K^T$ paths. The filtered casino curve responds in the right places, but it is jumpy and tends to notice a loaded run late. It has not seen the future yet.

$
  "predict:" quad alpha_(t|t-1)(j) & eq.def p(z_t = j | y_(1:t-1)) = sum_i A_(i j) thin alpha_(t-1)(i) \
  "update:" quad alpha_t (j) & eq.def p(z_t = j | y_(1:t)) = 1/Z_t lambda_t (j) thin alpha_(t|t-1)(j) \
  Z_t & eq.def p(y_t | y_(1:t-1)) = sum_j lambda_t (j) thin alpha_(t|t-1)(j)
$

In matrix-vector form, with $dot.o$ the elementwise product,
$
  bold(alpha)_t = "normalize"(bold(lambda)_t dot.o (A^top bold(alpha)_(t-1))), quad log p(y_(1:T)) = sum_(t=1)^T log Z_t.
$

#sidenote(
  numbered: false,
  dy: -6em,
)[Textbook §9.2.3.4, p. 407. For the unnormalized form, if observations were independent of the state we would have $p(z_t = j, y_(1:t)) = p(z_t = j) product_(i=1)^t p(y_i)$, which becomes exponentially small with $t$.]

#figure(
  image("Figures/textbook-casino-hmm.png", width: 100%),
  caption: [Inference in the dishonest casino over $T = 300$ rolls. Gray bars mark the times the loaded die was actually in use; blue lines show the posterior probability of the loaded state. (a) Filtered, $p(z_t | y_(1:t))$. (b) Smoothed, $p(z_t | y_(1:T))$. (c) The Viterbi (MAP) trajectory. Reproduced from Murphy, Textbook Figure 9.3, p. 404 (CC BY-NC-ND).],
)

#pagebreak()
=== The Forwards-Backwards Algorithm
#sidenote(numbered: false)[Textbook: §§9.2.3–9.2.5, pp. 404–409]

#figure(
  caption: [Smoothing splits the evidence at $z_t$. The forwards message $alpha_t$ summarizes everything to the left, including $y_t$; the backwards message $beta_t$ summarizes everything to the right. Because $z_t$ d-separates the two regions, the smoothed marginal is their normalized product.],
  fb-sweep(),
)

The forward pass already summarizes everything to the left of $z_t$. For smoothing we also need a message from the right. Define $beta_t (j)$ as the likelihood of all later observations if the current state is $j$. A scaled implementation stores $beta_t^("sc") prop beta_t$ to avoid underflow.

To move one step left, try every possible next state, multiply its transition probability by its local evidence and its remaining backward likelihood, then sum. This gives $bold(beta)_(t-1)=A(bold(lambda)_t dot.o bold(beta)_t)$, with $bold(beta)_T=bold(1)$ because there is no future evidence after time $T$. Multiplying $bold(alpha)_t$ by either $bold(beta)_t$ or its scaled version and normalizing gives $bold(gamma)_t$.

The pairwise marginal $xi_(t,t+1)$ records how much posterior mass uses each transition. Baum-Welch uses sums of $gamma$ as expected state counts and sums of $xi$ as expected transition counts. Both passes take $O(K^2 T)$ time; storing the forward messages takes $O(K T)$ space. In the casino plot, the backward evidence makes the smoothed curve less jumpy and lines it up better with the hidden runs.

$
     beta_t (j) & eq.def p(y_(t+1:T) | z_t = j) \
    gamma_t (j) & eq.def p(z_t = j | y_(1:T)) prop alpha_t (j) thin beta_t (j), \
  bold(gamma)_t & = "normalize"(bold(alpha)_t dot.o bold(beta)_t)
$

$
  beta_(t-1)(i) & = p(y_(t:T) | z_(t-1) = i) \
  & = sum_j p(y_(t+1:T) | z_t = j) thin p(y_t | z_t = j) thin p(z_t = j | z_(t-1) = i) \
  & = sum_j beta_t (j) thin lambda_t (j) thin A_(i j)
$
$
  bold(beta)_(t-1) = A (bold(lambda)_t dot.o bold(beta)_t), quad beta_T (i) = p(emptyset | z_T = i) = 1
$

#pagebreak(weak: true)
#algorithm-figure(
  "Forwards-Backwards",
  inset: 0.35em,
  vstroke: .5pt + luma(200),
  {
    import algorithmic: *
    Comment[Given $pi$, $A$, and local evidence $bold(lambda)_(1:T)$]
    Assign[$bold(alpha)_1, Z_1$][$"normalize"(bold(lambda)_1 dot.o pi)$]
    For($t = 2, dots, T$, {
      Assign[$bold(alpha)_t, Z_t$][$"normalize"(bold(lambda)_t dot.o (A^top bold(alpha)_(t-1)))$]
    })
    Assign[$bold(beta)_T^("sc")$][$bold(1)$]
    For($t = T, dots, 2$, {
      Assign[$bold(beta)_(t-1)^("sc")$][$"normalize"(A (bold(lambda)_t dot.o bold(beta)_t^("sc")))$]
    })
    For($t = 1, dots, T$, {
      Assign[$bold(gamma)_t$][$"normalize"(bold(alpha)_t dot.o bold(beta)_t^("sc"))$]
    })
    Return[$bold(gamma)_(1:T)$, $log p(y_(1:T)) = sum_t log Z_t$]
  },
)

$
  xi_(t,t+1)(i, j) & eq.def p(z_t = i, z_(t+1) = j | y_(1:T)) \
  & prop alpha_t (i) thin A_(i j) thin lambda_(t+1)(j) thin beta_(t+1)(j)
$

$
  underbrace(sum_(z_(1:T)) p(y_(1:T), z_(1:T)), O(K^T) "terms")
  quad arrow.r.long quad
  underbrace(T "steps of" A^top bold(alpha), O(K^2 T))
$

#discussion[
  In the casino plot, the smoothed probability sometimes rises before the filtered probability. How can a belief about time $t$ respond to later rolls, and which message carries that information?
]

#pagebreak()
=== Viterbi Algorithm
#sidenote(numbered: false)[Textbook: §9.2.6, pp. 409–412]

#figure(
  kind: image,
  caption: [Viterbi decoding in a three-state HMM for a single phone. Left: the state transition diagram and the emission probabilities of each symbol $C_1, dots, C_7$. Right: the trellis for observations $(C_1, C_3, C_4, C_6)$. Each node shows $delta_t (j)$ and each edge is labeled (transition probability, emission probability). The red path is recovered by traceback. After textbook Figure 9.6, adapted from Russell and Norvig.],
  viterbi-figure(),
)

Viterbi asks a different question. Instead of a marginal distribution at each time, it asks for the single most probable hidden path. Since the observed sequence is fixed, maximizing the posterior path probability is the same as maximizing its joint probability with the observations.

The recursion is the unnormalized forward recursion with the sum replaced by a max. $delta_t (j)$ stores the score of the best prefix ending in state $j$. In the trellis, for example,
$
  delta_3 (2)=max(0.045 dot 0.7, 0.07 dot 0.9) dot 0.7=0.0441.
$
The winning incoming state is stored as a backpointer. After reaching the end, follow those pointers backward to recover one consistent path. The cost is again $O(K^2 T)$ time and $O(K T)$ stored pointers; implementations normally use max-sum in log space.

A Viterbi path is a hard, whole-sequence decision. It need not minimize the number of state-by-state errors. On the textbook casino run, the per-time smoothed choices make fewer errors than the MAP path, even though the latter is the most probable complete sequence. Those decoders are minimizing different losses.

$
  z^*_(1:T) & = limits("argmax")_(z_(1:T)) p(z_(1:T) | y_(1:T)) \
            & = limits("argmax")_(z_(1:T)) [log pi(z_1) + log lambda_1 (z_1) \
            & quad quad + sum_(t=2)^T (log A_(z_(t-1) z_t) + log lambda_t (z_t))]
$

$
  delta_t (j) & = lambda_t (j) max_i [delta_(t-1)(i) thin A_(i j)], quad delta_1 (j) = pi_j lambda_1 (j) \
  a_t (j) & = limits("argmax")_i [delta_(t-1)(i) thin A_(i j)] \
  z^*_T & = limits("argmax")_i delta_T (i), quad z^*_t = a_(t+1)(z^*_(t+1))
$

#side-discussion[
  What changes in the forward recursion when the sum is replaced by a max? What extra information must we store to recover a path?
]

#discussion[
  Why can the most probable complete sequence make more state-by-state errors than choosing the largest smoothed marginal at each time? What loss does each rule minimize?
]

== Variable Elimination
#sidenote(numbered: false)[Textbook: §9.5, pp. 428–433]

#figure(
  kind: image,
  caption: [The running example for the rest of the section: a binary chain $x_1 - x_2 - x_3$ as a factor graph, with a prior factor $g$ on $x_1$, pairwise factors $f_A, f_B$ that prefer agreement, and an indicator factor $e$ entering the evidence $x_3 = 1$. ],
  stack(
    spacing: 1em,
    chain-graph(),
    chain-tables(),
  ),
)

The HMM recursions were tailored to a chain. Variable elimination uses the same distributive-law trick on any factor graph. In this small example, $e(x_3)=[0,1]$ enters the observation $x_3=1$ as one more factor.

Brute force sums the product of all four factors over $x_1$ and $x_3$. We can instead push each sum next to the factors that mention its variable. The left branch becomes
$ tau_1 (x_2)=[2.2,1.8] $
and the right branch becomes
$ tau_3 (x_2)=[1,2]. $
Their product is $[2.2,3.6]$, which normalizes to $[0.379,0.621]$. The value $5.8$ is the clamped partition value for these unnormalized potentials.

Each $tau$ is a summary of a piece of the graph after its internal variable has been removed. That is also a message. If we eliminate the hidden states of an HMM from left to right, these summaries are the unnormalized forward messages.

$
  tilde(p)(x_2, e) & = sum_(x_1) sum_(x_3) g(x_1) f_A (x_1, x_2) f_B (x_2, x_3) e(x_3) \
  & = underbrace([sum_(x_1) g(x_1) f_A (x_1, x_2)], tau_1 (x_2) = [2.2, 1.8]) thin underbrace([sum_(x_3) f_B (x_2, x_3) e(x_3)], tau_3 (x_2) = [1, 2]) = [2.2, 3.6] \
  p(x_2 | x_3 = 1) & = [2.2, 3.6] \/ 5.8 = [0.379, 0.621]
$

#figure(
  caption: [The running example after variable elimination has summed out $x_1$ and $x_3$: each eliminated branch has become a single factor on $x_2$.],
  chain-eliminated(),
)

#figure(
  caption: [Symbolic variable elimination on the student network (Coherence, Difficulty, Intelligence, Grade, SAT, Letter, Job, Happy). (a) The DPGM. (b) Its moralization; gray dashed edges join co-parents. (c) Eliminating $C$ then $D$ adds no edges. (d) Eliminating $I$ joins its remaining neighbors $G$ and $S$ with a fill-in edge (red). After textbook Figure 9.18, adapted from Koller and Friedman Figure 9.10.],
  student-strip(),
)

On a larger graph we do the same thing repeatedly. Choose a variable, multiply all current factors that mention it, sum it out, and put the resulting factor back into the pool. The table follows the order $C,D,I,H,G,S,L$ for the query $p(J)$.

The graph strip shows the same work without the numbers. Eliminating $C$ and then $D$ creates no new adjacency among the remaining variables. Eliminating $I$ does: its remaining neighbors $G$ and $S$ must be joined, producing both the red fill-in edge and the new factor $tau_3(G,S)$. The graph therefore tells us the scope of the tables before we calculate them.

For a conditional query, first enter the observations as evidence factors, eliminate every variable that is neither observed nor queried, and normalize the final factor.

$
  p(J) & = sum_(L, S, G, H, I, D, C) psi_C (C) psi_D (D, C) psi_I (I) psi_G (G, I, D) \
  & quad quad quad times psi_S (S, I) psi_L (L, G) psi_J (J, L, S) psi_H (H, G, J) \
  & = sum_(L, S) psi_J (J, L, S) sum_G psi_L (L, G) sum_H psi_H (H, G, J) \
  & quad quad quad times sum_I psi_S (S, I) psi_I (I) sum_D psi_G (G, I, D) \
  & quad quad quad times sum_C psi_C (C) psi_D (D, C)
$

#side-discussion[
  In the elimination below, step 4 sums out $H$ from $psi_H (H, G, J)$ alone. If we only want $p(J)$, what is $sum_H psi_H (H, G, J)$ for a directed model, and which variables could we have pruned before starting? (Berkeley CS188, Bayes net inference lecture)
]

#figure(
  caption: [Eliminating the student network in the order $C, D, I, H, G, S, L$ to compute $p(J)$. After textbook Table 9.1.],
  text(size: 9pt, table(
    columns: 4,
    stroke: none,
    align: (center, center, left, left),
    table.hline(),
    table.header([Step], [Eliminate], [Multiply], [New factor]),
    table.hline(),
    [1], [$C$], [$psi_C (C), psi_D (D, C)$], [$tau_1 (D)$],
    [2], [$D$], [$psi_G (G, I, D), tau_1 (D)$], [$tau_2 (G, I)$],
    [3], [$I$], [$psi_S (S, I), psi_I (I), tau_2 (G, I)$], [$tau_3 (G, S)$],
    [4], [$H$], [$psi_H (H, G, J)$], [$tau_4 (G, J)$],
    [5],
    [$G$],
    [$psi_L (L, G), tau_4 (G, J), tau_3 (G, S)$],
    [$tau_5 (J, L, S)$],
    [6], [$S$], [$psi_J (J, L, S), tau_5 (J, L, S)$], [$tau_6 (J, L)$],
    [7], [$L$], [$tau_6 (J, L)$], [$tau_7 (J) = p(J)$],
    table.hline(),
  )),
)

=== Complexity and Hardness
#sidenote(numbered: false)[Textbook: §§9.5.2–9.5.4, pp. 430–433]

#side-discussion[
  Chains and trees have treewidth 1. What is the treewidth of an $n times n$ grid, and what does that imply about exact inference in an image-sized Ising model? (Stanford CS228 notes, "Variable elimination"; Koller & Friedman §9.4)
]

The order matters because a variable's current neighbors become the scope of the temporary computation used to eliminate it. With the order in the table, eliminating $G$ works over $G,J,L,S$. If $G$ is eliminated first, its five neighbors are joined and the temporary table involves six binary variables. Both orders return the same answer; one creates much larger tables.

For finite tabular factors with at most $K$ values per variable, an order of induced width $w$ costs roughly $O(N K^(w+1))$. Treewidth is the smallest induced width over all orders. Chains and trees have treewidth one. Finding the best order is itself hard, so implementations usually use a heuristic such as min-fill.

Exact marginal inference is hard in general; low treewidth is the important easy case for discrete graphical models. Domain size and the algebra of the factors matter too, especially for continuous models. There is also repeated work if we run ordinary variable elimination again for every query. Belief propagation keeps the intermediate results and reuses them.

$
  "cost"(prec) & = sum_(c in cal(C)(G_prec)) K^(|c|) = O(N K^(w_prec + 1)) \
  w_prec & = max_(c in cal(C)(G_prec)) |c| - 1, quad "treewidth" = min_prec w_prec
$

#discussion[
  From the moral graph, choose a cheap variable to eliminate next and an expensive one. What table would each elimination create?
]

== Belief Propagation on Factor Graphs
#sidenote(numbered: false)[Textbook: §§9.3–9.4, 9.6, pp. 412–428, 434]

#figure(
  caption: [The two sum-product rules. Both rules exclude the recipient's own message (dashed): a node never echoes information back to where it came from. After Kschischang, Frey, and Loeliger 2001, Figure 6 (textbook Figure 9.10).],
  sp-rules(),
)

Sum-product can be read as variable elimination cached on the edges. A variable sends a factor the product of the messages from its other neighboring factors. A factor multiplies its table by the messages from its other variables, sums those variables out, and sends the remaining function to the recipient.

The phrase “other neighbors” is important. A node does not immediately send a message back along the edge it came from; doing so would count the same evidence twice. Messages are just nonnegative functions. They do not have to be normalized probability distributions.

On a tree, after messages have crossed every edge in both directions, multiplying the incoming messages at a variable gives its exact marginal up to normalization. The analogous factor belief gives the exact marginal over that factor's scope. Leaf variables begin with an all-ones message, while a leaf factor can send its own table. With bounded factor size, the total work is linear in the number of edges.

$
  p(bold(x)) = 1/Z product_(f in cal(F)) f(bold(x)_f)
$

$
  m_(x arrow.r f)(x) & = product_(h in "nbr"(x) without {f}) m_(h arrow.r x)(x) \
  m_(f arrow.r x)(x) & = sum_(bold(x)_f without x) f(bold(x)_f) product_(x' in "nbr"(f) without {x}) m_(x' arrow.r f)(x') \
  "bel"_x (x) & prop product_(f in "nbr"(x)) m_(f arrow.r x)(x) \
  "bel"_f (bold(x)_f) & prop f(bold(x)_f) product_(x in "nbr"(f)) m_(x arrow.r f)(x)
$

=== Worked Example: Sum-Product on a Chain

#figure(
  caption: [Sum-product on the running example, rooted at $x_2$. Blue messages collect toward $x_2$; red messages distribute back out. Each reply excludes the message received on that edge.],
  align(center, chain-graph(
    msgs: sp-collect + sp-distribute,
    below: sp-beliefs,
    highlight: (3,),
    spacing: 20pt,
    size: 8pt,
  )),
)

Pick $x_2$ as the root and collect messages from both ends. From the left, $g$ sends $[0.6,0.4]$ through $x_1$. The factor $f_A$ then sums out $x_1$ and sends $[2.2,1.8]$. From the right, the evidence sends $[0,1]$ through $x_3$, and $f_B$ sends $[1,2]$. Their product at $x_2$ is $[2.2,3.6]$, giving the belief $[0.379,0.621]$ after normalization.

Now distribute back out. Toward $x_1$, $x_2$ sends only the information that arrived from the right, namely $[1,2]$. After $f_A$ sums over $x_2$, its message is $[5,7]$. Multiplying by $g$ gives $[3.0,2.8]$, or $[0.517,0.483]$. The same calculation toward $x_3$ gives $[0,1]$, as it must because $x_3$ was observed.

These are the same intermediate factors produced by variable elimination, but now they stay on the edges. The four-row table below gives a direct check: its entries sum to $5.8$, and summing the appropriate rows reproduces the variable beliefs.

#figure(
  caption: [Brute-force check. With $x_3 = 1$ fixed, the unnormalized joint $g(x_1) f_A (x_1, x_2) f_B (x_2, 1)$ has four terms. It is also the factor belief $"bel"_(f_A)(x_1, x_2)$ before normalization.],
  text(size: 9pt, table(
    columns: 4,
    stroke: none,
    align: center,
    table.hline(),
    table.header(
      [$(x_1, x_2)$], [product], [$tilde(p)$], [$p(x_1, x_2 | x_3 = 1)$]
    ),
    table.hline(),
    [$(0, 0)$], [$0.6 dot 3 dot 1$], [$1.8$], [$0.310$],
    [$(0, 1)$], [$0.6 dot 1 dot 2$], [$1.2$], [$0.207$],
    [$(1, 0)$], [$0.4 dot 1 dot 1$], [$0.4$], [$0.069$],
    [$(1, 1)$], [$0.4 dot 3 dot 2$], [$2.4$], [$0.414$],
    table.hline(),
    [], [], [$Z = 5.8$], [],
  )),
)

#discussion(vspace: 0em)[
  Remove the evidence factor $e$. What message does $f_B$ send to $x_2$? Why does an unobserved leaf carry no information?
]

=== Exact Inference on Trees
#sidenote(numbered: false)[Textbook: §§9.3.2, 9.5.5–9.6, pp. 414–415, 433–434]

#figure(
  caption: [On a tree, the message a factor sends toward $x$ is the sum over the whole subtree behind it (blue region), and different neighbors' subtrees (blue, red) share no variables. Multiplying all messages into $x$ therefore sums the full joint over everything except $x$.],
  subtree-sum(),
)

For a tree, choose any node as a root. In the collect pass, messages move from the leaves toward the root. In the distribute pass, they move back out. Each edge carries one message in each direction, after which every variable and factor belief is exact.

The reason is visible in the shaded-subtree figure. A message across an edge is the sum of the product of all factors on one side of that edge. Different branches of a tree share no variables, so the distributive law lets us compute each branch separately and multiply the summaries at the receiving node. The root changes the schedule, not the answer.

The HMM is the same algorithm on a chain-shaped factor graph. The message arriving from the left transition is the forward prediction, the message from the right is $beta_t$, and their product with the local evidence gives $gamma_t$. In a linear-Gaussian chain, the same pattern gives the Kalman smoother.

For graphs with cycles, exact inference can still be organized by a junction tree: combine variables into cliques, connect those cliques as a tree, and pass messages between them. This reuses work across marginals, but its clique tables remain exponential in treewidth.

#figure(
  caption: [The HMM as a factor graph. Square nodes are the transition factors $A_t (z_(t-1), z_t) = A_(z_(t-1) z_t)$ and the local evidence factors $lambda_t$. Sum-product messages into $z_t$ from the left and right transition factors are exactly the forwards prediction $alpha_(t|t-1)$ and the backwards message $beta_t$.],
  hmm-factor-graph(),
)

$
  m_(z_(t-1) arrow.r A_t)(z_(t-1)) & = lambda_(t-1)(z_(t-1)) thin m_(A_(t-1) arrow.r z_(t-1))(z_(t-1)) prop alpha_(t-1)(z_(t-1)) \
  m_(A_t arrow.r z_t)(z_t) & = sum_(z_(t-1)) A_(z_(t-1) z_t) thin m_(z_(t-1) arrow.r A_t)(z_(t-1)) prop alpha_(t|t-1)(z_t) \
  m_(A_(t+1) arrow.r z_t)(z_t) & = sum_(z_(t+1)) A_(z_t z_(t+1)) thin lambda_(t+1)(z_(t+1)) thin m_(A_(t+2) arrow.r z_(t+1))(z_(t+1)) = beta_t (z_t) \
  "bel"_(z_t)(z_t) & prop alpha_(t|t-1)(z_t) thin lambda_t (z_t) thin beta_t (z_t) prop gamma_t (z_t)
$

#side-discussion[
  The sum-product answer does not depend on which node we choose as the root. Why not? And which step of the argument would fail if the graph had a single cycle? (MacKay, _Information Theory, Inference, and Learning Algorithms_, Ch. 16, "counting soldiers")
]

=== Max-Product
#sidenote(numbered: false)[Textbook: §9.3.3, pp. 415–417]

#figure(
  caption: [Max-product on the running example. Each max-marginal peaks at $2.4$ and points to the MAP assignment $(x_1,x_2)=(1,1)$.],
  wideblock(align(center, chain-graph(
    msgs: mp-msgs,
    below: mp-beliefs,
    highlight: (1, 3),
    spacing: 28pt,
    size: 9pt,
  ))),
)

Max-product changes one operation: factor nodes maximize over their other variables instead of summing them out. The resulting max-marginal $zeta_i (k)$ is the score of the best complete assignment having $z_i=k$. On an HMM this is Viterbi.

For the running example, $f_A$ sends $[1.8,1.2]$ and $f_B$ sends $[1,2]$, so $zeta_2=[1.8,2.4]$. Passing back toward $x_1$ gives $[3,6]$, and multiplication by $g$ again produces $[1.8,2.4]$. Both max-marginals point to the joint MAP assignment $(1,1)$, whose unnormalized score is $2.4$.

Sum-product answers a different question. Its marginal modes are $(0,1)$: $x_1=0$ is slightly more likely after summing over $x_2$, even though the best joint assignment uses $x_1=1$. Marginal modes minimize expected per-variable mistakes; joint MAP minimizes the chance that the whole assignment is wrong. If max-marginals tie, independent choices may not form a valid MAP assignment, so keep backpointers.

$
  m_(f arrow.r x)(x) = max_(bold(x)_f without x) f(bold(x)_f) product_(x' in "nbr"(f) without {x}) m_(x' arrow.r f)(x')
$

$
  gamma_i (k) & = sum_(z_(-i)) p(z_i = k, z_(-i) | y), & hat(z)_i & = limits("argmax")_k gamma_i (k) & quad "(MPM)" \
  zeta_i (k) & = max_(z_(-i)) tilde(p)(z_i = k, z_(-i), y), & tilde(z)_i & = limits("argmax")_k zeta_i (k) & quad "(MMM)" \
  & & z^* & = limits("argmax")_z p(z | y) & quad "(MAP)" quad quad quad
$

=== Loopy Belief Propagation
#sidenote(numbered: false)[Textbook: §9.4, pp. 417–428]

#sidenote(
  numbered: false,
)[J. S. Yedidia, W. T. Freeman, and Y. Weiss, #link("https://doi.org/10.1109/TIT.2005.850085")["Constructing free-energy approximations and generalized belief propagation algorithms"], _IEEE Trans. Information Theory_ 51(7), 2005.]

#figure(
  caption: [(a) A simple loopy graph. (b) Its computation tree rooted at node 1 after three rounds of message passing. Evidence at node 4 (shaded) reaches node 1 along two different branches, and the original variables recur in several places. After textbook Figure 9.12, from Wainwright and Jordan 2008.],
  loopy-comp-tree(),
)

The local message rules still make sense on a graph with cycles. Initialize the messages, update them repeatedly, and stop if they settle down. This is _loopy belief propagation_. Unlike the tree case, it may oscillate, and a fixed point need not give the exact marginals.

The computation tree explains the trouble. After a few rounds, loopy BP at node 1 behaves like exact BP on the unrolled tree in the figure. The same original variable appears in several places, so its evidence can return along more than one route. Thinking of this as “echoing” or double counting is useful: weak, distant influence may die away, while strong influence can be repeated and make beliefs unstable or too sharp. Sparse coding graphs are often locally tree-like, which is one reason BP works remarkably well for decoding.

Damping mixes a new message with its old value. Asynchronous and residual schedules change which message is updated next. These tricks often help convergence, but they do not make the answer exact. The Ising example shows both points: one schedule oscillates, while another converges to the wrong value for $X_17$.

There is a useful bridge to the next lecture. Fixed points of loopy BP correspond to stationary points of the Bethe free energy, an approximation to the exact variational objective. This does not mean the ordinary message updates steadily minimize that objective, but it does put loopy BP in the same larger family of approximate inference ideas.

$
  m^((k))_(f arrow.r x) = lambda thin tilde(m)^((k))_(f arrow.r x) + (1 - lambda) thin m^((k-1))_(f arrow.r x), quad 0 < lambda <= 1
$

#figure(
  align(left, image("Figures/textbook-lbp-convergence.png", width: 125%)),
  caption: [Loopy BP on an $11 times 11$ Ising grid with random couplings $w_(i j) tilde "Unif"(-C, C)$, $C = 11$. (a) Fraction of messages converged over time for damped synchronous (dotted), undamped asynchronous (dashed), and damped asynchronous (solid) schedules. (b–f) Marginal beliefs of individual nodes over time against the true marginal (straight line). Reproduced from Murphy, Textbook Figure 9.13, p. 422, originally Koller and Friedman Figure 11.C.1 (CC BY-NC-ND).],
)

#side-discussion[
  How should a smaller damping value $lambda$ change the speed and stability of the updates?
]

#discussion[
  In panel (f), the messages converge but the belief for $X_17$ is wrong. What does this say about using convergence as evidence that inference succeeded?
]

#discussion[
  Exact inference is fast on a chain but hard on a general graph. What changes as treewidth grows? Besides graph width, what can make a local elimination step expensive?
]

#figure(
  caption: [The algorithms of this section at a glance. $K$ is the number of states per variable, $T$ the chain length, $N$ the number of variables, $w$ the induced width of the elimination order, and $d_max$ the largest factor arity.],
  algorithm-summary(),
)

All of these methods avoid repeating the same sums. On chains and trees this gives efficient exact inference. On wide graphs the intermediate factors become too large, and some continuous factors are hard to integrate even when the graph is simple.

Next we give up exactness. Variational inference fits a tractable distribution $q$ by optimization; Monte Carlo uses samples. The next lecture starts by asking what the best fully factorized $q$ looks like.
