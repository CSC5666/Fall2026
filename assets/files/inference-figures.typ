// Shared diagrams for the inference notes (05-Inference.typ) and the
// lecture companion (05-Inference-Lecture.typ). Each function returns bare
// content; the caller wraps it in a figure with its own caption.
#import "wdf.typ": *

#let obs-fill = luma(80%)
#let fac-fill = luma(85%)
#let fwd = blue.darken(10%)
#let bwd = red.darken(10%)

// Black-and-white mode. Set with `#bw.update(true)` in a document that will
// be printed in grayscale. Every distinction drawn with color in the default
// mode is then drawn with line weight, dash pattern, or gray fill instead.
// Roles: "c" = collect / forwards / incoming, "d" = distribute / backwards,
// "out" = the emphasized outgoing message in the rule diagrams.
#let bw = state("inference-bw", false)
#let ink(role, bwm) = if bwm { black } else if role == "c" { fwd } else { bwd }
#let msg-stroke(role, bwm) = if bwm {
  if role == "c" { 0.8pt + black } else if role == "d" {
    (paint: black, thickness: 0.8pt, dash: "dashed")
  } else { 1.8pt + black }
} else {
  if role == "out" { 1.3pt + bwd } else { ink(role, bwm) }
}
#let hl-stroke(bwm) = if bwm { 1.8pt + black } else { 1.4pt + bwd }
#let hl-fill(bwm) = if bwm { luma(85%) } else { bwd.lighten(85%) }
#let region(role, bwm) = if bwm {
  if role == "c" {
    (stroke: (paint: black, dash: "dashed"), fill: luma(92%))
  } else {
    (stroke: (paint: black, dash: "dotted", thickness: 1pt), fill: white)
  }
} else {
  let c = ink(role, bwm)
  (stroke: (paint: c, dash: "dashed"), fill: c.lighten(92%))
}
#let pgm = (edge-stroke: 0.8pt, node-stroke: 0.8pt, node-corner-radius: 8pt)
#let fg = (edge-stroke: 0.8pt, node-stroke: 0.8pt)

// Figure 7.1: global, local, and global + local latent variables.
#let latent-patterns() = {
  let panel(theta-y: false, known: true) = if theta-y {
    diagram(
      ..pgm,
      spacing: (12pt, 18pt),
      node((0, 0), [$theta_y$], name: <t>),
      node((-1, 1), [$y_1$], name: <y1>, fill: obs-fill),
      node((0, 1), [$dots.c$], stroke: none),
      node((1, 1), [$y_N$], name: <yN>, fill: obs-fill),
      node((-1, 2), [$x_1$], name: <x1>, fill: obs-fill),
      node((0, 2), [$dots.c$], stroke: none),
      node((1, 2), [$x_N$], name: <xN>, fill: obs-fill),
      edge(<t>, <y1>, "->"),
      edge(<t>, <yN>, "->"),
      edge(<x1>, <y1>, "->"),
      edge(<xN>, <yN>, "->"),
    )
  } else {
    let tf = if known { obs-fill } else { none }
    diagram(
      ..pgm,
      spacing: (12pt, 18pt),
      node((0, 0), [$theta_z$], name: <tz>, fill: tf),
      node((-1, 1), [$z_1$], name: <z1>),
      node((0, 1), [$dots.c$], stroke: none),
      node((1, 1), [$z_N$], name: <zN>),
      node((-1, 2), [$x_1$], name: <x1>, fill: obs-fill),
      node((0, 2), [$dots.c$], stroke: none),
      node((1, 2), [$x_N$], name: <xN>, fill: obs-fill),
      node((0, 3), [$theta_x$], name: <tx>, fill: tf),
      edge(<tz>, <z1>, "->"),
      edge(<tz>, <zN>, "->"),
      edge(<z1>, <x1>, "->"),
      edge(<zN>, <xN>, "->"),
      edge(<tx>, <x1>, "->"),
      edge(<tx>, <xN>, "->"),
    )
  }
  grid(
    columns: 3,
    column-gutter: 1.5em,
    row-gutter: 0.5em,
    align: center + bottom,
    panel(theta-y: true), panel(known: true), panel(known: false),
    [(a) global], [(b) local], [(c) global + local],
  )
}

