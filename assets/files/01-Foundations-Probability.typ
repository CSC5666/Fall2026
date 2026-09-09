#import "wdf.typ": *

#show: template.with(
  title: [Foundations and Probability],
  title-short: none,
  authors: "CSC 5666: Advanced Machine Learning, Fall 2026",
  authors-short: none,
  title-extra: [Professor Austin P. Wright: Course Notes],
  date: none,
  toc: false,
  full: false,
  header-content: none,
  abstract: [Introduction to the fundamentals of Probability Theory and Bayesian Statistics the rest of the course will be built on. Closely follows Chapters 2–3 of Murphy's textbook.],
  bib: none,
  serif: true,
  exam: false,
)

#sidenote(dy: 1.15em, numbered: false)[#outline(depth: 2)]

= Probability

In this course we are interested in learning from data, and the fundamental position from which learning is possible is through uncertainty. The best tool we have in understanding uncertainty is the theory of probability, which we will introduce in a semi-formal way here in order to give you at least the conceptual understanding of the mathematical objects we will be working with.


== Probability spaces and random variables
#sidenote(numbered: false)[Textbook: §2.1, pp. 5–8]

#def(term: "Probability space")[ A probability space (
  $Omega, cal(F), PP$
) consists of a sample space $Omega$ of all possible outcomes of some experiment, an event space $cal(F)$ of subsets of $Omega$ closed under complements and countable unions, and a measure#sidenote(dy:10em)[This course will not be going into the nuances of Measure Theory which are the "foundations of the foundations" for us since Measure theory is how Probability theory is built. However for the working computer scientist, we can stop the regress of foundations here.] $PP: cal(F) arrow.r [0,1]$ that assigns a size to each event.]

The process of *sampling* from the probability space produces an outcome $o in Omega$, but we cannot say which specific outcome. Instead the probability measure is what determines which outcomes are more or less likely. All uncertainty in probability theory, and thus in all of our models, derives from this foundational uncertainty of outcomes of sampling based on a probability measure. This process is a sufficiently general and expressive source of uncertainty that we can then develop the theories of probability around different properties of objects that relate to or structure probability spaces.

An *event* $E in cal(F)$ is a set of outcomes, where if the outcome of a sample ($o in Omega$) is in $E$ ($o in E$), the event is considered to have occurred. A *random variable* $X: Omega arrow.r cal(X)$ reads off a numerical or categorical summary of an outcome.  We almost always work with the distribution $X$ induces on $cal(X)$ and never touch $Omega$ directly, the same way nobody enumerates "every possible atmospheric state" when they check tomorrow's forecast, instead we look at the distribution of likely temperatures.

#pagebreak()
We define the fundamental properties of a probability space using the Kolmogorov Axioms. #sidenote()[Cox's theorem: any scheme for reasoning under uncertainty that satisfies a few common-sense desiderata is *forced* to reduce to the sum and product rules.]

#def(term: "Kolmogorov axioms")[
  - $PP(E) >= 0$.
  - $PP(Omega)=1$.
  - For disjoint ${E_i}$, $PP(union.big_i E_i)=sum_i PP(E_i)$.


]
#discussion(vspace: 0em)[
  Based on the Kolmogorov axioms, derive the values of:
  + $PP(not E) =$
  + $PP(A union B) = $
]

#discussion(vspace: 4em)[
  Consider the case of sampling the values of two fair dice. One is green and the other is gold, and the result is always read in order of green then gold.

  + Define $Omega$ as ordered outcomes. Would it be different with two green die?
  + List the event sets $S={"sum is 8"}$ and $D={"at least one die is 3"}$.
  + Compute $PP(S)$ and $PP(D)$, then locate $S inter D$ before computing $PP(S union D)$.
  + Check the result two ways: inclusion–exclusion (i.e. event union) and direct counting. Which mistake does the second method expose?
  + Two dice give a small number of outcomes that is easy to list by hand. A poker hand is $5$ cards from a $52$-card deck: about $2.6$ million possibilities. Nobody computes poker odds by listing hands one at a time. What do people (and computers) do instead?
]

== Distributions and summaries
#sidenote(numbered: false)[Textbook: §2.2, pp. 8–22]

