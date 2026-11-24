! Factor Music Words -- canon demo: a round in four voices
!
! A self-contained demo script: the music and music.forms
! vocabularies are inlined above the demo (generated from
! music/music.factor and music/forms/forms.factor), so this file
! runs directly:  factor canon-demo.factor
USING: arrays combinators io kernel locals math math.functions
    prettyprint sequences ;
IN: canon-demo

! Factor Music Words -- core combinators.
!
! A small combinator library for composing music in Factor, in the
! spirit of Haskell's diagrams / composing-contracts style libraries:
! a piece is built by composing phrases with musically meaningful
! combinators, not by listing raw events.
!
! This vocabulary is the phrase model: a note is
! { pitch-ratio duration-in-beats }, both exact rationals, and a
! phrase is an array of notes. Pitches are frequency ratios
! (just intonation), so no 12-tone grid is assumed: 1 is the tonic,
! 5/4 a just major third, 3/2 a perfect fifth, 2 an octave.

! --- notes ---
: note ( ratio dur -- note ) 2array ;
: pitch ( note -- ratio ) first ;
: dur ( note -- dur ) second ;

:: transpose-note ( note ratio -- note' )
    note pitch ratio * note dur 2array ;

:: stretch-note ( note factor -- note' )
    note pitch note dur factor * 2array ;

! --- combinators ---
! seq: play two phrases one after another.
: seq ( phrase phrase -- phrase' ) append ;

! par: overlay two phrases as separate voices.
: par ( phrase phrase -- voices ) 2array ;

! up: transpose a whole phrase by a frequency ratio.
: up ( phrase ratio -- phrase' ) [ transpose-note ] curry map ;

! augment: scale every duration in a phrase by a factor.
: augment ( phrase factor -- phrase' ) [ stretch-note ] curry map ;

! retro: play a phrase backwards (retrograde).
: retro ( phrase -- phrase' ) reverse ;

! --- measuring and rendering helpers ---
:: freq-of ( note base -- freq ) note pitch base * >float ;

: total-dur ( phrase -- dur ) 0 [ dur + ] reduce ;
: freqs ( phrase base -- freqs ) [ freq-of ] curry map ;

! Factor Music Words -- formatters for fixed musical forms.
!
! A formatter is a higher-order combinator: give it thematic material
! and it assembles a complete piece in a classical fixed form. The
! patterns implemented here are the standard textbook schemes:
!
!   canon       strict imitation: the same phrase enters voice after
!               voice at a fixed delay, at the unison or at a fixed
!               transposition interval (fifth, octave, ...).
!               A round is a canon at the unison.
!   rondo       ABACA, ABACABA, ... : a refrain returns after every
!               episode. `rondo` takes the refrain and the array of
!               episodes and interleaves them.
!   ternary     ABA: statement, contrast, return (da capo).
!   binary      AABB: two sections, each repeated.
!   variations  theme, then one variation per quotation given.
!   ostinato    a short bass repeated to cover the melody, as in a
!               passacaglia or chaconne (ground bass).
!   steps       a sequence: a phrase repeated, transposed by a fixed
!               ratio at every repetition.
!
! Forms are built from the `music` vocabulary's phrases, so every
! formatter composes freely with seq / par / up / augment / retro.

! --- rests and delay: the phrase model gains silence ---
! A rest is a note whose pitch is f; renderers skip it, but its
! duration still advances the voice's clock.
: rest-note ( dur -- note ) f swap 2array ;
: rest-note? ( note -- ? ) pitch not ;

:: delay-by ( phrase beats -- phrase' )
    beats zero? [ phrase ] [ beats rest-note 1array phrase seq ] if ;

! --- repetition ---
:: rep ( phrase n -- phrase' )
    n [ phrase ] replicate concat ;

<PRIVATE
: (ratio^) ( ratio k -- ratio^k )
    swap <array> 1 [ * ] reduce ;

:: (canon-voice) ( phrase delay interval k -- voice )
    phrase interval k (ratio^) up delay k * delay-by ;
PRIVATE>

! --- the formatters ---

! canon: voice k is the phrase transposed by interval^k and delayed
! by k * delay beats. interval 1 gives a round (canon at the unison);
! 3/2 gives a canon at the fifth, 2 at the octave.
:: canon ( phrase delay interval n -- voices )
    n <iota> [ [ phrase delay interval ] dip (canon-voice) ] map ;

! rondo: refrain, then each episode followed by the refrain.
! { B C } gives ABACA; { B C B } gives ABACABA (sonata rondo).
:: rondo ( refrain episodes -- phrase )
    episodes empty? [ refrain ]
    [ refrain episodes first seq
      refrain episodes rest rondo seq ] if ;

:: ternary ( a b -- phrase )
    a b seq a seq ;

: binary ( a b -- phrase )
    [ 2 rep ] bi@ seq ;

! variations: the theme, then the theme transformed by each
! quotation in turn.
:: variations ( theme quots -- phrase )
    theme 1array quots [ theme swap call( a -- b ) ] map append concat ;

! ostinato: the bass is repeated as many times as its length needs
! to cover the melody; the two are overlaid as voices.
:: ostinato ( bass melody -- voices )
    bass melody total-dur bass total-dur / ceiling rep melody par ;

! steps: a melodic sequence -- the phrase repeated n times, the
! k-th repetition transposed by step^k.
:: steps ( phrase step n -- phrase' )
    n <iota> [ phrase swap step swap (ratio^) up ] map concat ;

! --- demo: Frere Jacques (traditional) as a four-voice round ---
! The tune itself is assembled with the formatters: each line is
! stated twice (rep), the lines are sequenced (seq), and the round
! is a canon at the unison, four voices entering 8 beats apart.
: jacques-1 ( -- phrase )
    { { 1 1 } { 9/8 1 } { 5/4 1 } { 1 1 } } 2 rep ;

: jacques-2 ( -- phrase )
    { { 5/4 1 } { 4/3 1 } { 3/2 2 } } 2 rep ;

: jacques-3 ( -- phrase )
    { { 3/2 1/2 } { 5/3 1/2 } { 3/2 1/2 } { 4/3 1/2 } { 5/4 1 } { 1 1 } }
    2 rep ;

: jacques-4 ( -- phrase )
    { { 1 1 } { 3/4 1 } { 1 2 } } 2 rep ;

: jacques ( -- phrase )
    jacques-1 jacques-2 seq jacques-3 seq jacques-4 seq ;

: score ( -- voices ) jacques 8 1 4 canon ;

: print-voice ( voice -- )
    dup length . [ first2 [ . ] bi@ ] each ;

: main ( -- )
    score dup length . [ print-voice ] each ;

MAIN: main
