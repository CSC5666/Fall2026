#import "wdf.typ": *

#show: template.with(
  title: [Information Optimization],
  title-short: none,
  authors: "CSC 5666: Advanced Machine Learning, Fall 2026",
  authors-short: none,
  title-extra: [Professor Austin P. Wright: Course Notes],
  date: none,
  toc: false,
  full: false,
  header-content: none,
  abstract: [Introduction to the foundational concepts in Information theory that are used in the context of probabilistic inference and machine learning. Closely follows Chapter 5 of Murphy's textbook.],
  bib: none,
  serif: true,
  exam: false,
)


#sidenote(dy: 1.15em, numbered: false)[#outline(depth: 1)]

= Introduction to Information Theory
#sidenote(numbered: false)[Textbook: Chapter 5, pp. 219–260]

So far this course has treated machine learning in terms of _probability and uncertainty_. Learning only makes sense when we do not know the answers ahead of time, so a learner must start with uncertain beliefs and update them. Representing how much those beliefs changed, that is what actually has been learned, means representing _information_.

Information theory answers two questions: what information is, and how to measure it. We want to quantify the magnitude of what changes when a model updates its beliefs, and it turns out that comparatively few requirements pin down a unique answer, the Kullback-Leibler (KL) divergence.

We will introduce the general properties of the KL divergence and two special cases, entropy and mutual information. We then use them to say what a good learned representation is, and how to get one, using information bottlenecks. We close with a different way of counting information altogether.


== Desiderata
#sidenote(numbered: false)[Textbook: §5.1.1, p. 220]

First we need a way to measure information. Here we can derive what that should mean.

Start with a distribution $q(x)$ holding our current degrees of belief about a random variable. We then update to a new distribution $p(x)$, perhaps after taking measurements, perhaps after thinking longer. We want to quantify the magnitude of that update, and we write it $I[p||q]$. What criteria should such a measure satisfy?

It helps to have something concrete in mind. Suppose we are about to draw a card, and $S in {"♣", "♠", "♡", "♢"}$ is its suit. We start out believing all four suits are equally likely, $q = [1/4,1/4,1/4,1/4]$. A friend now tells us they removed every red card, so we update to $q' = [1/2,1/2,0,0]$. Alternatively, we might learn that half of the diamonds were swapped for clubs, and update to $q'' = [3/8,2/8,2/8,1/8]$. Which was the bigger update? In order to develop an answer we can write down the properties any sensible answer must have.

A reasonable measure of information gain should be:
+ _Continuous_ in its arguments, so small perturbations to $p$ or $q$ only slightly change $I[p||q]$.
+ _Non-negative_, $I[p||q] >= 0$, since we are measuring the magnitude of an update, not scoring it as good or bad. This pins down the sign and nothing else, and in particular says nothing about whether $I[p||q]$ and $I[q||p]$ agree.
+ _Permutation invariant_, so relabeling the outcomes of $x$ consistently across $p$ and $q$ does not change the answer.
+ _Monotonic for uniform distributions_, so narrowing a uniform belief on $N$ states to a uniform belief on $N'$ of those same states, as when all four suits drop to the two black ones, is increasing in $N$ and decreasing in $N'$. The nesting matters: if the new states were not among the old ones the divergence would simply be infinite. #prompt(dy: -10em)[Monotonicity is imposed only on uniform distributions. Why does pinning down that one family determine $I$ everywhere else, up to a single overall constant? And what survives if we drop the axiom entirely? (Textbook §5.1.2.4, p. 223)]

+ _Chain-rule consistent_, so that describing the same update in stages gives the same total. #sidenote()[This means that we could describe the $q'$ update equally as eliminating diamonds, and then eliminating hearts, and that the sum of those two information updates should equal the information of updating all at once. The physical situation is identical, so the measured update must be too. Notice what the requirement forces on us. The right hand side averages the conditional term over a marginal, and we had to choose _which_ of the two distributions to average under. This is what forces any measure of information to be _asymmetric_.] Splitting $x = (x_L, x_R)$ so that $p(x) = p(x_L)p(x_R|x_L)$, we require
$
  I[p(x)||q(x)] = I[p(x_L)||q(x_L)] + EE_(p(x_L))[I[p(x_R|x_L)||q(x_R|x_L)]].
$


#discussion(vspace: 12em)[
  + Before reading on, commit to an answer: is $q arrow.r q'$ or $q arrow.r q''$ the larger update? Say in your own words which feature of the change you are deciding on. Then describe what someone who answered the other way must be measuring instead. Only one of the two survives the axioms. Note which you reached for first.#v(12em)
  + Suppose we dropped non-negativity, so an update could have "negative size". Describe in your own words what a negative-sized update would license someone to claim about the relationship between data and belief. Then sketch a pair of beliefs $p$ and $q$ for which you would be tempted to call the update negative, and identify what quantity you are actually reading off that picture.
]

= KL Divergence
#sidenote(
  numbered: false,
)[Textbook: §5.1, pp. 219–233. ]

It turns out that the *KL divergence*, also called the _information gain_ or _relative entropy_, is the unique measure satisfying all of the desiderata above, up to a multiplicative constant.#sidenote()[See Hobson 1969 or Rényi 1961 for the uniqueness proof, which we do not reproduce here.]

#def(term: "KL divergence")[
  For discrete $p, q$ over the same $K$ states, with $q_k > 0$ wherever $p_k > 0$ and the convention $0 log 0 = 0$,
  $
    D_("KL") (p || q) eq.def sum_(k=1)^K p_k log (p_k)/(q_k),
  $
  extending to continuous distributions as $D_("KL") (p||q) eq.def integral dif x thin p(x) log (p(x))/(q(x))$.
]


So $I[p||q] = D_("KL")(p||q)$ up to the choice of base, and we use the $D_("KL")$ notation from here on. The letter $I$ is about to be needed for something else, the mutual information.

Note how $D_"KL"$ is an average or expectation. What is averaged, and under which distribution? Kullback and Leibler introduced the quantity as a _mean information for discrimination_, defining the per-observation quantity first.#sidenote()[S. Kullback and R. A. Leibler, #link("https://doi.org/10.1214/aoms/1177729694")["On Information and Sufficiency"], _Annals of Mathematical Statistics_ 22(1):79–86, 1951, §1.] Suppose two hypotheses assign densities $p$ and $q$ to an observation $x$. Apply Bayes' rule under each and divide. The marginal likelihood cancels, and what is left is
$
  log (Pr(H_p|x))/(Pr(H_q|x)) - log (Pr(H_p))/(Pr(H_q)) = log (p(x))/(q(x)).
$
The log-ratio measures exactly how far seeing $x$ moves our log-odds between the two hypotheses. Kullback and Leibler call it the information in $x$ for discriminating $p$ from $q$; write it $i_(p:q)(x)$. Two features matter. Being a _ratio_, it cancels anything both hypotheses agree about. Being a _logarithm_, it adds across independent observations rather than multiplying, which is the chain rule desideratum in its simplest form.

#def(term: "KL divergence as an expectation")[
  $
    D_("KL")(p||q) = EE_(x tilde p)[i_(p:q)(x)] = EE_(x tilde p) [log (p(x))/(q(x))].
  $
]

We average under $p$ because of the question being asked. We want the rate at which evidence accumulates _when $p$ is the truth_, so outcomes should be weighted by how often the truth produces them. Averaging under $q$ answers a different question. Every asymmetry below descends from that one choice, which the chain rule already put to us. We return to $i_(p:q)$ under I. J. Good's name for it, the weight of evidence.

