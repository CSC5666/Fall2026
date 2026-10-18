#import "wdf.typ": *
#import "Figures/inference-figures.typ": *
#import "@preview/cetz:0.4.2"

#show: template.with(
  title: [Introduction to Generative Models],
  title-short: none,
  authors: "CSC 5666: Advanced Machine Learning, Fall 2026",
  authors-short: none,
  title-extra: [Professor Austin P. Wright: Course Notes],
  date: none,
  toc: false,
  full: false,
  header-content: none,
  abstract: [Overview of generative models, model types, tasks, and evaluation. See textbook Chapter 20.],
  bib: none,
  serif: true,
  exam: false,
)

#sidenote(dy: 1.15em, numbered: false)[#outline(depth: 1)]

#v(-3em)
= Types of Generative Model
#sidenote(
  numbered: false,
)[Textbook: §§20.1–20.2. Stanford CS236, #link("https://deepgenerativemodels.github.io/notes/introduction/")[Introduction].]

A *generative model* is a joint probability distribution $p(x)$, for $x in cal(X)$. In some cases, the model may be conditioned on inputs or covariates $c in cal(C)$, which gives rise to a *conditional generative model* of the form $p(x|c)$.

Fitting one means picking the parameters within a family of model distributions that minimizes some notion of distance to the data distribution,
$
  min_(theta in cal(M)) d(p_"data", p_theta),
$

where $p_"data"$ is accessed only through the dataset and $d$ is a notion of distance between probability distributions. Discriminative models predict a label for any given datapoint. Generative models, on the other hand, learn a joint distribution over the entire data.

At a high level, we can distinguish between *deep generative models* (DGM) which use deep neural networks to learn a complex mapping from a single latent vector $z$ to the observed data $x$, and more "classical" *probabilistic graphical models* (PGM), that map a set of interconnected latent variables $z_1,dots,z_L$ to the observed variables $x_1,dots,x_D$ using simpler, often linear, mappings #sidenote()[Though in fact these classes afford plenty of combination, such as using neural networks to map relations within a PGM as well as enforcing state space structure within a DGM]. The main kinds of DGM are: _variational autoencoders_ (VAE), _autoregressive models_ (ARM), _normalizing flows_, _diffusion models_, _energy based models_ (EBM), and _generative adversarial networks_ (GAN), many of which we will cover in more detail in the coming lectures.

We can categorize these models in terms of the following criteria:
- _Density:_ does the model support pointwise evaluation of the probability density function $p(x)$, and if so, is this fast or slow, exact, approximate or a bound, etc? For implicit models, such as GANs, there is no well-defined density $p(x)$. For other models, we can only compute a lower bound on the density (VAEs), or an approximation to the density (EBMs, UPGMs).
- _Sampling:_ does the model support generating new samples, $x ∼ p(x)$, and if so, is this fast or slow, exact or approximate? Directed PGMs, VAEs, and GANs all support fast sampling. However, undirected PGMs, EBMs, ARM, diffusion, and flows are slow for sampling.
- _Training:_ what kind of method is used for parameter estimation? For some models (such as AR, flows and directed PGMs), we can perform exact maximum likelihood estimation (MLE), although the objective is usually non-convex, so we can only reach a local optimum. For VAEs we maximize a lower bound on the likelihood; for EBMs and UGMs, an approximation to it. For GANs we have to use min-max training, which can be unstable, with no clear objective function to monitor.
- _Latents:_ does the model use a latent vector $z$ to generate $x$ or not, and if so, is it the same size as $x$ or is it a potentially compressed representation? For example, ARMs do not use latents; flows and diffusion use latents, but they are not compressed. Graphical models, including EBMs, may or may not use latents.
- _Architecture:_ what kind of neural network should we use, and are there restrictions? Flows are restricted to invertible networks with tractable Jacobians; EBMs can use any model we like.

#let gcol = rgb("#b6d7a8")
#let gline = rgb("#38761d")
#let bcol = rgb("#cfe2f3")
#let bline = rgb("#3d85c6")
#let rcol = rgb("#ea9999")
#let rline = rgb("#b45f5f")
#let ycol = rgb("#ffe599")
#let ocol = rgb("#f9cb9c")
#let pcol = rgb("#b4a7d6")
#let tens(lbl, fill, line, h: 2.60em) = node.with(
  width: 0.90em,
  height: h,
  fill: fill,
  stroke: 1.1pt + line,
  inset: 0pt,
)
#let trap(lbl, fill, line, flip: false) = box(width: 4.60em, height: 3.00em, {
  let pts = if flip {
    ((0pt, 0pt), (4.6em, 0.6em), (4.6em, 2.4em), (0pt, 3em))
  } else {
    ((0pt, 0.6em), (4.6em, 0pt), (4.6em, 3em), (0pt, 2.4em))
  }
  place(polygon(fill: fill, stroke: 1.1pt + line, ..pts))
  place(center + horizon, text(size: 0.9em, hyphenate: false, lbl))
})
#let rowlabel(title, desc) = text(size: 0.95em)[*#title* #desc]


