#import "wdf.typ": *

#show: template.with(
  title: [Optimization],
  title-short: none,
  authors: "CSC 5666: Advanced Machine Learning, Fall 2026",
  authors-short: none,
  title-extra: [Professor Austin P. Wright: Course Notes],
  date: none,
  toc: false,
  full: false,
  header-content: none,
  abstract: [Introduction to the foundational concepts in optimization theory that are used in the context of probabilistic inference and machine learning. Closely follows Chapter 6 of Murphy's textbook.],
  bib: none,
  serif: true,
  exam: false,
)

#let prompt(dy: auto, body) = sidenote(dy: dy, numbered: false)[
  #text(fill: green.darken(25%), style: "italic", weight: "semibold")[Prompt.]
  #body
]

#sidenote(dy: 1.15em, numbered: false)[#outline(depth: 1)]

= Introduction to Optimization
#sidenote(numbered: false)[Textbook: Chapter 6, pp. 261–342]

So far in this course we have introduced many mathematical constructs that represent process we wish to model. However when it comes to actually constructing programs or models that have the properties we want, this most often requires some form of optimization. In extreme generality, this means writing problems in the form
$
  theta^* in limits("argmin")_(theta in Theta) cal(L)(theta)
$
where $cal(L) : Theta -> RR$ is the objective or loss function and $Theta$ is the parameter space we optimize over. What we have yet to discuss is _how_ to actually construct $theta$ to where those objectives want it.

Optimization theory is a rich field unto itself, and I will assume some minimal prior familiarity with it. What follows refreshes the parts this course leans on, plus a few topics that matter in the probabilistic and Bayesian setting.

In particular we will simply take as a starting point the existence of some class of differentiable functions about which we can take gradients. In reality there is a huge amount of work involved in the construction of such functions, and they can take the form of restricted classes of computation graph such as Pytorch#sidenote()[https://pytorch.org/], or can be more complex _differentiable programs_. Systems such as JAX#sidenote()[https://docs.jax.dev/en/latest/index.html], and Dex#sidenote()[https://google-research.github.io/dex-lang/] are examples of highly general purpose differentiable programming systems built around a pure functional style.


= Stochastic Gradient Descent
#sidenote(numbered: false)[Textbook: §6.3, pp. 271–279]

In this class the majority of objects about which we are trying to optimize are probabilistic. Thus the opitimization objectives we care about will frequently take the form:
$
  cal(L)(theta) = EE_(q_theta (z))[tilde(cal(L)) (theta, z)]
$
where $theta$ are parameters over which we want to optimize, and $z$ is a random variable, modeling something like external noise.

If we then have a way of calculating an estimate of the gradient of the objective function, we can use the procedure of gradient descent to improve our estimates of $theta$ iteratively using a _learning rate_, $alpha$.
$
  theta_(t+1) = theta_t + alpha_t (nabla_theta cal(L)(theta) |_(theta_t))
$

This is _stochastic gradient descent (SGD)_, differentiated as stochastic because the gradient being calculated is in face an _expectation_ over some random variables.

Note that we actually index the learning rate as a function of the iteration step $t$. This is because in general we want to lower the learning rate over time, as big updates make sense early on in the process where we are far away from an optimal solution, but smaller steps are needed to fine tune closer to an optimum. In fact in general it can be shown that any learning rate schedule that meets the Robbins-Monro conditions will reach convergence in SGD.
$
  alpha_t -> 0 "and" (sum_t=1^infinity alpha_t^2)/(sum_t=1^infinity alpha_t) -> 0
$

Common schedules that are used (or sometimes combined) are:
- Piecewise constant: $alpha_t = alpha_i "if" t_i <= t < t_(i+1)$
- Exponential decay: $alpha_t = alpha_0 e^(-lambda t)$
- Polynomial decay: $alpha_t = alpha_0 (b dot t + 1)^(-a)$
- Reduce on plateau: Estimate if loss has stopped decreasing enough over some time horizon, and if so reduce $alpha$

In addition to all of these methods there is a huge array of tricks and variants on the basic SGD process. Any of the libraries you are likely to deal with will have support for many of them, and in practice the different learning rate values (or schedule hyperparamters) are determined through pure empirical trial and error for any given optimization.

