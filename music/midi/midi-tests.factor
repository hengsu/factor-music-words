USING: accessors arrays assocs kernel locals midi music.midi
    sequences sequences.generalizations tools.test ;
IN: music.midi.tests

! helper: build a note-on/note-off midi-event on channel 0
:: (mk-ev) ( delta name note vel -- event )
    H{ } clone :> v
    0 "channel" v set-at
    note "note" v set-at
    vel "velocity" v set-at
    delta name v <midi-event> ;

! events>bars: pickup bar 0, then full bars of 768 ticks
{ { { { 0 60 384 } } { { 0 62 384 } } { { 0 64 384 } } } }
[ { { 0 60 384 } { 384 62 384 } { 1152 64 384 } } 768 384 events>bars ]
unit-test

! events>bars: silent bars are kept as empty bars
{ { { { 0 60 100 } } { } { } { { 0 62 100 } } } }
[ { { 0 60 100 } { 1920 62 100 } } 768 384 events>bars ]
unit-test

! events>bars: no notes, no bars
{ { } }
[ { } 768 384 events>bars ]
unit-test

! track>notes: note-on/note-off pairs become { start midi dur }
{ { { 0 60 96 } { 96 62 96 } } }
[ 0 "note-on" 60 100 (mk-ev) 96 "note-off" 60 64 (mk-ev)
  0 "note-on" 62 100 (mk-ev) 96 "note-off" 62 64 (mk-ev)
  4 narray midi-track boa track>notes ]
unit-test

! track>notes: a note-on with velocity 0 is a note-off
{ { { 0 60 96 } } }
[ 0 "note-on" 60 100 (mk-ev) 96 "note-on" 60 0 (mk-ev)
  2array midi-track boa track>notes ]
unit-test

! track>notes: overlapping notes of one pitch pair up FIFO
{ { { 0 60 96 } { 48 60 96 } } }
[ 0 "note-on" 60 100 (mk-ev) 48 "note-on" 60 100 (mk-ev)
  48 "note-off" 60 64 (mk-ev) 48 "note-off" 60 64 (mk-ev)
  4 narray midi-track boa track>notes ]
unit-test

! midi>voices and midi>division on a one-track file
{ { { { 0 60 96 } } } }
[ 0 "note-on" 60 100 (mk-ev) 96 "note-off" 60 64 (mk-ev)
  2array midi-track boa
  1 1 384 midi-header boa swap 1array <midi> midi>voices ]
unit-test

{ 384 }
[ 1 1 384 midi-header boa { } <midi> midi>division ]
unit-test
