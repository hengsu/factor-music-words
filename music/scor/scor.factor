! Factor Music Words -- SCORE (PMX) input.
!
! Reads music in PMX, the ASCII form of the SCORE music
! typesetting format, and converts it into the event model used
! by the rest of Factor Music Words: one voice per staff, each
! voice an array of bars, each bar an array of { start midi dur }
! events in ticks (384 ticks per quarter note).
!
! SCORE data is graphical, not logical: an item's P3 is its
! horizontal position on the page (0-200), its P4 the diatonic
! staff position (bottom line = 3). Pitch is reconstructed from
! the staff position, the clef in force (code 3, P5: 0 treble,
! 1 bass, 2 alto, 3 tenor; default treble), the key signature
! (code 17, P5 = sharps > 0 or flats < 0) and the accidental in
! the note's P5 units digit (0 none, 1 flat, 2 sharp, 3 natural,
! 4 double flat, 5 double sharp; quarter-tone codes 6-9 are
! approximated as no accidental). Accidentals persist within
! the bar, as in ordinary notation. Start times are
! reconstructed from the order of distinct P3 positions within
! each bar: a position lasts as long as its longest note or
! rest (P7, in quarter notes; 65 and 0 are grace notes and are
! skipped). Bars are delimited by barlines (code 14) on any
! staff. Slurs (code 5) that join two notes of the same pitch
! at adjacent positions are read as ties and merged. Text
! items (lines starting with t, and the line that follows
! them), EPS items (code 15, also two lines), comments (#) and
! all other item codes are ignored. One rhythmic voice per
! staff is assumed; cross-staff notes (P12) keep the staff
! they are written on. A single PMX page is read; PPMX
! multi-page files are not split.
USING: arrays assocs combinators io.encodings.utf8 io.files
    kernel locals math math.functions math.order math.parser
    sequences sequences.extras sequences.generalizations sorting
    splitting strings ;
IN: music.scor

<PRIVATE

CONSTANT: ticks-per-quarter 384

! ---------- PMX lines ----------

! Parameters are 1-based in the SCORE documentation; (param)
! takes the 0-based index and reads missing parameters as 0.
:: (param) ( item n -- x )
    n item length < [ n item nth ] [ 0 ] if ;

: (code) ( item -- code ) 0 (param) >integer ;
: (staff) ( item -- staff ) 1 (param) >integer ;
: (hpos) ( item -- hpos ) 2 (param) ;

: (round3) ( x -- y ) 1000 * round >integer 1000 / ;
: (round2) ( x -- y ) 100 * round >integer 100 / ;

: (strip-cr) ( line -- line' )
    dup ?last 13 = [ but-last ] when ;

: (rest2) ( seq -- seq' )
    rest dup empty? [ ] [ rest ] if ;

! How to treat a PMX line: "item" (one line of numbers),
! "item2" (a code 15 item: the following line is skipped too),
! "skip" (blank, comment or non-numeric line), "skip2"
! (a text item: the following line is skipped too).
:: (line-kind) ( line -- kind )
    line split-words harvest :> tokens
    tokens empty? [ "skip" ]
    [ tokens first :> tok
      { { [ tok "#" head? ] [ "skip" ] }
        { [ tok "t" = ] [ "skip2" ] }
        { [ tokens [ string>number ] map [ number? ] all? ]
          [ tokens first string>number 15 =
            [ "item2" ] [ "item" ] if ] }
        [ "skip" ] } cond ] if ;

: (line>item) ( line -- item )
    split-words harvest [ string>number ] map ;

:: (collect-items) ( lines -- items )
    lines empty? [ { } ]
    [ lines first (strip-cr) :> line
      line (line-kind) {
        { "item"
          [ lines rest (collect-items) line (line>item) prefix ] }
        { "item2"
          [ lines (rest2) (collect-items) line (line>item) prefix ] }
        { "skip2" [ lines (rest2) (collect-items) ] }
        [ drop lines rest (collect-items) ] } case ] if ;

: (pmx-items) ( string -- items )
    string-lines (collect-items) ;

! ---------- pitch ----------

CONSTANT: step-base { 0 2 4 5 7 9 11 }
CONSTANT: sharp-order { 3 0 4 1 5 2 6 }
CONSTANT: flat-order { 6 2 5 1 4 0 3 }

! The accidental in a note's P5: the units digit of its
! integer part (hundreds = brackets, tens = stem direction,
! decimals = horizontal displacement of the accidental).
: (accidental-code) ( p5 -- code )
    abs floor >integer 100 mod 10 mod ;

! f means "no accidental written"; a natural is a real 0.
: (accidental-delta) ( code -- delta/f )
    { f -1 1 0 -2 2 f f f f } nth ;

:: (key-alteration) ( step fifths -- n )
    { { [ fifths 0 > ]
        [ step sharp-order fifths head member? [ 1 ] [ 0 ] if ] }
      { [ fifths 0 < ]
        [ step flat-order fifths neg head member? [ -1 ] [ 0 ] if ] }
      [ 0 ] } cond ;

! Clef code (code 3, P5) to the diatonic number of staff
! position 0. Diatonic numbers count C = 0 in each octave
! (middle C = 28) and staff position 3 is the bottom line:
! treble E4 = 30, bass G2 = 18, alto F3 = 24, tenor D3 = 22.
: (clef-offset) ( clef -- offset )
    { 27 15 21 19 } ?nth 27 or ;

! Vertical positions of grace/cue notes carry +/-100 offsets.
:: (normalize-vpos) ( v -- v' )
    v abs 100 >=
    [ v 0 > [ v 100 - ] [ v 100 + ] if (normalize-vpos) ]
    [ v ] if ;

! Truncated /mod adjusted to floored division by 7.
: (divmod7) ( d -- oct step )
    7 /mod dup 0 < [ [ 1 - ] dip 7 + ] when ;

! The sounding pitch of a note item: an accidental written on
! the note wins and is remembered in baracc (keyed by diatonic
! number) for the rest of the bar; otherwise the bar's earlier
! accidental for that pitch, else the key signature, applies.
:: (note-midi) ( item clef fifths baracc -- midi )
    item 3 (param) round >integer (normalize-vpos)
    clef (clef-offset) + :> d
    d (divmod7) :> ( oct step )
    item 4 (param) (accidental-code) (accidental-delta) :> written
    written
    [ written d baracc set-at written ]
    [ d baracc at [ step fifths (key-alteration) ] unless* ]
    if :> alt
    oct 1 + 12 * step step-base nth + alt + ;

: (dur>ticks) ( p7 -- ticks )
    ticks-per-quarter * round >integer ;

! ---------- staff walk ----------

: (priority) ( item -- n )
    (code) H{ { 3 0 } { 17 1 } { 5 2 } { 1 3 } { 2 3 } } at 3 or ;

: (sort-key) ( item -- key )
    [ (hpos) (round3) ] [ (priority) ] bi 2array ;

: (by-position) ( items -- items )
    [ [ (sort-key) ] keep 2array ] map sort [ second ] map ;

:: (bar-of) ( hpos bounds -- n )
    bounds [ hpos < ] count ;

! A record is { hpos bar midi/f dur }: midi f marks a rest.
! Ties are collected as { left-hpos right-hpos } pairs.
:: (walk) ( items bounds clef fifths baracc lastbar records ties -- records ties )
    items empty? [ records ties ]
    [ items first :> item
      item (hpos) (round3) :> h
      h bounds (bar-of) :> bar
      bar lastbar = [ baracc ] [ H{ } clone ] if :> baracc2
      item (code) {
        { 3 [ items rest bounds item 4 (param) >integer fifths
              baracc2 bar records ties (walk) ] }
        { 17 [ items rest bounds clef item 4 (param) >integer
               baracc2 bar records ties (walk) ] }
        { 5 [ items rest bounds clef fifths baracc2 bar records
              ties h item 5 (param) (round3) 2array suffix (walk) ] }
        { 1 [ items rest bounds clef fifths baracc2 bar
              item 6 (param) :> p7
              p7 0 = p7 65 = or [ records ]
              [ records h bar item clef fifths baracc2 (note-midi)
                p7 (dur>ticks) 4array suffix ] if
              ties (walk) ] }
        { 2 [ items rest bounds clef fifths baracc2 bar
              item 6 (param) :> p7
              p7 0 = [ records ]
              [ records h bar f p7 (dur>ticks) 4array suffix ] if
              ties (walk) ] }
        [ drop items rest bounds clef fifths baracc2 bar records
          ties (walk) ] } case ] if ;

! ---------- timing ----------

:: (dedupe) ( seq -- seq' )
    seq length 2 < [ seq ]
    [ seq rest (dedupe) :> rest'
      rest' first seq first = [ rest' ]
      [ rest' seq first prefix ] if ] if ;

:: (max-dur) ( records pos -- dur )
    records [ first pos = ] filter [ fourth ] map 0 [ max ] reduce ;

:: (record>event) ( record start pos -- event )
    start record third record fourth pos 4array ;

! The bar's events as { start midi dur hpos } and its total
! length in ticks, as one { events barlen } pair.
:: (bar-events) ( records -- data )
    records [ first ] map (dedupe) :> positions
    positions empty? [ { } 0 2array ]
    [ positions [ records swap (max-dur) ] map :> maxdurs
      maxdurs 0 [ + ] accumulate nip :> starts
      positions starts zip
      [ first2 :> ( pos start )
        records [ first pos = ] filter [ third ] filter
        [ start pos (record>event) ] map ] map concat
      starts last maxdurs last + 2array ] if ;

:: (bar-records) ( records bar -- records' )
    records [ second bar = ] filter ;

:: (tie-target?) ( ev a r -- ? )
    4 ev nth r - abs 0.011 <=
    ev third a third =
    ev second a second a fourth + = and and ;

: (remove-index) ( seq i -- seq' )
    [ head ] [ 1 + tail ] 2bi append ;

:: (try-ties) ( events tie ais -- events )
    ais empty? [ events ]
    [ ais first events nth :> a
      events [ a tie second (tie-target?) ] map t swap index :> bi
      bi [ events clone :> evs
           a first a second a third
           a fourth bi evs nth fourth + 4 a nth 5 narray
           ais first evs set-nth
           evs bi (remove-index) ]
      [ events tie ais rest (try-ties) ] if ] if ;

:: (apply-tie) ( events tie -- events )
    events length <iota>
    [ events nth 4 swap nth tie first - abs 0.011 <= ] filter :> ais
    events tie ais (try-ties) ;

:: (apply-ties) ( events ties -- events )
    ties empty? [ events ]
    [ events ties first (apply-tie) ties rest (apply-ties) ] if ;

! Bars of { start midi dur } events from one staff's records:
! starts are made absolute to merge ties across barlines,
! then split back into bars.
:: (records>voice) ( records ties -- bars )
    records empty? [ { } ]
    [ records [ second ] map :> barnums
      barnums first :> minbar
      barnums last :> maxbar
      maxbar minbar - 1 + <iota> [ minbar + ] map :> barseq
      barseq [ records swap (bar-records) (bar-events) ] map :> bardata
      bardata [ second ] map 0 [ + ] accumulate nip :> offsets
      bardata
      [| data i |
        data first
        [| ev | i barseq nth ev first i offsets nth +
          ev second ev third ev fourth 5 narray ] map ]
      map-index concat ties (apply-ties) :> merged
      barseq [| bar |
        merged [ first bar = ] filter
        [| ev | ev second bar minbar - offsets nth -
          ev third ev fourth 3array ] map ] map ] if ;

! ---------- top level ----------

: (bar-boundaries) ( items -- seq )
    [ (code) 14 = ] filter [ (hpos) (round2) ] map sort (dedupe) ;

:: (staff-items) ( items staff -- items' )
    items
    [ [ (staff) staff = ]
      [ (code) { 1 2 3 5 17 } member? ] bi and ] filter ;

PRIVATE>

:: scor>score ( string -- voices )
    string (pmx-items) :> items
    items (bar-boundaries) :> bounds
    items [ (code) { 1 2 3 17 } member? ] filter [ (staff) ] map
    sort (dedupe) :> staves
    staves [ items swap (staff-items) (by-position) bounds
             0 0 H{ } clone f { } { } (walk) (records>voice) ] map ;

: scor-file>score ( path -- voices )
    utf8 file-contents scor>score ;
