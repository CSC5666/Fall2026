#import "wdf.typ": *
#import "inference-figures.typ": *

#show: template.with(
  title: [Monte-Carlo Methods],
  title-short: none,
  authors: "CSC 5666: Advanced Machine Learning, Fall 2026",
  authors-short: none,
  title-extra: [Professor Austin P. Wright: Course Notes],
  date: none,
  toc: false,
  full: false,
  header-content: none,
  abstract: [Introduction to sampling-based Bayesian inference, including ancestral and rejection sampling, likelihood weighting, importance sampling, Monte Carlo error, and Gibbs sampling as preparation for Markov chain Monte Carlo. See textbook Chapter 11 for more detail.],
  bib: none,
  serif: true,
  exam: false,
)

#sidenote(dy: 1.15em, numbered: false)[#outline(depth: 1)]

= Inference by Sampling
#sidenote(numbered: false)[Textbook: Chapter 11, especially §§11.1–11.3]

In the previous lecture we turned Bayesian inference into an optimization problem. Given the problem of making inferences from an intractable posterior $p(z|x)$, we chose a tractable family $cal(Q)$ and found one $q(z)$ meant to stand in for the posterior $p_theta (z|x)$. This forms one class of approximate solution, sampling gives us another representation.

Instead of approximating the intractable posterior through a functional approximation, we can form estimates from the fundamental insight that _distributions_ are essentially the generalization of _histograms_, and that information about a distribution can be reconstructed by sampling enough times.

Most of the questions we ask of a posterior are expectations:
$
  mu_f = EE_(p_theta (z|x))[f(z)]
  = integral f(z)p_theta (z|x)dif z.
$
For discrete $z$, replace the integral with a sum. The function $f$ could return one coordinate of $z$, a prediction, an indicator of an event, or the loss from an action. If we have a way to sample $z_(1),dots,z_(S)$ as independent draws from the posterior#sidenote()[And this is in fact not a contradiction with the intractability of the posterior. It is a common occurance in many classes of problem where the _forward mode_ generally might be easy (generating samples), while the _inverse problem_ (learning the whole distribution) is difficult.], then
$
  hat(mu)_f = 1/S sum_(s=1)^S f(z_(s)).
$ <mc-estimator>
For integrable $f$, the law of large numbers ensures this will convergence. With finite variance, its standard deviation is $sqrt("Var"[f(z)]/S)$.

#def(
  term: [Monte-Carlo approximation ],
)[
  The general stragetegy of a Monte-Carlo approximation #sidenote()[Monte-Carlo is a famous gambling center Monaco near France. We will follow the long and storied history of the connection between probability theory and gambling. But remember, if there ends up being on takeaway from this work it is generally that the house always wins and so dont gamble kids!] is to replace an expectation under a difficult distribution with an empirical average over samples. We must ask both whether the sampling procedure targets the right distribution and whether it provides enough information about the particular function $f$ that we care about.
]

In this general approach there are three cases to keep separate which we will introduce. In the ideal case we have independent draws from the target and use an ordinary average. Importance sampling will work be taking independent draws from another distribution and correcting them with weights. Markov Chain Monte-Carlo (MCMC) will sample a _dependent_ sequence whose long-run distribution is the target. We will reach the third case through Gibbs sampling, but leave the general construction and diagnostics of Markov chains to the next lectures.

== Compared with Variational Inference

The approximation trade-off for VI is fundamentally different than the trade-off for Monte-Carlo methods, so it bears emphasis here. VI can miss dependence or entire modes even if its optimizer succeeds, because it is limited to the variational model class $Q$. A good sampler is not restricted to that family, but a finite run #sidenote()[And while we like to show mathematical properties of the infinite horizon convergence properties, every actual inference computation is in fact finite.] may never fully cover all of the modes. These are different failures.

The practical contrast is still useful. VI returns a compact distribution, and can answer many new inference problems quickly after the posterior approximation has been trained. Sampling may return independent, weighted, or correlated draws and often has to be rerun for a new posterior. On the other hand, samples can preserve complicated dependence and can be fed directly into predictions and decisions.

