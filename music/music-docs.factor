USING: help.markup help.syntax kernel math sequences ;
IN: music

HELP: note
{ $values { "ratio" "a frequency ratio (a number)" }
    { "dur" "a duration in beats (a number)" }
    { "note" "a note: a two-element array { ratio dur }" } }
{ $description "Builds a note from a pitch ratio and a duration. Pitches are just-intonation frequency ratios: 1 is the tonic, 9/8 a whole tone, 5/4 a just major third, 3/2 a perfect fifth, 2 an octave." } ;

HELP: pitch
{ $values { "note" "a note" } { "ratio" "the note's frequency ratio" } }
{ $description "Extracts a note's pitch ratio." } ;

HELP: dur
{ $values { "note" "a note" } { "dur" "the note's duration in beats" } }
{ $description "Extracts a note's duration." } ;

HELP: transpose-note
{ $values { "note" "a note" } { "ratio" "a frequency ratio" }
    { "note'" "the transposed note" } }
{ $description "Multiplies a note's pitch ratio by the given ratio, leaving its duration unchanged. The per-note helper behind " { $link up } "." } ;

HELP: stretch-note
{ $values { "note" "a note" } { "factor" "a number" }
    { "note'" "the stretched note" } }
{ $description "Multiplies a note's duration by the given factor, leaving its pitch unchanged. The per-note helper behind " { $link augment } "." } ;

HELP: seq
{ $values { "phrase" "a phrase (an array of notes)" }
    { "phrase'" "the two phrases concatenated" } }
{ $description "Plays two phrases one after another: the sequential composition of phrases." }
{ $examples
    { $example "USING: music prettyprint ;" "{ { 1 1 } } { { 3/2 1 } } seq ." "{ { 1 1 } { 1+1/2 1 } }" } } ;

HELP: par
{ $values { "phrase" "a phrase (an array of notes)" }
    { "voices" "an array of two phrases" } }
{ $description "Overlays two phrases as simultaneous voices: the parallel composition of phrases. Returns the two phrases as an array of voices." } ;

HELP: up
{ $values { "phrase" "a phrase" } { "ratio" "a frequency ratio" }
    { "phrase'" "the transposed phrase" } }
{ $description "Transposes every note of a phrase by the given ratio: 2 is an octave up, 3/2 a perfect fifth up, 1/2 an octave down." } ;

HELP: augment
{ $values { "phrase" "a phrase" } { "factor" "a number" }
    { "phrase'" "the phrase with scaled durations" } }
{ $description "Scales every duration in a phrase by the given factor: 2 is augmentation (twice as slow), 1/2 is diminution." } ;

HELP: retro
{ $values { "phrase" "a phrase" } { "phrase'" "the phrase reversed" } }
{ $description "Retrograde: plays a phrase backwards, reversing the order of its notes." } ;

HELP: freq-of
{ $values { "note" "a note" } { "base" "the frequency of ratio 1, in Hz" }
    { "freq" "the note's absolute frequency, in Hz" } }
{ $description "Converts a note's ratio to an absolute frequency for the given base frequency (for example 440 for A4)." } ;

HELP: total-dur
{ $values { "phrase" "a phrase" } { "dur" "the total duration in beats" } }
{ $description "The total length of a phrase in beats: the sum of its notes' durations." }
{ $examples
    { $example "USING: music prettyprint ;" "{ { 1 1 } { 3/2 2 } } total-dur ." "3" } } ;

HELP: freqs
{ $values { "phrase" "a phrase" } { "base" "the frequency of ratio 1, in Hz" }
    { "freqs" "an array of absolute frequencies, in Hz" } }
{ $description "The absolute frequencies of every note in a phrase, for the given base frequency. Ready to feed to a synthesizer." } ;

{ note pitch dur } related-words
{ seq par } related-words
{ up augment retro } related-words

ARTICLE: "music" "Factor Music Words: core combinators"
"The " { $vocab-link "music" } " vocabulary is the phrase model of Factor Music Words. A note is a two-element array { pitch-ratio duration-in-beats }, both exact rationals; a phrase is an array of notes. Pitches are just-intonation frequency ratios, so no 12-tone grid is assumed."
{ $subsections note pitch dur }
"Phrases are composed with musically meaningful combinators:"
{ $subsections seq par up augment retro }
"Measurements and rendering support:"
{ $subsections total-dur freq-of freqs }
"Per-note helpers:"
{ $subsections transpose-note stretch-note }
"Formatters that assemble whole pieces in fixed forms live in the " { $vocab-link "music.forms" } " vocabulary; automatic factorization lives in " { $vocab-link "music.optimize" } "." ;

ABOUT: "music"