#figure(
  placement: auto,
  caption: [Summary of various kinds of deep generative models. Here $x$ is the observed data, $z$ is the latent code, and $x'$ is a sample from the model. AR models do not have a latent code $z$; for diffusion and flow models, $z$ is the same size as $x$. Adapted from Figure 1 of Weng (2021) and Fig. 20.1 of Murphy (2023).],
)[
  #set text(size: 10pt)
  #v(1.6em)
  #layout(size => {
    let d = diagram(
      spacing: (1.6em, 3.4em),
      node-inset: 0pt,
      edge-stroke: 0.9pt + luma(35%),
      // EBM
      node(
        (-0.6, 0),
        place(left + horizon, move(dy: -2.5em, box(width: 28em, rowlabel(
          [EBM:],
          [Approximate maximum likelihood],
        )))),
        stroke: none,
        width: 0.1pt,
        height: 0.1pt,
      ),
      node(
        (0, 0),
        [$x$],
        width: 0.90em,
        height: 2.60em,
        fill: gcol,
        stroke: 1.1pt + gline,
        name: <e0>,
      ),
      node(
        (1.5, 0),
        trap([*Energy* \ $E(x)$], gcol, gline),
        stroke: none,
        name: <e1>,
      ),
      node(
        (3, 0),
        [$R$],
        shape: circle,
        fill: pcol,
        stroke: 1.1pt + rgb("#674ea7"),
        width: 1.30em,
        name: <e2>,
      ),
      edge(<e0>, <e1>, "->"),
      edge(<e1>, <e2>, "->"),
      // GAN
      node(
        (-0.6, 1),
        place(left + horizon, move(dy: -2.5em, box(width: 28em, rowlabel(
          [GAN:],
          [Adversarial training],
        )))),
        stroke: none,
        width: 0.1pt,
        height: 0.1pt,
      ),
      node(
        (-0.6, 1),
        [$x'$],
        width: 0.90em,
        height: 2.60em,
        fill: bcol,
        stroke: 1.1pt + bline,
      ),
      node(
        (0, 1),
        [$x$],
        width: 0.90em,
        height: 2.60em,
        fill: gcol,
        stroke: 1.1pt + gline,
        name: <g0>,
      ),
      node(
        (1.5, 1),
        trap([*Discrim.* \ $D(x)$], gcol, gline),
        stroke: none,
        name: <g1>,
      ),
      node(
        (3, 1),
        [$0\/1$],
        shape: circle,
        fill: pcol,
        stroke: 1.1pt + rgb("#674ea7"),
        width: 1.70em,
        name: <g2>,
      ),
      node(
        (4.4, 1),
        [$z$],
        width: 0.90em,
        height: 1.20em,
        fill: rcol,
        stroke: 1.1pt + rline,
        name: <g3>,
      ),
      node(
        (5.9, 1),
        trap([*Generator* \ $G(z)$], bcol, bline, flip: true),
        stroke: none,
        name: <g4>,
      ),
      node(
        (7.4, 1),
        [$x'$],
        width: 0.90em,
        height: 2.60em,
        fill: bcol,
        stroke: 1.1pt + bline,
        name: <g5>,
      ),
      edge(<g0>, <g1>, "->"),
      edge(<g1>, <g2>, "->"),
      edge(<g3>, <g4>, "->"),
      edge(<g4>, <g5>, "->"),
      // VAE
      node(
        (-0.6, 2),
        place(left + horizon, move(dy: -2.5em, box(width: 28em, rowlabel(
          [VAE:],
          [Maximize variational lower bound],
        )))),
        stroke: none,
        width: 0.1pt,
        height: 0.1pt,
      ),
      node(
        (0, 2),
        [$x$],
        width: 0.90em,
        height: 2.60em,
        fill: gcol,
        stroke: 1.1pt + gline,
        name: <v0>,
      ),
      node(
        (1.5, 2),
        trap([*Encoder* \ $q_phi (z|x)$], gcol, gline, flip: true),
        stroke: none,
        name: <v1>,
      ),
      node(
        (4.4, 2),
        [$z$],
        width: 0.90em,
        height: 1.20em,
        fill: rcol,
        stroke: 1.1pt + rline,
        name: <v2>,
      ),
      node(
        (5.9, 2),
        trap([*Decoder* \ $p_theta (x|z)$], bcol, bline),
        stroke: none,
        name: <v3>,
      ),
      node(
        (7.4, 2),
        [$x'$],
        width: 0.90em,
        height: 2.60em,
        fill: bcol,
        stroke: 1.1pt + bline,
        name: <v4>,
      ),
      edge(<v0>, <v1>, "->"),
      edge(<v1>, <v2>, "->"),
      edge(<v2>, <v3>, "->"),
      edge(<v3>, <v4>, "->"),
      // Flow
      node(
        (-0.6, 3),
        place(left + horizon, move(dy: -2.5em, box(width: 28em, rowlabel(
          [Flow-based model:],
          [Invertible transform of distributions],
        )))),
        stroke: none,
        width: 0.1pt,
        height: 0.1pt,
      ),
      node(
        (0, 3),
        [$x$],
        width: 0.90em,
        height: 2.60em,
        fill: gcol,
        stroke: 1.1pt + gline,
        name: <f0>,
      ),
      node(
        (1.5, 3),
        [*Flow* \ $f(x)$],
        width: 3.60em,
        height: 2.50em,
        fill: gcol,
        stroke: 1.1pt + gline,
        name: <f1>,
      ),
      node(
        (4.4, 3),
        [$z$],
        width: 0.90em,
        height: 2.60em,
        fill: rcol,
        stroke: 1.1pt + rline,
        name: <f2>,
      ),
      node(
        (5.9, 3),
        [*Inverse* \ $f^(-1)(z)$],
        width: 3.60em,
        height: 2.50em,
        fill: bcol,
        stroke: 1.1pt + bline,
        name: <f3>,
      ),
      node(
        (7.4, 3),
        [$x'$],
        width: 0.90em,
        height: 2.60em,
        fill: bcol,
        stroke: 1.1pt + bline,
        name: <f4>,
      ),
      edge(<f0>, <f1>, "->"),
      edge(<f1>, <f2>, "->"),
      edge(<f2>, <f3>, "->"),
      edge(<f3>, <f4>, "->"),
      // Diffusion
      node(
        (-0.6, 4),
        place(left + horizon, move(dy: -2.5em, box(width: 28em, rowlabel(
          [Diffusion model:],
          [Gradually add Gaussian noise and then reverse],
        )))),
        stroke: none,
        width: 0.1pt,
        height: 0.1pt,
      ),
      node(
        (0, 4),
        [$x$],
        width: 1.30em,
        height: 2.80em,
        fill: gcol,
        stroke: 1.1pt + gline,
        name: <d0>,
      ),
      node(
        (1.5, 4),
        [$z_1$],
        width: 1.30em,
        height: 2.80em,
        fill: ycol,
        stroke: 1.1pt + rgb("#e6b800"),
        name: <d1>,
      ),
      node(
        (3, 4),
        [$z_2$],
        width: 1.30em,
        height: 2.80em,
        fill: ocol,
        stroke: 1.1pt + rgb("#e69138"),
        name: <d2>,
      ),
      node((4.4, 4), [$dots$], stroke: none, name: <d3>),
      node(
        (7.4, 4),
        [$z_T$],
        width: 1.30em,
        height: 2.80em,
        fill: rcol,
        stroke: 1.1pt + rline,
        name: <d4>,
      ),
      edge(<d0>, <d1>, "->", shift: 6pt),
      edge(<d1>, <d0>, "-->", shift: 6pt),
      edge(<d1>, <d2>, "->", shift: 6pt),
      edge(<d2>, <d1>, "-->", shift: 6pt),
      edge(<d2>, <d3>, "->", shift: 6pt),
      edge(<d3>, <d2>, "-->", shift: 6pt),
      edge(<d3>, <d4>, "->", shift: 6pt),
      edge(<d4>, <d3>, "-->", shift: 6pt),
      // Autoregressive
      node(
        (-0.6, 5),
        place(left + horizon, move(dy: -2.5em, box(width: 28em, rowlabel(
          [Autoregressive model:],
          [Learn conditional of each variable given past],
        )))),
        stroke: none,
        width: 0.1pt,
        height: 0.1pt,
      ),
      node(
        (0, 5),
        [$x^0$],
        width: 1.30em,
        height: 2.80em,
        fill: gcol,
        stroke: 1.1pt + gline,
        name: <a0>,
      ),
      node(
        (1.5, 5),
        [$x^1$],
        width: 1.30em,
        height: 2.80em,
        fill: gcol,
        stroke: 1.1pt + rgb("#e69138"),
        name: <a1>,
      ),
      node(
        (3, 5),
        [$x^2$],
        width: 1.30em,
        height: 2.80em,
        fill: gcol,
        stroke: 1.1pt + rgb("#e69138"),
        name: <a2>,
      ),
      node(
        (4.4, 5),
        [$x^3$],
        width: 1.30em,
        height: 2.80em,
        fill: gcol,
        stroke: 1.1pt + rgb("#e69138"),
        name: <a3>,
      ),
      node((5.6, 5), [$dots$], stroke: none, name: <a4>),
      node(
        (7.4, 5),
        [$x^D$],
        width: 1.30em,
        height: 2.80em,
        fill: gcol,
        stroke: 1.1pt + rline,
        name: <a5>,
      ),
      edge(<a0>, <a1>, "->"),
      edge(<a1>, <a2>, "->"),
      edge(<a2>, <a3>, "->"),
      edge(<a3>, <a4>, "->"),
      edge(<a4>, <a5>, "->"),
      edge(<a0>, <a2>, "->", bend: -40deg),
      edge(<a0>, <a3>, "->", bend: -40deg),
      edge(<a1>, <a3>, "->", bend: -40deg),
    )
    let m = measure(d)
    if m.width > size.width {
      scale(size.width / m.width * 100%, reflow: true, d)
    } else { d }
  })
] <gen-fig>

#pagebreak()
= Goals of Generative Modeling
#sidenote(numbered: false)[Textbook: §20.3]

There are several different kinds of tasks that we can use generative models for, as we discuss below.

#discussion(vspace: 3em)[
  When considering the a _conditional generative model_, $p(x|c)$, where the goal is to genrate a distribution over data $x$ given some fixed _condition_, notice the similarity to _supervised learning_, where the goal is the predict a class given input data, i.e. $p(c|x)$.

  Describe a familiar supervised learning problem that you know well. Then articulate what a corresponding conditional generative modeling problem for the same domain would look like. Finally, sketch out some different analysis or use case scenarios where one or the other modeling problem may be more useful. Which problems are "harder"? Why?
]


== Generating Data
One of the main goals of generative models is to generate (create) new data samples. This is sometimes called generative AI. For example, if we fit a model $p(x)$ to images of faces, we can sample new faces from it.

To control what is generated, it is useful to use a conditional generative model of the form $p(x|c)$. Here are some examples:
- $c$ = text prompt, $x$ = image. This is a text-to-image model (e.g., "a cute corgi lives in a house made out of sushi").
- $c$ = image, $x$ = image. This is an image-to-image model, and can be used for image colorization, inpainting, uncropping, JPEG artefact restoration, etc.
- $c$ = sequence of English words, $x$ = sequence of French words. This is a sequence-to-sequence model, which is useful for machine translation.

Note that, in the conditional case, we sometimes denote the inputs by $x$ and the outputs by $y$. In this case the model has the familiar form $p(y|x)$. In the special case that $y$ denotes a low dimensional quantity, such as a integer class label, $y in {1,dots,C}$, we get a predictive (discriminative) model. The main difference between a discriminative model and a conditional generative model is this: in a discriminative model, we assume there is one correct output, whereas in a conditional generative model, we assume there may be multiple correct outputs. This makes it harder to evaluate generative models, as we discuss in the next section.

== Density Estimation
The task of *density estimation* refers to evaluating the probability of an observed data vector, i.e., computing $p(x)$. This can be useful for outlier detection, generative classifiers, model comparison, etc.

A simple approach to this problem, which works in low dimensions, is to use *kernel density estimation* or KDE, which has the form
$
  p(x|cal(D))=1/N sum_(n=1)^N cal(K)_h (x-x_n).
$ <kde>
Here $cal(D)={x_1,dots,x_N}$ is the data, and $cal(K)_h$ is a density kernel with *bandwidth* $h$, which is a function $cal(K) colon RR arrow.r RR_+$ such that $integral cal(K)(x) dif x=1$ and $integral x cal(K)(x) dif x=0$. In higher dimensions, KDE suffers from the curse of dimensionality, and we need to use parametric density models $p_theta (x)$ of some kind.


#figure(
  caption: [A nonparametric (Parzen) density estimator in 1d estimated from 6 datapoints, denoted by $x$. Top row: uniform kernel. Bottom row: Gaussian kernel. Left column: bandwidth $h=1$. Right column: $h=2$. Murphy (2023), Fig. 20.5.],
)[
  #image("Figures/textbook-kde-parzen.png", width: 95%)
] <kde-fig>


