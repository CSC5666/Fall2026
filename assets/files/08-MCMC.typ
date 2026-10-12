#import "wdf.typ": *
#import "Figures/inference-figures.typ": *
#import "@preview/cetz:0.4.2"

#show: template.with(
  title: [Markov Chain Monte Carlo],
  title-short: none,
  authors: "CSC 5666: Advanced Machine Learning, Fall 2026",
  authors-short: none,
  title-extra: [Professor Austin P. Wright: Course Notes],
  date: none,
  toc: false,
  full: false,
  header-content: none,
  abstract: [Basic introduction to the foundations, algorithms, and applications of MCMC. See textbook Chapters 12–13.],
  bib: none,
  serif: true,
  exam: false,
)

#sidenote(dy: 1.15em, numbered: false)[#outline(depth: 1)]

#v(-3em)
= Markov Chain Monte Carlo
#sidenote(
  numbered: false,
)[Textbook: §§12.1–12.2. Stanford CS228, #link("https://ermongroup.github.io/cs228-notes/inference/sampling/")[Sampling Methods].]

MCMC produces a dependent sequence whose long-run distribution is a target $p^*$, usually a posterior. Let $K(x'|x)$ be a transition kernel. The sequence is a Markov chain when
$
  p(x^((s+1))|x^((0:s)))=K(x^((s+1))|x^((s))).
$
We design $K$ so that $p^*$ is _stationary_ or _invariant_:
$
  p^* (x')=integral p^* (x)K(x'|x) dif x.
$ <mcmc-invariance>
If $x^((s))∼p^*$, one more transition also has distribution $p^*$. A chain started from a fixed $x^((0))$ has some other distribution at every finite step.

Detailed balance is a sufficient condition:
$
  p^* (x)K(x'|x)=p^* (x')K(x|x').
$ <detailed-balance>
Integrating over $x$ (or summing for a discrete chain) gives @mcmc-invariance. Some invariant kernels, such as a deterministic Gibbs sweep, violate detailed balance.

For a finite chain, irreducibility means every state can eventually reach every other state; aperiodicity rules out permanent cycles. For an ergodic chain, time averages converge:
$
  1/S sum_(s=1)^S f(x^((s))) arrow.r EE_(p^*) thin [f(X)].
$ <mcmc-average>
The theorem says nothing about how large $S$ must be. Retained draws remain correlated, so $S$ draws carry less information than $S$ independent draws.

#side-discussion(dy: -14em)[
  Rejection and importance sampling from the previous notes give independent draws. Why accept dependent draws? Consider the acceptance rate of rejection sampling for a posterior over $100$ parameters. (MacKay, _Information Theory, Inference, and Learning Algorithms_, §29.3)
]

#figure(
  caption: [Repeated transitions construct one dependent trajectory. States before $B$ are warmup; retained states still require empirical checks.],
)[
  #diagram(
    edge-stroke: 0.75pt,
    node-stroke: 0.8pt,
    node-corner-radius: 6pt,
    node((0, 0), [$x^((0))$], name: <x0>),
    node((1.2, 0), [$x^((1))$], name: <x1>),
    node((2.4, 0), [$dots$], name: <xd>),
    node((3.6, 0), [$x^((B))$], name: <xb>),
    node((4.8, 0), [$dots$], name: <xe>),
    node((6.0, 0), [$x^((B+S))$], name: <xs>),
    edge(<x0>, <x1>, "->", label: [$K$]),
    edge(<x1>, <xd>, "->", label: [$K$]),
    edge(<xd>, <xb>, "->", label: [$K$]),
    edge(<xb>, <xe>, "->", label: [$K$]),
    edge(<xe>, <xs>, "->", label: [$K$]),
  )
]

== Mixing Is a Separate Property
#figure(
  caption: [A sticky two-state chain. Each step switches state with probability $epsilon$.],
)[
  #diagram(
    edge-stroke: 0.75pt,
    node-stroke: 0.8pt,
    node((0, 0), [$0$], shape: circle, name: <s0>),
    node((2, 0), [$1$], shape: circle, name: <s1>),
    edge(<s0>, <s1>, "->", bend: 25deg, label: [$epsilon$]),
    edge(<s1>, <s0>, "->", bend: 25deg, label: [$epsilon$]),
    edge(
      <s0>,
      <s0>,
      "->",
      bend: 130deg,
      loop-angle: 180deg,
      label: [$1-epsilon$],
    ),
    edge(
      <s1>,
      <s1>,
      "->",
      bend: 130deg,
      loop-angle: 0deg,
      label: [$1-epsilon$],
    ),
  )
]
The kernel $K=mat(1-epsilon, epsilon; epsilon, 1-epsilon)$ has eigenvalues $1$ and $lambda=1-2epsilon$. Started at state $0$, and at stationarity respectively,
$ P(x^((s))=0)-1/2=1/2 (1-2epsilon)^s,
quad "Corr"(x^((s)), x^((s+k)))=(1-2epsilon)^k. $ The chain stays in a state for a geometric number of steps with mean $1\/epsilon$. Invariance fixes the eigenvalue $1$; the speed of mixing depends on how close the next eigenvalue is to $1$, which invariance leaves free.

#discussion(vspace: 5em)[
  A two-state chain has kernel $K=mat(0.99, 0.01; 0.01, 0.99)$, so its stationary distribution is $(1/2, 1/2)$. It starts at state $0$ and runs for $50$ steps.

  Sketch two plausible traces of this run. Then explain, using the sketches, why the average of $x^((s))$ can sit far from $1/2$ even though the kernel is invariant, irreducible, and aperiodic. Which property of the chain does the invariance equation leave out? A strong answer separates three claims: what the kernel guarantees, what the ergodic average guarantees as $S arrow.r oo$, and what $50$ draws can support.
]