Once we have a random variable, we describe it directly on its range rather than returning to $cal(F)$.

#def(term: "pmf, pdf, and cdf")[
  For discrete $X$, the probability mass function is $p_X(x)=PP(X=x)$ and $sum_x p_X(x)=1$.

  For continuous $X$, a probability density satisfies $p_X(x)>=0$ and $integral p_X(x) dif x=1$, with
  $PP(a < X <= b)=integral_a^b p_X(x) dif x$.
  *Note that a density value is not a probability.*

  In either case, the cumulative distribution function is $F_X(x)=PP(X<=x)$.
]

#def(term: "Expectation and variance")[
  $ EE[g(X)] = cases(
    sum_x g(x)p_X(x) & "discrete",
    integral g(x)p_X(x) dif x & "continuous",
  ) $

  We then define common statistics thusly:
  - $mu=EE[X]$
  - $VV[X]=EE[(X-mu)^2]=EE[X^2]-EE[X]^2$
  - $"Cov"(X,Y)=EE[(X-EE[X])(Y-EE[Y])]$.
]

Using these definitions we can see some of the algebraic properties of expected values:

+ Linearity always holds for means, $EE[a X+b Y]=a EE[X]+b EE[Y]$
+ Variances add only when covariance vanishes: $VV[X+Y]=VV[X]+VV[Y]+2"Cov"(X,Y)$.#sidenote()[This is part of why we care so much about independence, it makes certain transformations possible.]

#v(1fr)
== Joint, marginal, and conditional distributions
#sidenote(numbered: false)[Textbook: §2.1.5–2.1.6, pp. 7–8]

A model of several variables starts from their *joint distribution* $p(x,y)$. We can then *marginalize* over a random variable to reconstruct individual distributions:
$
  p(x)=sum_y p(x,y) quad "or" quad p(x)=integral p(x,y) dif y.
$

We then can define the *conditional probability* as the probability of some event occurring, _given that some other event is already known_. What this involves is considering the intersection of the events, and renormalizing to ensure the conditional probability meets the Kolmogorov axioms, that is conditioning forms a kind of "new probability space" where some of our uncertainty has been concretized.
#def(term: "Conditional probability")[
  For $p(y)>0$,
  $ p(x|y) = (p(x,y))/(p(y)), quad p(x,y)=p(x|y)p(y). $
  Conditioning selects outcomes compatible with $y$, then renormalizes.
]

Repeated use of the product rule gives the *chain rule*:
$
  p(x_(1:N))=p(x_1) product_(n=2)^N p(x_n|x_(1:n-1)).
$
The *law of total probability* follows by marginalization:
$
  p(y)=sum_x p(y|x)p(x).
$

#def(term: "Independence")[
  $X$ and $Y$ are independent, $X tack.t.t Y$, if an only if
  $p(x,y)=p(x)p(y)$ for every $x,y$.

  They are conditionally independent given $Z$, $(X tack.t Y) | Z$, if and only iff
  $p(x,y|z)=p(x|z)p(y|z)$ for every relevant $x,y,z$.
]

Independence is a strong claim, in fact strictly speaking real variables are rarely exactly independent. Conditional independence is weaker, and it's what makes big joint distributions tractable because the factorization ensures that each distribution can be relatively small to keep track of, as the amount of data to represent a larger joint distribution increases combinatorialy with the number of dependent variables. #sidenote()[This is the reason we care about graphical models to express independence assumptions, as these assumptions are nearly always present and have a huge impact on how we can model distributions.]

#figure(
  caption: [A common cause can induce dependence that disappears after conditioning.],
  diagram(
    edge-stroke: 0.8pt,
    node-corner-radius: 8pt,
    node-stroke: 0.8pt,
    node((0, 0), [$P$], name: <prep>),
    node((-1, 1), [$E$], name: <exam>),
    node((1, 1), [$S$], name: <sleep>),
    edge(<prep>, <exam>, "->"),
    edge(<prep>, <sleep>, "->"),
  ),
)