== Imputation

#sidenote(dy: -5em, numbered: false)[
  #figure(
    placement: auto,
    caption: [Missing data imputation. Left: input data: NA means "not available" (missing), and the bottom row shows the mean of each column. Right: output data, where NA values are replaced by the mean. Redrawn from Murphy (2023), Fig. 20.6.],
  )[
    #set text(size: 0.9em)
    #let rows-in = (
      (6, 6, none),
      (none, 6, 0),
      (none, 6, none),
      (10, 10, 10),
      (10, 10, 10),
      (10, 10, 10),
    )
    #let rows-out = (
      (6, 6, 7.5),
      (9, 6, 0),
      (9, 6, 7.5),
      (10, 10, 10),
      (10, 10, 10),
      (10, 10, 10),
    )
    #let cell(v, fill-if: false) = table.cell(fill: if fill-if {
      luma(88%)
    } else { none })[#if v == none [NA] else [#v]]
    #grid(
      columns: (auto, auto),
      column-gutter: 3em,
      table(
        columns: 3,
        stroke: 0.4pt + luma(60%),
        inset: (x: 8pt, y: 3pt),
        align: center,
        [*A*], [*B*], [*C*],
        ..rows-in.flatten().map(v => cell(v)),
        table.cell(fill: rgb("#f4cccc"))[9],
        table.cell(fill: rgb("#f4cccc"))[8],
        table.cell(fill: rgb("#f4cccc"))[7.5],
      ),
      table(
        columns: 3,
        stroke: 0.4pt + luma(60%),
        inset: (x: 8pt, y: 3pt),
        align: center,
        [*A*], [*B*], [*C*],
        ..rows-out
          .flatten()
          .enumerate()
          .map(((i, v)) => cell(
            v,
            fill-if: (i == 2 or i == 3 or i == 6 or i == 8),
          )),
        table.cell(fill: rgb("#f4cccc"))[9],
        table.cell(fill: rgb("#f4cccc"))[8],
        table.cell(fill: rgb("#f4cccc"))[7.5],
      ),
    )
  ] <imputation>
]

