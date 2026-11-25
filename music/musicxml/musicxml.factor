! Factor Music Words -- MusicXML input.
!
! Reads score-partwise MusicXML documents and converts them into
! the event model used by the rest of Factor Music Words: one
! voice per <part>, each voice an array of bars, each bar an array
! of { start midi dur } events in ticks (384 ticks per quarter
! note, the file's <divisions> are scaled to that). All voices and
! staves within a part are merged into the part's event stream.
!
! Handled: pitch with <alter>, rests, <chord> notes, <backup> and
! <forward> (multiple voices), <tie> merging (tied notes become
! one event), <divisions> changes, pickup measures (a short first
! measure is simply a short bar). Grace notes are skipped, as
! they carry no duration in the performance model.
USING: accessors arrays assocs combinators kernel locals math
    math.bitwise math.functions math.order math.parser sequences
    sorting strings xml xml.data xml.traversal ;
IN: music.musicxml

<PRIVATE
CONSTANT: step-values H{
    { "C" 0 } { "D" 2 } { "E" 4 } { "F" 5 }
    { "G" 7 } { "A" 9 } { "B" 11 }
}

:: (child-text) ( tag name -- string/f )
    tag name tags-named dup empty?
    [ drop f ] [ first children>string ] if ;

:: (child-number) ( tag name -- n )
    tag name (child-text) :> txt
    txt [ txt string>number 0 or ] [ 0 ] if ;

:: (pitch-midi) ( note -- midi )
    note "pitch" tags-named first :> p
    p "step" (child-text) step-values at
    p "alter" (child-number)
    p "octave" (child-number) 1 + 12 * + + ;

:: (scale) ( x div -- ticks )
    x 384 * div / round ;

:: (tie-flags) ( note -- flags )
    note "tie" tags-named [ "type" attr ] map :> types
    "stop" types member? [ 1 ] [ 0 ] if
    "start" types member? [ 2 ] [ 0 ] if + ;

:: (note-child) ( note st -- )
    note "grace" tags-named empty? [
        "div" st at :> div
        note "duration" (child-number) :> dur
        note "chord" tags-named empty? not :> chord?
        "cursor" st at :> cursor
        chord? [ "prevstart" st at ] [ cursor ] if :> start
        note "rest" tags-named empty? [
            start div (scale) note (pitch-midi) dur div (scale)
            note (tie-flags) 4array "events" st at push
            start dur + div (scale)
            "maxend" st at max "maxend" st set-at
        ] when
        chord? [ ] [
            cursor dur + :> newcursor
            newcursor "cursor" st set-at
            start "prevstart" st set-at
            newcursor div (scale)
            "maxend" st at max "maxend" st set-at
        ] if
    ] when ;

:: (backup-child) ( tag st -- )
    "cursor" st at tag "duration" (child-number) -
    "cursor" st set-at ;

:: (forward-child) ( tag st -- )
    "cursor" st at tag "duration" (child-number) + :> newcursor
    newcursor "cursor" st set-at
    newcursor "div" st at (scale)
    "maxend" st at max "maxend" st set-at ;

:: (attributes-child) ( tag st -- )
    tag "divisions" (child-text) :> txt
    txt [ txt string>number "div" st set-at ] when ;

:: (measure-child) ( child st -- )
    child name>> main>> :> nm
    nm "note" = [ child st (note-child) ] [
    nm "backup" = [ child st (backup-child) ] [
    nm "forward" = [ child st (forward-child) ] [
    nm "attributes" = [ child st (attributes-child) ] when
    ] if ] if ] if ;

! returns the measure's events (bar-relative, with tie flags),
! its length in ticks, and the divisions now in force
:: (measure-events) ( measure div -- events length div' )
    H{ } clone :> st
    0 "cursor" st set-at
    div "div" st set-at
    0 "maxend" st set-at
    0 "prevstart" st set-at
    V{ } clone "events" st set-at
    measure children-tags [ st (measure-child) ] each
    "events" st at >array "maxend" st at "div" st at ;

:: (shift-event) ( ev off -- ev' )
    ev first off + ev second ev third 3 ev nth 4array ;

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

:: (part>bars) ( part -- bars )
    H{ } clone :> st
    1 "div" st set-at
    0 "offset" st set-at
    V{ } clone "events" st set-at
    V{ } clone "lengths" st set-at
    part children-tags [ name>> main>> "measure" = ] filter
    [| measure |
        measure "div" st at (measure-events) :> ( evts len newdiv )
        newdiv "div" st set-at
        "offset" st at :> off
        evts [ off (shift-event) ] map "events" st at push-all
        len "lengths" st at push
        off len + "offset" st set-at
    ] each
    "events" st at >array sort (merge-ties)
    "lengths" st at >array (split-bars) ;

:: (doc>score) ( doc -- voices )
    doc body>> children-tags [ name>> main>> "part" = ] filter
    [ (part>bars) ] map >array ;
PRIVATE>

: musicxml>score ( string -- voices )
    string>xml (doc>score) ;

: musicxml-file>score ( path -- voices )
    file>xml (doc>score) ;