#discussion(vspace: 5em)[
  Let $P$ be preparation, $E$ exam score, and $S$ sleep the night before.

  + Write the unrestricted factorization $p(p,e,s)$ using the chain rule.
  + Read the diagram above as representing the joint as $
     p(p,e,s) = p(p)p(e|p)p(s|p)
     $ Which term was simplified, and what assumption licenses dropping it?
  + Decide whether $E tack.t.t S$ and whether $E tack.t.t S | P$ must hold.
  + Give one omitted variable that would make the conditional-independence claim implausible (something that affects both sleep and exam performance directly). Redraw the model.
]

== Bayes' rule
#sidenote(numbered: false)[Textbook: §2.1.6, p. 8]

Based on our definitions so far developed, we can do some simple algebra to derive some interesting relationships within the joint $p(x,y)$.
$
  p(x|y)=(p(y|x)p(x))/(p(y))
       =(p(y|x)p(x))/(sum_(x')p(y|x')p(x')).
$

Despite this simplicity, this equation forms the fundamental structure of Bayesian modeling. and is sometimes called "the most important equation in all of artificial intelligence".

#def(term: "Bayesian vocabulary")[
  $ underbrace(p(x|y))_"posterior"
    = (underbrace(p(y|x))_"likelihood" underbrace(p(x))_"prior") /
      underbrace(p(y))_"evidence". $

  As a function of $x$, $p(y|x)$ need not normalize. Therefore
  $p(x|y) prop p(y|x)p(x)$ is often the useful form.
]


#discussion(vspace: 3em)[
  A disease has prevalence $0.01$; a test has sensitivity $0.95$ and false-positive rate $0.05$.

  + Predict whether $PP("disease"|"positive")$ is above or below $1/2$.
  + Recompute using Bayes' rule and reconcile the two answers.
  + Which single change, to prevalence, sensitivity, or specificity, would most improve the posterior here?
]

== Useful distribution families
#sidenote(numbered: false)[Textbook: §2.2, pp. 8–22]

Picking a likelihood means picking a family for each observed or latent quantity. Start from *support* which is what values are even possible, then worry about shape.

- Bernoulli$(theta)$: one binary outcome, Binomial$(N,theta)$: multiple trials count.
- Categorical$(arrow(theta))$: one of $K$ classes; Multinomial$(N,arrow(theta))$: class counts.
- Poisson$(lambda)$: count in a fixed rate, mean equal to variance
- Exponential$(lambda)$: positive waiting time between events.
- Beta$(alpha,beta)$: probability in $[0,1]$; Dirichlet$(arrow(alpha))$: probability vector.
- Gaussian $cal(N)(mu,sigma^2)$
- Multivariate Gaussian $cal(N)(arrow(mu),Sigma)$

#discussion(vspace: 4em)[
  A city's 911 dispatch center wants a likelihood for:
  + whether a given call is a false alarm (yes/no);
  + calls received per hour;
  + time until the next call arrives;
  + call counts split across four neighborhoods.

  For each, name its parameter and one implied assumption. Then diagnose: which of these breaks under a holiday surge, a lull between shifts, or a single caller placing repeated calls, and what would you switch to?
]

== Gaussian systems
#sidenote(numbered: false)[Textbook: §2.3, pp. 22–33]

The Gaussian is mathematically convenient enough that whole model families are built from nothing else.

#def(term: "Multivariate Gaussian")[
  For $arrow(x) in RR^D$,
  $ cal(N)(arrow(x)|arrow(mu),Sigma)
    =(2pi)^(-D/2)|Sigma|^(-1/2)
      exp(-1/2 (arrow(x)-arrow(mu))^T Sigma^(-1)(arrow(x)-arrow(mu))). $
  $Sigma$ is symmetric positive semidefinite; its diagonal stores variances and its off-diagonal stores covariances.
]

- If $arrow(x) tilde cal(N)(arrow(mu),Sigma)$ and $bold(y)=A arrow(x)+bold(b)+bold(epsilon)$ with $bold(epsilon) tilde cal(N)(0,Q)$ independent, then
  $bold(y) tilde cal(N)(A arrow(mu)+bold(b), A Sigma A^T+Q)$.