#pagebreak()
= Metropolis-Hastings
#sidenote(numbered: false)[Textbook: §12.2]

Metropolis-Hastings (MH) turns a proposal distribution into a transition that preserves $p^*$. We only need an unnormalized density
$
  p^* (x)=frac(tilde(p) lr((x)), Z).
$
At state $x$:
+ Propose $x'∼q(x'|x)$.
+ Accept with probability
  $
    A(x'|x)=min(
      1,
      (tilde(p) thin (x')q(x|x'))/(tilde(p) thin (x)q(x'|x))
    ).
  $ <mh-accept>
+ After rejection, retain $x$ as the next state.

The unknown $Z$ cancels. The proposal ratio corrects asymmetric proposals. For symmetric $q$, only the target ratio remains. Repeated states from rejection stay in every Monte Carlo average; deleting them underweights the states where the chain lingers, which are often the high-density ones.

#side-discussion(dy: -6em)[
  MH needs only ratios $tilde(p) thin (x')\/tilde(p) thin (x)$. Name a model from earlier notes where $tilde(p)$ is cheap to evaluate and $Z$ is intractable.
]

For $x' != x$, $K(x'|x)=q(x'|x)A(x'|x)$, and
$
  p^* (x)K(x'|x)
  =min(p^* (x)q(x'|x), p^* (x')q(x|x'))
  =p^* (x')K(x|x').
$
The self-transition receives the remaining probability:
$
  K(x|x)=1-sum_(x' != x) q(x'|x)A(x'|x).
$

== Proposals
- _Random-walk MH:_ $x'=x+epsilon$, often with $epsilon∼cal(N)(0,Sigma)$. Small steps accept often and move slowly; large steps move farther and are rejected often.
- _Independence MH:_ $q(x'|x)=q(x')$. The chain is irreducible only if $q>0$ wherever $p^*>0$. If $q$ has lighter tails than $p^*$, a chain that reaches the tail can stay there for a long run of rejections.
- _Composed kernels:_ apply invariant kernels in sequence, such as coordinate moves, block moves, and moves designed for the problem.

Judge a proposal by exploration, autocorrelation, and ESS. A high acceptance rate can come from tiny moves that mix slowly.

#figure(
  caption: [Random-walk MH on the same bimodal target with proposal standard deviations $1$, $500$, and $8$. The first chain remains near its initial mode; the second repeats states after large rejected proposals; the third explores both modes. Source: Murphy (2023), Fig. 12.1.],
)[
  #image("Figures/textbook-mh-proposal-scale.png", width: 100%)
]

== Diagnosing an MH Run
- _Acceptance near $0$, long flat stretches:_ steps are too large for the local scale of $p^*$.
- _Acceptance near $1$, slow drift:_ steps are too small.
- _Each run looks stable, but runs disagree:_ separated modes. Compare $tilde(p)$ across dispersed restarts, or add global moves (§VI).
For random-walk proposals on smooth targets, theory recommends acceptance near $0.44$ in one dimension and $0.234$ in high dimensions (Roberts, Gelman & Gilks 1997). These targets tune efficiency within a mode and say nothing about reaching other modes.

Compute acceptance in log space. Accept when $log u < log tilde(p) thin (x') - log tilde(p) thin (x) + log q(x|x') - log q(x'|x)$ for $u∼"Unif"(0,1)$. A score that multiplies thousands of letter-pair frequencies underflows to $0$ in floating point.

#discussion(vspace: 4em)[
  Diaconis (2009) describes decoding a substitution cipher from a prison inmate's letters. The state $f$ assigns a letter to each code symbol. The score
  $
    tilde(p) thin (f)=product_i M(f(c_i), f(c_(i+1)))
  $
  multiplies letter-pair frequencies $M$ estimated from a long English text. Each step proposes swapping the letters assigned to two random symbols.

  + Identify the target, the proposal, and the acceptance probability. Why is the normalizing constant, a sum over every possible assignment, irrelevant? Why does the proposal ratio drop out?
  + Later write-ups report that only some runs recover readable text. Runs that fail settle on stable decodings with high scores that are still unreadable. Diagnose this behavior in the language of this section, then propose two changes to the experiment and say what evidence would show that each worked.
]

#pagebreak()
= Gibbs Sampling as MH
#sidenote(numbered: false)[Textbook: §12.3]

Gibbs sampling is coordinate-wise MH with the exact full conditional as its proposal. Choose coordinate $i$ and propose
$
  x_i'∼p^* (x_i|x_(-i)),
  quad x_(-i)'=x_(-i).
$
The Hastings ratio is
$
  (p^* (x_i', x_(-i))p^* (x_i|x_(-i)))/
  (p^* (x_i, x_(-i))p^* (x_i'|x_(-i)))=1,
$
so every valid Gibbs proposal is accepted.

A systematic sweep uses new values immediately:
$
  x_1^((s+1)) & ∼p^* (x_1|x_2^((s)), dots, x_d^((s))), \
  x_2^((s+1)) & ∼p^* (x_2|x_1^((s+1)), x_3^((s)), dots), \
              & dots
$
Each coordinate update preserves $p^*$, so their composition does too. Random-scan Gibbs picks coordinate $i$ with fixed probability $pi_i>0$ at every step. The two scans define different chains with the same stationary distribution.

Coordinates may be updated simultaneously when they are conditionally independent given the rest. In an Ising model, color the grid like a checkerboard; all black pixels can be resampled at once given the white ones. Updating _every_ coordinate from the previous state's values is a different kernel and generally fails to preserve $p^*$.

Every Gibbs update is accepted, yet Gibbs draws can mix slowly. Coordinate moves travel poorly along a narrow diagonal or between separated modes. Three repairs change the geometry:
- _Blocked Gibbs:_ sample strongly dependent variables jointly.
- _Reparameterization:_ change variables so the posterior is closer to axis-aligned, for example by centering a regression predictor.
- _Collapsed Gibbs:_ integrate out selected variables and sample a smaller state.
// When a full conditional has no standard form, replace that update with any $p^*$-invariant MH step (_Metropolis within Gibbs_).

#figure(
  caption: [Coordinate Gibbs makes steps of conditional width $l$ while the target extends over length $L$. Treating the moves as a random walk, crossing the long axis takes on the order of $(L\/l)^2$ steps. Source: Murphy (2023), Fig. 12.5.],
)[
  #image("Figures/textbook-gibbs-correlated.png", width: 52%)
]

== Why Correlation Slows Gibbs
For a standard bivariate Gaussian with correlation $rho$, $x_1|x_2∼cal(N)(rho x_2, 1-rho^2)$. One sweep gives $x_1^((s+1))=rho^2 x_1^((s))+"noise"$, an autoregression with
$
  rho_1=rho^2,
  quad tau=(1+rho^2)/(1-rho^2).
$
At $rho=0.5$, $tau approx 1.7$; at $rho=0.99$, $tau approx 100$.

In linear regression with a flat prior, the posterior correlation of intercept and slope is $-macron(x)\/sqrt(macron(x^2))$, where $macron(x^2)$ is the mean of $x_j^2$. Predictors far from zero push it toward $-1$. Centering sets $macron(x)=0$ and makes the two coordinates independent.

#figure(
  caption: [Checkerboard coloring of an Ising grid. Same-color pixels share no edge, so given one color, the other color's pixels are conditionally independent and can be updated together.],
)[
  #grid(
    columns: 6,
    ..range(36).map(i => box(
      width: 1.1em,
      height: 1.1em,
      fill: if calc.rem(calc.quo(i, 6) + calc.rem(i, 6), 2) == 0 {
        luma(25%)
      } else { white },
      stroke: 0.4pt + luma(40%),
    )),
  )
]

#discussion(vspace: 4em)[
  A team models house price against year built, $y_j∼cal(N)(alpha+beta x_j, sigma^2)$, with $x_j$ between $1900$ and $2020$, and runs Gibbs on $(alpha, beta)$ with $sigma$ fixed. Every intercept that fits the data must pair with a nearly determined slope, so the posterior of $(alpha, beta)$ is a long, thin diagonal ridge.

  + Sketch the posterior ridge and six Gibbs moves from one end. Sketch the trace of $beta$ you expect over $1000$ sweeps and explain what it would do to the ESS for $beta$.
  + Compare three fixes: running ten times longer, sampling $(alpha, beta)$ as one block, and refitting with $x_j-macron(x)$. Which changes the sampler, which changes the parameterization, and what plot would confirm each fix?
]

#pagebreak()
= MCMC Convergence
#sidenote(
  numbered: false,
)[Textbook: §12.6. Vehtari et al. (2021), #link("https://doi.org/10.1214/20-BA1221")[Rank-normalization, folding, and localization].]

Convergence is assessed from finite runs. Check three things separately:
+ _Kernel validity:_ does the transition preserve $p^*$? Establish this from the algorithm and test the code on a model with a known posterior. Plots of a finite run cannot certify it.
+ _Dependence on initialization:_ do post-warmup traces and summaries still differ between chains started at dispersed points?
+ _Estimation adequacy:_ is the Monte Carlo error small enough for each quantity $f$ you plan to report?

Warmup draws tune adaptive samplers and are discarded. The retained draws must then show stationarity on their own. Extra warmup cannot carry a chain across a barrier it never crosses.

== Start with Plots
Before running, list the quantities you will report, including derived ones such as predictions and tail probabilities. Run at least four chains from dispersed initial states and inspect, for each listed quantity:
- _Trace plots:_ drift, long flat stretches, mode-specific bands, and chains that behave differently.
- _Chain-specific marginals or rank plots:_ persistent differences between chains reveal failures that a pooled histogram hides.
- _Autocorrelation plots:_ slow decay means few effectively new draws.
- _Joint plots:_ narrow diagonals, funnels, and separated clusters point to a poor parameterization or transition.

#figure(
  placement: auto,
  caption: [Marginals (left) and traces (right) of three chains for a mean $alpha$ and scale $sigma$ fit to two observations. Upper: nearly flat priors give a posterior with enormous tails; the chains drift and disagree. Lower: weakly informative priors give overlapping traces and matching marginals. Black ticks mark divergent transitions in the source's sampler. Agreeing chains can still all miss the same mode. Source: Murphy (2023), Figs. 12.13–12.14, after McElreath (2020), §9.5.3.],
)[
  #image("Figures/textbook-convergence-traces.png", width: 68%)
]

#side-discussion[
  The lower run was repaired by changing the priors, which changes the posterior. When is changing the model a legitimate response to a sampling problem? (Gelman's "folk theorem of statistical computing"; McElreath, _Statistical Rethinking_, §9.5.3)
]

== Quantitative Checks
For $f_s=f(x^((s)))$, let $rho_k="Corr"(f_s,f_(s+k))$. Integrated autocorrelation time and effective sample size are
$
  tau_f=1+2 sum_(k=1)^oo rho_k,
  quad "ESS"_f=S/tau_f,
$ <mcmc-ess>
and the Monte Carlo standard error of the mean of $f$ is
$
  "MCSE"(hat(mu)_f) approx sqrt(frac("Var"_(p^*) thin [f], "ESS"_f)).
$
Software truncates the infinite sum where the estimated autocorrelations become noise. ESS depends on $f$. The _bulk ESS_ applies @mcmc-ess to rank-normalized draws and governs means and medians; the _tail ESS_ is the smaller ESS of the indicators for the $5%$ and $95%$ quantiles. A mean can have adequate ESS while a tail probability has poor ESS.

#figure(
  placement: top,
  caption: [Autocorrelation for the three MH proposal scales and for Gibbs sampling with latent component indicators, all on the bimodal target of the MH figure. Slow decay means low ESS. Source: Murphy (2023), Fig. 12.17.],
)[
  #image("Figures/textbook-autocorrelation.png", width: 66%)
]

$hat(R)$ splits every chain in half and compares the variance between halves with the variance within them. The modern version rank-normalizes the draws first, so heavy tails and scale differences also register. A common rule: require $hat(R)<1.01$ and bulk and tail ESS above $400$ total across four chains, and compare each MCSE with the precision your conclusion needs. These rules screen for failure. A run can pass all of them and still miss a mode, as Problem 6 shows. Thinning saves storage and leaves mixing unchanged. Acceptance rate describes proposal behavior and says little about convergence.

#block(breakable: false)[
  Match each symptom to a cause and a response. Every response produces a new run that needs all of these checks again.
  - _Early drift:_ transient from initialization; lengthen warmup.
  - _Slow ACF decay:_ small or misaligned moves; tune the proposal, block, or reparameterize.
  - _Chains in separate bands:_ a barrier between modes; add global moves or tempering.
  - _Large MCSE despite good mixing:_ too few retained draws; run longer.
]

Diagnostics are computed per quantity. When a posterior has symmetric modes that differ only by relabeling, as in mixture models, quantities that ignore labels can pass every check while labeled parameters fail.

== Reading a Summary Report
An illustrative report for a hierarchical model of test scores in eight schools, with population mean $mu$, school effect $theta_1$, and between-school scale $tau$ (four chains, $4000$ retained draws):

#align(center, text(size: 0.9em, table(
  columns: 7,
  stroke: none,
  inset: (x: 5pt, y: 3pt),
  align: (left, ..range(6).map(_ => right)),
  table.hline(stroke: 0.6pt),
  [], [Mean], [SD], [MCSE], [$hat(R)$], [Bulk ESS], [Tail ESS],
  table.hline(stroke: 0.4pt),
  [$mu$], [$4.4$], [$3.3$], [$0.08$], [$1.00$], [$1700$], [$1300$],
  [$theta_1$], [$6.2$], [$5.6$], [$0.15$], [$1.00$], [$1400$], [$900$],
  [$tau$], [$3.6$], [$3.2$], [$0.31$], [$1.02$], [$105$], [$38$],
  table.hline(stroke: 0.6pt),
)))