// HMM as a directed graphical model (textbook Figure 9.1).
#let hmm-dpgm() = diagram(
  ..pgm,
  spacing: (22pt, 18pt),
  node((0, 0), [$z_1$], name: <z1>),
  node((1, 0), [$z_2$], name: <z2>),
  node((2, 0), [$z_3$], name: <z3>),
  node((3, 0), [$dots.c$], name: <zd>, stroke: none),
  node((4, 0), [$z_T$], name: <zT>),
  node((0, 1), [$y_1$], name: <y1>, fill: obs-fill),
  node((1, 1), [$y_2$], name: <y2>, fill: obs-fill),
  node((2, 1), [$y_3$], name: <y3>, fill: obs-fill),
  node((4, 1), [$y_T$], name: <yT>, fill: obs-fill),
  edge(<z1>, <z2>, "->"),
  edge(<z2>, <z3>, "->"),
  edge(<z3>, <zd>, "->"),
  edge(<zd>, <zT>, "->"),
  edge(<z1>, <y1>, "->"),
  edge(<z2>, <y2>, "->"),
  edge(<z3>, <y3>, "->"),
  edge(<zT>, <yT>, "->"),
)

// Casino HMM state transition diagram (textbook Figure 9.2).
#let casino-states() = diagram(
  edge-stroke: 0.8pt,
  node-corner-radius: 6pt,
  node-stroke: 0.8pt,
  spacing: (40pt, 10pt),
  node((0, 0), [Fair \ #text(7pt)[each face $1\/6$]], name: <f>),
  node((1, 0), [Loaded \ #text(7pt)[six: $1\/2$]], name: <l>),
  edge(<f>, <l>, "->", bend: 25deg, label: [$0.05$]),
  edge(<l>, <f>, "->", bend: 25deg, label: [$0.10$]),
  edge(<f>, <f>, "->", bend: 130deg, label: [$0.95$]),
  edge(<l>, <l>, "->", bend: 130deg, label: [$0.90$]),
)

// Which evidence each query conditions on. `query` is the queried state and
// `used` the last observation conditioned on (1-indexed, chain of length 5).
#let query-chain(query, used) = context diagram(
  ..pgm,
  spacing: (16pt, 10pt),
  node-inset: 3pt,
  ..for i in range(1, 6) {
    (
      node(
        (i, 0),
        [$z_#i$],
        stroke: if i == query { hl-stroke(bw.get()) } else { 0.8pt },
        fill: if i == query { hl-fill(bw.get()) } else { none },
      ),
      node(
        (i, 1),
        [$y_#i$],
        fill: if i <= used { obs-fill } else { none },
        stroke: if i <= used { 0.8pt } else {
          (paint: luma(60%), dash: "dashed")
        },
      ),
      edge((i, 0), (i, 1), "->"),
    )
    if i < 5 { (edge((i, 0), (i + 1, 0), "->"),) }
  },
)

#let query-chains() = grid(
  columns: 2,
  column-gutter: 1.5em,
  row-gutter: 0.8em,
  align: (right + horizon, left + horizon),
  [filtering \ $p(z_3 | y_(1:3))$], query-chain(3, 3),
  [smoothing \ $p(z_3 | y_(1:5))$], query-chain(3, 5),
  [prediction \ $p(z_5 | y_(1:3))$], query-chain(5, 3),
)

// Bar chart of a two-state belief (fair, loaded).
#let belief-bars(vals, scale: 48pt, fill: auto, note: none) = context {
  let fill = if fill != auto { fill } else if bw.get() { luma(60%) } else {
    fwd.lighten(40%)
  }
  set text(size: 7.5pt)
  stack(
    spacing: 2pt,
    grid(
      columns: 2,
      column-gutter: 3pt,
      align: center + bottom,
      ..vals.map(v => [#calc.round(v, digits: 3)]),
      ..vals.map(v => rect(
        width: 16pt,
        height: calc.max(v, 0.01) * scale,
        fill: fill,
        stroke: 0.5pt,
      )),
      [F], [L],
    ),
    if note != none { align(center, note) },
  )
}

#let step-arrow(label) = {
  set text(size: 7.5pt)
  stack(spacing: 2pt, align(center, label), align(center, text(
    12pt,
  )[$arrow.r.long$]))
}

// One step of the forwards algorithm on the casino HMM: yesterday's belief
// after one six, predict with A, update with a second six, normalize.
#let forward-bars() = grid(
  columns: 7,
  column-gutter: 0.9em,
  align: center + bottom,
  belief-bars((0.25, 0.75), note: [$bold(alpha)_(1)$]),
  step-arrow[predict \ $A^top bold(alpha)_1$],
  belief-bars((0.3125, 0.6875), note: [$bold(alpha)_(2|1)$]),
  step-arrow[update \ $dot.o bold(lambda)_2$ #h(0.3em) #box(baseline: 30%, belief-bars((1 / 6, 0.5), scale: 26pt, fill: luma(88%)))],
  belief-bars(
    (0.0521, 0.3438),
    fill: luma(30%),
    note: [unnormalized, \ sums to $Z_2 = 0.396$],
  ),
  step-arrow[normalize \ $div Z_2$],
  belief-bars((0.1316, 0.8684), note: [$bold(alpha)_2$]),
)

// Forwards and backwards messages meeting at z_t on a chain.
#let fb-sweep() = context diagram(
  ..pgm,
  spacing: (11pt, 14pt),
  node-inset: 3pt,
  node(
    enclose: ((1, 0), (3, 1)),
    ..region("c", bw.get()),
    corner-radius: 6pt,
    inset: 7pt,
  ),
  node(
    enclose: ((4, 0), (6, 1)),
    ..region("d", bw.get()),
    corner-radius: 6pt,
    inset: 7pt,
  ),
  ..for i in range(1, 7) {
    let lab = if i == 3 { $z_t$ } else if i == 4 { $z_(t+1)$ } else { $z_#i$ }
    let ylab = if i == 3 { $y_t$ } else if i == 4 { $y_(t+1)$ } else { $y_#i$ }
    (
      node((i, 0), lab, stroke: if i == 3 { 1.6pt + black } else { 0.8pt }),
      node((i, 1), ylab, fill: obs-fill),
      edge((i, 0), (i, 1), "->"),
    )
    if i < 6 { (edge((i, 0), (i + 1, 0), "->"),) }
  },
  node(
    (2, 2.1),
    text(
      fill: ink("c", bw.get()),
      size: 8pt,
    )[$alpha_t (j) = p(z_t = j | y_(1:t))$],
    stroke: none,
  ),
  node(
    (5, 2.1),
    text(
      fill: ink("d", bw.get()),
      size: 8pt,
    )[$beta_t (j) = p(y_(t+1:T) | z_t = j)$],
    stroke: none,
  ),
)

// Viterbi decoding on the three-state phone HMM (textbook Figure 9.6).
#let viterbi-figure() = grid(
  columns: (auto, auto),
  column-gutter: 3.5em,
  align: horizon,
  stack(
    spacing: 1em,
    diagram(
      ..fg,
      spacing: (22pt, 10pt),
      node((0, 0), [$S_1$], name: <s1>),
      node((1, 0), [$S_2$], name: <s2>),
      node((2, 0), [$S_3$], name: <s3>),
      edge(<s1>, <s2>, "->", label: text(size: 7pt)[$0.7$]),
      edge(<s2>, <s3>, "->", label: text(size: 7pt)[$0.1$]),
      edge(<s1>, <s1>, "->", bend: 130deg, label: text(size: 7pt)[$0.3$]),
      edge(<s2>, <s2>, "->", bend: 130deg, label: text(size: 7pt)[$0.9$]),
      edge(<s3>, <s3>, "->", bend: 130deg, label: text(size: 7pt)[$0.4$]),
    ),
    text(size: 8pt, table(
      columns: 4,
      stroke: none,
      inset: 3pt,
      align: center,
      table.hline(),
      [], [$S_1$], [$S_2$], [$S_3$],
      table.hline(),
      [$C_1$], [$0.5$], [$0$], [$0$],
      [$C_2$], [$0.2$], [$0$], [$0$],
      [$C_3$], [$0.3$], [$0.2$], [$0$],
      [$C_4$], [$0$], [$0.7$], [$0.1$],
      [$C_5$], [$0$], [$0.1$], [$0$],
      [$C_6$], [$0$], [$0$], [$0.5$],
      [$C_7$], [$0$], [$0$], [$0.4$],
      table.hline(),
    )),
  ),
  context {
    let path-stroke = if bw.get() { 2pt + black } else { 1.2pt + red }
    let d = (
      ("0.5", "0", "0"),
      ("0.045", "0.07", "0"),
      ("0", "0.0441", "0.0007"),
      ("0", "0", "0.0022"),
    )
    let lam = ((0.3, 0.2, 0), (0, 0.7, 0.1), (0, 0, 0.5))
    let trans = (
      (0, 0, 0.3),
      (0, 1, 0.7),
      (1, 1, 0.9),
      (1, 2, 0.1),
      (2, 2, 0.4),
    )
    let path = ((0, 0, 1), (1, 1, 1), (2, 1, 2))
    set text(size: 7pt)
    diagram(
      node-stroke: 0.8pt,
      spacing: (38pt, 26pt),
      ..for t in range(4) {
        for k in range(3) {
          let on = (t, k) in ((0, 0), (1, 1), (2, 1), (3, 2))
          (
            node(
              (t, k),
              [$#d.at(t).at(k)$],
              shape: circle,
              width: 30pt,
              stroke: if on { path-stroke } else { 0.8pt },
            ),
          )
        }
      },
      ..for t in range(3) {
        for (i, j, a) in trans {
          let on = (t, i, j) in path
          (
            edge(
              (t, i),
              (t + 1, j),
              "->",
              stroke: if on { path-stroke } else { 0.5pt + luma(55%) },
              label: [$#a, #lam.at(t).at(j)$],
              label-size: 6pt,
              label-sep: 1pt,
            ),
          )
        }
      },
      ..for (t, c) in ((0, 1), (1, 3), (2, 4), (3, 6)) {
        (node((t, -0.8), [$C_#c$], stroke: none),)
      },
      ..for k in range(3) { (node((-0.6, k), [$S_#(k + 1)$], stroke: none),) },
    )
  },
)

// ---------------------------------------------------------------------------
// The running example: a three-variable binary chain with a prior on x1 and
// evidence x3 = 1.  Layout: g - x1 - fA - x2 - fB - x3 - e.
#let chain-nodes = (
  (0, [$g$], "f"),
  (1, [$x_1$], "v"),
  (2, [$f_A$], "f"),
  (3, [$x_2$], "v"),
  (4, [$f_B$], "f"),
  (5, [$x_3$], "v"),
  (6, [$e$], "f"),
)

// `msgs` is a list of (edge, dir, label, role): edge i joins chain-nodes i
// and i + 1, dir is "r" (drawn above) or "l" (drawn below), and role is "c"
// (collect pass) or "d" (distribute pass). `below` is a list of
// (position, role, label) drawn underneath a node (e.g. a belief).
#let chain-graph(
  msgs: (),
  below: (),
  highlight: (),
  spacing: 22pt,
  size: 7pt,
) = context {
  let bwm = bw.get()
  set text(size: size)
  diagram(
    ..fg,
    spacing: (spacing, 22pt),
    node-inset: 5pt,
    ..for (x, lab, kind) in chain-nodes {
      (
        node(
          (x, 0),
          lab,
          shape: if kind == "v" { circle } else { shapes.rect },
          fill: if kind == "f" { fac-fill } else if x in highlight {
            hl-fill(bwm)
          } else { none },
          stroke: if x in highlight { hl-stroke(bwm) } else { 0.8pt },
        ),
      )
    },
    ..for i in range(6) { (edge((i, 0), (i + 1, 0), "-"),) },
    ..for (i, dir, lab, role) in msgs {
      let (a, b) = if dir == "r" { ((i, 0), (i + 1, 0)) } else {
        ((i + 1, 0), (i, 0))
      }
      (
        edge(
          a,
          b,
          "->",
          bend: 45deg,
          stroke: msg-stroke(role, bwm),
          label: text(fill: ink(role, bwm), lab),
          label-side: left,
          label-sep: 1pt,
        ),
      )
    },
    ..for (x, role, lab) in below {
      (node((x, 1.5), text(fill: ink(role, bwm), lab), stroke: none),)
    },
  )
}

#let chain-tables() = {
  set text(size: 8pt)
  let tab(name, a, b, rows) = table(
    columns: 3,
    stroke: none,
    inset: 3pt,
    align: center,
    table.hline(),
    [#name], [#b $= 0$], [#b $= 1$],
    table.hline(),
    [#a $= 0$], [#rows.at(0)], [#rows.at(1)],
    [#a $= 1$], [#rows.at(2)], [#rows.at(3)],
    table.hline(),
  )
  grid(
    columns: 4,
    column-gutter: 1.2em,
    align: horizon,
    [$g(x_1) = [0.6, 0.4]$ \ $e(x_3) = [0, 1]$],
    tab($f_A$, $x_1$, $x_2$, ($3$, $1$, $1$, $3$)),
    tab($f_B$, $x_2$, $x_3$, ($2$, $1$, $1$, $2$)),
  )
}

// The same chain after variable elimination has summed out x1 and x3.
#let chain-eliminated() = context {
  set text(size: 8pt)
  diagram(
    ..fg,
    spacing: (22pt, 22pt),
    node-inset: 5pt,
    node((2, 0), [$tau_1 = [2.2, 1.8]$], shape: shapes.rect, fill: if bw.get() {
      luma(88%)
    } else { fwd.lighten(80%) }),
    node((3, 0), [$x_2$], shape: circle),
    node((4, 0), [$tau_3 = [1, 2]$], shape: shapes.rect, fill: if bw.get() {
      white
    } else { bwd.lighten(80%) }),
    edge((2, 0), (3, 0), "-"),
    edge((3, 0), (4, 0), "-"),
  )
}

// Sum-product messages on the running example: collect toward x2 (blue),
// then distribute back out (red).
#let sp-collect = (
  (0, "r", [$[0.6, 0.4]$], "c"),
  (1, "r", [$[0.6, 0.4]$], "c"),
  (2, "r", [$[2.2, 1.8]$], "c"),
  (5, "l", [$[0, 1]$], "c"),
  (4, "l", [$[0, 1]$], "c"),
  (3, "l", [$[1, 2]$], "c"),
)
#let sp-distribute = (
  (2, "l", [$[1, 2]$], "d"),
  (1, "l", [$[5, 7]$], "d"),
  (3, "r", [$[2.2, 1.8]$], "d"),
  (4, "r", [$[6.2, 5.8]$], "d"),
)
#let sp-beliefs = (
  (1, "d", [$b_1 = [0.517, 0.483]$]),
  (3, "c", [$b_2 = [0.379, 0.621]$]),
  (5, "d", [$b_3 = [0, 1]$]),
)
// Max-product on the same example.
#let mp-msgs = (
  (2, "r", [$[1.8, 1.2]$], "c"),
  (3, "l", [$[1, 2]$], "c"),
  (1, "l", [$[3, 6]$], "d"),
)
#let mp-beliefs = (
  (1, "d", [$zeta_1 = [1.8, 2.4]$]),
  (3, "c", [$zeta_2 = [1.8, 2.4]$]),
)

// Two message rules, drawn on a fragment of a factor graph.
#let sp-rules() = context {
  let bwm = bw.get()
  let excl = (paint: luma(60%), dash: "dotted", thickness: 0.9pt)
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.6em,
    align: center + horizon,
    diagram(
      ..fg,
      spacing: (38pt, 14pt),
      node((0, -1), [$h_1$], shape: shapes.rect, fill: fac-fill),
      node((0, 1), [$h_2$], shape: shapes.rect, fill: fac-fill),
      node((1, 0), [$x$], shape: circle),
      node((2.4, 0), [$f$], shape: shapes.rect, fill: fac-fill),
      edge((0, -1), (1, 0), "->", stroke: msg-stroke("c", bwm), label: text(
        fill: ink("c", bwm),
      )[$m_(h_1 arrow.r x)$]),
      edge(
        (0, 1),
        (1, 0),
        "->",
        stroke: msg-stroke("c", bwm),
        label: text(fill: ink("c", bwm))[$m_(h_2 arrow.r x)$],
        label-side: right,
      ),
      edge((1, 0), (2.4, 0), "->", stroke: msg-stroke("out", bwm), label: text(
        fill: ink("d", bwm),
      )[$m_(x arrow.r f)$]),
      edge((2.4, 0), (1, 0), "->", stroke: excl, bend: 40deg, label: text(
        fill: luma(45%),
        size: 7pt,
      )[not used]),
    ),
    diagram(
      ..fg,
      spacing: (38pt, 14pt),
      node((0, 0), [$x$], shape: circle),
      node((1.4, 0), [$f$], shape: shapes.rect, fill: fac-fill),
      node((2.4, -1), [$y_1$], shape: circle),
      node((2.4, 1), [$y_2$], shape: circle),
      edge(
        (2.4, -1),
        (1.4, 0),
        "->",
        stroke: msg-stroke("c", bwm),
        label: text(fill: ink("c", bwm))[$m_(y_1 arrow.r f)$],
        label-side: right,
      ),
      edge((2.4, 1), (1.4, 0), "->", stroke: msg-stroke("c", bwm), label: text(
        fill: ink("c", bwm),
      )[$m_(y_2 arrow.r f)$]),
      edge(
        (1.4, 0),
        (0, 0),
        "->",
        stroke: msg-stroke("out", bwm),
        label: text(fill: ink("d", bwm))[$m_(f arrow.r x)$],
        label-side: right,
      ),
      edge(
        (0, 0),
        (1.4, 0),
        "->",
        stroke: excl,
        bend: -40deg,
        label: text(fill: luma(45%), size: 7pt)[not used],
        label-side: right,
      ),
    ),

    [(a) variable $arrow.r$ factor: *multiply* \ what every _other_ factor said],
    [(b) factor $arrow.r$ variable: multiply by $f$, \ *sum out* every _other_ variable],
  )
}

// Why a message on a tree is exact: it is a sum over the subtree behind it.
#let subtree-sum() = context diagram(
  ..fg,
  spacing: (20pt, 12pt),
  node(
    enclose: ((1, -1), (3, 1)),
    ..region("c", bw.get()),
    corner-radius: 6pt,
    inset: 8pt,
  ),
  node(
    enclose: ((-2, 0), (-1, 0)),
    ..region("d", bw.get()),
    corner-radius: 6pt,
    inset: 8pt,
  ),
  node((0, 0), [$x$], shape: circle, stroke: 1.3pt),
  node((1, 0), [$f$], shape: shapes.rect, fill: fac-fill),
  node((2, -1), [$y_1$], shape: circle),
  node((2, 1), [$y_2$], shape: circle),
  node((3, -1), [$h$], shape: shapes.rect, fill: fac-fill),
  node((-1, 0), [$k$], shape: shapes.rect, fill: fac-fill),
  node((-2, 0), [$w$], shape: circle),
  edge((0, 0), (1, 0), "-"),
  edge((1, 0), (2, -1), "-"),
  edge((1, 0), (2, 1), "-"),
  edge((2, -1), (3, -1), "-"),
  edge((0, 0), (-1, 0), "-"),
  edge((-1, 0), (-2, 0), "-"),
  node(
    (2, 2.2),
    text(
      fill: ink("c", bw.get()),
      size: 7.5pt,
    )[$m_(f arrow.r x)(x) = sum_(y_1, y_2) f(x, y_1, y_2) h(y_1)$],
    stroke: none,
  ),
  node(
    (-1.5, 2.2),
    text(
      fill: ink("d", bw.get()),
      size: 7.5pt,
    )[$m_(k arrow.r x)(x) = sum_w k(x, w)$],
    stroke: none,
  ),
)

// HMM as a factor graph, with forwards and backwards messages into z_t.
#let hmm-factor-graph() = context diagram(
  ..fg,
  spacing: (40pt, 30pt),
  node-inset: 7pt,
  node((-1, 0), [$dots.c$], name: <l>, stroke: none),
  node((0, 0), [$z_(t-1)$], name: <z0>, shape: circle),
  node((1, 0), [$A_t$], name: <a1>, shape: shapes.rect, fill: fac-fill),
  node((2, 0), [$z_t$], name: <z1>, shape: circle),
  node((3, 0), [$A_(t+1)$], name: <a2>, shape: shapes.rect, fill: fac-fill),
  node((4, 0), [$z_(t+1)$], name: <z2>, shape: circle),
  node((5, 0), [$dots.c$], name: <r>, stroke: none),
  node(
    (0, 1),
    [$lambda_(t-1)$],
    name: <l0>,
    shape: shapes.rect,
    fill: fac-fill,
  ),
  node((2, 1), [$lambda_t$], name: <l1>, shape: shapes.rect, fill: fac-fill),
  node(
    (4, 1),
    [$lambda_(t+1)$],
    name: <l2>,
    shape: shapes.rect,
    fill: fac-fill,
  ),
  edge(<l>, <z0>, "-"),
  edge(<z0>, <a1>, "-"),
  edge(<a1>, <z1>, "-"),
  edge(<z1>, <a2>, "-"),
  edge(<a2>, <z2>, "-"),
  edge(<z2>, <r>, "-"),
  edge(<z0>, <l0>, "-"),
  edge(<z1>, <l1>, "-"),
  edge(<z2>, <l2>, "-"),
  edge(
    <a1>,
    <z1>,
    "->",
    bend: -60deg,
    stroke: msg-stroke("c", bw.get()),
    label: [$alpha_(t|t-1)$],
    label-side: left,
    label-sep: 2pt,
  ),
  edge(
    <a2>,
    <z1>,
    "->",
    bend: 60deg,
    stroke: msg-stroke("d", bw.get()),
    label: [$beta_t$],
    label-side: right,
    label-sep: 2pt,
  ),
)

// A loopy graph and its computation tree (textbook Figure 9.12).
#let loopy-comp-tree() = grid(
  columns: 2,
  column-gutter: 3em,
  row-gutter: 0.5em,
  align: center + horizon,
  diagram(
    ..fg,
    spacing: (22pt, 22pt),
    node((0, 0), [$1$], name: <n1>),
    node((-1, 1), [$2$], name: <n2>),
    node((1, 1), [$3$], name: <n3>),
    node((0, 2), [$4$], name: <n4>, fill: fac-fill),
    edge(<n1>, <n2>, "-"),
    edge(<n1>, <n3>, "-"),
    edge(<n2>, <n3>, "-"),
    edge(<n2>, <n4>, "-"),
    edge(<n3>, <n4>, "-"),
  ),
  diagram(
    ..fg,
    spacing: (8pt, 18pt),
    node((4, 0), [$1$]),
    node((2, 1), [$2$]),
    node((6, 1), [$3$]),
    node((1, 2), [$3$]),
    node((3, 2), [$4$], fill: fac-fill),
    node((5, 2), [$2$]),
    node((7, 2), [$4$], fill: fac-fill),
    node((0.5, 3), [$1$]),
    node((1.5, 3), [$4$], fill: fac-fill),
    node((3, 3), [$3$]),
    node((4.5, 3), [$1$]),
    node((5.5, 3), [$4$], fill: fac-fill),
    node((7, 3), [$2$]),
    edge((4, 0), (2, 1), "-"),
    edge((4, 0), (6, 1), "-"),
    edge((2, 1), (1, 2), "-"),
    edge((2, 1), (3, 2), "-"),
    edge((6, 1), (5, 2), "-"),
    edge((6, 1), (7, 2), "-"),
    edge((1, 2), (0.5, 3), "-"),
    edge((1, 2), (1.5, 3), "-"),
    edge((3, 2), (3, 3), "-"),
    edge((5, 2), (4.5, 3), "-"),
    edge((5, 2), (5.5, 3), "-"),
    edge((7, 2), (7, 3), "-"),
  ),

  [(a)], [(b)],
)

// ---------------------------------------------------------------------------
// Student network (Koller & Friedman), drawn at successive stages of
// symbolic variable elimination.
#let student-pos = (
  C: (0, 0),
  D: (0, 1),
  I: (2, 1),
  G: (1, 2),
  S: (3, 2),
  L: (1, 3),
  J: (2, 4),
  H: (0, 4),
)
#let student-edges = (
  ("C", "D"),
  ("D", "G"),
  ("I", "G"),
  ("I", "S"),
  ("G", "L"),
  ("L", "J"),
  ("S", "J"),
  ("G", "H"),
  ("J", "H"),
)
#let student-moral = (("D", "I"), ("L", "S"), ("G", "J"))

