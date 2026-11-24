USING: help.markup help.syntax kernel math sequences ;
IN: music.optimize

HELP: segments
{ $values { "phrase" "a phrase (or any sequence)" } { "n" integer }
    { "segs" "an array of consecutive segments of n elements" } }
{ $description "Splits a phrase into consecutive segments of n notes (the last segment may be shorter). The unit of factorization for " { $link factor-phrase } "." } ;

HELP: factor-phrase
{ $values { "phrase" "a phrase" } { "n" integer }
    { "table" "the distinct segments, in order of first appearance" }
    { "indices" "the segment index at each position" } }
{ $description "Factorizes a phrase: splits it into segments of n notes and returns the table of distinct segments plus the index of the segment at each position — a compressed representation of the phrase. " { $link expand-phrase } " is its exact inverse." } ;

HELP: expand-phrase
{ $values { "table" "an array of segments" } { "indices" "an array of segment indices" }
    { "phrase" "the reconstructed phrase" } }
{ $description "Reconstructs a phrase from a segment table and indices, as produced by " { $link factor-phrase } "." }
{ $examples
    { $example "USING: music.optimize prettyprint ;" "{ { { 1 1 } } } { 0 } expand-phrase ." "{ { 1 1 } }" } } ;

HELP: emit-optimized
{ $values { "voices" "an array of voices; a voice is an array of bars; a bar is an array of { start midi dur } events" }
    { "names" "an array of voice names (strings)" }
    { "bar-ticks" "the length of a full bar, in ticks" }
    { "pickup" "the length of bar 0 (the pickup bar), in ticks" } }
{ $description "Prints a complete, factored Factor program for an event-model score: every distinct bar becomes a bar-N word, phrases of 8 bars are built from bar words with narray, repeated phrases are shared, and the voices are assembled with seq. The generated program's event output is identical to the unfactored score's. This automates the optimization of the Turkish March example: on that score it emits a 17,296-byte program, against 30,630 bytes unfactored." } ;

{ factor-phrase expand-phrase } related-words

ARTICLE: "music.optimize" "Factor Music Words: automatic optimization"
"The " { $vocab-link "music.optimize" } " vocabulary automates refactoring repeated musical material, at two levels."
"Phrase level — a phrase as a compressed table plus indices:"
{ $subsections segments factor-phrase expand-phrase }
"Score level — a whole event-model score printed as a factored program:"
{ $subsections emit-optimized } ;

ABOUT: "music.optimize"