Each MCSE is roughly $"SD"\/sqrt("ESS")$. The rows for $mu$ and $theta_1$ pass every rule. The $tau$ row fails $hat(R)$ and both ESS thresholds, and its tail ESS is lowest: the chains rarely visit small $tau$. A joint plot of $theta_1$ against $log tau$ would show a funnel. The usual repair is a reparameterization, $theta_j=mu+tau eta_j$ with $eta_j∼cal(N)(0,1)$, which removes the funnel from the sampled coordinates.

#side-discussion[
  A two-component mixture has two identical posterior modes that differ only by swapping the component labels. Which reported quantities does label switching damage, and which does it leave intact? (Stephens 2000, _JRSS B_)
]

#discussion(vspace: 4em)[
  A psychologist fits a two-component Gaussian mixture to reaction times, intended to separate fast guesses from attentive responses. Four chains run $2000$ post-warmup draws each. Chains 1–2 put the fast component in slot 1; chains 3–4 put it in slot 2. For the slot-1 mean $mu_1$, $hat(R)=1.9$. For the predicted reaction-time density at $500$ ms, $hat(R)=1.00$ and bulk ESS $=3100$.

  + Is this a convergence failure? Decide which reported quantities can be trusted, and propose a summary of "the mean of the fast component" that the run supports.
  + Now suppose the two bands differ in height: chains 3–4 sit in a mode whose predictive fit is clearly worse, and no chain ever switches. Explain why this case is more serious, which diagnostics in this section would detect it, and which repair from the list above you would try.
]

