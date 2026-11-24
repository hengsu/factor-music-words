USING: music tools.test ;
IN: music.tests

{ { 1 2 3 4 } } [ { 1 2 } { 3 4 } seq ] unit-test
{ { { { 1 1 } } { { 2 1 } } } } [ { { 1 1 } } { { 2 1 } } par ] unit-test
{ { { 3/2 1 } } } [ { { 1 1 } } 3/2 up ] unit-test
{ { { 1 2 } } } [ { { 1 1 } } 2 augment ] unit-test
{ { { 2 1 } { 1 1 } } } [ { { 1 1 } { 2 1 } } retro ] unit-test
{ 5 } [ { { 1 2 } { 1 3 } } total-dur ] unit-test
{ { 660.0 } } [ { { 3/2 1 } } 440 freqs ] unit-test
{ 5/4 } [ 5/4 1 note pitch ] unit-test
{ 2 } [ 5/4 2 note dur ] unit-test