- Marginals and conditionals of a joint Gaussian are Gaussian. Conditioning updates both mean and covariance analytically. #sidenote()[This pair of facts, run over a continuum of indices instead of a finite vector, is the entire Gaussian-process regression algorithm — later this course.]

Zero covariance implies independence for jointly Gaussian variables, but this does not hold in general.


#pagebreak()
= Statistics: Learning from Data
#sidenote(numbered: false)[Textbook: Chapter 3, pp. 63–142]

While probability distributions allow us to talk about, given a model, what data is likely to appear. Statistics reverses it, given data $cal(D)={y_1,...,y_N}$, what parameters produced it?

== Bayesian inference
#sidenote(numbered: false)[Textbook: §3.2, pp. 63–72]

#def(term: "Bayesian inference")[
  $ p(theta|cal(D))
    = (p(theta)p(cal(D)|theta))/(p(cal(D)))
    = (p(theta)p(cal(D)|theta))/(integral p(theta')p(cal(D)|theta') dif theta'). $
]

Note that the posterior is a _*distribution*_ and not a single estimate. From the distribution we can estimate:
- a point summary: posterior mean, median, or MAP;
- uncertainty: credible intervals and joint posterior geometry;
- prediction: average over parameter uncertainty;
- evidence: compare complete probabilistic models.

Four different questions, one object: best guess, how sure, what happens next, is this model any good.

=== Running example: tossing a coin

We work this by hand because every quantity above has a closed form here.

Let $y_n in {0,1}$, $theta=PP(y_n=1|theta)$, and let $N_1=sum_n y_n$, $N_0=N-N_1$. The likelihood is
$
  p(cal(D)|theta)=theta^(N_1)(1-theta)^(N_0).
$
With prior $theta tilde "Beta"(alpha_0,beta_0)$,
$
  p(theta|cal(D))="Beta"(hat(alpha),hat(beta)), quad
  hat(alpha)=alpha_0+N_1, quad hat(beta)=beta_0+N_0.
$
The update adds observed counts to prior pseudo-counts.

#figure(
  image("Figures/textbook-beta-update.png", width: 95%),
  caption: [Uniform and weakly informative beta priors updated by the same Bernoulli data. Reproduced from Murphy, Textbook Figure 3.1, p. 65 (CC BY-NC-ND).],
)

  $ EE[theta|cal(D)]=(hat(alpha))/(hat(alpha)+hat(beta)), $
  $ "MAP"(theta)=(hat(alpha)-1)/(hat(alpha)+hat(beta)-2) $
  when $hat(alpha),hat(beta)>1$, and
  $ VV[theta|cal(D)]=(hat(alpha)hat(beta))/((hat(alpha)+hat(beta))^2(hat(alpha)+hat(beta)+1)). $


#def(term: "Credible interval")[
  A $(1-delta)$ credible set $C$ satisfies $PP(theta in C|cal(D))=1-delta$. This is a probability statement about $theta$ conditional on the observed data.
]


=== Prediction and evidence

When discussing uncertainty, we must distinguish between what the source of our uncertainty is. We can have both *aleatoric* uncertainty (rain is genuinely random) and *epistemic* uncertainty (you're unsure your forecast model is any good). More data shrinks the second but not the first. Bayesian approaches that utilize good prior distributions allow us to include epistemic uncertainty in our analysis.

#figure(
  image("Figures/textbook-predictive-uncertainty.png", width: 100%),
  caption: [Aleatoric uncertainty stays narrow away from the data; Bayesian prediction widens as parameter uncertainty grows. Reproduced from Murphy, Textbook Figure 3.3, p. 71 (CC BY-NC-ND).],
)
#pagebreak()
=== Exchangeability
An interesting philosophical question is: where do priors come from, given that they refer to
parameters which are just abstract quantities in a model, and not directly observable. A fundamental
result, known as de Finetti’s theorem, explains how they are related to our beliefs about observable
outcomes.
#def(term: "Exchangeability")[
  $X_1,...,X_N$ are infinitely exchangeable if their joint distribution is unchanged by permutation.
]
#def(term: "de-Finetti's Theorem")[
  $X_1,...,X_N$ are infinitely exchangeable if and only if we have:
  $ p(x_(1:N))=integral product_(n=1)^N p(x_n|theta)p(theta) dif theta. $

  Where $theta$ is some hidden, common, random variable.
]
We often interpret $theta$ as a parameter. The theorem tells us that, if our data is exchangeable, then there must exist a parameter $theta$, and a likelihood $p(x_i|theta)$, and a prior $p(theta)$. Thus the Bayesian
approach follows automatically from exchangeability.