This also settles the card wager from the desiderata. Since we are computer scientists let us use logarithms base two, so the answers come out in bits. Ruling the red cards out gives
$
  D_("KL")(q'||q) = 1/2 log_2 (1\/2)/(1\/4) + 1/2 log_2 (1\/2)/(1\/4) + 0 + 0 = log_2 2 = 1 "bit",
$
where the two emptied suits contribute nothing under the convention $0 log 0 = 0$, which continuity forces on us. Reweighting to $q''$ gives
$
  D_("KL")(q''||q) &= 3/8 log_2 (3\/8)/(1\/4) + 2/8 log_2 (2\/8)/(1\/4) + 2/8 log_2 (2\/8)/(1\/4) + 1/8 log_2 (1\/8)/(1\/4) \
  &= 3/8 log_2 (3\/2) + 0 + 0 - 1/8 approx 0.219 - 0.125 = 0.094 "bits".
$
Ruling possibilities out is expensive and nudging probabilities around is cheap, here by a factor of more than ten. Notice where the cost did _not_ come from. Spades and hearts hold a quarter of the mass each in both beliefs and contribute zero. Only the log-ratio registers; the amount of probability that moved does not.


Let us now try to actually show how $D_"KL"$ meets the requirements. Some of the proofs below lean on one theorem which we can use without proof.

#def(term: "Jensen's inequality")[
  For a convex $f$, weights $lambda_i >= 0$ with $sum_i lambda_i = 1$, and any points $x_i$,
  $
    f(sum_i lambda_i x_i) <= sum_i lambda_i f(x_i), quad "equivalently" quad f(EE[X]) <= EE[f(X)].
  $
  The inequality reverses for concave $f$, such as $log$. Equality holds only when $X$ is constant, or $f$ is affine on an interval containing the support of $X$. A corollary we will want later is the _log-sum inequality_,
  $
    sum_i a_i log (a_i)/(b_i) >= (sum_i a_i) log (sum_i a_i)/(sum_i b_i),
  $
  for non-negative $a_i, b_i$.
]

We can now check each desideratum directly.

_Non-negativity_ #sidenote()[Non-negativity is more useful than you might expect. Whenever an expression can be rearranged to contain a KL divergence, we can use this and remove the divergence term to produce a valid bound.], also called the information inequality or Gibbs' inequality, states $D_("KL")(p||q) >= 0$ with equality if and only if $p=q$. Writing $A = {x : p(x) > 0}$ for the support of $p$ and applying Jensen to the concave $log$,
$
  -D_("KL")(p||q) &= sum_(x in A) p(x) log (q(x))/(p(x)) <= log sum_(x in A) p(x) (q(x))/(p(x)) \
  &= log sum_(x in A) q(x) <= log sum_(x in cal(X)) q(x) = log 1 = 0.
$
Equality needs both inequalities tight at once. Jensen is tight only when the ratio $q(x)\/p(x)$ is constant on $A$, and the last step is tight only when $q$ places no mass outside $A$. Together these force $q = p$.



_Reparametrization invariance_ says that pushing $x$ through an invertible map $y = f(x)$ leaves $D_("KL")$ unchanged, because $p(x) dif x = p(y) dif y$ and the Jacobian factors cancel between numerator and denominator. This is stronger than the permutation invariance we asked for, and more useful. The divergence describes the distributions themselves rather than the coordinates we wrote them in, so we may measure heights in feet or centimetres, or work in cartesian or polar coordinates, without changing the answer.

#prompt(
  dy: -1em,
)[Reparametrization invariance is stronger than the desiderata asked for. Name a modeling situation where the extra strength does real work for you. (Textbook §5.1.2.3, p. 222)]

_The chain rule_ falls out of the definition by splitting the joint,
$
  D_("KL")(p(x,y) || q(x,y)) & = D_("KL")(p(x)||q(x)) \
                             & quad + EE_(p(x))[D_("KL")(p(y|x)||q(y|x))],
$
It is conventional to define the _conditional_ KL divergence so that the outer average is already inside it,
$
  D_("KL")(p(y|x)||q(y|x)) eq.def integral dif x thin p(x) integral dif y thin p(y|x) log (p(y|x))/(q(y|x)),
$
which lets us write the chain rule with no expectation symbol, as $D_("KL")(p(x,y)||q(x,y)) = D_("KL")(p(x)||q(x)) + D_("KL")(p(y|x)||q(y|x))$. The same symbol therefore means two things, depending on whether an outer $EE_(p(x))$ appears in front of it.

#sidenote(dy: 2em, numbered: false)[#set math.equation(numbering: none)
  For two Gaussians the divergence has a closed form worth knowing, since it appears in nearly every variational objective:
  $
    & D_("KL")(cal(N)(mu_1,sigma_1^2) || cal(N)(mu_2,sigma_2^2)) \
    & = log sigma_2/sigma_1 + (sigma_1^2 + (mu_1-mu_2)^2)/(2 sigma_2^2) - 1/2.
  $
  Textbook §5.1.8.1, p. 232 gives the multivariate version.]

#discussion(vspace: 4em)[
  + Information for Monty Hall. I am sure you have already heard about the famous Monty Hall problem. You are presented with three door, behind one of the doors is a brand new car and behind the other two are goats. You pick a door and the host, who knows where the car is and always opens an unpicked door hiding a goat. You now have the opportunity to either _stay_ with your original pick, or _switch_ to the remaining unopened door.  After the host reveals one of the doors, your belief about the car's location moves from the distribution $q = [1\/3,1\/3,1\/3]$ to some new distribution $p$. Compute $D_("KL")(p||q)$ in bits; that number is exactly the information the host handed you. #v(4em)
  + The non-negativity proof works even when $q(x) = 0$ somewhere that $p(x) > 0$. Check that it does, then say what else breaks in that case, and which of the five desiderata really insists that $q$ have support wherever $p$ does. Give a pair of distributions with $D_("KL")(p||q) = infinity$, and say in plain words what claim the model $q$ was making that the data refuted.
]

== Properties of KL Divergence
#sidenote(numbered: false)[Textbook: §§5.1.3, 5.1.5, pp. 224–225, 228–230]

When interpreting the KL divergence, it is important to keep in mind the following properties it has.

=== Units
#sidenote(numbered: false)[Textbook: §5.1.3.1, p. 224]

The desiderata fix $D_("KL")$ only up to a multiplicative constant, and logarithms in different bases differ by exactly such a constant. Our choice of base is therefore a choice of _units_. Base-2 logarithms give _bits_, the natural logarithm gives _nats_, and converting between them is a single division:
$
  1 "bit" = ln 2 approx 0.693 "nats", quad 1 "nat" = 1/(ln 2) approx 1.44 "bits".
$

For us, bits have a nice interpretation. Suppose we encode outcomes drawn from $p$ using a code #sidenote()[The optimal code for a known $p$ comes from _Huffman's algorithm_, which takes one line to describe: repeatedly merge the two least probable symbols into one carrying their combined probability, then read the merge tree back as a prefix code. Merging rare symbols first pushes them deep into the tree. Textbook §5.4, p. 247.] designed for $q$, spending $log_2 1\/q(x)$ bits on outcome $x$.#sidenote()[Kraft's inequality $sum_x 2^(-ell(x)) <= 1$ holds for any prefix-free code, and conversely any such lengths are achievable. So we can build a code that spends about $log_2 1\/q(x)$ bits on $x$. Textbook §5.4, p. 247.] The extra cost of that mismatch, averaged over data actually drawn from $p$, is exactly $D_("KL")(p||q)$ bits per symbol. A divergence of one bit means our coding scheme wastes one yes/no question per observation. The same reading explains the monotonicity desideratum: narrowing a uniform belief from $N$ states to $N'$ states costs $log_2 N \/ N'$ bits, the number of yes/no questions needed to bisect the space down to size $N'$.




=== Asymmetry
#sidenote(numbered: false)[Textbook: §5.1.3.2, pp. 224–225]

In general $D_("KL")(p||q) eq.not D_("KL")(q||p)$. This means that we cannot quite interpret the divergence as a distance. We have seen where the asymmetry comes from: the chain rule forced us to average under the first argument. The effect can be large. For two Bernoulli distributions with success probabilities $0.443$ and $0.975$,
$
  D_("KL")(0.975||0.443) approx 0.692 "nats" approx 1.0 "bit", \
  D_("KL")(0.443||0.975) approx 1.38 "nats" approx 2.0 "bits".
$
Moving from a near coin-flip to near certainty costs about one well-chosen question. Moving back from near certainty to a coin flip takes twice as much persuading.

=== Weight of Evidence
#sidenote(numbered: false)[Textbook: §5.1.3.3, p. 225]

