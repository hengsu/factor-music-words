USING: kernel music.optimize tools.test ;
IN: music.optimize.tests

! factor-phrase at n = 1: three distinct notes, indices in order
{ { { { 1 1 } } { { 2 1 } } { { 3 1 } } } }
[ { { 1 1 } { 2 1 } { 1 1 } { 3 1 } { 1 1 } { 2 1 } } 1 factor-phrase drop ]
unit-test

{ { 0 1 0 2 0 1 } }
[ { { 1 1 } { 2 1 } { 1 1 } { 3 1 } { 1 1 } { 2 1 } } 1 factor-phrase nip ]
unit-test

! expand-phrase is the exact inverse of factor-phrase
{ { { 1 1 } { 2 1 } { 1 1 } { 3 1 } { 1 1 } { 2 1 } } }
[ { { 1 1 } { 2 1 } { 1 1 } { 3 1 } { 1 1 } { 2 1 } } 1 factor-phrase expand-phrase ]
unit-test

! at n = 2 the segments are two-note units: XYXY has table { X Y }
{ 2 }
[ { { 1 1 } { 2 1 } { 3 1 } { 4 1 } { 1 1 } { 2 1 } { 3 1 } { 4 1 } }
  2 factor-phrase drop length ]
unit-test

{ { { 1 1 } { 2 1 } { 3 1 } { 4 1 } { 1 1 } { 2 1 } { 3 1 } { 4 1 } } }
[ { { 1 1 } { 2 1 } { 3 1 } { 4 1 } { 1 1 } { 2 1 } { 3 1 } { 4 1 } }
  2 factor-phrase expand-phrase ]
unit-test
