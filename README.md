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
music/music-docs.factor     help documentation for the core words
music/forms/forms.factor    formatters for fixed forms (IN: music.forms)
music/forms/forms-tests.factor   unit tests for the formatters
music/forms/forms-docs.factor    help documentation for the formatters
music/optimize/optimize.factor   automatic factorization (IN: music.optimize)
music/optimize/optimize-tests.factor   unit tests for the optimizer
music/optimize/optimize-docs.factor  help documentation for the optimizer
music/midi/midi.factor      MIDI file input (IN: music.midi)
music/midi/midi-tests.factor   unit tests for the MIDI converter
music/midi/midi-docs.factor    help documentation for the MIDI converter
music/musicxml/musicxml.factor   MusicXML file input (IN: music.musicxml)
music/musicxml/musicxml-tests.factor   unit tests for the MusicXML converter
music/musicxml/musicxml-docs.factor    help documentation for the MusicXML converter
music/abc/abc.factor        ABC notation input (IN: music.abc)
music/abc/abc-tests.factor   unit tests for the ABC converter
music/abc/abc-docs.factor    help documentation for the ABC converter
music/scor/scor.factor      SCORE (PMX) input (IN: music.scor)
music/scor/scor-tests.factor   unit tests for the PMX converter
music/scor/scor-docs.factor    help documentation for the PMX converter
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

(`transpose-note` and `stretch-note` are the per-note helpers behind
`up` and `augment`.)

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

## MIDI input (`music.midi` vocabulary)

A conversion layer on top of Factor's bundled `midi` vocabulary,
which parses Standard MIDI Files. These words turn its delta-timed
events into the array models used here:

| Word | Stack effect | Meaning |
|---|---|---|
| `track>notes` | `( track -- notes )` | one track → `{ start midi dur }` events with absolute ticks, sorted by start (note-on with velocity 0 counts as note-off; overlapping notes of one pitch pair up FIFO) |
| `midi>voices` | `( midi -- voices )` | every track of a parsed file → one note array per track |
| `midi>division` | `( midi -- division )` | the file's ticks per quarter note |
| `file>voices` | `( path -- voices )` | read a MIDI file → voices of absolute-tick notes |
| `events>bars` | `( notes bar-ticks pickup -- bars )` | group absolute-tick notes into bars (bar 0 is the pickup bar); starts become bar-relative, silent bars stay empty |
| `file>score` | `( path bar-ticks pickup -- voices )` | read a MIDI file → voices of bars, ready for `emit-optimized` |

The whole pipeline — MIDI file → `file>score` → `emit-optimized` →
factored program — was verified on the Turkish March: the emitted
program's event output is byte-identical to the golden output
(1,614 events).

## MusicXML input (`music.musicxml` vocabulary)

Reads score-partwise MusicXML documents, on top of Factor's bundled
`xml` vocabulary, into the same event model:

| Word | Stack effect | Meaning |
|---|---|---|
| `musicxml>score` | `( string -- voices )` | parse a MusicXML document from a string → voices of bars |
| `musicxml-file>score` | `( path -- voices )` | read a MusicXML file → voices of bars |

Pitches are built from step, alter and octave; rests, `<chord>`
notes, `<backup>` and `<forward>` (multiple voices in a part) are
handled; tied notes are merged into single events; grace notes are
skipped; the file's `<divisions>` are scaled to 384 ticks per
quarter note. All voices and staves within a part are merged into
the part's event stream. Verified on a full Turkish March document
(256 measures): the resulting score feeds `emit-optimized` to a
program byte-identical to the one produced from the MIDI file.

## ABC notation input (`music.abc` vocabulary)

Reads tunes in ABC notation (the text format of abcnotation.com)
into the same event model:

| Word | Stack effect | Meaning |
|---|---|---|
| `abc>score` | `( string -- voices )` | parse an ABC tune from a string → voices of bars |
| `abc-file>score` | `( path -- voices )` | read an ABC file → voices of bars |

Header fields `L:` (default note length) and `K:` (key signature —
major, minor, dorian, mixolydian, lydian, phrygian and locrian) are
honoured; several voices are declared with `V:` fields. Accidentals
persist within the bar; note lengths are numbers and fractions of
the `L:` unit; rests, chords, ties, tuplets and broken rhythm
(`>` and `<`) are handled; grace notes, quoted chord symbols and
decorations are skipped. Unlike the other two inputs, repeats are
performed: `|: :|` sections are expanded, with first and second
endings, and `[K:...]` fields change the key mid-tune. Verified
against the canon demo: Frère Jacques written in ABC with repeats
produces exactly the demo tune's 32 events.

