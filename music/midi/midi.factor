! Factor Music Words -- MIDI file input.
!
! A conversion layer on top of Factor's bundled `midi` vocabulary
! (extra/midi), which already parses Standard MIDI Files. These
! words turn its delta-timed tuple events into the array models
! used by the rest of Factor Music Words:
!
!   track>notes   a midi-track -> { { start midi dur } ... } with
!                 absolute ticks, sorted by start
!   midi>voices   a whole parsed file -> one note array per track
!   events>bars   absolute-tick notes -> bars of relative events,
!                 the event model of the Turkish March example and
!                 of music.optimize's emit-optimized
!   file>score    a file path -> voices of bars, in one call
!
! Note-on with velocity 0 is treated as note-off, as usual. Notes
! still open at the end of a track are dropped.
USING: accessors arrays assocs kernel locals math midi sequences
    sorting vectors ;
IN: music.midi

<PRIVATE
:: (note-on?) ( ev -- ? )
    ev name>> "note-on" = ev value>> "velocity" of 0 > and ;

:: (note-event?) ( ev -- ? )
    ev midi-event?
    [ ev name>> { "note-on" "note-off" } member? ] [ f ] if ;

! a raw note event is { tick on? note channel }
:: (raw-event) ( event-tick -- raw/f )
    event-tick first :> ev
    ev (note-event?)
    [ event-tick second ev (note-on?)
      ev value>> "note" of ev value>> "channel" of 4array ]
    [ f ] if ;

: (raw-notes) ( track -- raw )
    events>> dup [ delta>> ] map 0 [ + ] accumulate* zip
    [ (raw-event) ] map sift ;

:: (pair-notes) ( raw -- notes )
    H{ } clone :> open
    V{ } clone :> done
    raw [| ev |
        ev first :> tick ev second :> on?
        ev third :> note 3 ev nth :> chan
        chan note 2array :> key
        on?
        [ key open at { } or tick suffix key open set-at ]
        [ key open at { } or
          [| starts |
            starts first :> st
            starts rest key open set-at
            st note tick st - 3array done push ] unless-empty
        ] if
    ] each
    done >array sort ;

:: (bar-of) ( note bar-ticks pickup -- placed )
    note first :> s
    s pickup <
    [ 0 note 2array ]
    [ s pickup - bar-ticks /i :> q
      s pickup q bar-ticks * + - :> rel
      q 1 + rel note second note third 3array 2array ] if ;
PRIVATE>

: track>notes ( track -- notes )
    (raw-notes) (pair-notes) ;

: midi>voices ( midi -- voices )
    chunks>> [ midi-track? ] filter [ track>notes ] map ;

: midi>division ( midi -- division )
    header>> division>> ;

: file>voices ( path -- voices )
    file>midi midi>voices ;

:: events>bars ( notes bar-ticks pickup -- bars )
    notes empty? [ { } ]
    [ notes [ bar-ticks pickup (bar-of) ] map :> placed
      placed [ first ] map maximum 1 + :> nbars
      nbars <iota> [| k |
          placed [ first k = ] filter [ second ] map ] map
    ] if ;

:: file>score ( path bar-ticks pickup -- voices )
    path file>voices [ bar-ticks pickup events>bars ] map ;