#pagebreak()
= Auxiliary Variable MCMC
#sidenote(
  numbered: false,
)[Textbook: §12.4. Neal (2003), "Slice sampling," _Annals of Statistics_.]

Adding a variable $u$ can turn a hard target into a pair of easy conditionals. Define a joint target whose $x$ marginal is the original:
$
  p^* (x)=integral p^* (x, u) dif u.
$
Run any valid chain on $(x,u)$ and discard $u$; the $x$ draws target $p^* (x)$.

== Slice Sampling
For $p^* (x)=frac(tilde(p) lr((x)), Z)$, define
$
  p^* (x, u)=1/Z bold(1){0<u<tilde(p) thin (x)}.
$
The $x$ marginal is correct because the vertical slice at $x$ has height $tilde(p) thin (x)$. Ideal Gibbs updates are
$
  u^((s+1)) & ∼"Unif"(0,tilde(p) thin (x^((s)))), \
  x^((s+1)) & ∼"Unif"{x:tilde(p) thin (x)>u^((s+1))}.
$
Draw a height $u$ under the current density, then draw $x$ uniformly from the horizontal slice at that height. The slice is rarely available in closed form. In one dimension, Neal's stepping-out procedure grows an interval around $x$ in steps of width $w$, and shrinkage draws from that interval and shrinks it after each point outside the slice. Neal shows this update leaves the uniform distribution on the slice invariant, because the procedure started from the new point $x'$ could have built the same interval. Ad hoc interval rules that lack this symmetry bias the chain.

#figure(
  caption: [Left: one slice-sampling update. The sampled height $u$ lies below the valley between the modes, so the slice is a single interval containing both modes and $x$ can jump across the valley. Right: histogram of slice-sampling output on a different multimodal target. Source: Murphy (2023), Fig. 12.7.],
)[
  #image("Figures/textbook-slice-sampling.png", width: 80%)
]

