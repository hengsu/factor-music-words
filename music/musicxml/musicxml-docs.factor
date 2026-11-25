USING: help.markup help.syntax kernel sequences strings ;
IN: music.musicxml

HELP: musicxml>score
{ $values { "string" string } { "voices" sequence } }
{ $description "Parses a score-partwise MusicXML document from a string and converts it into the event model: one voice per part element, each voice an array of bars, each bar an array of { start midi dur } events in ticks (384 per quarter note; the file's divisions are scaled to that). Pitches are built from step, alter and octave; rests, chord notes, backup and forward elements and multiple voices within a part are handled; tied notes are merged into single events; grace notes are skipped." }
{ $examples
  { $example "USING: music.musicxml prettyprint ;" "\"<score-partwise><part><measure><attributes><divisions>2</divisions></attributes><note><pitch><step>C</step><octave>4</octave></pitch><duration>2</duration></note></measure></part></score-partwise>\" musicxml>score ." "{ { { { 0 60 384 } } } }" }
} ;

HELP: musicxml-file>score
{ $values { "path" string } { "voices" sequence } }
{ $description "Reads the MusicXML file at path and converts it with " { $link musicxml>score } "." } ;

ARTICLE: "music.musicxml" "Factor Music Words: MusicXML input"
"The " { $vocab-link "music.musicxml" } " vocabulary reads score-partwise MusicXML documents, on top of Factor's bundled " { $vocab-link "xml" } " vocabulary, and converts them into the bar-based event model used by the rest of Factor Music Words — the same model " { $vocab-link "music.midi" } " produces from MIDI files, so a score from either source can go straight to emit-optimized in " { $vocab-link "music.optimize" } "."
{ $subsections musicxml>score musicxml-file>score } ;

ABOUT: "music.musicxml"