#discussion(vspace: 20em)[
  Consider the pros and cons of sampling vs variational approximations for approximate inference. Describe a data/model/analysis task where each methods would be prefered#sidenote()[Obviously we have not yet defined the specific details of Monte-Carlo/Sampling approaches, so you can keep the comparison high level and conceptual], and explain why.
]

= Ancestral Sampling

Recall that a Bayesian Network or DPGM factorizes the joint distribution as
$
  p(x_(1:n))=product_(i=1)^n p(x_i|"parents"(x_i)).
$

One of the benefits of this directed model is that this is also a recipe for sampling the joint. Visit variables in topological order and sample each node conditional on the parent values already sampled. For $A arrow.r B$, first draw $a∼p(A)$ and then $b∼p(B|A=a)$. The pair $(a,b)$ is a draw from $p(A,B)$. This is often called _prior sampling_ since it runs the generative model forward without using evidence.

== A Running Emergency-Response Model

We will use one small network for the next three methods. All six variables are binary: $F$ is fire, $E$ earthquake, $H$ heat, $S$ smoke, $A$ alarm, and $C$ a call to emergency services. We observe $H=1$ and $A=1$ and want $P(E=1|H=1,A=1)$.

#figure()[
  #diagram(
    edge-stroke: 0.75pt,
    node-corner-radius: 10pt,
    node-stroke: 1pt,
    edge-corner-radius: 10pt,
    node((0, 0), [$F$], name: <f>),
    node((1, -0.5), [$H$], name: <h>, fill: luma(85%)),
    node((1, 0.5), [$S$], name: <s>),
    node((2, 0.5), [$A$], name: <a>, fill: luma(85%)),
    node((1, 1.3), [$E$], name: <e>),
    node((3, 0.5), [$C$], name: <c>),
    edge(<f>, <h>, "->"),
    edge(<f>, <s>, "->"),
    edge(<s>, <a>, "->"),
    edge(<e>, <a>, "->"),
    edge(<a>, <c>, "->"),
    edge(<e>, <c>, "->"),
  )
]

We can define all of the conditional probabilities for the model as follows

$
  P(F=1) & =0.001, & P(E=1) & =0.0001, \
$
$
  P(H=1|F=1) & =0.8, & P(H=1|F=0) & =0.1, \
  P(S=1|F=1) & =0.9, & P(S=1|F=0) & =0.2,
$
$
  P(A=1|S=0,E=0) & =0.01, & P(A=1|S=1,E=0) & =0.8, \
  P(A=1|S=0,E=1) & =0.9,  & P(A=1|S=1,E=1) & =0.99.
$
$
  P(C=1|A=0,E=0) & =0.01, & P(C=1|A=1,E=0) & =0.9, \
  P(C=1|A=0,E=1) & =0.2,  & P(A=1|S=1,E=1) & =0.7.
$ <emergency-cpts>

We will use this example to illustrate the basic approaches to Monte-Carlo sampling. Consider, however, how the approached discussed will generalize in continuous contexts, and where entities like _parameters_ for such contexts will fit.

= Rejection Sampling

For the moment assume the evidence variables are discrete. If we can sample $(z,x)$ from the joint using ancestral sampling, we can then filter out samples that are not consistent with the actual observed evidence. The retained latent values have distribution
$
  p_theta (z|x^*)=(p_theta (z,x^*))/(P_theta (X=x^*)).
$
Among the retained draws, the mass or density at $z$ is proportional to the numerator; restricting attention to that population performs the normalization. In a Bayes net we can abandon a draw as soon as an evidence node disagrees with its observed value. That saves downstream calculations but does not change the acceptance probability $P_theta (X=x^*)$. #sidenote()[This exact-match procedure is useless for a continuously distributed observation, where $P(X=x^*)=0$. Accepting a neighborhood instead leads to a different, approximate procedure rather than exact rejection conditioning.]