When $u$ lies above the valley floor, the slice splits into two intervals. Stepping out from one interval can stop before reaching the other, so the chain stays in its mode until a low enough $u$ is drawn. Slice sampling has no step size to tune, which makes it a common choice for single nonstandard conditionals inside a Gibbs sampler.

== Stepping Out and Shrinkage
Given the current $x$, a height $u$, and a width $w$:
+ _Place:_ put an interval of width $w$ at a uniformly random offset around $x$.
+ _Step out:_ while an endpoint has $tilde(p)>u$, move that endpoint out by $w$.
+ _Shrink:_ draw $x'$ uniformly from the interval. If $tilde(p) thin (x')>u$, accept it. Otherwise move the endpoint on $x'$'s side in to $x'$ and draw again.
Shrinkage always terminates, because the interval contracts toward $x$, which lies in the slice.

#figure(
  caption: [A height above the valley floor gives a slice with two pieces (thick). Stepping out from $x$ with width $w$ stops once both endpoints fall below $u$, so the interval (bracket) never reaches the right-hand piece.],
)[
  #cetz.canvas(length: 0.62cm, {
    import cetz.draw: *
    let f(x) = (
      0.7 * calc.exp(-calc.pow(x - 2.2, 2) / 0.8)
        + calc.exp(-calc.pow(x - 5.2, 2) / 0.9)
    )
    let sy = 3.2
    let xs = range(0, 161).map(i => i * 0.05)
    line(..xs.map(x => (x, sy * f(x))), stroke: 1pt + blue.darken(20%))
    line((0, 0), (8, 0), stroke: 0.5pt)
    let u = 0.35
    line((0, sy * u), (8, sy * u), stroke: (
      paint: gray,
      dash: "dashed",
      thickness: 0.6pt,
    ))
    content((8.1, sy * u), anchor: "west", [$u$])
    line((1.45, sy * u), (2.95, sy * u), stroke: 2.2pt + black)
    line((4.23, sy * u), (6.17, sy * u), stroke: 2.2pt + black)
    let yb = -0.45
    line(
      (1.4, yb + 0.15),
      (1.4, yb),
      (3.0, yb),
      (3.0, yb + 0.15),
      stroke: 0.9pt + red.darken(20%),
    )
    content((2.2, yb - 0.1), anchor: "north", text(
      size: 0.8em,
    )[stepped-out interval])
    circle((2.6, 0), radius: 0.08, fill: black)
    content((2.6, 0.1), anchor: "south-west", text(size: 0.8em)[$x$])
  })
]

Other augmentations follow the same pattern of adding variables that make each conditional easy:
- _Hamiltonian Monte Carlo_ adds a momentum per coordinate and follows gradient-driven trajectories.
- _Data augmentation_ for probit regression adds a latent Gaussian per observation, giving conjugate Gibbs updates (Albert & Chib 1993).
- _Swendsen–Wang_ adds bond variables to an Ising model and flips whole clusters in one move.

#discussion(vspace: 4em)[
  A hand-written Gibbs sampler for a hierarchical model has one awkward update: the conditional for a variance hyperparameter has no standard form, and in some data sets it is bimodal. The options are random-walk MH or slice sampling for that coordinate.

  Draw a bimodal conditional with a shallow valley. Mark three heights: one below the valley floor, one just above it, and one near the taller peak. For each, draw the slice and describe what one update can do from a point in the shorter mode. Use your sketch to argue which method you would choose for this coordinate and what would still go wrong if the valley were very deep.
]

#pagebreak()
= Annealing
#sidenote(numbered: false)[Textbook: §12.9]

Write a target as an energy model and introduce temperature:
$
  p_T^* (x)=1/Z_T exp(-E(x)/T).
$ <tempered-target>
Large $T$ flattens the landscape and eases movement across barriers. Small $T$ concentrates mass near minimum-energy states.

#figure(
  caption: [The same energy-based target at four temperatures. High temperature flattens barriers; cooling concentrates probability around low-energy modes. Source: Murphy (2023), Fig. 12.22.],
)[
  #image("Figures/textbook-annealing-temperatures.png", width: 58%)
]

_Simulated annealing_ uses tempered MH transitions for optimization. At iteration $s$, run an MH move targeting $p_(T_s)^*$ and gradually cool $T_s arrow.r 0$. For a symmetric proposal,
$
  A_(s)(x'|x)=min(1, exp(-(E(x')-E(x))/T_s)).
$
Under conditions on the proposal, the schedule $T_s=c\/log(s+1)$ with $c$ at least the depth of the deepest non-global local minimum converges to the global minimizers (Hajek 1988). At temperature $T$, escaping a well of depth $d$ takes on the order of $exp(d\/T)$ steps, so the guaranteed schedule cools too slowly for practice. Practitioners use geometric cooling $T_(s+1)=gamma T_s$, which has no such guarantee.

#side-discussion(dy: -10em)[
  Simulated annealing on a delivery-route problem returns one route. What would MH at fixed $T=1$ return, and which output answers "how sure are we this route is best?" (Kirkpatrick, Gelatt & Vecchi 1983)
]

_Parallel tempering_ keeps chains at fixed inverse temperatures $0<beta_1<dots<beta_L=1$, with $p_beta^* (x) prop tilde(p) thin (x)^beta$. Neighboring chains occasionally propose to swap states. The swap is accepted with
$
  min(
    1,
    (tilde(p) thin (x_j)^beta_i tilde(p) thin (x_i)^beta_j)/
    (tilde(p) thin (x_i)^beta_i tilde(p) thin (x_j)^beta_j)
  ).