Asymmetry becomes much less mysterious once we go back to the quantity being averaged. We saw at the definition that $i_(p:q)(x) = log p(x)\/q(x)$ is the shift in log-odds between two hypotheses caused by seeing $x$. I. J. Good named this the _weight of evidence_#sidenote()[I. J. Good, "Weight of evidence: A brief survey," _Bayesian Statistics 2_, 1985. Good and Turing used the idea at Bletchley Park under the names _ban_ and _deciban_, well before log-odds updates became routine elsewhere. Note that $w$ is an increment to a log-odds, not a log-odds itself.] for $P$ over $Q$,
$
  w[P slash Q; cal(D)] eq.def log (p(cal(D)))/(q(cal(D))),
$
so that posterior log-odds are prior log-odds plus $w$, and evidence from independent observations adds up. Compare that with the definition of KL: the divergence $D_("KL")(P||Q)$ is the _expected weight of evidence per observation, assuming $P$ is true_.

#discussion(vspace: 15em)[
  A colleague proposes ranking models by $D_("KL")(p||q) + D_("KL")(q||p)$, to "fix" the asymmetry. Evaluate the proposal on three grounds: whether it still satisfies the desiderata, whether it retains an operational reading as evidence, and whether the property that bothered them was a defect at all. Symmetry is what we would demand of a _distance_ between distribution, so state why or why not we should have ever wanted one.
]


=== Compression Lemma
#sidenote(numbered: false)[Textbook: §5.1.5.1, p. 228]

The KL Divergence gives us, in addition to a measure of information gain, powerful bounds on the properties of expectations across distributions.

#def(term: "Compression lemma")[
  For distributions $P, Q$ with $D_("KL")(P||Q) < infinity$, and any function $psi$ on their common domain with $EE_Q [e^psi] < infinity$,
  $
    EE_P [psi] <= log EE_Q [e^psi] + D_("KL")(P||Q).
  $
]

The proof is a good example of the "rearrange into a KL and delete it" move. Define a tilted distribution $g(x) = q(x)e^(psi(x))\/Z$ with $Z = integral dif x thin q(x) e^(psi(x))$, which reweights $q$ toward wherever $psi$ is large. Non-negativity of the divergence from $P$ to that tilted distribution gives
$
  0 <= D_("KL")(P||G) = D_("KL")(P||Q) - EE_P[psi] + log Z,
$
and rearranging is the lemma. Taking the supremum over all $psi$ turns the bound into an identity, the _Donsker-Varadhan_ representation,
$
  D_("KL")(P||Q) = sup_psi (EE_P[psi] - log EE_Q[e^psi]),
$
which says the divergence is what the most discriminating test function can extract.

This is one way that KL gets estimated from samples alone, by parameterizing $psi$ as a neural network. Any particular $psi$ under-shoots the supremum, so such an estimator returns a _lower_ bound, the right way round for a quantity we want to certify as large.#sidenote(dy: -24em)[Belghazi et al., #link("https://arxiv.org/abs/1801.04062")["MINE: Mutual Information Neural Estimation"], ICML 2018.]

=== Data Processing Inequality
#sidenote(numbered: false)[Textbook: §5.1.5.2, pp. 229–230]

In our discussion of graphical models, and in most modeling in general, we are frequently concerned about how distributions and uncertainty change under transformations. The KL divergence gives us further bounds about not just how distributions relate, but how those relations generalize across transformations.

#def(term: "DPI for KL divergence")[
  Let $p(x), q(x)$ be pushed through a shared channel $t(y|x)$ to give $p(y), q(y)$. Then
  $
    D_("KL")(p(x)||q(x)) >= D_("KL")(p(y)||q(y)).
  $
]

_Processing can only make two distributions harder to tell apart._ Marginalizing out a variable is a special case, so $D_("KL")(p(x,y)||q(x,y)) >= D_("KL")(p(x)||q(x))$: seeing part of the data can never distinguish hypotheses better than seeing all of it. No feature transformation, however clever, adds information about the label that the raw input did not already carry.

Feature engineering earns its keep by making existing information easier for a limited model to use. One caveat matters in practice: this holds only for transformations that are functions of the input alone. Target encoding, label-aware feature selection, and joins against outside data are not links in this chain, which is why leakage is so easy to create without noticing.


#discussion(vspace: 12em)[
  + Deep networks are long chains of processing, so the DPI applies to them directly. Does it follow that later layers have less information about the input than earlier ones? Does it follow that they are less _useful_? These are different questions with different answers, so answer both. #v(10em)
  + A student claims that a random projection of their features "lost no information, since the projection happened to be invertible on the observed data". Say where the argument goes wrong, and describe the circumstances under which it is right.
]

== KL Divergence and MLE
#sidenote(numbered: false)[Textbook: §5.1.6, pp. 230–231]

Frequently we use KL Divergence as the objective of an optimization problem. That is we want to minimize the information difference between our estimate distribution and some notion of the true distribution.

Suppose we minimize $D_("KL")(p||q)$ by  over $q$, where $p = p_cal(D)$ is the _empirical distribution_ that places an equal spike of mass on each observed data point, $p_cal(D)(x) = 1/N sum_(n=1)^N delta(x - x_n)$. Using the sifting property of $delta$,
$
  D_("KL")(p_cal(D) || q) = -1/N sum_n log q(x_n) + C
$
where $C$ does not depend on $q$. Since the second term is fixed by the data, and $log$ is monotonic, minimizing the divergence to the empirical distribution and maximizing the likelihood are equivalent. This equivalence also explains the weakness of maximum likelihood. The target $p_cal(D)$ is a comb of spikes with zero density between them, and we have essentially just asked the model to match that comb.

Consider s dataset of images. Any actual dataset, no matter how large, is a vanishingly small sample of "all natural images", so fitting the comb exactly is necessarily overfitting. Regularization, smoothing, and priors are all ways of admitting that $p_cal(D)$ was never the actual distribution we wanted.

== KL Divergence and Bayesian Inference
#sidenote(numbered: false)[Textbook: §5.1.7, pp. 231–232]

More surprising, perhaps, than the MLE case is that Bayesian updating comes out the same way. We can find this by reversing which term we optimize over. If $q$ is the belief we already hold, and $p$ is the distribution we solve for being the result of an update. Let $q(theta, cal(D)) = q(theta) q(cal(D)|theta)$ be our prior joint over parameters and data. Having observed $cal(D)_0$, define our updated beliefs as the joint _closest_ to the prior joint that still respects what we saw:
#prompt(
  dy: 1em,
)[Suppose we had posed the update as minimizing the _reverse_ divergence $D_("KL")(q||p)$ under the same constraint. What goes wrong, and what does that say about which argument is allowed to be a delta?]

$
  p(theta,cal(D)) = limits("argmin")_p D_("KL")(p(theta,cal(D)) || q(theta,cal(D))) quad "s.t." quad p(cal(D)) = delta(cal(D) - cal(D)_0).
$
Apply the chain rule for KL, $D_("KL")(p||q) = D_("KL")(p(cal(D))||q(cal(D))) + D_("KL")(p(theta|cal(D))||q(theta|cal(D)))$. The constraint fixes the first term, and the second is minimized at zero by setting $p(theta|cal(D)) = q(theta|cal(D))$. Marginalizing gives $p(theta) = q(theta|cal(D)=cal(D)_0)$, the ordinary posterior.

What this shows is that Bayesian inference is precisely the procedure that updates beliefs by the minimum amount of information that is consistent with new evidence.#sidenote()[This is sometimes called the principle of minimum discrimination information, and it is the same logic behind maximum entropy priors.] This gives us further independent reason to value Bayesian inference on the grounds of Occam's razor. Furthermore this framing generalizes. If the observation is itself uncertain, say a measurement with known error, replace the delta with the appropriate $p(cal(D))$. The conditional stays the Bayesian posterior and the marginal becomes $p(theta) = integral dif cal(D) thin p(cal(D)) q(theta|cal(D))$, known as _Jeffrey's conditionalization rule_.



== Minimizing KL
#sidenote(numbered: false)[Textbook: §5.1.4, pp. 225–227]

