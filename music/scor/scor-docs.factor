USING: help.markup help.syntax kernel sequences strings ;
IN: music.scor

HELP: scor>score
{ $values { "string" string } { "voices" sequence } }
{ $description "Parses one page of PMX, the ASCII form of SCORE data, from a string and converts it into the event model: one voice per staff (SCORE numbers staves from the bottom, so voice 1 is the bottom staff), each voice an array of bars, each bar an array of { start midi dur } events in ticks (384 per quarter note). SCORE data is graphical, so pitch and time are reconstructed: pitch from the diatonic staff position (P4, bottom line = 3), the clef in force (code 3, P5: 0 treble, 1 bass, 2 alto, 3 tenor; default treble), the key signature (code 17, P5 = number of sharps or, if negative, flats) and the accidental in the note's P5 units digit (1 flat, 2 sharp, 3 natural, 4 double flat, 5 double sharp; quarter-tone codes 6-9 are approximated as no accidental), with accidentals persisting within the bar. Start times come from the order of distinct horizontal positions (P3) within each bar: a position lasts as long as its longest note or rest (P7, in quarter notes). Grace notes (P7 = 65 or 0) are skipped, slurs (code 5) joining two notes of the same pitch at adjacent positions are merged as ties, and text items, EPS items, comments and all other item codes are ignored. One rhythmic voice per staff is assumed." }
{ $examples
  { $example "USING: music.scor prettyprint ;" "\"1 1 10 1 10 0 1\\n\" scor>score ." "{ { { { 0 60 384 } } } }" }
} ;

HELP: scor-file>score
{ $values { "path" string } { "voices" sequence } }
{ $description "Reads the PMX file at path (UTF-8) and converts it with " { $link scor>score } "." } ;

ARTICLE: "music.scor" "Factor Music Words: SCORE (PMX) input"
"The " { $vocab-link "music.scor" } " vocabulary reads PMX, the text form of SCORE data, and converts it into the bar-based event model used by the rest of Factor Music Words — the same model " { $vocab-link "music.midi" } " produces from MIDI files, " { $vocab-link "music.musicxml" } " from MusicXML and " { $vocab-link "music.abc" } " from ABC notation. Of the four inputs this one needs the most reconstruction, because SCORE describes a printed page, not musical time: a note is a horizontal position (P3, 0-200 across the page), a diatonic staff position (P4) and a logical duration (P7). The vocabulary rebuilds pitch from staff position, clef, key signature and accidentals, and rebuilds time from the order of positions within each bar."
{ $heading "About SCORE" }
"SCORE was created by Leland Smith at Stanford University. It began in 1967 as an input language for the MUSIC V synthesis system, grew into the MSS typesetting program in the 1970s (Smith's Six Bagatelles for Piano, printed in 1971, was the first complete work typeset entirely by computer), and became a commercial product for MS-DOS in 1987. Version 4 followed in 1998 and the Windows version, WinScore, reached its final release, 5.01, in 2013, the year of Smith's death. For decades SCORE was the tool behind a large share of the world's finest commercial music engraving — Schott and other publishers used it for their editions — and research centres, above all CCARH at Stanford, hold very large corpora engraved in it, including complete scholarly editions."
{ $heading "Why SCORE data is still useful" }
"Those corpora are the reason to read SCORE today: thousands of professionally edited scores survive only as SCORE files. The format is openly documented and PMX is plain text, but because the data is graphical it stayed hard to reuse — you could print the page, yet not easily play, search or analyse the music. Converting a page into the event model removes that barrier: the same music can then be analysed, played back, compared, re-factored with " { $vocab-link "music.optimize" } ", or carried onward to any other format, exactly like a MIDI, MusicXML or ABC source."
{ $heading "Using SCORE data today" }
"To get PMX from a SCORE page, use the PMX command of the SCORE editor itself, or convert binary .MUS/.PAG files with scorelib, Craig Sapp's open-source library. Then, in Factor: read the page with " { $link scor-file>score } ", sanity-check the bars and events it returns, and feed the result to emit-optimized in " { $vocab-link "music.optimize" } " to obtain a compact, factored Factor program for the piece — a good archival form, since it is small, readable and regenerates the events exactly. Flattened bars also serve directly for playback, pitch and rhythm statistics, or as material for the phrase combinators in " { $vocab-link "music.forms" } ". Keep the subset in mind when choosing source material: one rhythmic voice per staff converts cleanly (single-staff parts and most chamber music), while dense multi-voice staves and multi-page PPMX files need splitting or manual repair first."
{ $subsections scor>score scor-file>score } ;

ABOUT: "music.scor"