$
The joint target over all chains is the product of the tempered targets, and swaps preserve it. Only the $beta=1$ chain supplies unweighted draws from $p^*$. A state reaches the cold chain only by a sequence of accepted swaps up the ladder, so the swap acceptance rate between each neighboring pair is a diagnostic: neighboring tempered targets must overlap, and one rarely accepted pair cuts the hot chains off from the cold one.

In log form the swap ratio between chains $i$ and $j$ is
$
  log r=(beta_i-beta_j)(log tilde(p) thin (x_j)-log tilde(p) thin (x_i)).
$
A swap that hands the colder chain the higher-density state is always accepted. The reverse is accepted with probability $r<1$, which shrinks as the gap in $beta$ or in log density grows.

#figure(
  caption: [A four-rung ladder with geometric spacing $beta_l=0.25^((4-l)\/3)$. Swaps pass states between neighbors; only the $beta=1$ chain is reported.],
)[
  #diagram(
    edge-stroke: 0.75pt,
    node-stroke: 0.8pt,
    node-corner-radius: 4pt,
    node((0, 0), [$beta=0.25$], name: <b1>),
    node((1.5, 0), [$beta=0.40$], name: <b2>),
    node((3, 0), [$beta=0.63$], name: <b3>),
    node((4.5, 0), [$beta=1$], name: <b4>, fill: luma(88%)),
    edge(<b1>, <b2>, "<->", label: [swap]),
    edge(<b2>, <b3>, "<->", label: [swap]),
    edge(<b3>, <b4>, "<->", label: [swap]),
  )
]
Design the ladder from its swap rates. Neighboring rates of roughly $0.2$ to $0.4$ indicate overlapping targets; a rate near $0$ calls for an extra rung between that pair, and rates near $1$ suggest rungs can be removed. The hottest chain must be hot enough to cross the barriers that trap the cold chain. Hot-chain states follow $p_beta^* prop tilde(p)^beta$; reweighting them by $tilde(p)^(1-beta)$ gives valid estimates whose weights are so uneven that few draws contribute.

#discussion(vspace: 4em)[
  Bayesian phylogenetics software such as MrBayes runs one cold chain and three heated chains over tree topologies (Metropolis-coupled MCMC). An analysis of $40$ species reports these swap acceptance rates:
  $
    1 arrow.l.r 2: 0.61, quad 2 arrow.l.r 3: 0.48, quad 3 arrow.l.r 4: 0.02.
  $
  Two independent runs disagree on the most probable topology.

  + Explain how the hottest chain is supposed to help the cold chain, and use the swap rates to locate where that help is breaking down.
  + A colleague proposes reporting the trees visited by chain 4, since it explored the most topologies. Explain what distribution those trees follow and why they cannot be summarized as posterior draws. Then propose a change to the temperature ladder and the evidence that would show it helped.
]

#pagebreak()
= Sequential Monte Carlo
#sidenote(numbered: false)[Textbook: §§13.1, 13.6]

Parallel tempering runs one chain at each temperature simultaneously. Sequential Monte Carlo (SMC) moves one population of $N$ weighted particles through the temperatures in order, and more generally through any sequence of targets
$
  p_t^* (z)=frac(tilde(gamma)_(t) lr((z)), Z_t),
  quad t=0,dots,T,
$
represented by
$
  hat(p)_(t) thin (dif z)=sum_(i=1)^N W_t^i delta_(z_t^i)(dif z),
  quad sum_i W_t^i=1.
$
A population can hold several modes at once, with the weights recording their relative mass.

For static Bayesian inference, a tempered bridge runs from prior to posterior:
$
  p_t^* (theta) & prop p(theta)p(cal(D)|theta)^lambda_t,
                  quad 0=lambda_0<dots<lambda_T=1.
$
Each step of the cycle is:
+ _Reweight:_ $tilde(w)_t^i=W_(t-1)^i p(cal(D)|theta_(t-1)^i)^(lambda_t-lambda_(t-1))$, then normalize.
+ _Diagnose:_ compute the weighted ESS
  $
    "ESS"_w=1/(sum_i (W_t^i)^2),
  $
  which ranges from $1$ (one particle holds all weight) to $N$ (equal weights).
+ _Resample_ when $"ESS"_w<N\/2$: draw $N$ particles in proportion to $W_t^i$ and reset weights to $1\/N$.
+ _Move:_ apply a few MCMC transitions that preserve $p_t^*$, so duplicated particles spread out again.
Adaptive schedules choose each $lambda_t$ by bisection so that the reweighting step gives $"ESS"_w approx N\/2$, then resample and move at every step. A large jump in $lambda$ collapses the weights. Weighted ESS measures weight concentration; @mcmc-ess measures autocorrelation.

For a growing path $z_(1:t)$ proposed by
$
  q_(t)(z_(1:t))=q_(t-1)(z_(1:t-1))q_(t)(z_t|z_(1:t-1)),
$
the same reweighting step generalizes to the form particle filtering uses:
$
  tilde(w)_t^i=W_(t-1)^i
  (tilde(gamma)_(t) thin (z_(1:t)^i))/
  (tilde(gamma)_(t-1) thin (z_(1:t-1)^i)q_(t)(z_t^i|z_(1:t-1)^i)).
$ <smc-weight>

#figure(
  caption: [One SMC step for a tempered bridge. The weighted ESS decides whether to resample; the move step uses any MCMC kernel invariant for $p_t^*$.],
)[
  #diagram(
    edge-stroke: 0.75pt,
    node-stroke: 0.8pt,
    node-corner-radius: 4pt,
    spacing: (1.6em, 1.8em),
    node((0, 0), [choose $lambda_t$], name: <c1>),
    node((1, 0), [reweight], name: <c2>),
    node((2, 0), [$"ESS"_w<N\/2$?], name: <c3>),
    node((3, 0), [resample], name: <c4>),
    node((4, 0), [move], name: <c5>),
    edge(<c1>, <c2>, "->"),
    edge(<c2>, <c3>, "->"),
    edge(<c3>, <c4>, "->", label: [yes], label-side: right),
    edge(<c4>, <c5>, "->"),
    edge(<c3>, <c5>, "->", bend: 35deg, label: [no], label-side: left),
    edge(<c5>, <c1>, "->", bend: 22deg, label: [$t+1$], label-side: left),
  )
]