#v(-1em)
The task of *imputation* refers to "filling in" missing values of a data vector or data matrix. For example, suppose $bold(X)$ is an $N times D$ matrix of data (think of a spreadsheet) in which some entries, call them $bold(X)_m$, may be missing, while the rest, $bold(X)_o$, are observed. A simple way to fill in the missing data is to use the mean value of each feature, $EE[x_d]$; this is called *mean value imputation*. However, this ignores dependencies between the variables within each row, and does not return any measure of uncertainty. We can generalize this by fitting a generative model to the observed data, $p(bold(X)_o)$, and then computing samples from $p(bold(X)_m|bold(X)_o)$. This is called *multiple imputation*.



== Structure Discovery
Some kinds of generative models have latent variables $z$, which are assumed to be the "causes" that generated the observed data $x$. We can use Bayes' rule to invert the model to compute $p(z|x) prop p(z) p(x|z)$. This can be useful for discovering latent, low-dimensional patterns in the data.

For example, suppose we perturb various proteins in a cell and measure the resulting phosphorylation state using a technique known as flow cytometry. Each row represents a data sample $x_n ∼ p(dot|a_n, z)$, where $x in RR^11$ is a vector of outputs (phosphorylations), $a in {0,1}^6$ is a vector of input actions (perturbations) and $z$ is the unknown cellular signaling network structure. We can infer the graph structure $p(z|cal(D))$ using graphical model structure learning techniques.