== Conjugate Priors
#sidenote(numbered: false)[Textbook: §3.4, pp. 83–101]

#def(term: "Conjugate prior")[
  A prior family is conjugate to a likelihood when the posterior remains in the same family. That is if $p(theta) in cal(F)$ then $p(theta | cal(D)) in cal(F)$. Thus $cal(F)$ is closed under Bayesian updating, and so inference reduces to updating hyperparameters.
]
 Most relevant for us is that the multivariate normal distribution with known covariance is _conjugate to itself_. You can derive conjugacy for common distributions or #link("https://en.wikipedia.org/wiki/Conjugate_prior#Example")[look them up]. While conjugate priors can help some computations, they are not an excuse to make poorly justified modeling choices.

== Selecting and checking priors
#sidenote(numbered: false)[Textbook: §§3.2.3, 3.4.6–3.5, pp. 71, 99–107]

Choosing a prior is a central part of the model. Specifying exactly how much uncertainty you have to start is a surprisingly difficult task, and saying: "I don't know, so I'll be vague" is itself a claim with consequences, and should be defended like any other modeling decision.

Some common language to describe kinds of priors include:
- *informative:* encodes substantial external evidence#sidenote()[The opposite of this, noninformative, is not literal since every prior privileges some scale or parameterization. Prefer default, diffuse, or minimally informative, and state the criterion used.]
- *weakly informative:* rules out implausible extremes while leaving many values possible
- *regularizing:* stabilizes estimation toward a simpler region
- *conjugate:* chosen partly for algebraic convenience
- *hierarchical/empirical:* learns shared prior structure from related data



=== Maximum entropy priors
A natural way to define an uninformative prior is to use one that has maximum entropy, since
it makes the least commitments to any particular value in the state space.#sidenote()[We will discuss entropy in more detail later on.]

#def(term: "Maximum entropy prior")[
  Among distributions satisfying some stated constraints $EE[f_k(theta)]=F_k$, choose
  $ p^*=arg max_p HH(p). $
]

Max entropy allows us to formalize "what's the least extra information beyond exactly these constraints." Useful examples are that a mean-and-variance constraint gives a Gaussian; a mean-only constraint on $[0,infinity)$ gives an Exponential.

#figure(
  image("Figures/textbook-maxent-priors.png", width: 100%),
  caption: [Maximum entropy is relative to constraints: none, a fixed mean, or concentrated mass on selected values. Reproduced from Murphy, Textbook Figure 3.12, p. 104 (adapted there from MKL11; CC BY-NC-ND).],
)

Maximum entropy makes no commitments *beyond the declared constraints*. It does not decide which support, coordinates, or constraints are appropriate.

#pagebreak()
=== Jeffreys priors

#def(term: "Jeffreys prior")[
  $ p_J(theta) prop sqrt(det cal(I)(theta)), $
  where $cal(I)(theta)$ is Fisher information. The prior is invariant under smooth one-to-one reparameterization.
]
Consider the 1d case:
$

  p_phi(phi) &= p_theta(theta) |frac(d theta,d phi)|\
  &prop sqrt(F(theta)(frac(d theta,d phi))) = sqrt(EE[(frac(d log p(x|theta),d theta))^2](frac(d theta,d phi))^2)\
&= sqrt(EE[(frac(d log p(x|theta),d theta)frac(d theta,d phi))^2])= sqrt(EE[(frac(d log p(x|phi),d phi))^2])\
  &=sqrt(F(phi))

$

Note that there is no parameterization-free notion of "knowing nothing." In more than one dimension, Jeffreys priors get unwieldy and are rarely used directly; people fall back on priors motivated by scale instead.

Known symmetries give related defaults:
- translation invariance for location: $p(mu) prop 1$;
- scale invariance: $p(sigma) prop 1/sigma$;
- a reference prior maximizes expected information gain $EE_cal(D)[D_"KL"(p(theta|cal(D)) || p(theta))]$ and equals Jeffreys in one dimension.

