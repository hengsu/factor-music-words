! Factor Music Words -- ABC notation input.
!
! Reads tunes in ABC notation (abcnotation.com) and converts
! them into the event model used by the rest of Factor Music
! Words: one voice per V: voice, each voice an array of bars,
! each bar an array of { start midi dur } events in ticks
! (384 ticks per quarter note).
!
! Supported: header fields X: T: M: L: K: V: (other fields are
! ignored), key signatures for the major, minor, dorian,
! mixolydian, lydian, phrygian and locrian modes, accidentals
! (^ _ = ^^ __) with the usual bar-local persistence, note
! lengths as numbers and fractions, rests (z, x), chords [CEG],
! ties (-), tuplets (3, (3:2:3, ...), broken rhythm (> and <),
! grace notes {..} (skipped), quoted chord symbols (skipped),
! decorations (!..!, ~, .), repeat barlines |: :| :: with
! first/second endings [1 [2 (repeats are expanded), and
! [K:...] key changes in the body. L: is read from the header;
! [V:...] inline voice changes and nested repeats are not
! supported.
USING: accessors arrays ascii assocs combinators io.encodings.utf8
    io.files kernel locals math math.functions math.order
    math.parser
    sequences sequences.extras sequences.generalizations sorting
    splitting
    strings ;
IN: music.abc

<PRIVATE
! ---------- key signatures ----------
CONSTANT: step-base H{
    { "C" 0 } { "D" 2 } { "E" 4 } { "F" 5 }
    { "G" 7 } { "A" 9 } { "B" 11 }
}
CONSTANT: sharp-order { "F" "C" "G" "D" "A" "E" "B" }
CONSTANT: flat-order { "B" "E" "A" "D" "G" "C" "F" }
CONSTANT: major-fifths H{
    { 0 0 } { 7 1 } { 2 2 } { 9 3 } { 4 4 } { 11 5 } { 6 6 }
    { 5 -1 } { 10 -2 } { 3 -3 } { 8 -4 } { 1 -5 }
}

:: (fifths-key) ( n -- assoc )
    H{ } clone :> sig
    n 0 >=
    [ sharp-order n head [ 1 swap sig set-at ] each ]
    [ flat-order n neg head [ -1 swap sig set-at ] each ] if
    sig ;

! mode offsets: parent major tonic = tonic + offset (mod 12)
:: (key-parse) ( str -- assoc )
    str first 1string :> step
    str length 1 >
    [ str second CHAR: # = str second CHAR: b = or ] [ f ] if
    :> has-acc
    has-acc [ str second CHAR: # = [ 1 ] [ -1 ] if ] [ 0 ] if
    :> acc
    has-acc [ 2 ] [ 1 ] if :> start
    start str length str subseq :> mode
    step step-base at acc + :> tonic
    mode
    { { "" [ 0 ] } { "m" [ 3 ] } { "min" [ 3 ] }
      { "dor" [ 10 ] } { "mix" [ 5 ] } { "lyd" [ 2 ] }
      { "phr" [ 8 ] } { "loc" [ 1 ] } [ drop 0 ] } case :> offset
    tonic offset + 12 mod major-fifths at :> fifths
    acc -1 = fifths 6 = and [ -6 ] [ fifths ] if (fifths-key) ;

:: (parse-fraction) ( str -- n )
    str "/" split dup length 1 =
    [ first string>number 0 or ]
    [ first2 [ string>number 0 or ] bi@ / ] if ;

! ---------- line stage: split the text into per-voice bodies ----------
:: (field-line?) ( line -- ? )
    line length 2 >=
    [ line first [ letter? ] [ Letter? ] bi or
      line second CHAR: : = and ] [ f ] if ;

:: (append-text) ( st id text -- )
    id "buffers" st at [ text append ] change-at ;

:: (ensure-voice) ( st id -- )
    id "buffers" st at key? [
        id "order" st at push
        "" id "buffers" st at set-at
    ] unless ;

:: (line-step) ( st line -- )
    line "%" split first [ " \t" member? ] trim :> text
    text empty? [ ] [
        text (field-line?) [
            text first 1string :> name
            2 text length text subseq [ " \t" member? ] trim
            :> value
            name "V" = [
                value " " split first :> id
                st id (ensure-voice)
                "cur" st at f =
                [ id "cur" st set-at ] when
                "started" st at [ id "cur" st set-at ] when
            ] [
            name "L" = [
                value (parse-fraction) "unit" st set-at
            ] [
            name "K" = [
                "started" st at [
                    "cur" st at [ ] [
                        "1" "cur" st set-at st "1" (ensure-voice)
                    ] if
                    "cur" st at :> id
                    st id "[K:" value append "]" append
                    (append-text)
                ] [
                    value (key-parse) "key" st set-at
                ] if
            ] [ ] if ] if ] if
        ] [
            t "started" st set-at
            "cur" st at [ ] [
                "1" "cur" st set-at st "1" (ensure-voice)
            ] if
            st "cur" st at text (append-text)
            st "cur" st at " " (append-text)
        ] if
    ] if ;

:: (split-voices) ( string -- data )
    H{ } clone :> st
    V{ } clone "order" st set-at
    H{ } clone "buffers" st set-at
    f "cur" st set-at
    1/8 "unit" st set-at
    0 (fifths-key) "key" st set-at
    f "started" st set-at
    string "\\\r\n" "" replace "\\\n" "" replace
    split-lines [ st swap (line-step) ] each
    "order" st at [
        "buffers" st at at
        "unit" st at "key" st at 3array
    ] map ;
PRIVATE>

! ---------- tokenizer ----------
:: (peek) ( st -- char/f )
    "s" st at :> s "i" st at :> i
    i s length < [ i s nth ] [ f ] if ;

:: (peek2) ( st -- char/f )
    "s" st at :> s "i" st at 1 + :> i
    i s length < [ i s nth ] [ f ] if ;

:: (peek-is?) ( st char -- ? )
    st (peek) char = ;

:: (bump) ( st -- )
    "i" st [ 1 + ] change-at ;

:: (take) ( st -- char/f )
    st (peek) dup [ st (bump) ] when ;

:: (digit?) ( ch -- ? )
    ch CHAR: 0 >= ch CHAR: 9 <= and ;

:: (read-digits) ( st -- string )
    V{ } clone :> acc
    [ st (peek) :> c c [ c (digit?) ] [ f ] if ]
    [ st (take) acc push ] while
    acc >string ;

:: (read-number) ( st -- n )
    st (read-digits) string>number 0 or ;

:: (read-length) ( st -- len )
    st (read-digits) :> n
    st CHAR: / (peek-is?) [
        st (bump)
        st (read-digits) :> d
        n string>number 1 or d string>number 2 or /
    ] [
        n empty? [ 1 ] [ n string>number ] if
    ] if ;

:: (read-accidentals) ( st -- string )
    V{ } clone :> acc
    [ st (peek) "^_=" member? ] [ st (take) acc push ] while
    acc >string ;

:: (count-char) ( st mc -- n )
    V{ } clone :> acc
    [ st mc (peek-is?) ] [ st (bump) 1 acc push ] while
    acc length ;

:: (read-pitch) ( st -- step octave alter )
    st (read-accidentals) :> accs
    st (take) :> ch
    ch CHAR: a >= [ ch 32 - 5 ] [ ch 4 ] if :> ( stepch base )
    base st CHAR: ' (count-char) + st CHAR: , (count-char) -
    :> octave
    accs [ CHAR: ^ = ] count :> sharps
    accs [ CHAR: _ = ] count :> flats
    accs [ CHAR: = = ] any? :> nat
    stepch 1string octave
    nat [ 0 ] [ accs empty? [ f ] [ sharps flats - ] if ] if ;

:: (note-flags) ( st -- flags )
    "tie" st at [ 1 ] [ 0 ] if f "tie" st set-at ;

:: (read-note) ( st -- )
    st (read-pitch) :> ( step octave alter )
    st (read-length) :> len
    "note" step octave alter len st (note-flags) 6 narray
    "tokens" st at push ;

:: (read-rest) ( st -- )
    st (bump)
    st (read-length) :> len
    f "tie" st set-at
    "rest" len 2array "tokens" st at push ;

:: (read-chord) ( st -- )
    st (bump)
    V{ } clone :> pitches
    [ st (peek) :> c c [ c CHAR: ] = not ] [ f ] if ] [
        st (peek) " \t\n\r" member?
        [ st (bump) ]
        [ st (peek) "^_=" member?
          st (peek) "ABCDEFGabcdefg" member? or
          [ st (read-pitch) 3array pitches push
            st (read-length) drop ]
          [ st (bump) ] if ] if
    ] while
    st (bump)
    st (read-length) :> len
    "chord" pitches >array len st (note-flags) 4array
    "tokens" st at push ;

:: (tie-mark) ( st -- )
    "tokens" st at :> toks
    toks empty? [ ] [
        toks length 1 - toks nth :> last
        last first "note" = [ 5 ]
        [ last first "chord" = [ 3 ] [ f ] if ] if :> idx
        idx [ idx last nth 2 bitor idx last set-nth ] when
    ] if
    t "tie" st set-at ;

:: (bar-token-push) ( st kind -- )
    "bar" kind 2array "tokens" st at push ;

:: (bar-after-pipe) ( st -- )
    st (bump)
    st CHAR: : (peek-is?) [ st (bump) st "start" (bar-token-push) ] [
    st CHAR: ] (peek-is?) [ st (bump) st "plain" (bar-token-push) ] [
    st CHAR: | (peek-is?) [ st (bump) st "plain" (bar-token-push) ] [
    st "plain" (bar-token-push) ] if ] if ] if ;

:: (bar-after-colon) ( st -- )
    st (bump)
    st CHAR: | (peek-is?) [ st (bump) st "end" (bar-token-push) ] [
    st CHAR: : (peek-is?) [ st (bump) st "both" (bar-token-push) ] [
    ] if ] if ;

:: (bracket) ( st -- )
    st (peek2) :> c2
    c2 [ c2 (digit?) ] [ f ] if [
        st (bump) st (read-number) "ending" swap 2array
        "tokens" st at push
    ] [
    c2 CHAR: | = [
        st (bump) st (bump) st "plain" (bar-token-push)
    ] [
        "s" st at "i" st at 1 + tail :> rest
        CHAR: ] rest index :> j
        j [
            rest j head :> content
            content length 2 >=
            [ content second CHAR: : = ] [ f ] if [
                "i" st [ j + 2 + ] change-at
                content first CHAR: K = [
                    2 content length content subseq (key-parse)
                    "key" swap 2array "tokens" st at push
                ] when
            ] [ st (read-chord) ] if
        ] [ st (read-chord) ] if
    ] if ] if ;

:: (open-paren) ( st -- )
    st (peek2) :> c2
    c2 [ c2 (digit?) ] [ f ] if [
        st (bump) st (read-number) :> p
        st CHAR: : (peek-is?) [ st (bump) st (read-number) ]
        [ 0 ] if :> q
        st CHAR: : (peek-is?) [ st (bump) st (read-number) ]
        [ 0 ] if :> r
        "tuplet" p q r 4array "tokens" st at push
    ] [ st (bump) ] if ;

:: (skip-to) ( st char -- )
    st (bump)
    [ st char (peek-is?) not st (peek) and ] [ st (bump) ] while
    st (bump) ;

:: (token-step) ( st -- )
    st (peek) :> c
    c " \t\n\r" member? [ st (bump) ] [
    c CHAR: % = [
        [ st (peek) dup f = not swap CHAR: \n = not and ]
        [ st (bump) ] while ] [
    c "^_=" member? c "ABCDEFGabcdefg" member? or
    [ st (read-note) ] [
    c "zxZ" member? [ st (read-rest) ] [
    c CHAR: [ = [ st (bracket) ] [
    c CHAR: | = [ st (bar-after-pipe) ] [
    c CHAR: : = [ st (bar-after-colon) ] [
    c CHAR: - = [ st (bump) st (tie-mark) ] [
    c CHAR: ( = [ st (open-paren) ] [
    c CHAR: ) = [ st (bump) ] [
    c CHAR: { = [ st CHAR: } (skip-to) ] [
    c CHAR: ! = [ st CHAR: ! (skip-to) ] [
    c 34 = [ st 34 (skip-to) ] [
    c CHAR: > = [ st (bump) "gt" 1array "tokens" st at push ] [
    c CHAR: < = [ st (bump) "lt" 1array "tokens" st at push ] [
    c ".~y" member? [ st (bump) ] [
    st (bump) ] if ] if ] if ] if ] if ] if ] if ] if ] if ] if
    ] if ] if ] if ] if ] if ] if ;

:: (tokenize) ( string -- tokens )
    H{ } clone :> st
    string "s" st set-at
    0 "i" st set-at
    V{ } clone "tokens" st set-at
    f "tie" st set-at
    [ st (peek) ] [ st (token-step) ] while
    "tokens" st at >array ;

! ---------- parser: tokens -> bars of rational-tick events ----------
:: (resolve-alter) ( st step octave alter -- alter' )
    alter [ alter ] [
        step octave 2array "barmap" st at at :> frombar
        frombar [ frombar ]
        [ step "key" st at at 0 or ] if
    ] if ;

:: (length-of) ( st toklen -- ticks )
    ! only note/chord/rest tokens call this: the bar now has content
    f "fresh" st set-at
    "unit" st at toklen *
    "tup-left" st at 0 > [ "tup-factor" st at ] [ 1 ] if *
    "broken" st at * ;

:: (tup-tick) ( st -- )
    "tup-left" st at dup 0 > [ 1 - "tup-left" st set-at ]
    [ drop ] if ;

:: (note-token) ( st tok -- )
    1 tok nth :> step
    2 tok nth :> octave
    3 tok nth :> alter
    st step octave alter (resolve-alter) :> eff
    alter [ eff step octave 2array "barmap" st at set-at ] when
    octave 1 + 12 * step step-base at + eff + :> midi
    st 4 tok nth (length-of) :> len
    st (tup-tick)
    "cursor" st at :> start
    start midi len 5 tok nth 4array "events" st at push
    "events" st at length 1 - 1array start len 3array
    "last" st set-at
    start len + "cursor" st set-at
    start len + "maxend" st at max "maxend" st set-at
    1 "broken" st set-at ;

:: (chord-token) ( st tok -- )
    st 2 tok nth (length-of) :> len
    st (tup-tick)
    "cursor" st at :> start
    1 tok nth [| p |
        1 p nth :> octave
        2 p nth :> alter
        st 0 p nth octave alter (resolve-alter) :> eff
        alter [ eff 0 p nth octave 2array "barmap" st at set-at ]
        when
        "events" st at length :> idx
        start octave 1 + 12 * 0 p nth step-base at + eff +
        len 3 tok nth 4array "events" st at push
        idx
    ] map :> idxs
    idxs start len 3array "last" st set-at
    start len + "cursor" st set-at
    start len + "maxend" st at max "maxend" st set-at
    1 "broken" st set-at ;

:: (rest-token) ( st tok -- )
    st 1 tok nth (length-of) :> len
    st (tup-tick)
    "cursor" st at len + "cursor" st set-at
    "cursor" st at "maxend" st at max "maxend" st set-at
    f "last" st set-at
    1 "broken" st set-at ;

:: (broken-token) ( st gt? -- )
    "last" st at :> last
    last [
        gt? [ 3/2 1/2 ] [ 1/2 3/2 ] if :> ( f1 f2 )
        last first :> idxs
        last second :> lstart
        last third :> llen
        idxs [| idx |
            idx "events" st at nth :> ev
            ev first ev second ev third f1 * 3 ev nth 4array
            idx "events" st at set-nth
        ] each
        llen f1 1 - * "cursor" st at + "cursor" st set-at
        lstart llen f1 * + "maxend" st at max "maxend" st set-at
        f2 "broken" st set-at
        f "last" st set-at
    ] when ;

CONSTANT: tuplet-q H{
    { 2 3 } { 3 2 } { 4 3 } { 6 2 } { 8 3 } { 9 2 } { 12 2 }
}

:: (tuplet-token) ( st tok -- )
    1 tok nth :> p
    2 tok nth dup 0 = [ drop p tuplet-q at 2 or ] when :> q
    3 tok nth dup 0 = [ drop p ] when :> r
    q p / "tup-factor" st set-at
    r "tup-left" st set-at ;

:: (round-event) ( ev -- ev' )
    ev first round ev second ev third round 3 ev nth 4array ;

:: (bar-token) ( st tok -- )
    1 tok nth :> kind
    "events" st at empty? "fresh" st at and [
        ! consecutive barline: no new bar; a repeat end here
        ! belongs to the previous bar instead
        kind "end" = kind "both" = or [
            "bars" st at empty? [ ] [
                "bars" st at length 1 - "bars" st at nth :> prev
                t 2 prev set-nth
                "ending" st at dup 0 >
                [ 3 prev set-nth ] [ drop ] if
            ] if
        ] when
        kind "start" = kind "both" = or "nextstart" st set-at
        H{ } clone "barmap" st set-at
        0 "ending" st set-at
    ] [
    "events" st at [ (round-event) ] map
    "maxend" st at round
    kind "end" = kind "both" = or
    "ending" st at
    "nextstart" st at
    5 narray "bars" st at push
    V{ } clone "events" st set-at
    0 "cursor" st set-at
    0 "maxend" st set-at
    H{ } clone "barmap" st set-at
    0 "ending" st set-at
    f "last" st set-at
    1 "broken" st set-at
    0 "tup-left" st set-at
    t "fresh" st set-at
    kind "start" = kind "both" = or "nextstart" st set-at
    ] if ;

:: (token-parse) ( st tok -- )
    tok first :> kind
    kind "note" = [ st tok (note-token) ] [
    kind "chord" = [ st tok (chord-token) ] [
    kind "rest" = [ st tok (rest-token) ] [
    kind "gt" = [ st t (broken-token) ] [
    kind "lt" = [ st f (broken-token) ] [
    kind "tuplet" = [ st tok (tuplet-token) ] [
    kind "key" = [
        1 tok nth "key" st set-at
        H{ } clone "barmap" st set-at ] [
    kind "ending" = [ 1 tok nth "ending" st set-at ] [
    kind "bar" = [ st tok (bar-token) ] [
    ] if ] if ] if ] if ] if ] if ] if ] if ] if ;

:: (parse-voice) ( data -- bars )
    data first (tokenize) :> tokens
    H{ } clone :> st
    data third "key" st set-at
    H{ } clone "barmap" st set-at
    V{ } clone "bars" st set-at
    V{ } clone "events" st set-at
    0 "cursor" st set-at
    0 "maxend" st set-at
    0 "ending" st set-at
    f "nextstart" st set-at
    t "fresh" st set-at
    0 "tup-left" st set-at
    1 "tup-factor" st set-at
    1 "broken" st set-at
    f "last" st set-at
    data second 1536 * "unit" st set-at
    tokens [ st swap (token-parse) ] each
    "events" st at empty? [ ] [ st "bar" "plain" 2array (bar-token) ] if
    "bars" st at >array ;

! ---------- repeat expansion ----------
:: (expand-repeats) ( bars -- bars' )
    H{ } clone :> st
    V{ } clone "out" st set-at
    0 "i" st set-at
    0 "repstart" st set-at
    [ "i" st at bars length < ] [
        "i" st at bars nth :> bar
        4 bar nth [ "i" st at "repstart" st set-at ] when
        3 bar nth 2 = [ ] [ bar "out" st at push ] if
        2 bar nth [
            "repstart" st at "i" st at 1 + bars subseq :> seg
            seg [ 3 swap nth 1 = not ] filter "out" st at push-all
            "i" st at 1 + bars length min :> from
            from bars length < [
                bars from tail [ 3 swap nth 2 = ] take-while
                :> e2s
                e2s "out" st at push-all
                from e2s length + dup "i" st set-at
                "repstart" st set-at
            ] [
                bars length dup "i" st set-at "repstart" st set-at
            ] if
        ] [ "i" st [ 1 + ] change-at ] if
    ] while
    "out" st at >array ;

! ---------- tie merging and bar assembly (as in music.musicxml) ----------
<PRIVATE
:: (shift-event) ( ev offset -- ev' )
    ev first offset + ev second ev third 3 ev nth 4array ;

! events carry tie flags: 1 = tie stop, 2 = tie start
:: (merge-ties) ( events -- merged )
    H{ } clone :> open
    V{ } clone :> out
    events [| ev |
        ev second :> midi 3 ev nth :> flags
        flags 1 bitand 0 > midi open at and :> cont
        cont [
            cont out nth :> old
            old first midi old third ev third + 3array
            cont out set-nth
            flags 2 bitand 0 = [ midi open delete-at ] when
        ] [
            ev first midi ev third 3array out push
            flags 2 bitand 0 >
            [ out length 1 - midi open set-at ] when
        ] if
    ] each
    out >array ;

:: (rel-event) ( ev start -- ev' )
    ev first start - ev second ev third 3array ;

:: (split-bars) ( events lengths -- bars )
    lengths 0 [ + ] accumulate nip :> starts
    lengths starts zip [| pair |
        pair first :> len pair second :> s0
        events [ first s0 >= ] filter
        [ first s0 len + < ] filter
        [ s0 (rel-event) ] map
    ] map >array ;
PRIVATE>

:: (assemble) ( bars -- bars' )
    bars [ second ] map :> lengths
    lengths 0 [ + ] accumulate nip :> starts
    bars starts zip [| pair |
        pair first first pair second [ (shift-event) ] curry map
    ] map concat
    sort
    (merge-ties)
    lengths (split-bars) ;

! ---------- public words ----------
: abc>score ( string -- voices )
    (split-voices) >array
    [ (parse-voice) (expand-repeats) (assemble) ] map ;

: abc-file>score ( path -- voices )
    utf8 file-contents abc>score ;