#wideblock()[
  #figure(
    placement: auto,
    caption: [(a) A design matrix of 5400 datapoints (rows) measuring the state of 11 proteins (columns) under different experimental conditions, discretized into low (black), medium (grey), and high (white). (b) A directed graphical model of dependencies between proteins (blue circles) and experimental interventions (pink ovals), inferred from this data. We plot all edges for which $p(G_(i j)=1|cal(D))>0.5$. Dotted edges were not discovered by the algorithm; solid edges are true positives. From Eaton and Murphy (2007); Murphy (2023), Fig. 20.7.],
  )[
    #image("Figures/textbook-flow-cytometry-structure.png", width: 100%)
  ] <flow-fig>
]

== Latent Space Interpolation and Arithmetic
One of the most interesting abilities of certain latent variable models is the ability to generate samples that have certain desired properties by interpolating between existing datapoints in latent space. Let $x_1$ and $x_2$ be two inputs (e.g., images), and let $z_1=e(x_1)$ and $z_2=e(x_2)$ be their latent encodings. We can regard $z_1$ and $z_2$ as two "anchors" in latent space. We can now generate new images that interpolate between these points by computing $z=lambda z_1+(1-lambda) z_2$, where $0<=lambda<=1$, and then decoding by computing $x'=d(z)$, where $d()$ is the decoder. This is called *latent space interpolation*, and will generate data that combines semantic features from both $x_1$ and $x_2$.