#discussion(vspace: 10em)[
  Above we motivated decaying $alpha_t$ by saying that large updates make sense
  early and small ones late. However, some research has shown that you can instead hold
  $alpha$ fixed and grow the batch size on the same schedule, and obtain
  essentially the same training curve. Without writing any algebra, say what
  quantity the two procedures are holding in common, and what that implies about
  which of the two knobs is the real one. Then give one practical reason you might
  still prefer decay, and one reason you might prefer growth. #sidenote()[_Hint_: A mini-batch is defined as using a small sample of data-point for the SGD expectation which otherwise is over the full dataset. If we think of the mini-batch loss then as a noisey estimate of the overall loss, what changes about this estimate when changing the size of the mini-batch?]

]


== Reparametrization Trick
#sidenote(numbered: false)[Textbook: §6.3.5, pp. 275–276]

Consider now the case where the stochasticity we are optimizing over itself depends on the parameters we are optimizing. This happens frequently in Reinforcement learning where $z$ may be actions sampled from a policy we are training, or more relevantly for us $z$ may be a _latent variable_ sampled from an inference network $q_theta$ which occurs in stochastic variational inference. In this case we have the gradient:
$
  nabla_theta EE_(q_theta (z))[tilde(cal(L))(theta,z)] &= nabla_theta integral tilde(cal(L))(theta,z) q_theta (z) d z\
  &= integral nabla_theta tilde(cal(L))(theta,z) q_theta (z) d z\
  &= integral [nabla_theta tilde(cal(L))(theta,z)] q_theta (z) d z + integral tilde(cal(L))(theta,z) [nabla_theta q_theta (z)] d z\
$

While the first term can be approximated by Monte-Carlo sampling, the second term cannot. Thus in order to estimate the gradient we need to use something called the _reparametrization trick_. #sidenote()[While there are other tricks we could use such as Score Function Estimation or REINFORCE, the reparametrization trick tends in practise to be lower variance and thus preferred if we can reparametrize the problem appropriately.]

For this we need to be able to meet two additional requirements:
+ $tilde(cal(L))(theta,z)$ must be differentiable with respect to $z$
+ We must be able to sample from $q_theta (z)$ by first sampling  $epsilon$ from some noise distribution that is _independent of $theta$_ and then transforming to $z$ using a determinisitc and differentiable function $z=g(theta,epsilon)$. Most frequently this will be something like producing a sample $z ~ cal(N)(mu, sigma^2)$ by first sampling $epsilon ~ cal(N)(0,1)$ and then calculating $z=mu + sigma epsilon$ (where here $theta = (mu,sigma)$).

Doing this allows us to rewrite the objective
$
  cal(L)(theta) = EE_(q_theta (z))[tilde(cal(L))(theta,z)] = EE_(q_0(epsilon.alt))[tilde(cal(L))(theta, g(theta,epsilon.alt))],
$

Since now the expectation is over a distribution _independent of the parameters $theta$_, we can push the gradient inside the expectation and approximate with Monte-Carlo.

$
  nabla_theta cal(L)(theta) = EE_(q_0 (epsilon.alt))[nabla_theta tilde(cal(L))(theta, g(theta,epsilon.alt))] approx 1/S sum_(s=1)^S nabla_theta tilde(cal(L))(theta, g(theta,epsilon.alt_s)).
$


#discussion(vspace: 5em)[
  Consider the point in the derivation above where moving the gradient inside
  the expectation became legal. What would have gone wrong if we just applied the same step to the first form? Then answer the question that should be bothering you: Since the reparametrized objective is the same objective, taking the same value for every $theta$, how can rewriting an expression change which gradients we are able to compute?
]


=== The Gumbel-Softmax Relaxation
#sidenote(numbered: false)[Textbook: §6.3.6, pp. 277–278]

The reparametrization trick is very powerful and useful, however not all distributions can be reparametrized. Most notably perhaps are discrete variables which we often want to be able to encode in a latent representation. In such cases we can _relax_ the discrete variables into continuous variables in a way that allows the trick to be used.

