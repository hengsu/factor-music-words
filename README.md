# Factor Music Words

A small combinator library for composing music in [Factor](https://factorcode.org):
a core phrase vocabulary, a library of formatters for fixed musical
forms (canon, rondo, ternary, ...), and worked examples. It explores, in a concatenative language, the
approach of Haskell combinator libraries such as `diagrams` and the
"composing contracts" style: a piece of music is *composed* from phrases
with musically meaningful combinators, instead of being written out as a
flat list of raw events.

Factor is unusually well suited to this: juxtaposition of words *is*
composition, quotations are first-class, and combinators (`map`, `bi`,
`curry`, ...) are the native idiom.

## Layout

```
music/music.factor          the core vocabulary (IN: music)
music/music-tests.factor    unit tests for the core words
music/forms/forms.factor    formatters for fixed forms (IN: music.forms)
music/forms/forms-tests.factor   unit tests for the formatters
music/optimize/optimize.factor   automatic factorization (IN: music.optimize)
music/optimize/optimize-tests.factor   unit tests for the optimizer
examples/demo.factor        a minimal end-to-end demo (phrase model)
examples/demo.mp3           audio rendered from the demo
examples/turkish-march.factor   Mozart's Rondo alla Turca, full piece (event model)
examples/turkish-march.mp3      audio rendered from the program (2:17)
examples/canon-demo.factor  Frere Jacques as a four-voice round (music.forms)
examples/canon-demo.mp3     audio rendered from the canon demo
examples/rondo-demo.factor  a five-part rondo, ABACA (music.forms)
examples/rondo-demo.mp3     audio rendered from the rondo demo
```

## The phrase model (`music` vocabulary)

A note is `{ pitch-ratio duration-in-beats }`, both exact rationals.
Pitches are frequency ratios (just intonation), so no 12-tone grid is
assumed: `1` is the tonic, `9/8` a whole tone, `5/4` a just major third,
`3/2` a perfect fifth, `2` an octave. A phrase is an array of notes.

| Word | Stack effect | Meaning |
| --- | --- | --- |
| `note` | `( ratio dur -- note )` | build a note |
| `pitch` / `dur` | `( note -- ratio )` / `( note -- dur )` | accessors |
| `seq` | `( phrase phrase -- phrase' )` | play two phrases one after another |
| `par` | `( phrase phrase -- voices )` | overlay two phrases as voices |
| `up` | `( phrase ratio -- phrase' )` | transpose a phrase by a ratio |
| `augment` | `( phrase factor -- phrase' )` | scale all durations by a factor |
| `retro` | `( phrase -- phrase' )` | retrograde (play backwards) |
| `total-dur` | `( phrase -- dur )` | total length in beats |
| `freqs` | `( phrase base -- freqs )` | absolute frequencies for a base (e.g. A=440) |

The demo builds a four-note motif (`1, 9/8, 5/4, 3/2`), sequences it with
itself transposed up a fifth, and finishes with the retrograde — ten
beats in all.

## Formatters (`music.forms` vocabulary)

A formatter is a higher-order combinator: give it thematic material
and it assembles a complete piece in a classical fixed form. The
phrase model gains rests — a note whose pitch is `f` — so voices can
enter late.

| Word | Stack effect | Form |
| --- | --- | --- |
| `canon` | `( phrase delay interval n -- voices )` | strict imitation: voice *k* is the phrase transposed by *interval^k* and delayed by *k·delay* beats. Interval `1` is a round; `3/2` a canon at the fifth |
| `rondo` | `( refrain episodes -- phrase )` | the refrain returns after every episode: episodes `{ B C }` give ABACA, `{ B C B }` give ABACABA (sonata rondo) |
| `ternary` | `( a b -- phrase )` | ABA (da capo) |
| `binary` | `( a b -- phrase )` | AABB, each section repeated |
| `variations` | `( theme quots -- phrase )` | the theme, then the theme transformed by each quotation in turn |
| `ostinato` | `( bass melody -- voices )` | a ground bass (passacaglia/chaconne) repeated to cover the melody |
| `steps` | `( phrase step n -- phrase )` | a melodic sequence: the phrase repeated, transposed by *step^k* |
| `rep` | `( phrase n -- phrase )` | a phrase repeated *n* times |
| `rest-note` / `delay-by` | `( dur -- note )` / `( phrase beats -- phrase )` | rests and delayed entries |

The canon demo builds *Frère Jacques* from its four lines (each
stated twice with `rep`, joined with `seq`) and turns it into a
four-voice round with a single `canon` call. The rondo demo makes
its episodes from the refrain itself — B is the refrain backwards
(`retro`), C is the refrain up a fifth — and lets `rondo` interleave
them into ABACA.

## Automatic optimization (`music.optimize` vocabulary)

Repeated material should be stated once and referenced afterwards —
and that refactoring can itself be a word.

| Word | Stack effect | Meaning |
| --- | --- | --- |
| `factor-phrase` | `( phrase n -- table indices )` | split a phrase into segments of *n* notes; return the distinct segments and the segment index at each position (a compressed form) |
| `expand-phrase` | `( table indices -- phrase )` | the exact inverse of `factor-phrase` |
| `emit-optimized` | `( voices names bar-ticks pickup -- )` | print a complete factored program for an event-model score: distinct bars become `bar-N` words, 8-bar phrases are built with `narray`, repeated phrases are shared |

`emit-optimized` automates the optimization first done by hand for
the Turkish March below. Run on that score (256 bar instances), it
emits a 17,296-byte program — against 30,630 bytes unfactored and
18,629 for the hand-optimized version — whose event output is
byte-identical to the original's (1,614 events).

## The event model (Turkish March example)

Real scores need rests, chords, and several voices, so the full-piece
example uses events: `{ start midi dur }` in ticks (384 ticks = one
quarter note), grouped into bars, bars into 8-bar phrases. The
combinators assemble the score:

- `seq` joins phrases, `par` overlays the right- and left-hand voices
- `voice-events` / `score-events` flatten the structured score into an
  absolute event list, which `main` prints — ready to feed to any
  synthesizer or MIDI writer

The piece is Mozart's *Rondo alla Turca* (Piano Sonata No. 11, K. 331,
3rd movement), all 128 bars, 1,614 notes. Its event output was verified
to match the source score's note set exactly. The MP3 was rendered from
the program's own output at quarter = 112 with a simple harmonic
synthesizer (right hand slightly louder than left).