In the Bayesian derivation above the divergence could be driven to zero exactly, and in the maximum likelihood case only in the degenerate limit where the model collapses onto the data. Usually neither is available. We have a complicated target $p$, typically an intractable posterior, and a tractable family of approximations $q$, typically something factorized by a PGM and/or a parametrized distribution like a Gaussian. We then pick the optimal member of that family. Because KL is asymmetric there are two ways to pose this, and they give different answers.

#figure(
  image("Figures/textbook-kl-mode-covering.png", width: 100%),
  caption: [Approximating a bimodal $p$ (blue) with a single Gaussian $q$. Minimizing $D_("KL")(p||q)$ spreads $q$ across both modes (orange); minimizing $D_("KL")(q||p)$ commits to one (green). Reproduced from Murphy, Textbook Figure 5.1, p. 226 (CC BY-NC-ND).],
)

Conceptually we can differentiate the two directions by asking: "which mistake each refuses to make". The forwards divergence (optimizing the right hand size) averages under $p$, so it is enormous wherever $p$ has mass and $q$ has none: it refuses to leave a real possibility uncovered. The reverse divergence (optimizing the left hand size) averages under $q$, so it is enormous wherever $q$ has mass and $p$ has none: it refuses to claim what the target cannot support, even at the cost of ignoring most of the target.

=== Mode Covering
#sidenote(numbered: false)[Textbook: §5.1.4.2, pp. 226–227]

Minimizing the forwards divergence, $q = limits("argmin")_q D_("KL")(p||q)$, is called _M-projection_ or moment projection. Since $p log p\/q$ blows up wherever $q = 0$ while $p > 0$, the optimal $q$ must stay positive everywhere $p$ is, so it stretches to _cover_ every mode. This is also called zero-avoiding behaviour.

Suppose $q$ is something like a normal distribution, the optimum is found by _moment matching_ #sidenote()[Where moments are the generalizations of mean and variance towards higher dimensions]. The approximation covers $p$ but is too broad, and so is under-confident.

=== Mode Seeking
#sidenote(numbered: false)[Textbook: §5.1.4.3, p. 227]

Minimizing the reverse divergence, $q = limits("argmin")_q D_("KL")(q||p)$, is called _I-projection_ or information projection. Now the penalty falls wherever $q$ has mass and $p$ does not, so $q$ retreats onto a single mode and understates the spread, and so is over-confident.

#figure(
  image("Figures/textbook-kl-projections.png", width: 92%),
  caption: [A correlated Gaussian $p$ (blue) approximated by a factorized $q$ (red). (a) The M-projection matches the marginals and is too broad. (b) The I-projection fits inside one direction of the correlation and is too narrow. Reproduced from Murphy, Textbook Figure 5.2, p. 226 (CC BY-NC-ND).],
)

The reverse direction is the one we can compute, since its expectations are taken under $q$, which we chose to be tractable. Hence variational inference, covered later in the course, is built on the reverse divergence, and why variational posteriors are usually, though not always, over-confident.#sidenote()[A classic counterexample is Turner, Berkes, and Sahani, "Two problems with variational expectation maximisation for time series models," 2008, where reverse-KL fitting does not produce an over-compact approximation.] The forwards direction appears instead in expectation propagation and in moment-matching approximations.


#discussion(vspace: 15em)[
  + Consider a safety-critical monitor that must flag every plausible failure mode in some configuration space, accepting false alarms as the price. In optimizing a model for the true failure distribution, which projection matches that requirement? What would the other do on the same problem and why is that behaviour unacceptable here? Now give a second application where the preference reverses and explain why.#v(10em)
  + Consider a one dimensional exponential distritbuion being modeled by a gaussian. Matching the above figure, sketch the shape of what both I-projection and M-projection distirbution models would look like, and describe conceptually what kinds of errors each would have. Then sketch an arbitrary distribution for which no matter how many gaussian mixture components you add, both of the optimization directions will have serious issues.
]

= Entropy
#sidenote(numbered: false)[Textbook: §5.2, pp. 234–238]

Entropy is usually introduced first and treated as the basic quantity. We get it second, and almost for free, as the special case of KL divergence measured against the uniform distribution.

#def(term: "Entropy")[
  For discrete $X$ with distribution $p$ over $K$ states,
  $
    H(X) eq.def -sum_(k=1)^K p(X=k) log p(X=k) = -EE_X [log p(X)].
  $
]

#sidenote(
  dy: -10em,
  numbered: false,
)[#image("Figures/textbook-binary-entropy.png", width: 100%) Binary entropy $H(theta)$, maximized at one bit when $theta = 1\/2$. Reproduced from Murphy, Textbook Figure 5.4, p. 235 (CC BY-NC-ND).]

As with KL, base-2 logs give bits and base $e$ gives nats. The connection to the divergence is a one-line computation against the uniform $u$:
$
  H(X) = log K - D_("KL")(p(X)||u(X)),
$
so entropy is maximized at $log K$ when $p$ is uniform, and drops by the amount our beliefs have departed from ignorance. Entropy measures distance from knowing nothing, counted downwards from $log K$. #sidenote(dy: -10em)[The coding reading from earlier carries over. No uniquely decodable code can beat $H(X)$ bits per symbol on average when the data really comes from $p$. Codeword lengths are integers, so a code built for single symbols can sit up to one bit above $H(X)$. Coding long blocks of an independent source jointly closes that gap, because almost all of the probability concentrates on roughly $2^(N H)$ near-equiprobable sequences, and indexing that set costs $H$ bits per symbol. This is the asymptotic equipartition property. Entropy is the irreducible cost of describing the randomness that is there.]

For a binary variable with $p(X=1) = theta$, the _binary entropy function_, sometimes written $H_2$, is#sidenote()[$H(theta)$ abuses notation slightly, since the argument is a parameter rather than a random variable.]
$
  H(theta) = -[theta log theta + (1-theta) log(1-theta)],
$
plotted in the margin. It peaks at one bit for a fair coin, which needs exactly one yes/no question, and falls to zero at either extreme, where there is nothing left to ask.

For continuous variables the analogous quantity is the _differential entropy_ $h(X) = -integral dif x thin p(x) log p(x)$. Note that it can be negative, since densities may exceed one. More importantly it is not reparametrization invariant, so unlike $D_("KL")$ its value depends on whether we measure heights in feet or in centimetres.#sidenote()[Textbook §5.2.2, p. 235, works the height example through in both units.] Both warnings make sense once we know where $h$ comes from. Quantizing $X$ to $n$ bits of precision gives a discrete variable of entropy about $h(X) + n$, so $h$ measures description cost _relative to_ the precision we chose. A negative value means the distribution is tighter than the yardstick, and changing units changes the yardstick. Two Gaussian cases are worth knowing, since they turn several later calculations into one line:
$
  h(cal(N)(mu,sigma^2)) = 1/2 log(2 pi e sigma^2), quad h(cal(N)(mu,Sigma)) = 1/2 log((2 pi e)^D det Sigma).
$
Differences of differential entropies do not depend on the units even though $h$ itself does, so $I(X;Y) = h(X) + h(Y) - h(X,Y)$ is well defined for continuous variables, and is the definition we use for them.

#prompt(
  dy: -10em,
)[The entropy of a Gaussian depends on $sigma$ but not $mu$. Why is that what we want? And why is the same insensitivity, applied to a change of units, not what we want?]

// Working with several variables needs two more definitions and one identity.

// #def(term: "Joint and conditional entropy")[
//   $
//     H(X,Y) & eq.def -EE_(p(x,y))[log p(x,y)], \
//     H(X|Y) & eq.def -EE_(p(x,y))[log p(x|y)] = sum_y p(y) H(X | Y = y).
//   $
//   They are linked by the _chain rule for entropy_,
//   $
//     H(X,Y) = H(X) + H(Y|X) = H(Y) + H(X|Y),
//   $
//   which extends to $H(X_(1:n)) = sum_(i=1)^n H(X_i | X_(1:i-1))$.
// ]

// Conditional entropy averages entropies rather than taking the entropy of a conditional. The distinction matters: a _particular_ observation $Y = y$ can leave us more uncertain than we started, but on average observing $Y$ cannot hurt, since $H(X|Y) <= H(X)$. We prove that inequality when we reach mutual information, where it becomes a statement about $I(X;Y)$.

