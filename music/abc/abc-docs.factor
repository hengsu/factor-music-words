USING: help.markup help.syntax kernel sequences strings ;
IN: music.abc

HELP: abc>score
{ $values { "string" string } { "voices" sequence } }
{ $description "Parses a tune in ABC notation from a string and converts it into the event model: one voice per V: voice, each voice an array of bars, each bar an array of { start midi dur } events in ticks (384 per quarter note). Header fields X: T: M: are read and ignored except L: (default note length) and K: (key signature: major, minor and the dorian, mixolydian, lydian, phrygian and locrian modes). Accidentals (^ _ = ^^ __) persist within the bar, as in standard ABC; note lengths are numbers and fractions of the L: unit; rests, chords, ties, tuplets, broken rhythm (> and <) are handled; grace notes, quoted chord symbols and decorations are skipped. Repeat barlines are expanded, honouring first and second endings, and [K:...] fields change the key mid-tune." }
{ $examples
  { $example "USING: music.abc prettyprint ;" "\"L:1/4\\nK:C\\nC |\\n\" abc>score ." "{ { { { 0 60 384 } } } }" }
} ;

HELP: abc-file>score
{ $values { "path" string } { "voices" sequence } }
{ $description "Reads the ABC file at path (UTF-8) and converts it with " { $link abc>score } "." } ;

ARTICLE: "music.abc" "Factor Music Words: ABC notation input"
"The " { $vocab-link "music.abc" } " vocabulary reads tunes in ABC notation (the text format of abcnotation.com) and converts them into the bar-based event model used by the rest of Factor Music Words — the same model " { $vocab-link "music.midi" } " produces from MIDI files and " { $vocab-link "music.musicxml" } " from MusicXML, so a tune from any source can go straight to emit-optimized in " { $vocab-link "music.optimize" } ". Unlike the other two inputs, repeats are performed: |: :| sections are expanded, with first and second endings, before the bars are built."
{ $subsections abc>score abc-file>score } ;

ABOUT: "music.abc"
