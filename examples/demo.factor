! Minimal Factor demo for the "Ambitious Music Project" overview
! (Reasonably Polymorphic, 2026-11-02, sent by the user 2026-11-24).
! The paper defines no combinators yet -- it states three desiderata,
! so this demo embodies two of them in the smallest possible form:
!  1. no 12-tone assumption: pitches are rational frequency ratios
!     (just intonation), not pitch classes;
!  2. musically meaningful combinators: seq / par / up / retro / augment.
! It is a sketch, not the paper's library. Verified by running Factor.
USING: arrays combinators io kernel math prettyprint sequences ;
IN: music-combinators

! A note is { pitch-ratio duration-in-beats }, both rationals.
: note ( ratio dur -- note ) 2array ;
: pitch ( note -- ratio ) first ;
: dur ( note -- dur ) second ;

:: transpose-note ( note ratio -- note' )
    note pitch ratio * note dur 2array ;

:: stretch-note ( note factor -- note' )
    note pitch note dur factor * 2array ;

! Combinators: sequencing, overlay, transposition by a ratio,
! retrograde, and duration scaling.
: seq ( phrase phrase -- phrase' ) append ;
: par ( phrase phrase -- voices ) 2array ;
: up ( phrase ratio -- phrase' ) [ transpose-note ] curry map ;
: augment ( phrase factor -- phrase' ) [ stretch-note ] curry map ;
: retro ( phrase -- phrase' ) reverse ;

:: freq-of ( note base -- freq ) note pitch base * >float ;

: total-dur ( phrase -- dur ) 0 [ dur + ] reduce ;
: freqs ( phrase base -- freqs ) [ freq-of ] curry map ;

! A four-note motif in just intonation: 1, 9/8, 5/4, 3/2.
: motif ( -- phrase )
    1 1 note 9/8 1 note 5/4 1 note 3/2 2 note 4array ;

! Motif, then the same motif a fifth (3/2) up, then the retrograde.
: demo ( -- phrase ) motif 3/2 up motif retro seq ;

: main ( -- )
    "phrase: " write demo dup . nl
    "total beats: " write dup total-dur . nl
    "frequencies at A=440: " write 440 freqs . nl ;

MAIN: main