Consider a one-hot vector $d$ with $K$ bits, that is $d in {0,1}^K$ and $sum_k d_k = 1$. This vector represents a categorical variable with $K$ states. Then let $P(d) = "Cat"(d|pi)$ where $pi_k = P(d_k=1)$#sidenote()[We could also define the parametrization of the distribution for un-normalized values of $pi$, and calculate the normalization when needed.] define the probability distribution of the variable.We can sample a one-hot vector $d$ from this distirbution by computing
$
  d = "onehot"(limits("argmax")_k [epsilon_k+log(pi_k)])
$

Where $epsilon_k ~ "Gumbel"(0,1)$ is sampled from the Gumbel distribution. This gives us a reparamtrization, however it is not a very useful one.

#discussion(
  vspace: 0em,
)[Before moving on, what is the issue with this reparametrization?]

The big problem with the representation is that the argmax function is useless for gradient based optimization! It is zero everywhere except for on the borders of transitions from class to class, at which point it is undefined. Thus we will replace the argmax with _softmax_, and the vector $d$ with a continuous relaxation $x$ over the $K$ dimensional simplex #sidenote(dy: -5em)[The simplex is just defined as the continuous mutli-dimensional surface over the same space as the one-hot vector. #math.equation(block: true, numbering: none)[$ x in {x in RR^K | x_k in [0,1], sum_(k=1)^K x_k = 1} $]] allows us to write:

$
  x_k = (exp((log(pi_k)+epsilon_k) \/ tau)) / (sum_(k'=1)^(K) exp((log(pi_(k'))+epsilon_(k')) \/ tau))
$

#sidenote(numbered: false)[
  #discussion(vspace: 0em)[
    For a single categorical latent with $K = 7$ states, as in the figure, the objective $EE[tilde(cal(L))]$ is a sum of seven terms whose gradient can be computed exactly with no relaxation. If this is the case, why is the relaxation nonetheless the standard tool. What has to be true of the model for exact enumeration to stop being an option?
  ]
]

Where $tau >0$ is the _temperature_ hyperparameter. This is called the _Gumbel-softmax distribution_, which smoothly approximates the discrete distribution as $tau -> 0$, and thus allows us to replace $f(d)$ with $f(x)$ and take gradients with respect to $x$.


#v(-1em)

#figure(
  image("Figures/textbook-gumbel.png", width: 90%),
  caption: [ Illustration of the Gumbel-softmax distribution with $K = 7$ states at different temperatures $tau$. The top row shows $EE[z]$, and the bottom row shows samples $z∼"GumbelSoftmax"(pi,tau)$. The left
    column shows a discrete (categorical) distribution, which always produces one-hot samples. From Textbook Figure 6.3.],
)


= Natural Gradient Descent
#sidenote(numbered: false)[Textbook: §6.4]

So far when doing optimization we have been performing updates in terms of _parameters_, $theta$, of a distribution. However, it is important to note that differences in parameters not the same thing as differences in the distributions themselves.

#figure(
  image("Figures/textbook-kl-vs-euclidean.png", width: 80%),
  caption: [Shifting a Gaussian's mean by the same amount $delta$ (solid to dotted) when the variance is (a) small or (b) large. The Euclidean distance moved in parameter space is identical; the KL divergence, and so the change in information, is not. Reproduced from Murphy, Textbook Figure 6.5, p. 280.],
)

_Natural Gradient Descent_ (NGD) is defined in terms of the distance between two probability distributions, and thus in terms of KL divergence.

Let us say we have a conditional distribution $p_(theta)(y|x)$ for which we want to perturb the paramters $theta$, the divergence is thus given by #sidenote()[
  If you remember what we discussed about information theory, this move should set off some alarm bells. We heavily emphasized that KL is neither a distance nor symmetric, and here it behaves like a metric. In this case this is ok because the asymmetry is third order: to second order $D_("KL")(p_theta||p_(theta+delta))$ and $D_("KL")(p_(theta+delta)||p_theta)$ are the same quantity, $1/2 delta^T F delta$, for small $delta$. The local geometry is symmetric even though the global divergence is not, which is why we did not have to say which way round the arguments went.
]
$
  D_("KL")(p_theta || p_(theta + delta)) approx 1/2 delta^T F_(x)(theta) delta,
