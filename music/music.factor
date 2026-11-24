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
USING: arrays combinators kernel locals math sequences ;
IN: music

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