// #discussion(vspace: 4em)[
//   + Build a small joint distribution in which $H(X|Y=y) > H(X)$ for one particular $y$, while $H(X|Y) < H(X)$ on average. Then describe in words what that offending $y$ is like as an observation: what kind of thing did you just learn? Finally, say why it is the averaged statement that gets a theorem and the pointwise one that does not, and what would break in the information diagram if the pointwise version were also guaranteed. (MacKay, #link("http://www.inference.org.uk/itprnn/book.pdf")[_Information Theory, Inference, and Learning Algorithms_], Exercise 8.2, p. 140. The book is free online, and several later prompts draw on it)
//   + A fair die has $H = log_2 6 approx 2.58$ bits, which is not a whole number of yes/no questions. Say what a fractional bit means operationally, and what has to be true about how the questions are asked for the fraction to be realizable. Then explain why a code built for single rolls cannot reach $2.58$ bits per roll, and what specifically changes when many rolls are encoded together. You are describing the gap between a bound and an achievable scheme, and you should be able to do it without the formula.
// ]

== Cross entropy and Perplexity
#sidenote(numbered: false)[Textbook: §5.2.4, pp. 237–238]

A slight generalization of entropy to two distributions is the _cross entropy_.

#def(term: "Cross entropy")[
  $ H_("ce")(p,q) eq.def -sum_x p(x) log q(x), $
]

#prompt()[Algebraically how do Cross entropy, entropy, and KL divergence relate?]

We met cross entropy already as the training objective of maximum likelihood. By writing the cross entropy in terms of the KL divergence and single entropy we get two parts. The first is the divergence which we can reduce by improving the model, and second is the entropy of the data, which we cannot. A cross entropy that stops falling may not mean the optimizer failed. It may mean we have reached $H(p)$ and are now trying to predict noise.

Language modeling reports the same quantity on an exponentiated scale, called the _perplexity_:
$
  "perplexity"(p,q) eq.def 2^(H_("ce")(p,q)), quad H_("ce") "measured in bits".
$
The base of the exponential must match the base of the logarithm, so in nats it reads $e^(H_("ce"))$ and gives the same number. Empirically, scoring each token in its context as an autoregressive model does,
$
  H_("ce")(p_cal(D), q) = -1/N sum_(n=1)^N log q(x_n | x_(1:n-1)),
$
so perplexity is $(product_n q(x_n|x_(1:n-1)))^(-1\/N)$, the geometric mean of the inverse probability the model assigned to what actually happened, with $N$ the number of tokens in the corpus.

We can read this as a _branching factor_: a model with perplexity 20 is on average as uncertain about the next token as someone choosing uniformly among 20 options. Since $H(p^*) <= H_("ce")(p^*, q)$, no model can push its _expected_ cross entropy below the per-token entropy rate $H(p^*)$, so $2^(H(p^*))$ is a floor in expectation. A finite held-out corpus can still dip below it by luck.


#discussion(vspace: 0em)[
  Model A reports perplexity 18 on one tokenizer, model B reports 15 on another. Explain why that comparison is close to meaningless, and say what would have to be held fixed to rescue it. Then name the quantity the two models are competing on, and say whether it is a property of the models or of the language. A good answer explains why perplexity per _character_ is a fairer currency than perplexity per token.
]


= Mutual Information
#sidenote(numbered: false)[Textbook: §5.3, pp. 238–244]

While entropy allows us to measure fundamental uncertainty in the distribution of a single variable, we are more often concerned about the relationships between variables. Usually this take some form of the question: "How much does knowing $Y$ tell us about $X$?" Correlation can only answer a narrow version of this, catching only linear relationships or monotone ones under a rank correlation. For the general version we want a measure of _dependence_. Since two variables are independent exactly when their joint equals the product of its marginals, we can measure dependence by measuring how far the joint is from that product.

#def(term: "Mutual information (MI)")[
  $
    I(X;Y) eq.def D_("KL")(p(x,y) || p(x)p(y)) = sum_(y in cal(Y)) sum_(x in cal(X)) p(x,y) log (p(x,y))/(p(x)p(y)).
  $
]

#prompt()[
  Consider what we would be measuring if we defined MI using the opposite KL divergence direction.
]

A quick note on more notation weirdness. We write $I(X;Y)$ with a semicolon rather than $I(X,Y)$ so that each argument can itself be a set of variables: $I(X,Y;Z)$ will mean the information that the _pair_ $(X,Y)$ carries about $Z$. This will allow us to later show a distinction between $I(X,Y;Z)$ and $I(X;Y;Z)$.

Because MI is just a KL divergence, everything we proved transfers for free. It is non-negative, and zero exactly when $X tack.tt Y$. It is invariant to invertible reparametrization of either variable, notably unlike correlation.#sidenote()[The invariance cuts both ways. Blindness to monotone rescaling is what makes MI a good general dependence measure, and also why it says nothing about the _form_ of the relationship.] However note that unlike direct application of KL divergence, MI is _symmetric_, which allows MI to be used in additional ways that KL cannot. We also write $I(X;Y|Z)$ for the _conditional mutual information_, defined as the same quantity computed within each slice and then averaged,
$
  I(X;Y|Z) eq.def EE_(p(z))[D_("KL")(p(x,y|z) || p(x|z)p(y|z))] \
  = H(X|Z) - H(X|Y,Z).
$

== Interpretation
#sidenote(numbered: false)[Textbook: §5.3.2, p. 239]

Rewriting MI in terms of entropies gives:
$
  I(X;Y) & = H(X) - H(X|Y) \
         & = H(Y) - H(Y|X) \
         & = H(X) + H(Y) - H(X,Y)
$
This gives us a reading of $I(X;Y)$ as the _reduction in uncertainty_ about $X$ from observing $Y$, and symmetrically the reduction in uncertainty about $Y$ from observing $X$. That symmetry is not obvious from the phrasing, but it is immediate from the definition.


#figure(
  image("Figures/textbook-info-diagram.png", width: 78%),
  caption: [Marginal, joint, and conditional entropy, and mutual information, drawn as areas. Reproduced from Murphy, Textbook Figure 5.6, p. 240, used there with permission of Katie Everett (CC BY-NC-ND).],
)

#prompt(
  dy: -4em,
)[$I(X;Y)$ is symmetric, yet $H(X|Y)$ and $H(Y|X)$ usually differ. Which asymmetry survives in the diagram?]


== Data Processing Inequality
#sidenote(numbered: false)[Textbook: §5.3.3, p. 239]

Just as for KL generally, we can see how information in general is not gained through processing.

#def(term: "DPI for mutual information")[
  If we can write the DPGM $X arrow.r Y arrow.r Z$ (that is $X tack.tt Z | Y$), then $I(X;Y) >= I(X;Z)$.
]
The proof follows simply from the definitions
$
  I(X;Y,Z) & = I(X;Z) + I(X;Y|Z) \
           & = I(X;Y) + I(X;Z|Y).
$
The graphical model assumption sets $I(X;Z|Y) = 0$, and conditional MI is non-negative, so $I(X;Y) = I(X;Z) + I(X;Y|Z) >= I(X;Z)$.

== Sufficient Statistics
#sidenote(numbered: false)[Textbook: §5.3.4, pp. 240–241]

If processing can only lose information, the natural question is when it loses none. Consider the chain $theta arrow.r X arrow.r s(X)$, where $theta$ generates data $X$ and $s$ is any summary we compute. The DPI gives $I(theta; s(X)) <= I(theta;X)$. When that holds with _equality_, $s(X)$ is a _sufficient statistic_: the summary is as good as the raw data for learning $theta$. An equivalent condition is easier to check: $s$ is sufficient exactly when the likelihood factors as $p(x|theta) = g(s(x),theta) dot h(x)$, with $theta$ entering only through $s(x)$. This _factorization theorem_ is how sufficiency gets verified in practice.

A _minimal_ sufficient statistic is one that is sufficient and throws away everything else, which we can state as: for every other sufficient statistic $s'$ there is a function $f$ with $s(X) = f(s'(X))$, giving the chain $theta arrow.r s(X) arrow.r s'(X) arrow.r X$. The data itself is of course always sufficient, but it is almost never minimal. For $N$ Bernoulli trials, the count of successes and $N$ are minimal sufficient: the order of the flips is real information about the sequence, but none of it is information about $theta$.