## Running

Requires Factor 0.100.

```sh
# core vocabulary tests: in the Factor listener, add this directory
# as a vocabulary root, then run the test suite
factor -run=listener
USING: tools.test vocabs.loader ;
"/path/to/factor-music-words" add-vocab-root
"music" test
"music.forms" test
"music.optimize" test

# examples are standalone scripts
factor examples/demo.factor
factor examples/turkish-march.factor   # prints start/midi/dur per note
factor examples/canon-demo.factor      # prints the voices' pitch/dur pairs
factor examples/rondo-demo.factor
```

## Credits and references

- **Created with Muse.** All of the code in this repository — the
  `music` vocabulary, its tests, the examples, and the verification
  that the Turkish March program's events match the source score —
  was written and checked on 2026-11-24 in conversation with Muse,
  Meta's personal AI agent. The `music.forms` formatters and their
  demos followed on 2026-11-25.
- **Originating idea:** Sandy Maguire, "An Overview of an Ambitious
  Music Project", *Reasonably Polymorphic*, 2026-11-02 —
  <https://reasonablypolymorphic.com/blog/music-overview/>
  The post sets out to build a constructive theory of music as a
  Haskell combinator library, under three desiderata: express any
  music without assuming 12 pitch classes or harmonic function; make
  it easy to get good results through musically meaningful
  combinators; and make understanding the system teach you something
  about music. This repository is a small experiment in whether the
  same approach works in Factor.
- **The lineage that post draws on:**
  - Simon Peyton Jones, Jean-Marc Eber, Julian Seward, "Composing
    Contracts: An Adventure in Financial Engineering" (ICFP 2000) —
    <https://www.lexifi.com/pdf/contracts.pdf>
  - Brent Yorgey et al., *diagrams*, a declarative vector-graphics
    combinator library in Haskell — <https://diagrams.github.io/>

## Licenses

- Code: MIT (see `LICENSE`).
- Mozart's composition is public domain. The Turkish March score data
  comes from the [Mutopia Project](https://www.mutopiaproject.org)
  edition (typeset by Rune Zedeler and Chris Sawer), which is also
  public domain.

---

日本語: Haskell のコンビネータライブラリのような「音楽をコンビネータで
構成する」試みを、連結型言語 Factor で実装した小さなライブラリと実例。
`examples/turkish-march.factor` はモーツァルト「トルコ行進曲」全曲
（128小節・1,614音）をこの仕組みでプログラムしたもので、出力イベントが
原譜の音符と完全一致することを検証済みです。`music.forms` はカノン、
ロンド（ABACA）、三部形式、変奏、オスティナートなどの定型形式を
組み立てるフォーマッタ集で、「フレール・ジャック」の4声輪唱と
ロンドのデモ付きです。`music.optimize` は繰り返しの自動検出と
ファクタリングを行う最適化ワード集で、トルコ行進曲の手作業の
最適化を自動で再現できます。Meta社のMuseが作成しました。
発想の元は Reasonably Polymorphic の記事「An Overview of an Ambitious
Music Project」です（リンクは上の Credits and references を参照）。
