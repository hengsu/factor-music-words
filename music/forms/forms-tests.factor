USING: kernel music music.forms sequences tools.test ;
IN: music.forms.tests

! rondo: refrain A with episodes B and C gives ABACA
{ { 1 2 1 3 1 } }
[ { { 1 1 } } { { { 2 1 } } { { 3 1 } } } rondo [ pitch ] map ]
unit-test

! sonata rondo: episodes B C B give ABACABA
{ { 1 2 1 3 1 2 1 } }
[ { { 1 1 } } { { { 2 1 } } { { 3 1 } } { { 2 1 } } } rondo [ pitch ] map ]
unit-test

! ternary: ABA
{ { 1 2 1 } }
[ { { 1 1 } } { { 2 1 } } ternary [ pitch ] map ]
unit-test

! binary: AABB
{ { 1 1 2 2 } }
[ { { 1 1 } } { { 2 1 } } binary [ pitch ] map ]
unit-test

! rep: three copies in sequence
{ { 1 1 1 } }
[ { { 1 1 } } 3 rep [ pitch ] map ]
unit-test

! canon at the unison: two voices; the follower is delayed by
! 2 beats, so its total duration grows by the delay
{ 2 }
[ { { 1 1 } { 5/4 1 } } 2 1 2 canon length ]
unit-test

{ 4 }
[ { { 1 1 } { 5/4 1 } } 2 1 2 canon second total-dur ]
unit-test

! canon at the fifth: the follower's first sounding note is the
! leader's first note transposed by 3/2
{ 3/2 }
[ { { 1 1 } { 5/4 1 } } 2 3/2 2 canon second second pitch ]
unit-test

! delay-by prepends a rest (pitch f)
{ f }
[ { { 1 1 } } 3 delay-by first pitch ]
unit-test

! steps: a sequence transposed by 2, then 4
{ { 1 2 4 } }
[ { { 1 1 } } 2 3 steps [ pitch ] map ]
unit-test

! variations: theme, retrograde theme, theme up an octave
{ { 1 5/4 5/4 1 2 5/2 } }
[ { { 1 1 } { 5/4 1 } } { [ retro ] [ 2 up ] } variations [ pitch ] map ]
unit-test

! ostinato: a 2-beat bass under a 5-beat melody repeats 3 times
{ 6 }
[ { { 1 2 } } { { 1 5 } } ostinato first total-dur ]
unit-test