## SCORE (PMX) input (`music.scor` vocabulary)

Reads PMX, the ASCII form of SCORE data, into the same event model:

| Word | Stack effect | Meaning |
|---|---|---|
| `scor>score` | `( string -- voices )` | parse PMX text from a string → voices of bars |
| `scor-file>score` | `( path -- voices )` | read a PMX file → voices of bars |

SCORE, written by Leland Smith at Stanford, began in 1967 as an
input language for MUSIC V, produced the first complete
computer-typeset work in 1971, and was a commercial engraving
product from 1987 to its final release in 2013; publishers such as
Schott used it for decades, and research centres such as CCARH hold
very large corpora engraved in it. Those corpora are the reason to
read SCORE today — but its data is graphical, not logical: a note
is a horizontal position on the page (P3), a diatonic staff
position (P4) and a duration (P7). This vocabulary reconstructs
pitch from staff position, clef (treble/bass/alto/tenor), key
signature and the accidental packed into P5, with accidentals
persisting within the bar, and rebuilds time from the order of
positions within each bar, so archival SCORE pages become music
that can be analysed, played and re-factored like any other input.
Suggested use: obtain PMX with SCORE's own PMX command or by
converting binary .MUS/.PAG files with scorelib, read it with
`scor-file>score`, and archive the result as an `emit-optimized`
program. One rhythmic voice per staff is assumed; grace notes are
skipped and slurs joining equal pitches are merged as ties.
Verified on real published data: the PMX for the subject of Bach's
Fugue in C minor, BWV 847, from the Wikipedia article on SCORE
reproduces the subject exactly, accidentals included.

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
"music.midi" test
"music.musicxml" test
"music.abc" test
"music.scor" test

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
  Meta's personal AI agent. The `music.forms` formatters, their
  demos, and the `music.optimize`, `music.midi`, `music.musicxml`,
  `music.abc` and `music.scor` vocabularies followed on 2026-11-25.
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
最適化を自動で再現できます。`music.midi` は Standard MIDI ファイルを
読み込み、トラックを音符イベントの配列や小節単位のスコアに変換する
入力層で、MIDI → 最適化プログラムの全経路をトルコ行進曲で検証済みです。
`music.musicxml` は MusicXML（score-partwise）を読む入力層で、タイの
結合、和音、backup/forward による複数声部にも対応し、同じイベント
モデルに変換します。`music.abc` は ABC記譜法を読む入力層で、調号
（長調・短調・各旋法）、小節内のみ有効な臨時記号、連符、ブロークン・
リズムに対応し、反復記号は1番・2番カッコを含めて展開します。
`music.scor` は SCORE のテキスト形式 PMX を読む入力層です。SCORE は
スタンフォード大学の Leland Smith が作った楽譜浄書システムで、1967年に
MUSIC V の入力言語として始まり、1971年にはコンピュータで浄書された
最初の全曲作品を生み、1987年から2013年の最終版まで商用製品として
Schott 社など多くの出版社の版を支えました。CCARH をはじめ研究機関には
SCORE で浄書された膨大な楽譜コーパスが残っており、それを再利用できる
ことがこの入力層の有用性です。ただし SCORE のデータは論理的ではなく
図形的（音符＝ページ上の水平位置・五線上の位置・長さ）なので、本
ボキャブラリが音高（音部記号・調号・P5 に詰め込まれた臨時記号から）と
時刻（小節内の位置の順序から）を再構成してイベントモデルに変換します。
利用方法の提案：SCORE 本体の PMX コマンドか、オープンソースの
scorelib でバイナリ（.MUS/.PAG）を PMX に変換し、`scor-file>score` で
読み、`emit-optimized` のプログラムとして保存するのが、アーカイブの
活用に適します。検証は Wikipedia の SCORE 記事に掲載された実データ
（バッハ BWV 847 フーガ主題）で、臨時記号まで含めて一致しました。
Meta社のMuseが作成しました。
発想の元は Reasonably Polymorphic の記事「An Overview of an Ambitious
Music Project」です（リンクは上の Credits and references を参照）。