$
where $F_(x)$ is the _Fisher information matrix_.
$
  F_(x)(theta) &= -EE_(p_(theta)(y|x))[nabla_theta^2 log p_(theta)(y|x)] \
  &= EE_(p_(theta)(y|x))[(nabla_theta log p_(theta)(y|x))(nabla_theta log p_(theta))^top]
$
And we can compute the average KL between the current and update distributions using $1/2 delta^T F(theta) delta$ where $F$ is the average FIM.
$
  F(theta) = EE_(p_(cal(D))(x))[F_(x)(theta)]
$

For NGD we then use the inverse FIM as a _preconditioning matrix_ for updates of the form
$
  theta_(t+1) & = theta_t - alpha_t F(theta_t)^(-1) nabla_theta cal(L)(theta_t) \
              & = theta_t - alpha_t tilde(nabla)_theta cal(L)(theta_t)
$

Where $tilde(nabla)_theta$ is called the _natural gradient_.

Natural gradient descent can be much more robust to noise when compared to standard gradient descent, especially the noise introduced by mini-batch approximations where we can recompute $F$ online per mini-batch. Additionally, since NGD updates parameters in a way that _matters more for the predictions generated from the distribution_, we can sometimes get away with larger learning rates at least in the initial steps of the optimization, and somewhat avoid getting stuck in plateaus. Finally, since NGD is invariant to how the distribution is parameterized, which is useful when we are representing distributions using complex models such as neural networks.


== Approximating the Natural Gradient

#v(1em)
The main cost of NGD is in the calculation of the inverse of the Fisher Information Matrix. Frequently assumptions about the structure of $F$ are made in order to speed up this process, such as using a diagonal approximation or some other kind of factorization.

A simpler approach is to approximate the FIM by replacing the model's distribution with the empirical distribution, which allows us to calculate the _empirical Fisher_
$
  F approx 1/(|cal(D)|) sum_((x,y)in cal(D)) nabla log(p(y|x,theta)) nabla log(p(y|x,theta))^top
$

While this is a widely used approximation since it is simple to compute#sidenote()[AdaGrad uses a similar approach but including a momentum component.], the empirical Fisher does not work quite as well as the true Fisher. In particular in "plateau" regions the empirical Fisher becomes singular, while the true Fisher marginalizes out $y$ which allows it to detect small changes in the output by changing the parameters. Thus one of the main benefits of NGD is restricted to the more expensive full case.

#discussion(vspace: 15em)[
  + Despite the fact that NGD has a bevy of theoretical benefits, it is not used very frequently in practice. Why is this the case? Consider how much does NGD actually cost, and which of the benefits survive the approximations required to overcome this cost.#v(5em)
  + The figure at the top of this section shows how the $mu$ parameter space affects distributions. Redraw the
    argument for $sigma$: for a narrow Gaussian and a wide one, which
    is more changed in distribution terms, for a constant $Delta sigma$?
    Sketch what a preconditioner therefore has to do to the two coordinates, and thus describe something $F$ can do here that no choice of per-parameter learning rates could do.

]

#pagebreak()
= Additional Optimization Methods

#v(1em)
Beyond gradient descent, we sometimes want to be able to perform optimization in non-differentiable contexts. These will be considered outside of the scope of this course, however they are extremely interesting and powerful and may be useful to you in your project of other work, so we will briefly summarize some of the most valuable methods worth exploring. Many of these methods become useful in the _meta-learning_ process of choosing appropriate modeling choices and hyperparamters for which we cannot directly optimize.

== Bayesian Optimization
#v(1em)

If we have an optimization problem for which is it very expensive to generate samples, and for which we cannot calculate gradients (a _black box_), Bayesian Optimization (BayesOpt) provides a very powerful option.

