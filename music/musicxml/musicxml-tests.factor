USING: kernel music.musicxml tools.test ;
IN: music.musicxml.tests

! basic: two quarter notes at divisions=2, C4 then D4
{ { { { { 0 60 384 } { 384 62 384 } } } } }
[ "<score-partwise><part><measure><attributes><divisions>2</divisions></attributes><note><pitch><step>C</step><octave>4</octave></pitch><duration>2</duration></note><note><pitch><step>D</step><octave>4</octave></pitch><duration>2</duration></note></measure></part></score-partwise>" musicxml>score ]
unit-test

! pitch with alter: F#4 is 66, Bb3 is 58
{ { { { { 0 66 384 } { 384 58 384 } } } } }
[ "<score-partwise><part><measure><attributes><divisions>2</divisions></attributes><note><pitch><step>F</step><alter>1</alter><octave>4</octave></pitch><duration>2</duration></note><note><pitch><step>B</step><alter>-1</alter><octave>3</octave></pitch><duration>2</duration></note></measure></part></score-partwise>" musicxml>score ]
unit-test

! a rest advances the cursor but emits nothing
{ { { { { 384 60 384 } } } } }
[ "<score-partwise><part><measure><attributes><divisions>2</divisions></attributes><note><rest/><duration>2</duration></note><note><pitch><step>C</step><octave>4</octave></pitch><duration>2</duration></note></measure></part></score-partwise>" musicxml>score ]
unit-test

! a chord note shares the previous note's start
{ { { { { 0 60 384 } { 0 64 384 } { 384 67 384 } } } } }
[ "<score-partwise><part><measure><attributes><divisions>2</divisions></attributes><note><pitch><step>C</step><octave>4</octave></pitch><duration>2</duration></note><note><chord/><pitch><step>E</step><octave>4</octave></pitch><duration>2</duration></note><note><pitch><step>G</step><octave>4</octave></pitch><duration>2</duration></note></measure></part></score-partwise>" musicxml>score ]
unit-test

! backup: a second voice rewinds and plays under the first
{ { { { { 0 52 384 } { 0 60 768 } { 384 55 384 } } } } }
[ "<score-partwise><part><measure><attributes><divisions>2</divisions></attributes><note><pitch><step>C</step><octave>4</octave></pitch><duration>4</duration></note><backup><duration>4</duration></backup><note><pitch><step>E</step><octave>3</octave></pitch><duration>2</duration></note><note><pitch><step>G</step><octave>3</octave></pitch><duration>2</duration></note></measure></part></score-partwise>" musicxml>score ]
unit-test

! a tie across the barline merges into one event
{ { { { { 0 60 1536 } } { } } } }
[ "<score-partwise><part><measure><attributes><divisions>2</divisions></attributes><note><pitch><step>C</step><octave>4</octave></pitch><duration>4</duration><tie type='start'/></note></measure><measure><note><pitch><step>C</step><octave>4</octave></pitch><duration>4</duration><tie type='stop'/></note></measure></part></score-partwise>" musicxml>score ]
unit-test

! divisions are scaled to 384 ticks per quarter
{ { { { { 0 60 384 } { 384 62 192 } } } } }
[ "<score-partwise><part><measure><attributes><divisions>96</divisions></attributes><note><pitch><step>C</step><octave>4</octave></pitch><duration>96</duration></note><note><pitch><step>D</step><octave>4</octave></pitch><duration>48</duration></note></measure></part></score-partwise>" musicxml>score ]
unit-test

! grace notes are skipped
{ { { { { 0 62 384 } } } } }
[ "<score-partwise><part><measure><attributes><divisions>2</divisions></attributes><note><grace/><pitch><step>C</step><octave>4</octave></pitch></note><note><pitch><step>D</step><octave>4</octave></pitch><duration>2</duration></note></measure></part></score-partwise>" musicxml>score ]
unit-test

! forward moves the cursor without a note
{ { { { { 384 60 384 } } } } }
[ "<score-partwise><part><measure><attributes><divisions>2</divisions></attributes><forward><duration>2</duration></forward><note><pitch><step>C</step><octave>4</octave></pitch><duration>2</duration></note></measure></part></score-partwise>" musicxml>score ]
unit-test

! two parts become two voices
{ { { { { 0 60 384 } } } { { { 0 52 384 } } } } }
[ "<score-partwise><part><measure><attributes><divisions>2</divisions></attributes><note><pitch><step>C</step><octave>4</octave></pitch><duration>2</duration></note></measure></part><part><measure><attributes><divisions>2</divisions></attributes><note><pitch><step>E</step><octave>3</octave></pitch><duration>2</duration></note></measure></part></score-partwise>" musicxml>score ]
unit-test

! a standard MusicXML doctype is tolerated
{ { { { { 0 60 384 } } } } }
[ "<?xml version='1.0' encoding='UTF-8'?><!DOCTYPE score-partwise PUBLIC '-//Recordare//DTD MusicXML 4.0 Partwise//EN' 'http://www.musicxml.org/dtds/partwise.dtd'><score-partwise><part><measure><attributes><divisions>2</divisions></attributes><note><pitch><step>C</step><octave>4</octave></pitch><duration>2</duration></note></measure></part></score-partwise>" musicxml>score ]
unit-test