In some cases, we can go beyond interpolation, and can perform *latent space arithmetic*, in which we can increase or decrease the amount of a desired "semantic factor of variation". Let $bold(z)_i^+$ and $bold(z)_i^-$ be the average embeddings of images with and without attribute $i$. We define the offset vector as $Delta_i=bold(z)_i^+-bold(z)_i^-$. If we add some positive multiple of $Delta_i$ to a new point $z$, we increase the amount of the attribute $i$; if we subtract some multiple of $Delta_i$, we decrease the amount of the attribute $i$.

#figure(
  caption: [Interpolation between two MNIST images in the latent space of a $beta$-VAE (with $beta=0.5$). Murphy (2023), Fig. 20.8.],
)[
  #image("Figures/textbook-latent-interp-mnist.png", width: 54%)
] <interp>

The $j$'th reconstruction is computed using $hat(x)_j=d(z+s_j Delta)$, where $z=e(x)$ is the encoding of the original image, and $s_j$ is a scale factor. In the textbook's CelebA example with attribute "wearing sunglasses", $s_j>0$ adds sunglasses to the face. When $s_j<0$ we remove sunglasses; but this also has the side effect of making the face look younger and more female, possibly a result of dataset bias.

#wideblock()[
  #figure(
    caption: [Arithmetic in the latent space of a $beta$-VAE (with $beta=0.5$). The first column is an input image, with embedding $z$. Subsequent columns show the decoding of $z+s Delta$, where $s in {-2,-1,0,1,2}$ and $Delta=bold(z)^+-bold(z)^-$ is the difference in the average embeddings of images with or without a certain attribute (here, wearing sunglasses). Murphy (2023), Fig. 20.10.],
  )[
    #image("Figures/textbook-latent-arithmetic.png", width: 100%)
  ] <arith>
]