Since the true objective function $f$ may be expensive to evaluate (such as running a simulation or training a model), our goal is to make as few _queries_ of the _oracle_ $f$ as possible. In order to do this we construct a _surrogate function_ based on the data collected so far for which we can decide which point to query next. This task has an inherent tradeoff between picking a point $x$ for which we think $f(x)$ will be good #sidenote()[In the BayesOpt literature the convention is to actually be _maximizing_ $f$.], and picking points about which we are _uncertain_. #sidenote()[This is yet another instance of the classic, _exploration exploitation_ dilemma.] In the discrete case this becomes similar to the _multi-arm bandit_ problem. The most frequent surrogate function choice in BayesOpt is a Gaussian process#sidenote()[This is also a class of model that we will not discuss in depth but it very much worth learning for it's own sake as they support closed form Bayesian updating and work well in cases of small data.], as it gives us very high flexibility and good models of uncertainty. It also allows us to compute the _acquisition function_ to determine the next sample point $x_n$ with the highest expected utility, where our choice of utility model will determine where the optimization lands on exploration vs exploitation.

#import algorithmic: algorithm-figure, style-algorithm
#show: style-algorithm
#algorithm-figure(
  "Bayesian Optimization",
  inset: 0.35em,
  vstroke: .5pt + luma(200),
  {
    import algorithmic: *
    Comment[Given acquisition function, $alpha$]
    Comment[Collect initial dataset, $cal(D)_0={(x_i,y_i)}$]
    Comment[Initialize model by computing, $p(f|cal(D)_0)$ ]
    For(
      $n=1,2,... italic("until convergence")$,
      {
        Comment[Choose next query point, $x_(n+1) = "argmax"_x alpha (x; cal(D)_n)$ ]
        Comment[Measure function value, $y_(n+1) = f(x_(n+1)) +epsilon_n$ ]
        Comment[Augment dataset, $cal(D)_(n+1) = {(y_(n+1),x_(n+1))} union cal(D)_n$ ]
        Comment[Update model by computing, $p(f | cal(D)_(n+1))$ ]
      },
    )
    Return[$max cal(D)_("end")$]
  },
)

#wideblock()[
  #figure(
    image("Figures/textbook-bayesopt.png", width: 100%),
    caption: [Illustration of sequential Bayesian optimization over three iterations. The rows correspond to a training set of size $t= 2,3,4$. The dotted black line is the true, but unknown, function $f(x)$. The solid black line is the posterior mean, $mu(x)$. The shaded blue intervals are the 95% credible interval derived from $mu(x)$ and $sigma(x)$. The solid black dots correspond to points whose function value has already been computed, i.e., $x_n$ for which $f(x_n)$ is known. The green curve at the bottom is the acquisition function. The red dot is the proposed next point to query, which is the maximum of the acquisition function. From Textbook Figure 6.10],
  )
]
#pagebreak()

== Evolutionary Algorithms

#v(1em)

If we do not have the restriction that computing the optimization is expensive, but keep the restriction that it is not differentiable, one interesting method is to use an _Evolutionary Algorithm (EA)_, where we maintain a set or _population_ of candidates at each point in time, which we try to improve (locally for each candidate) at each step. In many ways this is a more efficient form of just guessing with local improvements, since it will explore more of the search space at once, and information from different members of the population can be shared.

Since, as you might expect, evolutionary algorithms take inspiration from biology, they often also borrow much of the same terminology. Thus we have:
- The _fitness_ of a member of the population is the value of the objective function (possibly normalized across population members)
- The members of the population at step $t+1$ are called the _offspring_ which are created by random _recombination_ of _parents_ at step $t$ and application of some randomness as a _mutation_.
- The procedure that determines the parents that are chosen to _reproduce_ is called the _selection function_

Different forms of EA generally are differentiated by their selection functions and recombination and mutation procedures. Examples include _genetic algorithms_ which use a recombination and mutation method based on _crossover_ of candidate vector representations, and _genetic programming_ which uses a tree structured representation.


#wideblock()[
  #figure(
    image("Figures/textbook-genetic-algorithm.png", width: 80%),
    caption: [Illustration of a genetic algorithm applied to the 8-queens problem. (a) Initial population of 4
      strings. (b) We rank the members of the population by fitness, and then compute their probability of mating. Here the integer numbers represent the number of nonattacking pairs of queens. From Textbook Figure 6.13],
  )
]