Sufficiency provides a very good metric for a learned representation, where a good representation is able to keep everything relevant to the target, but nothing more#sidenote()[Once again we can see this structure of valuing the minimum required model that we have seen in multiple forms so far.].

#discussion(vspace: 0em)[
  Consider a data scientist who finds that some feature of her data has near-zero correlation with her target label, and thus drops it. Is this justified? Sketch a scatter plot of a feature and a label with near-zero correlation and large mutual information. Then take your sketch, rescale one axis by a monotone but strongly nonlinear function, and say which of the two quantities changed.
]

== Multivariate Mutual Information (MMI)
#sidenote(numbered: false)[Textbook: §5.3.5, pp. 241–244]

With three or more variables there is no single generalization, since "shared information" can mean several inequivalent things. The direct option is to measure how far the joint sits from full independence, which is a measure we call _Total Correlation_.

#def(term: "Total correlation")[
  $
    "TC"(X_(1:D)) eq.def D_("KL") (p(x) || product_(d=1)^D p(x_d)) = sum_d H(X_d) - H(X_(1:D)) >= 0,
  $
  zero if and only if all $X_d$ are mutually independent.
]

Total correlation detects _any_ dependence, which is sometimes too blunt. If $X$ and $Y$ are coupled and $Z$ is independent of both, total correlation is positive even though nothing three-way is happening. To isolate higher-order structure we define _multivariate mutual information_ (MMI), also called co-information, inductively: #sidenote()[Note importantly that this value now lacks some of the same properties we have seen so far for single or two variable quantities. Importantly MMI is not non-negative, that is it can have negative values. However it turns out that this property actually _helps us_ in interpreting the value in the multivariate case.]
$
  I(X_1; dots.c; X_D) eq.def I(X_1; dots.c; X_(D-1)) - I(X_1; dots.c; X_(D-1) | X_D).
$

We can read this as measuring: "how much does conditioning on the last variable change the shared information among the rest?". Note that since $I$ is symmetric, this definition is also symmetric in its arguments even though the inductive form singles out $X_D$, since variables could be induced in any order. For three variables we can see:
$
  I(X;Y;Z) & = I(X;Y) - I(X;Y|Z) \
           & = I(X;Z) + I(Y;Z) - I(X,Y;Z).
$

#figure(
  image("Figures/textbook-mmi-diagram.png", width: 62%),
  caption: [The three-variable information diagram. The central region $I(x;y;z)$ is the MMI, and unlike every other region in the picture it can be negative. Reproduced from Murphy, Textbook Figure 5.7, p. 242, from Wikipedia author PAR (CC BY-NC-ND).],
)

If $X$ and $Y$ tell us overlapping things about $Z$, then $I(X;Z) + I(Y;Z) > I(X,Y;Z)$ and the MMI is positive, then the variables are _redundant_. If they tell us more together than separately, the MMI is negative and the variables are _synergistic_. The cleanest example of synergy is parity. Let $X$ and $Y$ be independent fair bits and let $Z = X xor Y$. Then $I(X;Z) = I(Y;Z) = 0$, since either bit alone says nothing about the parity, but $I(X,Y;Z) = 1$ bit. So $I(X;Y;Z) = 0 + 0 - 1 = -1$ bit, the most negative MMI that three bits can produce. Neither feature is individually predictive, and together they determine the label exactly.


=== MMI and Causality
#sidenote(numbered: false)[Textbook: §5.3.5.4, p. 243]

The sign of the three-way MMI lines up with the elementary triples of in DPGMs, giving an information-theoretic reading of d-separation:
- _Common cause_, $X arrow.l Z arrow.r Y$, claims that conditioning on $Z$ renders $X,Y$ independent, so $I(X;Y|Z) <= I(X;Y)$ and $I(X;Y;Z) >= 0$;
- _Common effect_, $X arrow.r Z arrow.l Y$: claims that  conditioning on $Z$ _induces_ dependence by explaining away, so $I(X;Y|Z) >= I(X;Y)$ and $I(X;Y;Z) <= 0$;
- _Chain_, $X arrow.r Z arrow.r Y$: claims that conditioning on the mediator $Z$ renders $X,Y$ independent, so $I(X;Y|Z) = 0$ and $I(X;Y;Z) = I(X;Y) >= 0$.



#discussion(vspace: 0em)[
  Take the parity ensemble above and draw its three-circle information diagram, filling in a number for every region. Use the result to explain to someone else why entropy Venn diagrams are a mnemonic and not a proof technique. Point at the specific region that a picture made of areas cannot represent, and say what that region means in words. Finally, determine an appropriate DPGM based on the information quantities. (MacKay, Exercise 8.8, p. 141)
]

= Information Bottleneck
#sidenote(numbered: false)[Textbook: §5.6, pp. 252–254]

We have already seen how suffieciency is a property that uses information theory to validate and produce useful representations. In general we can formalize this problem of learning effective representations using an information bottleneck (IB).

== Vanilla IB
#sidenote(numbered: false)[Textbook: §5.6.1, pp. 252–253]

Let $Z$ be a representation of input $X$, meaning a possibly stochastic function described by $p(z|x)$. We say $Z$ is _sufficient_ for the task $Y$ when $Y tack.tt X | Z$, or equivalently $I(Z;Y) = I(X;Y)$, that is nothing useful for the task is lost by using $Z$ instead of $X$. We say it is _minimal_ when, among sufficient representations, it has the smallest $I(Z;X)$. The IB objective optimizes for both, optimized over the encoder $p(z|x)$ and decoder $p(y|z)$, with $X$ and $Y$ dependent and $Z$ built from $X$ alone. The only assumption it encodes is $Z tack.tt Y | X$, that is that the encoder and learned representation only use information present in the input.

Concretely we can factorize under these assumptions as
$
  p(x,y,z) = p(z|x)p(y|x)p(x)
$

So $Z$ may carry any part of $X$, but nothing about $Y$ that $X$ does not already share, which is what panel (a) of the figure below shows. We can then write the optimization objective as
$
  min_(p(z|x), p(y|z)) beta thin I(Z;X) - I(Z;Y), quad beta >= 0.
$

#figure(
  image("Figures/textbook-ib-diagram.png", width: 95%),
  caption: [(a) $Z$ is built from $X$ alone, so it can carry any part of $X$ but nothing about $Y$ that $X$ does not already share. (b) The optimal representation keeps the overlap with $Y$ and discards the rest of $X$. Reproduced from Murphy, Textbook Figure 5.12, p. 253, used there with permission of Katie Everett (CC BY-NC-ND).],
)

Note the use of the scalare parameter $beta$, called the _Lagrange multiplier_. At $beta = 0$ we only care about prediction, and the identity map $Z = X$ is optimal, which is to say we have learned nothing beyond memorizing the input. As $beta$ grows we pay for every bit of the input we retain, so the encoder is forced to decide which bits "earn their keep" toward _learning a lossy compression that preserves relevance_.


Selecting the appropriate value for $Beta$ can be tricky. The Markov structure makes $Z arrow.l X arrow.r Y$ a processing chain, so the DPI gives $I(Z;Y) <= I(Z;X)$, and therefore $beta I(Z;X) - I(Z;Y) >= (beta-1)I(Z;X)$. Once $beta >= 1$ that is non-negative, and the constant representation attains zero, so the collapse does not arrive gradually as $beta$ grows, it has already happened at $beta = 1$. Everything interesting lives in $beta in (0,1)$.

Only the jointly Gaussian case is solvable in closed form, where the answer turns out to be a form of supervised PCA. When $X$, $Y$ and $Z$ are all discrete, the Blahut-Arimoto style iteration of Tishby, Pereira and Bialek converges to a self-consistent solution, though the problem is not convex and the fixed point it finds is a stationary one rather than a certified global optimum.#sidenote()[The original paper is Tishby, Pereira, and Bialek, #link("https://arxiv.org/abs/physics/0004057")["The Information Bottleneck Method"], 1999.] In general we need an approximation.

== Variational IB
#sidenote(numbered: false)[Textbook: §5.6.2, pp. 253–254]

