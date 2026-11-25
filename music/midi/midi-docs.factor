USING: help.markup help.syntax kernel math sequences strings ;
IN: music.midi

HELP: track>notes
{ $values { "track" "a midi-track" } { "notes" sequence } }
{ $description "Converts one track of a parsed MIDI file into note events of the form { start midi dur }, with absolute ticks and durations in ticks, sorted by start time. Note-on events with velocity 0 count as note-offs; overlapping notes of one pitch are paired first-in first-out; notes still open at the end of the track are dropped." } ;

HELP: midi>voices
{ $values { "midi" "a midi" } { "voices" sequence } }
{ $description "Converts every track of a parsed MIDI file with " { $link track>notes } ", yielding one note array per track. Tracks without notes, such as the conductor track of a format 1 file, yield empty arrays." } ;

HELP: midi>division
{ $values { "midi" "a midi" } { "division" integer } }
{ $description "The file's division: ticks per quarter note, as recorded in its header." } ;

HELP: file>voices
{ $values { "path" string } { "voices" sequence } }
{ $description "Reads the Standard MIDI File at path and converts it with " { $link midi>voices } "." } ;

HELP: events>bars
{ $values { "notes" sequence } { "bar-ticks" integer } { "pickup" integer } { "bars" sequence } }
{ $description "Groups absolute-tick notes into bars. Bar 0 is the pickup bar of pickup ticks; the following bars are bar-ticks long. Each note's start becomes relative to its bar, silent bars are kept as empty arrays, and an empty note array yields an empty bar array. This is the event model of the Turkish March example and of emit-optimized in music.optimize." }
{ $examples
  { $example "USING: music.midi prettyprint ;" "{ { 0 60 384 } { 384 62 384 } { 1152 64 384 } } 768 384 events>bars ." "{ { { 0 60 384 } } { { 0 62 384 } } { { 0 64 384 } } }" }
} ;

HELP: file>score
{ $values { "path" string } { "bar-ticks" integer } { "pickup" integer } { "voices" sequence } }
{ $description "Reads the Standard MIDI File at path and returns its voices already grouped into bars by " { $link events>bars } ": a complete score in the event model, ready for emit-optimized in music.optimize." } ;

ARTICLE: "music.midi" "Factor Music Words: MIDI input"
"The " { $vocab-link "music.midi" } " vocabulary is a conversion layer on top of Factor's bundled " { $vocab-link "midi" } " vocabulary, which parses Standard MIDI Files into delta-timed tuple events. These words turn them into the array models used by the rest of Factor Music Words:"
{ $subsections track>notes midi>voices midi>division file>voices }
"Grouping absolute-tick notes into the bar-based event model:"
{ $subsections events>bars file>score } ;

ABOUT: "music.midi"
