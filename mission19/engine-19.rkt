;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  This is the file engine-19.rkt
;;;;  Used in Chapter 6 M19
;;;;  Loads places and changes settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(module engine-19 racket
  (require "engine.rkt")
  (require "places-19.rkt")
  (provide (except-out (all-from-out "engine.rkt")
                       act-method-limits random-room-nums print-errors
                       spawn-drone-on-bot-death spawn-drone-on-card-pick
                       min-bot-inertia max-bot-inertia alarm-cycle))
  (layout-bitmap layout)
  (max-bot-inertia 2)
  (spawn-drone-on-bot-death #t)
  (spawn-drone-on-card-pick #f))