// directed: draw the DPGM. Otherwise draw the moralized graph with
// `gone` eliminated and `fill` fill-in edges (red).
#let student-graph(directed: false, gone: (), fill: ()) = context {
  let alive(v) = v not in gone
  diagram(
    ..pgm,
    spacing: (8pt, 10pt),
    node-inset: 2.5pt,
    ..for (v, p) in student-pos {
      (
        node(
          p,
          [$#v$],
          stroke: if alive(v) { 0.8pt } else {
            (paint: luma(75%), dash: "dotted")
          },
          fill: none,
        ),
      )
    },
    ..for (a, b) in student-edges {
      if directed {
        (edge(student-pos.at(a), student-pos.at(b), "->"),)
      } else if alive(a) and alive(b) {
        (edge(student-pos.at(a), student-pos.at(b), "-"),)
      }
    },
    ..if not directed {
      for (a, b) in student-moral {
        if alive(a) and alive(b) {
          (edge(student-pos.at(a), student-pos.at(b), "--", stroke: luma(50%)),)
        }
      }
    },
    ..for (a, b) in fill {
      if alive(a) and alive(b) {
        (
          edge(student-pos.at(a), student-pos.at(b), "--", stroke: if bw.get() {
            1.8pt + black
          } else { 1.2pt + red }),
        )
      }
    },
  )
}

