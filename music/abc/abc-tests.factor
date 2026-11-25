USING: kernel music.abc sequences tools.test ;
IN: music.abc.tests

! a C major scale over two bars, quarter notes (L:1/4)
{ { { { { 0 60 384 } { 384 62 384 } { 768 64 384 } { 1152 65 384 } } { { 0 67 384 } { 384 69 384 } { 768 71 384 } { 1152 72 384 } } } } }
[ "X:1\nL:1/4\nK:C\nC D E F | G A B c |\n" abc>score ] unit-test

! key signature: F is sharp in G major
{ { { { { 0 66 384 } { 384 67 384 } { 768 69 384 } { 1152 71 384 } } } } }
[ "L:1/4\nK:G\nF G A B\n" abc>score ] unit-test

! an accidental persists within the bar, then resets
{ { { { { 0 66 384 } { 384 66 384 } } { { 0 65 384 } } } } }
[ "L:1/4\nK:C\n^F F | F\n" abc>score ] unit-test

! octave marks: , lowers, ' raises; capitals are octave 4
{ { { { { 0 48 384 } { 384 60 384 } { 768 72 384 } { 1152 84 384 } } } } }
[ "L:1/4\nK:C\nC, C c c'\n" abc>score ] unit-test

! lengths: numbers, /n, bare /, and fractions
{ { { { { 0 60 768 } { 768 62 192 } { 960 64 192 } { 1152 65 576 } } } } }
[ "L:1/4\nK:C\nC2 D/2 E/ F3/2\n" abc>score ] unit-test

! rests advance the clock; a chord sounds its notes together
{ { { { { 768 60 768 } { 768 64 768 } { 768 67 768 } } } } }
[ "L:1/4\nK:C\nz2 [CEG]2\n" abc>score ] unit-test

! a tie across a barline merges into one event
{ { { { { 0 60 768 } { 768 60 1152 } } { { 768 60 384 } } } } }
[ "L:1/4\nK:C\nC2 C- | C2 C\n" abc>score ] unit-test

! a triplet: three quarters in the time of two
{ { { { { 0 60 256 } { 256 62 256 } { 512 64 256 } { 768 65 384 } } } } }
[ "L:1/4\nK:C\n(3C D E F\n" abc>score ] unit-test

! broken rhythm: > lengthens the first note, shortens the next
{ { { { { 0 60 576 } { 576 62 192 } } } } }
[ "L:1/4\nK:C\nC>D\n" abc>score ] unit-test

! broken rhythm: < does the reverse
{ { { { { 0 60 192 } { 192 62 576 } } } } }
[ "L:1/4\nK:C\nC<D\n" abc>score ] unit-test

! repeats are expanded, with first and second endings
{ { { { { 0 60 384 } } { { 0 62 384 } } { { 0 64 384 } } { { 0 65 384 } } { { 0 62 384 } } { { 0 64 384 } } { { 0 67 384 } } } } }
[ "L:1/4\nK:C\nC |: D | E | [1 F :| [2 G |\n" abc>score ] unit-test

! two voices, declared with V: fields
{ { { { { 0 60 384 } { 384 62 384 } } } { { { 0 52 384 } { 384 55 384 } } } } }
[ "X:1\nV:1\nV:2\nL:1/4\nK:C\nV:1\nC D\nV:2\nE, G,\n" abc>score ] unit-test

! minor keys use the relative major's signature: A minor
{ { { { { 0 69 384 } { 384 71 384 } { 768 72 384 } } } } }
[ "L:1/4\nK:Am\nA B c\n" abc>score ] unit-test

! E minor has F sharp
{ { { { { 0 66 384 } { 384 67 384 } } } } }
[ "L:1/4\nK:Em\nF G\n" abc>score ] unit-test

! an inline [K:...] field changes the key mid-tune
{ { { { { 0 60 384 } { 384 66 384 } } } } }
[ "L:1/4\nK:C\nC [K:G] F\n" abc>score ] unit-test

! grace notes and quoted chord symbols are skipped
{ { { { { 0 60 384 } { 384 64 384 } } } } }
[ "L:1/4\nK:C\n\"G\" C {D}E\n" abc>score ] unit-test

! Frere Jacques (traditional), each line repeated with |: :|;
! ! the same tune the music.forms canon demo is built from
{ { { { { 0 60 384 } { 384 62 384 } { 768 64 384 } { 1152 60 384 } } { { 0 60 384 } { 384 62 384 } { 768 64 384 } { 1152 60 384 } } { { 0 64 384 } { 384 65 384 } { 768 67 768 } } { { 0 64 384 } { 384 65 384 } { 768 67 768 } } { { 0 67 192 } { 192 69 192 } { 384 67 192 } { 576 65 192 } { 768 64 384 } { 1152 60 384 } } { { 0 67 192 } { 192 69 192 } { 384 67 192 } { 576 65 192 } { 768 64 384 } { 1152 60 384 } } { { 0 60 384 } { 384 55 384 } { 768 60 768 } } { { 0 60 384 } { 384 55 384 } { 768 60 768 } } } } }
[ "X:1\nT:Frere Jacques\nM:4/4\nL:1/4\nK:C\n|: C D E C :|\n|: E F G2 :|\n|: G/2 A/2 G/2 F/2 E C :|\n|: C G, C2 :|\n" abc>score ] unit-test