#discussion(vspace: 4em)[
  Sample the emergency network in the order $F,H,E,S,A,C$. For each sequence, cross out every draw that could be avoided after the first contradiction with $H=1,A=1$:

  $[F=1,H=1,E=1,S=1,A=1,C=1]$

  $[F=1,H=0,E=1,S=0,A=1,C=0]$

  $[F=0,H=1,E=0,S=0,A=0,C=1]$

  Why does stopping early change computation but not the distribution of retained samples?
  #v(10em)
  What about the above samples I have given you hides the actual downside and cost of rejection sampling?
  #v(5em)
]

When the evidence is rare, rejection is hopeless. If any conditional distribution has very low probability (which becomes progressively more true with longer chains), we may end up rejecting the vast majority of our samples! The temptation is to force the evidence to its observed value. That avoids rejection, but it also removes the evidence factors from the probability of the sampled state. We need to put them back.

= Importance Sampling and Likelihood Weighting

Importance sampling draws from a convenient proposal $q(z)$ and corrects for using the wrong distribution. We require $p(z|x)>0 arrow.r q(z)>0$ up to null sets; then
$
  EE_(p(z|x))[f(z)]
  = (EE_(q)[w(z)f(z)])/(EE_(q)[w(z)]),
  quad w(z)=(p(z,x))/(q(z)).
$
Given $z_(s)∼q$, we estimate this ratio by
$
  hat(mu)_f=
  (sum_s w_s f(z_(s)))/(sum_s w_s).
$ <importance-estimator>
The unknown evidence cancels. The price is that this self-normalized ratio is generally biased at finite $S$, though consistent under standard support and moment conditions. It is undefined if every weight is zero.#sidenote()[With many evidence factors, compute log weights and normalize with log-sum-exp to avoid numerical underflow.]

_Likelihood weighting_ is the Bayes-net version. Clamp evidence, sample each non-evidence node in topological order, and multiply the weight by the conditional probability of each clamped value:
$
  q(z)=product_(i in "latent")
  p(z_i|"parents"(z_i)),
$
$
  w(z)=product_(j in "observed")
  p(x_j^*|"parents"(x_j)).
$ <likelihood-weight>


#discussion(vspace: 13em)[
  For the query $P(E=1|H=1,A=1)$, consider four likelihood-weighted draws of the non-evidence variables:
  $
    z_(1) & =[F=1,E=0,S=1,C=0] \
    z_(2) & =[F=1,E=0,S=1,C=1] \
    z_(3) & =[F=0,E=1,S=0,C=1] \
    z_(4) & =[F=0,E=0,S=0,C=0].
  $
  Use @emergency-cpts to calculate each weight. Then calculate the self-normalized estimate of the query and @weight-ess. Why do samples 1 and 2 receive the same weight even though $C$ differs?
]

In liklihood wieghting we now can ensire that every sample is actually used, however it remains that for low probability events a few large weights may dominate. We can try to at least measure this, and common weight-concentration diagnostic is
$
  "ESS"_w=(sum_s w_s)^2/(sum_s w_s^2).
$ <weight-ess>

If at least one finite weight is positive, this lies between $1$ and $S$. It ignores $f(z)$, so it is not a universal statement about the accuracy of every query which may have a different weighting of certain regions of $z$ as important.

#discussion()[
  Let $R$ indicate a rare condition and let $T=1$ denote a negative test result:
  $
        P(R=1) & =0.01, \
    P(T=1|R=1) & =0.1, quad P(T=1|R=0)=0.9.
  $
  For $P(R=1|T=1)$, likelihood weighting samples $R$ from its prior and clamps $T=1$.

  Consider sampling 1000 times. About how many samples would you expect to see with $R=1$ and $R=0$? What would be their weights? Calculate the ESS for this expected sample, compared to the sample size of 1000. What is the issue with using ESS in this case when assessing the reliability of the process for diagnosis of the rare condition?
]

#pagebreak()
= Gibbs Sampling: The First Markov Chain

Instead of starting from the "top" of the network and sampling through, for Gibbs sampling we will do operations over the whole network in a more distributed style. This may allow us to have the influence of evidence "flow both ways" where in likelihood weighting the evidence influences choices of children, but does not effect the samples of parents even though the evidence does give us information about the parents. For Gibbs sampling we want to consider the evidence when we sample _every variable_. We do this by building a sequence of complete states, such that in the long run the distribution of the sequence matches the joint.