#figure(
  caption: [Left: without resampling, sequential importance weights collapse onto one trajectory. Right: bootstrap filtering resamples ancestors, proposes descendants, and weights them using the newest observation. Source: Murphy (2023), Fig. 13.2.],
)[
  #image("Figures/textbook-smc-degeneracy-bootstrap.png", width: 86%)
]

The final population answers questions a single chain cannot. The posterior mass of a mode is estimated by the total weight of the particles in it. The run also estimates the marginal likelihood:
$
  hat(p) thin (cal(D))=product_(t=1)^T sum_(i=1)^N W_(t-1)^i p(cal(D)|theta_(t-1)^i)^(lambda_t-lambda_(t-1)).
$
Mode masses come from the reweighting steps; the move steps rarely carry particles across a barrier. Check mode masses and $log hat(p) thin (cal(D))$ across several independent runs before reporting them.

#discussion(vspace: 1em)[
  An epidemiologist fits a disease-transmission model with $N=1000$ particles. The posterior has two separated modes: fast spread with strong reporting delay, and slow spread with little delay. A tempered SMC run jumps straight from $lambda=0$ to $lambda=1$; afterward $"ESS"_w=3$.

  + Explain in words what happened to the weights and why resampling alone cannot fix it. Describe how the adaptive $lambda$ schedule and the MCMC move step each address part of the problem.
  + A single MH chain on the same posterior stays in one mode. Explain what the SMC population can represent that the chain cannot, and what you would check in the final particle set before trusting the mode weights.
]

#pagebreak()
= Particle Filtering
#sidenote(
  numbered: false,
)[Textbook: §13.2. Thrun, Burgard & Fox, _Probabilistic Robotics_ (2005), Chs. 4 and 8.]

Particle filtering applies SMC to online inference in a state-space model:
$
  p(z_(1:T),y_(1:T))
  =p(z_1)p(y_1|z_1)
  product_(t=2)^T p(z_t|z_(t-1))p(y_t|z_t).
$
At time $t$, particles approximate $p(z_t|y_(1:t))$ and are updated when $y_(t+1)$ arrives. In robot localization, $z_t$ is the robot's pose and $y_t$ is a range-sensor scan.

== Bootstrap Particle Filter
Given particles ${z_(t-1)^i,W_(t-1)^i}_(i=1)^N$:
+ Resample ancestor $a_i∼"Categorical"(W_(t-1)^(1:N))$.
+ Propagate $z_t^i∼p(z_t|z_(t-1)^(a_i))$.
+ Weight $tilde(w)_t^i=p(y_t|z_t^i)$ and normalize.

In @smc-weight the transition density cancels because it is also the proposal. The bootstrap proposal ignores the newest observation. When $y_t$ is surprising, or the sensor is very precise, almost every propagated particle can receive negligible weight.

#side-discussion(dy: -6em)[
  Thrun et al. report that Monte Carlo localization can perform _worse_ as the range sensor becomes more accurate. Explain why using the bootstrap proposal. (_Probabilistic Robotics_, §8.3.7)
]

== Degeneracy
Without resampling, sequential importance weights concentrate on few particles. Resampling discards low-weight particles and duplicates high-weight ones. It reduces the number of distinct current particles at that moment; the next propagation step spreads the duplicates apart. Repeated selection creates _path degeneracy_: many current particles share the same early ancestors. Path degeneracy mainly harms smoothing of old states; current-state filtering can remain accurate.

#figure(
  caption: [Panel (a): resampling keeps the current particles spread over the high-probability region. Panel (b): tracing them back shows that the surviving trajectories share a few early ancestors. Source: Murphy (2023), Fig. 13.3.],
)[
  #image("Figures/textbook-path-degeneracy.png", width: 94%)
]

Resample when $"ESS"_w$ falls below a threshold such as $N\/2$. Stratified resampling has lower offspring-count variance than multinomial resampling for the same weights (Douc, Cappé & Moulines 2005); systematic resampling is a common default. Proposals that use $y_t$ reduce incremental-weight variance.

The filter also estimates the marginal likelihood, which is used to compare models or fit parameters:
$
  hat(p) thin (y_(1:T))=product_(t=1)^T [sum_(i=1)^N W_(t-1)^i tilde(w)_t^i],
$
with $W_(t-1)^i=1\/N$ after a resampling step. With unbiased resampling schemes this estimate is unbiased (Del Moral 2004). Its logarithm underestimates $log p(y_(1:T))$ on average, by Jensen's inequality.

== Repairs and Extensions
- _Observation-informed proposal:_ the locally optimal choice is $q(z_t|z_(t-1),y_t)=p(z_t|z_(t-1),y_t)$, with incremental weight $p(y_t|z_(t-1))$. That weight does not depend on the sampled $z_t$, so its variance comes only from the ancestors.
- _Robust motion model:_ $p_epsilon (z_t|z_(t-1))=(1-epsilon)p(z_t|z_(t-1))+epsilon thin u(z_t)$ with $u$ uniform over the map. A small $epsilon$ states that the robot can be moved, and particles drawn from $u$ can find it.
- _Monitoring:_ track $"ESS"_w$ and the average unnormalized weight $1/N sum_i tilde(w)_t^i$. A sustained drop in the average weight means the current particles cannot explain the observations.
- _Smoothing old states:_ fixed-lag smoothing, backward simulation through the stored particle sets, or particle MCMC.