#discussion(vspace: 10em)[
  Removing sunglasses with $Delta$ also made the face look younger and more female. Stated in terms of the distribution over latents, what must be true of the training images for $Delta$ to carry more than the sunglasses attribute?
]

#pagebreak()
= Evaluating Generative Models
#sidenote(
  numbered: false,
)[Textbook: §20.4. Theis, van den Oord & Bethge (2016), #link("https://arxiv.org/abs/1511.01844")[A note on the evaluation of generative models].]

Evaluating generative models requires metrics for
- _sample quality:_ are samples generated by the model a part of the data distribution?
- _sample diversity:_ are samples from the model distribution capturing all modes of the data distribution?
- _generalization:_ is the model generalizing beyond the training data?
There is no known metric which meets all these requirements, but various metrics have been proposed to capture different aspects of the learned distribution, some of which we discuss below.

== Likelihood-Based Evaluation
A standard way to measure how close a model $q$ is to a true distribution $p$ is in terms of the KL divergence:
$
  D_"KL" (p parallel q)=integral p(x) log p(x)/q(x) dif x=-H(p)+H_"ce" (p,q),
$
where $H(p)$ is a constant, and $H_"ce" (p,q)$ is the cross entropy. If we approximate $p(x)$ by the empirical distribution, we can evaluate the cross entropy in terms of the empirical negative log likelihood on the dataset:
$
  "NLL"=-1/N sum_(n=1)^N log q(x_n).
$ <nll>
Usually we care about negative log likelihood on a held-out test set.

Unfortunately, for many models, computing the likelihood requires knowing the normalization constant of the probability model. Variational inference gives lower (and sometimes upper) bounds on the log likelihood, and annealed importance sampling estimates it by Monte Carlo. For implicit generative models, such as GANs, the likelihood is not even defined, so we need metrics that do not rely on likelihood.

A more subtle concern with likelihood is that it is often uncorrelated with the perceptual quality of the samples, at least for real-valued data, such as images and sound. In particular, a model can have great log-likelihood but create poor samples and vice versa. To see why a model can have good likelihoods but create bad samples, consider the following argument from Theis et al. Suppose $q_0$ is a density model for $D$-dimensional data $x$ which performs arbitrarily well as judged by average log-likelihood, and suppose $q_1$ is a bad model, such as white noise. Consider the mixture model
$
  q_2(x)=0.01 q_0(x)+0.99 q_1(x).
$
Clearly 99% of the samples will be poor. However, the log-likelihood per pixel will hardly change between $q_2$ and $q_0$ if $D$ is large, since
$
  log q_2(x) & =log[0.01 q_0(x)+0.99 q_1(x)] \
             & >= log[0.01 q_0(x)]=log q_0(x)-2.
$
For high-dimensional data, $|log q_0(x)| ∼ D >> 100$, so $log q_2(x) approx log q_0(x)$, and hence mixing in the poor sampler does not significantly impact the log likelihood.

Now consider a case where the model has good samples but bad likelihoods. To achieve this, suppose $q$ is a GMM centered on the training images:
$
  q(x)=1/N sum_(n=1)^N cal(N)(x|x_n, epsilon^2 I).
$
If $epsilon$ is small enough that the Gaussian noise is imperceptible, samples from this model will look good, since they correspond to the training set. But the model will almost certainly have poor likelihood on the test set due to overfitting: it has effectively just memorized the training set.


== Distances and Divergences in Feature Space
Due to the challenges of comparing distributions in high dimensional spaces, most metrics used to evaluate generative models do not directly compare raw data (e.g., pixels) but use a neural network, commonly a pretrained classifier, to obtain features, and compare the feature distribution of model samples with that of the dataset.

The *Inception score* measures the average KL divergence between the marginal distribution of class labels obtained from the samples $p_theta (y)=integral p_"disc" (y|x) p_theta (x) dif x$ (where the integral is approximated by sampling images $x$ from a fixed dataset) and the distribution $p(y|x)$ induced by samples from the model, $x ∼ p_theta (x)$. This leads to the following score:
$
  "IS"=exp(EE_(p_theta (x)) [D_"KL" (p_"disc" (Y|x) parallel p_theta (Y))]).
$
To understand this, let us rewrite the log score as follows:
$
  log("IS")=H(p_theta (Y))-EE_(p_theta (x)) [H(p_"disc" (Y|x))].
$
Thus we see that a high scoring model will be equally likely to generate samples from all classes, thus maximizing the entropy of $p_theta (Y)$, while also ensuring that each individual sample is easy to classify, thus minimizing the entropy of $p_"disc" (Y|x)$.

The Inception score solely relies on class labels, and thus does not measure overfitting or sample diversity outside the predefined dataset classes. For example, a model which generates one perfect example per class would get a perfect Inception score, despite not capturing the variety of examples inside a class. To address this drawback, the *Fréchet Inception distance* or FID score measures the Fréchet distance between two Gaussian distributions on sets of features of a pre-trained classifier. If we assume that the mean and covariance obtained from model features are $mu_m$ and $Sigma_m$ and those from the data are $mu_d$ and $Sigma_d$, then the FID is
$
  "FID"=norm(mu_m-mu_d)_2^2+op("tr")(Sigma_d+Sigma_m-2(Sigma_d Sigma_m)^(1\/2)).
$
Since it uses features instead of class logits, the Fréchet distance captures more than modes captured by class labels. Unlike the Inception score, a lower score is better since we want the two distributions to be as close as possible.

#wideblock()[
  #figure(
    placement: auto,
    caption: [(a) Model samples with good (high) inception score are visually realistic. (b) Model samples with good (low) FID score are visually realistic and diverse. Murphy (2023), Fig. 20.11.],
  )[
    #image("Figures/textbook-inception-vs-fid.png", width: 100%)
  ] <is-fid>
]

== Precision, Recall, and Other Checks
Since the FID only measures the distance between the data and model distributions, it is difficult to use it as a diagnostic tool: a bad (high) FID can indicate that the model is not able to generate high quality data, or that it puts too much mass around the data distribution, or that the model only captures a subset of the data. Trying to disentangle these failure modes has motivated individual *precision* (sample quality) and *recall* (sample diversity) metrics, computed from nearest neighbors in the feature space of a pretrained classifier. Precision measures whether samples are as close to data as data is to other data examples, while recall measures whether data is as close to model samples as model samples are to other samples.

Other checks include two sample tests (expensive, so unsuited to monitoring training), inspecting each sample's nearest neighbors in the dataset to test for memorization, and human evaluation, which suits art and other data for human display but is hard to standardize and expensive.

#side-discussion(dy: -20em)[
  A (probably too) common use of generative models is in the construction of synthetic data for other machine learning tasks. If the goal of a generative model is to produce synthetic data for a downstream classification model to train on, which metric from this section best captures what should be optimized for.
]
