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
USING: arrays combinators kernel locals math math.functions music
    sequences ;
IN: music.forms

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
