USING: kernel music.scor tools.test ;
IN: music.scor.tests

! a single quarter note: treble clef is the default, staff
! position 1 is middle C
{ { { { { 0 60 384 } } } } }
[ "1 1 10 1 10 0 1\n" scor>score ]
unit-test

! empty input gives no voices
{ { } }
[ "" scor>score ]
unit-test

! key signature: one sharp makes F a sharp (staff position 4)
{ { { { { 0 66 384 } } } } }
[ "17 1 5 0 1\n1 1 10 4 10 0 1\n" scor>score ]
unit-test

! bass clef (code 3, P5 = 1): staff position 3 is G2
{ { { { { 0 43 384 } } } } }
[ "3 1 2 0 1\n1 1 10 3 10 0 1\n" scor>score ]
unit-test

! alto clef (P5 = 2): the middle line (position 7) is middle C
{ { { { { 0 60 384 } } } } }
[ "3 1 2 0 2\n1 1 10 7 10 0 1\n" scor>score ]
unit-test

! tenor clef (P5 = 3): position 9 is middle C
{ { { { { 0 60 384 } } } } }
[ "3 1 2 0 3\n1 1 10 9 10 0 1\n" scor>score ]
unit-test

! written accidentals in the P5 units digit: 2 = sharp,
! 1 = flat, 3 = natural (here cancelling the key signature)
{ { { { { 0 66 384 } { 384 70 384 } { 768 71 384 } } } } }
[ "17 1 5 0 -1\n1 1 10 4 12 0 1\n1 1 20 7 11 0 1\n1 1 30 7 13 0 1\n" scor>score ]
unit-test

! double sharp (5) and double flat (4)
{ { { { { 0 67 384 } { 384 62 384 } } } } }
[ "1 1 10 4 15 0 1\n1 1 20 3 14 0 1\n" scor>score ]
unit-test

! an accidental persists within the bar and resets at the
! barline: C# C# | C
{ { { { { 0 61 384 } { 384 61 384 } } { { 0 60 384 } } } } }
[ "1 1 10 1 12 0 1\n1 1 20 1 10 0 1\n14 1 30 1\n1 1 40 1 10 0 1\n" scor>score ]
unit-test

! a rest advances time but emits no event
{ { { { { 192 60 384 } } } } }
[ "2 1 10 0 0 0 0.5\n1 1 20 1 10 0 1\n" scor>score ]
unit-test

! two notes at one position form a chord
{ { { { { 0 60 384 } { 0 64 384 } } } } }
[ "1 1 10 1 10 0 1\n1 1 10 3 0 0 1\n" scor>score ]
unit-test

! a dotted duration (P7 = 1.5) lasts 576 ticks and the next
! note starts there
{ { { { { 0 60 576 } { 576 62 384 } } } } }
[ "1 1 10 1 10 0 1.5\n1 1 20 2 10 0 1\n" scor>score ]
unit-test

! a grace note (P7 = 65) is skipped and takes no time
{ { { { { 0 60 384 } } } } }
[ "1 1 10 3 10 0 65\n1 1 20 1 10 0 1\n" scor>score ]
unit-test

! a slur joining two notes of the same pitch at adjacent
! positions is a tie: the notes merge into one event
{ { { { { 0 60 768 } } } } }
[ "1 1 10 1 10 0 1\n1 1 20 1 0 0 1\n5 1 10 7 7 20 0 -1\n" scor>score ]
unit-test

! a slur between different pitches is not a tie
{ { { { { 0 60 384 } { 384 62 384 } } } } }
[ "1 1 10 1 10 0 1\n1 1 20 2 0 0 1\n5 1 10 7 7 20 0 -1\n" scor>score ]
unit-test

! two staves give two voices, staff 1 first (SCORE numbers
! staves from the bottom)
{ { { { { 0 43 384 } } } { { { 0 60 384 } } } } }
[ "3 1 2 0 1\n1 1 10 3 10 0 1\n1 2 10 1 10 0 1\n" scor>score ]
unit-test