// #discussion(vspace: 7em)[
//   *Prior design clinic.* Model a treatment success probability $theta$.
//   + Translate "usually between $0.2$ and $0.8$, centered near $0.5$" into a rough beta prior. Which two quantities would you elicit first?
//   + Compare $"Beta"(1,1)$, $"Beta"(1/2,1/2)$, and $"Beta"(20,20)$ by shape, equivalent sample size, and boundary behavior.
//   + For each prior, describe datasets generated by $theta tilde p(theta)$ then $Y tilde "Bin"(20,theta)$. Which prior predictive looks implausible for the domain?
//   + Observe $1$ success in $2$ trials. Rank posterior sensitivity across the priors; then predict what changes at $N=200$.
//   + Is it legitimate to choose the prior after viewing these two outcomes? Distinguish sensitivity analysis from data reuse.
// ]

// == Pooling and hierarchy
// #sidenote(numbered: false)[Textbook: §§3.6–3.7, pp. 108–118]

// You have many related groups — one per hospital, one per city, one per sensor — some data-rich, some data-poor. Pool everything and you erase real differences; fit each group alone and the data-poor ones overfit wildly. A hierarchical model splits the difference: per-group $theta_j$, tied together by a shared $xi$.

// #def(term: "Hierarchical model")[
//   For related groups $j=1,...,J$,
//   $ xi tilde p(xi), quad theta_j tilde p(theta_j|xi), quad cal(D)_j tilde p(cal(D)_j|theta_j). $
//   Shared hyperparameters $xi$ let groups exchange information.
// ]

// #figure(
//   caption: [A shared hyperparameter couples otherwise conditionally independent group models.],
//   diagram(
//     edge-stroke: 0.8pt,
//     node-corner-radius: 8pt,
//     node-stroke: 0.8pt,
//     node((0, 0), [$xi$], name: <hyper>),
//     node((-1, 1), [$theta_1$], name: <theta1>),
//     node((1, 1), [$theta_J$], name: <thetaJ>),
//     node((-1, 2), [$cal(D)_1$], name: <data1>),
//     node((1, 2), [$cal(D)_J$], name: <dataJ>),
//     node((0, 1.5), [$dots.c$], stroke: none),
//     edge(<hyper>, <theta1>, "->"),
//     edge(<hyper>, <thetaJ>, "->"),
//     edge(<theta1>, <data1>, "->"),
//     edge(<thetaJ>, <dataJ>, "->"),
//   ),
// )

// This is *partial pooling*: uncertain estimates shrink toward the population pattern, while data-rich groups keep their own signal. It interpolates between no pooling and complete pooling.

// #figure(
//   image("Figures/textbook-hierarchical-shrinkage.png", width: 100%),
//   caption: [Group MLEs are pulled toward a learned population mean; low-count groups have wider intervals and generally shrink more. Reproduced from Murphy, Textbook Figure 3.15, p. 110 (CC BY-NC-ND).],
// )

// *Empirical Bayes* estimates $xi$ by marginal maximum likelihood,
// $
//   hat(xi)=arg max_xi product_j integral p(cal(D)_j|theta_j)p(theta_j|xi) dif theta_j,
// $
// then conditions on $hat(xi)$. Fast, but it understates uncertainty by treating $hat(xi)$ as known rather than estimated.

// #discussion(vspace: 7em)[
//   *Pooling decisions for ten hospitals.* Sample sizes range from $5$ to $5000$.
//   + Draw the model and write its joint factorization for beta–binomial groups.
//   + Contrast no pooling, complete pooling, and partial pooling. State one assumption each makes about hospital variation.
//   + Two hospitals report $4/5$ and $4000/5000$. Which estimate shrinks more, in what direction, and why?
//   + Explain why shrinkage can reduce expected error despite introducing bias for a particular hospital.
//   + Predict a success rate for an existing hospital versus a new hospital. Which latent quantities must each prediction integrate out?
//   + Someone objects that partial pooling is just an assumption you baked in, not something the data justify. Using only tools from this lecture, how would you actually check that claim?
// ]