In cases where vanilla IB cannot be solved in closed form, we can approximate a representation and optimize the approximation. For this approximation we need to be able to define trainable equivalents of all of the terms:
- an encoder $e(z|x) eq.def p(z|x)$
- a decoder $d(y|z) approx p(y|z)$
- and a marginal approximation $m(z) approx p(z)$.


We will write $chevron.l dot chevron.r$ for an expectation under the joint $p_cal(D)(x,y) e(z|x)$, or under whichever of its marginals the expression needs. We can define bounds on the approximations by replacing $p(y|z)$ with $d(y|z)$:
$
  I(Z;Y) >= chevron.l log d(y|z) chevron.r + H(Y)
$

Since the entropy of the labels is a property of the data, and not of the encoder, we can safely ignore it. Similarly we can get an upper bound on the term we want to shrink, by replacing the intractable marginal $p(z)$ with $m(z)$:
$
  I(Z;X) <= chevron.l log e(z|x) chevron.r - chevron.l log m(z) chevron.r
$

Note that we can approximate the joint expectations by sampling from $p(x,z) = p(x)p(z|x)$. Putting it all together we can derive the VIB objective (noting the drop of $H(Y)$ which is a constant for the optimization):
$
  cal(L)_("VIB") &= beta chevron.l log e(z|x) - log m(z) chevron.r - chevron.l log d(y|z) chevron.r \
  &= -chevron.l log d(y|z) chevron.r + beta chevron.l D_("KL")(e(z|x) || m(z)) chevron.r
$

We can then minimize this objective with respect to the parameters of $e,d,m$. A common form of the encoder will be a conditional Gaussian, and the decoder as a softmax classifier, while the marginal should be very flexible since it needs to approximate the aggregated posterior which is a mixture of encoder (likely Gaussian depending on $e$) models.

#figure(
  image("Figures/textbook-vib-mnist.png", width: 100%),
  caption: [Two-dimensional embeddings of MNIST digits from an MLP classifier. (a) Deterministic encoder: every image gets its own point. (b, c) VIB encoder means and covariances: classes separate, but individual instances within a class become indistinguishable, since that detail is not useful for the label. Reproduced from Murphy, Textbook Figure 5.13, p. 255, used there with permission of Alex Alemi (CC BY-NC-ND).],
)


#prompt(
  dy: 1em,
)[Sufficiency was an equality, $I(Z;Y) = I(X;Y)$, which the IB objective never quite reaches for $beta > 0$. Explain why this is not a problem in terms of _generalization_.]

#discussion(vspace: 15em)[
  + Describe what happens to the representation as $beta arrow.r 0$ and as $beta$ approaches $1$ from below, naming each extreme with its ordinary machine learning vocabulary. Then on the $I(Z;X) "vs" I(Z;Y)$ plane, sketch out the curve traced out as $beta$ sweeps between the extremes, and shade the region that no representation of any kind can occupy. Where on your curve you would want a deployed model to sit. #v(10em)
  + There was an influential claim that ordinary deep networks train in two phases, first fitting and then compressing, visible as a trajectory in exactly the plane you just drew. It has been contested, partly because estimating mutual information in high dimensions is very hard #sidenote()[Original claim: Shwartz-Ziv and Tishby, #link("https://arxiv.org/abs/1703.00810")["Opening the Black Box of Deep Neural Networks via Information"], 2017. Rebuttal: Saxe et al., #link("https://openreview.net/forum?id=ry_WPG-A-")["On the Information Bottleneck Theory of Deep Learning"], ICLR 2018. The VIB method itself is Alemi et al., #link("https://arxiv.org/abs/1612.00410")["Deep Variational Information Bottleneck"], 2017] What would you have to measure to settle it? Before answering, work out what $I(Z;X)$ actually equals for a deterministic encoder with continuous $X$, and what that implies about any curve ever plotted for such a network.
]

= Algorithmic Information Theory and Kolmogorov Complexity
#sidenote(numbered: false)[Textbook: §5.7, pp. 256–260]

Everything so far measured the information content of a _source_, a stochastic process we imagine generating the data. However, consider a sequence of $n$ fair coin flips. This sequence requires $n$ bits to describe no matter what comes out, so the string of all heads, the string of strictly alternating flips, and a truly random string receive identical information content, though they are plainly not alike. Algorithmic information theory gives us some language to differentiate the information contained in an individual string rather than the probabilistic source.

#def(term: "Kolmogorov complexity")[
  For a bit string $x = x_(1:n)$ and universal Turing machine $U$,
  $
    K(x) eq.def min_(s in cal(B)^*) [ell(s) : U(s) = x],
  $
  the length of the shortest program $s$ that outputs $x$ when run on $U$, where $cal(B)^*$ is the set of finite bit strings and $ell(dot)$ is length in bits.
]

$K$ behaves much like entropy. We have $K(x|y) <= K(x) <= K(x,y)$ up to additive constants, mirroring the conditional and joint entropy inequalities. The choice of machine $U$ only shifts $K$ by a constant, since any universal machine can emulate any other with a fixed-size interpreter. That constant is fixed once the two machines are, but nothing bounds its size, so $K$ has content only asymptotically in $ell(x)$ and says nothing at all about any particular short string. One small problem is that in fact $K$ is _not computable_.#sidenote()[If $K$ were computable, then "print the first string with $K(x) > n$" is itself a program of length about $log n + c$, which for large enough $n$ is shorter than the complexity of the string it prints.]

The definition gives a notion of information for a single object with no reference to a generating distribution. A string is _compressible_ if $K(x) < ell(x)$, and _algorithmically random_ otherwise. It also enables a clean statement of Occam's razor. Solomonoff induction puts a universal prior $w_nu = 2^(-K(nu))$ over computable hypotheses, so shorter descriptions start out more probable, and the resulting predictor's total error is bounded by the complexity of the environment that generated the data.

#discussion(vspace: 2em)[
  + Entropy is a property of a distribution and $K$ is a property of a single string. Which is the right notion for "how surprising is this specific dataset"? Construct a case where the two disagree sharply, say which answer your intuition sides with, and then say what your intuition is quietly assuming about where the data came from.#v(2em)
  + Solomonoff's prior weights hypotheses by $2^(-K)$, which is a formal statement of Occam's razor. Name the assumption about the world that this encodes. Then give the strongest objection a critic could raise, and the best reply available to you. Connect the exchange to the practice of penalizing parameter count, which is the same argument with the search restricted.
]