! comment lines, text items (with their following line) and
! other item codes are ignored
{ { { { { 0 60 384 } } } } }
[ "# measure 1:\nt 1 5 5 1 1 0 0 0 0 0 0 3\n_00Adagio\n9 1 8 -3 53\n1 1 10 1 10 0 1\n" scor>score ]
unit-test

! a cue-size note carries +100 on its staff position
{ { { { { 0 60 384 } } } } }
[ "1 1 10 101 10 0 1\n" scor>score ]
unit-test

! a barline splits bars; a bar in the middle with no notes
! on this staff is kept empty
{ { { { { 0 60 384 } } { } { { 0 62 384 } } } } }
[ "1 1 10 1 10 0 1\n14 1 20 1\n14 1 30 1\n1 1 40 2 10 0 1\n" scor>score ]
unit-test

! Real PMX data: the subject of Bach's Fugue in C minor,
! BWV 847 (as published on the SCORE article on Wikipedia).
! Key signature -3 gives A-flat and E-flat; the B naturals
! are written once per bar and persist within the bar.
{ { {
    { { 192 72 96 } { 288 71 96 } { 384 72 192 } { 576 67 192 }
      { 768 68 192 } { 960 72 96 } { 1056 71 96 } { 1152 72 192 }
      { 1344 74 192 } }
    { { 0 67 192 } { 192 72 96 } { 288 71 96 } { 384 72 192 }
      { 576 74 192 } { 768 65 96 } { 864 67 96 } { 960 68 384 }
      { 1344 67 96 } { 1440 65 96 } }
    { { 0 63 768 } } } } }
[ "8 1 0 0 0 200\n3 1 1.5\n17 1 9.416 0 -3\n18 1 19.016 0 4 4\n2 1 26.516 0 1 0 0.5\n1 1 34.835 8 20 0 0.25\n9 1 34.835 -3 54 1 0 0 0 0 0 0 0 0 -5\n6 1 34.835 8 7 41.43 22\n5 1 34.835 10 10 41.43 1.1093 -1\n1 1 41.435 7 23 0 0.25\n1 1 47.233 8 10 0 0.5 -1\n6 1 47.233 7 5.5 55.55 11\n1 1 55.551 5 10 0 0.5 0.5\n1 1 64.122 6 20 0 0.5\n6 1 64.122 6 7 78.24 21 0 0 11 72.44 78.24\n1 1 72.441 8 20 0 0.25 1.33\n5 1 72.441 10 10 78.24 1.1092 -1\n1 1 78.239 7 20 0 0.25\n1 1 84.037 8 20 0 0.5\n6 1 84.037 8 9 92.36 21\n1 1 92.355 9 20 0 0.5\n14 1 100.842 1\n1 1 104.174 5 10 0 0.5 3\n6 1 104.174 8 8 119.09 11 0 0 11 112.49 119.09\n1 1 112.493 8 10 0 0.25\n5 1 112.493 6 4 119.09 -1.3092 -1\n1 1 119.093 7 13 0 0.25 1\n1 1 125.143 8 20 0 0.5\n6 1 125.143 8 9 133.46 21\n1 1 133.462 9 20 0 0.5\n1 1 141.781 4 10 0 0.25\n6 1 141.781 4 5 147.58 12\n5 1 141.781 2 4 153.38 -1.5185 -1\n1 1 147.578 5 10 0 0.25\n1 1 153.376 6 10 0 1\n1 1 165.476 5 10 0 0.25\n6 1 165.476 5 4 171.27 12\n5 1 165.476 2 2 171.27 -1.1092 -1\n1 1 171.274 4 10 0 0.25\n14 1 178.274 1\n1 1 181.606 3 10 1 2 0 0 0 14\n14 1 200 1 1\n" scor>score ]
unit-test
