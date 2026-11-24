USING: help.markup help.syntax kernel math music sequences ;
IN: music.forms

HELP: rest-note
{ $values { "dur" "a duration in beats (a number)" }
    { "note" "a rest: a note whose pitch is f" } }
{ $description "Builds a rest of the given duration. A rest is a note whose pitch is " { $snippet "f" } "; renderers skip it, but its duration still advances the voice's clock." } ;

HELP: rest-note?
{ $values { "note" "a note" } { "?" "a boolean" } }
{ $description "Tests whether a note is a rest (its pitch is " { $snippet "f" } ")." } ;

HELP: delay-by
{ $values { "phrase" "a phrase" } { "beats" "a duration in beats (a number)" }
    { "phrase'" "the phrase, preceded by a rest" } }
{ $description "Delays a phrase's entry by the given number of beats, by prepending a rest. A delay of zero returns the phrase unchanged." } ;

HELP: rep
{ $values { "phrase" "a phrase" } { "n" integer }
    { "phrase'" "the phrase repeated n times" } }
{ $description "Repeats a phrase n times in sequence." } ;

HELP: canon
{ $values { "phrase" "a phrase" } { "delay" "the entry delay in beats (a number)" }
    { "interval" "the transposition ratio between successive voices" }
    { "n" integer } { "voices" "an array of n phrases" } }
{ $description "Strict imitation: voice k is the phrase transposed by interval^k and delayed by k times the delay. An interval of 1 gives a canon at the unison (a round); 3/2 gives a canon at the fifth; 2 at the octave." }
{ $examples
    { $example "USING: music music.forms prettyprint ;" "{ { 1 1 } } 2 1 2 canon ." "{ { { 1 1 } } { { f 2 } { 1 1 } } }" } } ;

HELP: rondo
{ $values { "refrain" "a phrase" } { "episodes" "an array of phrases" }
    { "phrase" "the assembled rondo" } }
{ $description "Assembles a rondo: the refrain returns after every episode. Episodes { B C } give ABACA; { B C B } give ABACABA (sonata rondo); no episodes give the refrain alone." }
{ $examples
    { $example "USING: music music.forms prettyprint ;" "{ { 1 1 } } { { { 2 1 } } } rondo ." "{ { 1 1 } { 2 1 } { 1 1 } }" } } ;

HELP: ternary
{ $values { "a" "a phrase" } { "b" "a phrase" }
    { "phrase" "the assembled ABA form" } }
{ $description "Ternary form: statement, contrast, return (da capo) — A B A." } ;

HELP: binary
{ $values { "a" "a phrase" } { "b" "a phrase" }
    { "phrase" "the assembled AABB form" } }
{ $description "Binary form: two sections, each repeated — A A B B." } ;

HELP: variations
{ $values { "theme" "a phrase" }
    { "quots" "an array of quotations with stack effect ( phrase -- phrase )" }
    { "phrase" "the theme followed by its variations" } }
{ $description "Theme and variations: the theme, followed by the theme transformed by each quotation in turn. The quotations are typically combinators such as retrograde or transposition." } ;

HELP: ostinato
{ $values { "bass" "a short phrase" } { "melody" "a phrase" }
    { "voices" "an array of two phrases" } }
{ $description "A ground bass, as in a passacaglia or chaconne: the bass is repeated as many times as its length needs to cover the melody, and the two are overlaid as voices with " { $link par } "." } ;

HELP: steps
{ $values { "phrase" "a phrase" } { "step" "a transposition ratio" }
    { "n" integer } { "phrase'" "the assembled sequence" } }
{ $description "A melodic sequence: the phrase repeated n times, the k-th repetition transposed by step^k." } ;

{ canon rondo ternary binary variations ostinato steps } related-words
{ rest-note rest-note? delay-by } related-words

ARTICLE: "music.forms" "Factor Music Words: formatters for fixed forms"
"The " { $vocab-link "music.forms" } " vocabulary provides formatters: higher-order combinators that assemble complete pieces in classical fixed forms from thematic material, on top of the phrase model of the " { $vocab-link "music" } " vocabulary."
{ $subsections canon rondo ternary binary variations ostinato steps rep }
"Rests and delayed entries, which the formatters are built on:"
{ $subsections rest-note rest-note? delay-by } ;

ABOUT: "music.forms"