#discussion(vspace: 4em)[
  A warehouse robot runs a bootstrap filter with $500$ particles and has localized itself correctly. A worker lifts the robot and sets it down in another aisle. For the next minute every particle remains near the old location, the reported position is wrong, and $"ESS"_w$ stays near $1$ after every scan.

  + Diagnose the failure using the bootstrap steps. Why can't resampling or $5000$ particles reliably recover it? Compare two repairs: an observation-informed proposal, and replacing a small fraction of particles each step with poses drawn from the latest scan. What does each change about the model or the proposal?
  + Separately, a safety audit asks for the robot's full path over the last hour from the same particle set. Explain why the filter's current position estimate can be trusted while its reconstruction of the path an hour ago cannot.
]

// #pagebreak()
// = Practice Problems
// // Tighter problem headings so the problem set fits two pages.
// #show heading.where(level: 2): it => block(above: 1.8em, below: 0.65em, text(
//   size: 14pt,
//   weight: "medium",
//   style: "italic",
//   it.body,
// ))
// #sidenote(
//   numbered: false,
// )[Problem 1 adapts Stanford CS228's #link("https://ermongroup.github.io/cs228-notes/inference/sampling/")[Sampling Methods] notes. Problems 3, 5, and 7 use the examples in Murphy (2023), §§12.2–12.6. Problem 5 follows the diagnostic guidance of Vehtari et al. (2021). Problem 9 adapts Berkeley CS188's particle-filtering exam-prep problems. Problem 10 draws on the domain examples in Sections II–VIII.]

// == 1. A Sticky Two-State Chain
// For $K=mat(1-epsilon, epsilon; epsilon, 1-epsilon)$ with $epsilon=0.01$:
// + Verify that $(1\/2,1\/2)$ satisfies detailed balance.
// + Starting from state $0$, what is the expected number of state changes in $50$ transitions? What does that imply about the empirical average?
// + Would discarding the first half of the run, or keeping every tenth draw, repair the problem?

// == 2. MH by Hand
// A robot samples destinations $A,B,C$ with unnormalized target values $tilde(p) thin (A)=1$, $tilde(p) thin (B)=2$, $tilde(p) thin (C)=6$. From $A$ or $C$ it always proposes $B$; from $B$ it proposes $A$ or $C$ with probability $1\/2$ each.
// + Compute the four acceptance probabilities and the $3 times 3$ transition matrix, including rejection.
// + Check that $(1,2,6)\/9$ is stationary. Which stationary distribution results if every proposal is accepted?

// == 3. Reading Proposal-Scale Evidence
// Use the MH proposal figure. The estimand is the probability of the right-hand mode.
// + Rank the runs by acceptance rate and by mode coverage. Explain why the two rankings differ.
// + For which run is "run longer" least convincing as a repair? Name one plot and one numerical summary to request before reporting the estimate.

// == 4. Parallel Gibbs Updates in Image Denoising
// Gibbs sampling with an Ising prior restores a binary image from a noisy copy.
// + A GPU implementation resamples every pixel at once from its neighbors' previous values. Explain why this kernel can fail to preserve the posterior. Hint: consider two neighboring pixels that strongly prefer to agree.
// + Describe a parallel schedule that is valid, and state the conditional independence it relies on.

// == 5. A Diagnostic Dashboard
// Four chains each retain $5000$ draws of a parameter $theta$ with posterior standard deviation $3$. The traces occupy two separated bands. The summary reports $hat(R)=1.14$, an ESS of $120$ for the mean of $theta$, and a tail ESS of $18$.
// + Diagnose the dominant failure. Compute the MCSE the formula gives for the posterior mean; why is that number untrustworthy here?
// + Classify longer warmup, more dispersed starts, blocking, tempering, thinning, and pooling all draws as _detection_, _repair_, or neither.

// == 6. Starting Every Chain at the Optimum
// An analyst starts four chains at the MAP estimate from an optimizer. The chains produce overlapping stable traces near $theta=+5$, and $hat(R)=1.00$. A separate optimizer run from a different start finds a second high-density region near $theta=-5$.
// + Why do the diagnostics look good, and what does the experiment fail to test?
// + Redesign the initialization. If the new chains split between the modes, what should happen to $hat(R)$?

// == 7. Acceptance Rate versus Efficiency
// Sampler A accepts $99%$ of random-walk proposals and its ACF decays slowly. Sampler B accepts $45%$ and its ACF reaches zero after ten lags.
// + Which sampler likely has larger ESS per iteration, and what proposal behavior produces Sampler A's result?
// + If both chains remain in one mode, does Sampler B's lower autocorrelation settle the convergence question?

// == 8. A Tempering Swap
// A cold chain ($beta_c=1$) is at a state with $tilde(p) thin (x_c)=64$; a hot chain ($beta_h=0.25$) is at a state with $tilde(p) thin (x_h)=4$.
// + Compute the swap acceptance probability. Interpret the result: which chain gives up the better state?
// + Compare parallel tempering with spending the same computation on four longer ordinary chains, for a target whose modes are separated by a deep valley.

// == 9. Tracking with Weighted Particles
// Three equally weighted particles tracking a target receive likelihoods $(0.05,0.15,0.80)$.
// + Compute the normalized weights, $"ESS"_w$, and the expected multinomial offspring counts. Does the $N\/2$ rule call for resampling?
// + If this repeats for twenty steps, what happens to the particles' histories?

// == 10. Choosing a Sampler
// Choose a method and the first diagnostic to check for: (a) tracking aircraft from radar returns each second; (b) a topic model whose topic proportions integrate out analytically; (c) a phylogenetic posterior whose runs find different tree islands; (d) one nonstandard hyperparameter conditional in an otherwise conjugate Gibbs sampler.