#pagebreak()
#wideblock()[

  = Appendix: Additional Practice Problems

  #v(1em)
  Below is a selection of practice problems sourced from other courses and books on the topic. Most are solvable from the material above; a few may lean on material we state without developing, but serve as potentially useful jumping off points for further self study.

  + _Staged updates._ Write the card draw from the desiderata section as a two-stage process, colour first and then suit within colour, and verify by hand that the chain rule requirement is a real constraint rather than an identity. Then check the two-stage decomposition against the numbers computed for $q'$ and $q''$. (MacKay poses a version with a bent-coin cascade in #link("http://www.inference.org.uk/itprnn/book.pdf")[_Information Theory, Inference, and Learning Algorithms_], Exercise 2.28, p. 38. The book is free to read online)

  + _Jensen and Gibbs._ Prove Jensen's inequality for the two-point case directly from the definition of convexity, then extend it to $n$ points by induction. Use the result to prove Gibbs' inequality. (MacKay, Exercises 2.14, p. 35, and 2.26, p. 37)

  + _When evidence fails to accumulate._ Under what conditions does the expected weight of evidence per observation fail to accumulate, so that no amount of data separates two hypotheses? Give one case where the failure is a property of the hypotheses and one where it is a property of the experiment, and say which of the two a better experimental design could repair.

  + _Uncertain observations._ A sensor reports a temperature of $21 plus.minus 2$ degrees rather than an exact value. Write the posterior over $theta$ under Jeffrey's conditionalization rule, and explain what goes wrong if you instead condition on the point estimate $21$. Quantify the error in a simple Gaussian case.

  + _I-projection onto a linear family._ Show that the I-projection of $p$ onto the linear family ${q : EE_q [r_i (X)] = alpha_i}$ is an exponential family distribution with base measure $p$. (#link("http://www.cs.cmu.edu/~aarti/Class/10704/Homework2.pdf")[CMU 10-704, Homework 2, Problem 1] (A. Singh). The maximum entropy derivation from Notes 01 is the special case where $p$ is uniform)

  + _The entropy bound._ Prove $H(X) <= log K$, with equality only for the uniform distribution, working directly from Jensen's inequality rather than by quoting the identity $H(X) = log K - D_("KL")(p||u)$. (MacKay, Exercise 2.25, p. 37)

  + _Convexity of the divergence._ Show that $D_("KL")(p||q)$ is jointly convex in the pair $(p,q)$, and use this to argue that entropy is concave in $p$. (#link("http://www.cs.cmu.edu/~aarti/Class/10704/Homework1.pdf")[CMU 10-704 _Information Processing and Learning_, Homework 1, Problem 2(d)] (A. Singh))

  + _Information content and search._ You have twelve balls, identical except that one is either heavier or lighter, and a two-pan balance. Argue that weighing six against six cannot be optimal, and that three against three cannot either, then construct an optimal strategy. Explain the argument in terms of bits: how many bits does one weighing yield, and how many does the puzzle require? (#link("http://www.cs.cmu.edu/~aarti/Class/10704/Homework1.pdf")[CMU 10-704, Homework 1, Problem 1] (A. Singh); also MacKay, Exercise 4.1)

  + _Coding and units._ Construct a Huffman code for the source with probabilities $(1\/3, 1\/3, 1\/4, 1\/12)$ and compute its expected codeword length. Compare with the entropy of the source, and explain the gap in terms of the divergence between the true distribution and the implicit distribution $2^(-ell(x))$ of the code. (Adapted from #link("http://www.cs.cmu.edu/~aarti/Class/10704/Homework3.pdf")[CMU 10-704, Homework 3, Problem 3]. The interpretation via $D_("KL")$ is the "units" section of these notes)

  + _Maximum entropy with moment constraints._ Show that the density maximizing differential entropy subject to $EE[X] = mu$ and $EE[X^2] = alpha$ is Gaussian with mean $mu$ and variance $alpha - mu^2$. Then show that the maximum entropy joint distribution with given marginals is the product of those marginals, and connect this to total correlation. (#link("http://www.cs.cmu.edu/~aarti/Class/10704/Homework2.pdf")[CMU 10-704, Homework 2, Problems 2 and 3])

  + _Maximum entropy on the half line._ Find the differential entropy of $X tilde "Exp"(lambda)$, then prove that $"Exp"(lambda)$ uniquely maximizes differential entropy among non-negative random variables with $EE[X] <= 1\/lambda$. (#link("https://web.stanford.edu/class/ee376a/files/exams/final_2016_sol.pdf")[Stanford EE376A, Final Exam 2016, Problem 1] (T. Weissman). Solutions are included in the linked PDF)

  + _Entropy rate._ The entropy rate of a stationary process is $macron(H) = lim_(n arrow.r infinity) H(X_n|X_(1:n-1))$, and for a Markov chain it collapses to $H(X_2|X_1)$, which you may assume. For a stationary chain with transition matrix $T$ and stationary distribution $pi$, derive $macron(H)$ in terms of $pi$ and $T$, and find the transition probabilities that maximize it. For the two-state chain with rows $(1-p, p)$ and $(1,0)$, find the $p$ maximizing the entropy rate and interpret the answer. (#link("http://www.cs.cmu.edu/~aarti/Class/10704/Homework2.pdf")[CMU 10-704, Homework 2, Problem 4])

  + _Maximum conditional entropy and logistic regression._#super[†] Show that the conditional distribution maximizing $H(Y|X)$ subject to matching the empirical expectations of a set of features has the logistic (softmax) form. Relate this to the exponential family result you proved for the I-projection. (#link("http://www.cs.cmu.edu/~aarti/Class/10704/Homework2.pdf")[CMU 10-704, Homework 2, Problem 6])

  + _A joint table by hand._ Compute $I(X;Y)$ for the joint distribution below, along with $H(X,Y)$, $H(X)$, $H(Y)$, $H(X|y)$ for each $y$, and $H(X|Y)$. (MacKay, Exercise 8.6, p. 140. Working one table fully by hand is the fastest cure for confusing $H(X|y)$ with $H(X|Y)$)
    $
      p(x,y) = 1/32 mat(4, 2, 1, 1; 2, 4, 1, 1; 2, 2, 2, 2; 8, 0, 0, 0)
    $
    with rows indexed by $y = 1..4$ and columns by $x = 1..4$.

  + _Chain rules._ Prove the general chain rule for entropy, $H(X_(1:n)) = sum_i H(X_i|X_(1:i-1)) <= sum_i H(X_i)$, and state when the inequality is tight. Then prove the corresponding chain rule for mutual information, $I(X_(1:n);Y) = sum_i I(X_i;Y|X_(1:i-1))$. (#link("http://www.cs.cmu.edu/~aarti/Class/10704/Homework1.pdf")[CMU 10-704, Homework 1, Problems 2(b) and 2(c)]; MacKay, Exercise 8.3, p. 140)

  + _Processing chains._ Show that if $U arrow.r X arrow.r Y arrow.r V$ is a Markov chain then $I(U;V) <= I(X;Y)$. Justify any use of the implication that $X arrow.r Y arrow.r Z$ gives $Z arrow.r Y arrow.r X$. (#link("http://www.cs.cmu.edu/~aarti/Class/10704/Homework1.pdf")[CMU 10-704, Homework 1, Problem 3(a)]. MacKay, Exercise 8.9, p. 141, poses the same result for a world state, the data gathered about it, and the processed data)

  + _Sufficiency for a uniform._ Show that if $X_1, dots, X_n tilde "uniform"(theta, theta+1)$ are iid, then $T = {min_i X_i, max_i X_i}$ is sufficient for $theta$. (#link("http://www.cs.cmu.edu/~aarti/Class/10704/Homework1.pdf")[CMU 10-704, Homework 1, Problem 3(b)] (A. Singh))

  + _Gaussian mutual information._ For jointly Gaussian $(X,Y)$ with correlation $rho$ and equal variances, show $I(X;Y) = -1/2 log(1-rho^2)$. Comment on the limits $rho arrow.r plus.minus 1$ and $rho = 0$. (#link("http://www.cs.cmu.edu/~aarti/Class/10704/Homework2.pdf")[CMU 10-704, Homework 2, Problem 5] (A. Singh). Use the differential entropy of a Gaussian from the entropy section)

  + _Parity and the binary symmetric channel._ Let $x,y$ be independent bits with $Pr(x=1)=p$ and $Pr(y=1)=q$, and let $z = x + y mod 2$. Compute $p(z)$ and $I(Z;X)$, first for $q = 1\/2$ and then in general. (MacKay, Exercise 8.7, p. 141. The general case is the binary symmetric channel with $x$ the input, $y$ the noise, and $z$ the output)

  + _Explaining away._ Give an example of $X,Y,Z$ with $I(X;Y|Z) > I(X;Y)$ that is _not_ parity or exclusive-or, verify the strict inequality numerically, and name the causal structure you just built. (#link("http://www.cs.cmu.edu/~aarti/Class/10704/Homework1.pdf")[CMU 10-704, Homework 1, Problem 2(a)] (A. Singh))

  + _Tightness of the VIB bound._ The variational bottleneck replaced the intractable marginal $p(z)$ with a learned $m(z)$. Show that the resulting bound on $I(Z;X)$ is tight exactly when $m(z)$ equals the aggregated posterior $integral dif x thin p(x) e(z|x)$, and explain why a unit Gaussian $m$ is usually a poor fit for that aggregate.

  + _Information bottleneck in practice._ Train a small classifier with a stochastic encoder and the VIB objective on a dataset of your choice, sweeping $beta$. Plot accuracy against $EE[D_("KL")(e(z|x)||m(z))]$, which upper bounds $I(Z;X)$, and describe the shape of the resulting tradeoff curve. (Method and experimental setup from #link("https://arxiv.org/abs/1612.00410")[Alemi et al., "Deep Variational Information Bottleneck," 2017])

]