#let student-strip() = grid(
  columns: 4,
  column-gutter: 0.8em,
  row-gutter: 0.5em,
  align: center + bottom,
  student-graph(directed: true),
  student-graph(),
  student-graph(gone: ("C", "D")),
  student-graph(gone: ("C", "D", "I"), fill: (("G", "S"),)),

  text(8pt)[(a) DPGM],
  text(8pt)[(b) moral],
  text(8pt)[(c) $- C, D$],
  text(8pt)[(d) $- I$],
)

// Summary of the exact (and one approximate) inference algorithms.
#let algorithm-summary() = text(size: 8.5pt, table(
  columns: 5,
  stroke: none,
  inset: 4pt,
  align: (left, left, left, left, center),
  table.hline(),
  table.header([*Algorithm*], [*Graph*], [*Computes*], [*Cost*], [*Exact?*]),
  table.hline(),
  [Forwards],
  [chain],
  [filtered $alpha_t$, evidence $p(y_(1:T))$],
  [$O(K^2 T)$],
  [yes],
  [Forwards-backwards],
  [chain],
  [smoothed $gamma_t$, pairs $xi_(t,t+1)$],
  [$O(K^2 T)$],
  [yes],
  [Viterbi], [chain], [MAP sequence], [$O(K^2 T)$], [yes],
  [Variable elimination],
  [any],
  [one marginal (or $Z$)],
  [$O(N K^(w+1))$],
  [yes],
  [Sum-product BP],
  [tree],
  [all marginals, $Z$],
  [$O(|cal(E)| K^(d_max))$],
  [yes],
  [Max-product BP],
  [tree],
  [max-marginals, MAP],
  [$O(|cal(E)| K^(d_max))$],
  [yes],
  [Junction tree], [any], [all clique marginals], [$O(N K^(w+1))$], [yes],
  [Loopy BP],
  [any],
  [approximate marginals],
  [$O(|cal(E)| K^(d_max))$ per sweep],
  [no],
  table.hline(),
))