// == From fitting to a trustworthy model
// #sidenote(numbered: false)[Textbook: §§3.8–3.11, pp. 118–142]

// A generative model gets proposed, fit, checked, and revised — not fit once and shipped. The diagram at the end of this section is the actual workflow.

// #def(term: "Bayesian model comparison")[
//   $ p(m|cal(D)) prop p(cal(D)|m)p(m), quad
//     B_(1,0)=(p(cal(D)|m_1))/(p(cal(D)|m_0)). $
//   Predictions may average over models:
//   $p(tilde(y)|cal(D))=sum_m p(tilde(y)|m,cal(D))p(m|cal(D))$.
// ]

// Bayes factors integrate the likelihood over the *entire* prior, so a diffuse prior gets penalized for spreading mass over implausible values even when the posterior itself lands somewhere sensible. That sensitivity is the biggest practical strike against Bayes factors in complex models.

// Cross-validation asks a more direct question instead: refit on everything but one point — how well do you predict that point? LOO estimates
// $
//   "ELPD"_"LOO"=sum_n log integral p(y_n|theta)p(theta|cal(D)_(-n)) dif theta.
// $
// This sidesteps the prior's tails entirely, which is why it is the default tool for comparing complex models in practice.

// #def(term: "Posterior predictive check")[
//   Draw $theta^s tilde p(theta|cal(D))$, then replicated data $tilde(cal(D))^s tilde p(cal(D)|theta^s)$. Compare a domain-relevant statistic $T(tilde(cal(D))^s)$ with $T(cal(D))$. A systematic mismatch reveals what the model cannot reproduce.
// ]

// Murphy's own example: Newcomb's 1882 measurements of the speed of light. A Gaussian matches the data's mean and variance fine — but if $T=min(cal(D))$, the real minimum sits far in the left tail of $T(tilde(cal(D))^s)$. The Gaussian cannot reproduce the long left tail of large measurement errors actually present in the data, even though it passes every check that isn't looking at the tails.

// Model checking asks whether a model is adequate; model comparison asks which candidate is preferable. A best model may still be bad.

// #figure(
//   caption: [Probabilistic modeling is iterative; checks diagnose assumptions rather than certify truth.],
//   diagram(
//     edge-stroke: 0.8pt,
//     node-corner-radius: 8pt,
//     node-stroke: 0.8pt,
//     node((0, 0), [Assumptions], name: <assume>),
//     node((1.7, 0), [Prior prediction], name: <priorpred>),
//     node((1.7, 1.1), [Fit + predict], name: <fit>),
//     node((0, 1.1), [Check + revise], name: <check>),
//     edge(<assume>, <priorpred>, "->"),
//     edge(<priorpred>, <fit>, "->"),
//     edge(<fit>, <check>, "->"),
//     edge(<check>, <assume>, "->"),
//   ),
// )

// #discussion(vspace: 8em)[
//   *A fitted model is not yet a trusted model.* Newcomb's speed-of-light measurements are well fit by a Gaussian in mean and variance, but contain a handful of large negative outliers (equipment error) that a symmetric Gaussian treats as astronomically unlikely.
//   + Separate the questions "best among candidates?" and "adequate for use?". Which is comparison and which is checking, and could a model win the first while failing the second?
//   + Propose a test statistic $T$ that would expose the outlier problem, and a different $T$ that would miss it entirely by construction. What made the second one blind?
//   + A linear regression predicting US divorce rate from marriage rate and median age at marriage fits well on average but badly underpredicts for Utah and Idaho — both states with unusually large Mormon populations, and hence unusually low divorce rates relative to their marriage/age profile. Is this a failure a generic posterior predictive check would catch automatically, or does it require you to already suspect something about these states? What does that imply about the limits of automated model checking?
//   + Compare two revisions to the speed-of-light model: a Student-$t$ likelihood, and a two-component Gaussian mixture. Which failure mode does each target, and what does each cost you in extra parameters or inference difficulty?
//   + Name one downstream decision (flagging an anomalous measurement, setting a safety margin) for which the outlier mismatch would matter, and one for which it plausibly would not.
// ]