If $x^((t))$ is the entire current state immediately before one coordinate update, draw
$
  x_i'∼p(x_i|x_(-i)^((t))),
  quad x^((t+1))=(x_i',x_(-i)^((t))).
$ <gibbs-transition>

The distribution of the next state depends on the current state, not the earlier history. That is the Markov property, and @gibbs-transition is a transition rule for the chain.

To do this we start by setting all of the variables in the network to completely random values (entirely ignoring the conditional distributions). We then repeatedly choose one variable at a time (not in any kind of deterministic topological order), clear its current value, and resample the value given the current assigned values of its markov blanket. Note that this is _the whole markov blanket_, not just the parents, since we are treating all variables in the network as conditions, and thus we need to condition on the whole set of conditional variables to isolate the sampled variable from the rest of the network. Luckily this generalization of the provided Bayes Net conditionals can be calculated once before the sampling process using only the set of local conditional distributions of the blanket.

$
  p(x_i|x_(-i)) prop p(x_i|"parents"(x_i))
  product_(X_j in "children"(X_i))
  p(x_j|"parents"(x_j)).
$ <gibbs-blanket>
Normalize over the possible values of $x_i$. Parents, children, and co-parents enter through these local terms. Evidence variables remain fixed.

Over many iterations, our samples will eventually converge to the correct distribution#sidenote()[Except in some pathological cases which can generally be addressed by performing Gibbs sampling multiple times with different initializations.]. We can see how evidence can be accounted for by simply setting the evidence variables to the evidence values and never selecting evidence variables to resample from. Since we are including all of the relevant conditional distributions at each resample we do not have the same problem as naive sampling from above (since for each actual resample we are treating the whole rest of the network as fixed conditional anyway.) You can also notice how each sample is built from the previous sample in a "chain", which is _precisely_ the chain in Markov Chain Monte Carlo methods which we will develop in general in the coming lectures.

#discussion(vspace: 2em)[
  In the emergency model, let the current state have $F=1,E=0,S=1,C=1$, with $H=1,A=1$ clamped. Use @emergency-cpts to resample $S$.

  First write one unnormalized score for $S=0$ and one for $S=1$. Normalize them to find $P(S=0|F=1,E=0,A=1)$. Which factors in the joint cancel? Why can alarm evidence now affect smoke even though the generative arrow points from smoke to alarm?
]

Note that there are a few important caveats to this distribution.
+ The resultant samples are _highly dependent_ (since each sample will only differ from the previous sample in precisely one variable). This is sometimes addressed with _subsampling_ where we only include every $k^("th")$ sample in our final sample set.
+ It requires a "burn in" period where the initial samples are very unlikely due to the random initialization
+ Gibbs relies on being able to explore the whole sample space eventually  (and in principle visit each node infinitely many times). Since the initialization is a random and unlikely value, and each update only updates a single variable, if variables are strongly correlated enough to effectively "wall off" certain regions of the joint, convergence may be impossible or highly unlikely. This is frequently a consequence of the "curse of dimensionality".

However, in the limit of a large number of samples#sidenote()[Of course, with such methods what constitutes a sufficiently large sample for representativeness and convergence is not generally known ahead of time and so may be an issue.] (and frequently with the ability to throw out some predetermined amount of the initial samples) this still acts as a valid sampler.


#discussion()[
  Consider a two variable joint distribution where the probability distribution is uniform over a finite "checkerboard" in a continuous domain. What might be an issue with Gibbs sampling for this problem? Would likelihood weighting have the same problem?
]


#discussion()[
  Consider a joint distribution over 100-bit vector where the probability distribution is uniform over all vectors except for the zero vector which has probability $1/2$. What happens with Gibbs sampling when we have a value in the nonzero region? What about the zero region? What does this imply about the effectiveness of Gibbs sampling in this context? Would likelihood weighting have the same problem?
]

#discussion()[Consider a Gibbs run which gives a smooth trace and stable average, but every chain began in the same posterior mode. A mean-field VI run finds that mode with its best ELBO. What does each result support? What does neither support? What would you try next?]
