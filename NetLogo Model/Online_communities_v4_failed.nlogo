globals [ total-membership-strength decay total-comments chattiness thismember]

turtles-own [my-comments]

breed [ members member ]
members-own [ extra-chattiness my-chattiness membership-strength join-date latest-interaction active? chatty? done?]

breed [ managers manager ]

directed-link-breed [ intimacy-links intimacy-link ]
intimacy-links-own [ strength ]

directed-link-breed [ interaction-links interaction-link ]
interaction-links-own [ comments latest ] ;; NetLogo does not support multiple edges! The "latest" property keeps
                                         ;; track of the last time member i communicated with members j


to setup
  ca
  reset-ticks
  set decay 1 / 100
  set-default-shape turtles "circle"
  ;; the chooser is in terms of probabilities. These values enter the logistic function to generate those probabilities.
  if global-chattiness = 0.1 [ set chattiness -2.196 ]
  if global-chattiness = 0.2 [ set chattiness -1.386 ]
  if global-chattiness = 0.4 [ set chattiness -0.405 ]
  ;; the initial network is a clique of numerosity founders + 1 manager
  create-managers 1 [ set color red  set my-comments 0 ]
  create-members founders [ set color white set join-date -1 set active? True set chatty? False set done? False set my-comments 0 setxy random-xcor random-ycor ]
  ask members [ create-intimacy-links-to other members ]
  ask intimacy-links [ set strength 1 ]
  ask members [ set extra-chattiness 0
                ifelse randomised-chattiness [
                  let getrandomchattiness random-normal 0 1
                  if getrandomchattiness > 0 [set chatty? True]
                  set my-chattiness 1 / (1 + exp (- chattiness - getrandomchattiness )) ] ; subtract a standard normal from global chattiness to get agent-specific chattiness.
                  [ set my-chattiness 1 + (1 + exp (- chattiness))]
               ]
                ;;
  update-membership-strength
  ; update-lorenz-and-gini
  repeat count members [ tick ] ;; makes sure the date of birth of members coincides with their who number. Member 43 is created at tick 43.
  reset-timer
end

to go
  create-members 1 [
    set color white
    setxy random-xcor random-ycor
    set join-date ticks
    set active? True
    set chatty? False
    set done? False
    set my-comments 0
    ifelse randomised-chattiness [
      let getrandomchattiness random-normal 0 1
      if getrandomchattiness > 0 [set chatty? True]
      set my-chattiness 1 / (1 + exp (- chattiness - getrandomchattiness )) ]
      [ set my-chattiness 1 + (1 + exp (- chattiness))]

    ]
  converse
  update-intimacy-links
  update-membership-strength
  if count members = num-members [ show ( word "Time elapsed: " timer " seconds.") stop ]
  manage-community
  tick
end

to converse
  ;; each member must decide whether to engage in interaction.
  ;; probability of engaging increases if member received communication the previous period.
  ask members with [ active? ] [
    if my-in-interaction-links with [ latest = ticks - 1 ] != nobody [ ;; need to distinguish between in-interaction-links of community managers and those of members. Need an agentset with two "with" conditions!
      set extra-chattiness 0.2
      ]
    ifelse my-chattiness + extra-chattiness > 0.99 [
      if random-float 1.0 <= 0.99 [
        connect
      ]
    ]
    [
      if random-float 1.0 <= my-chattiness + extra-chattiness [
      connect
      ]
    ]
    set extra-chattiness 0 ;; after the decision to connect reset the extra chattiness
  ]
end

to connect
  ;; the member has decided to engage, now she must select the target of her communication.
  ;; average number of targets is 1
  ;; iterate over other members. Prob of creating an interaction-link with another member depends
  ;; on (relative) strength of intimacy-links with it
  ;; compute each numerator and decide whether to engage.
  let denominator count members ;; the denominator of equation (1) in the PDF file is at least [ count members ]
  let connect? False
  ask other members [
    let strength1 0
    let strength2 0
    if in-intimacy-link-from myself != nobody [
      ask in-intimacy-link-from myself [ set strength1 strength ]
      if out-intimacy-link-to myself != nobody [
        ask out-intimacy-link-to myself [ set strength2 strength ]
        set denominator denominator + 1 + intimacy-strength * strength1 * strength2
      ]
    ]
  ]
  let my-comments-this-tick 0
  ask other members [
    let numerator 1
    let strength1 0
    let strength2 0
    if in-intimacy-link-from myself != nobody [
      ask in-intimacy-link-from myself [ set strength1 strength ]
      if out-intimacy-link-to myself != nobody [
        ask out-intimacy-link-to myself [ set strength2 strength ]
        set numerator 1 + intimacy-strength * strength1 * strength2
      ]
    ]
    if numerator / denominator > random-float 1.0 [  ;; roll the dice for connecting each other member
      set connect? True  ;; keep track that at least one connection happened
      set my-comments-this-tick my-comments-this-tick + 1
      set total-comments total-comments + 1
      create-interaction-link-from myself [ set color 93 ] ;; if there already was one, the instruction is ignored
      ask in-interaction-link-from myself [
          set latest ticks
          set comments comments + 1
        ]
        create-intimacy-link-from myself ;; if there already was one, the instruction is ignored
        ask in-intimacy-link-from myself [ set strength strength + 1]
      ]
  ]
  set my-comments my-comments + my-comments-this-tick
  if connect? = True [ set latest-interaction ticks ]
end

to update-intimacy-links
  ask intimacy-links [
    set strength strength / ( 1 + decay )
  ]
end

to update-membership-strength
  ask members with [ active? ] [
    let ms 0
    ask my-in-intimacy-links [
      set ms ms + strength
    ]
    set membership-strength ms
    if membership-strength < threshold and ticks - join-date > 50 [
      set active? False
      set color grey
      set membership-strength 0
      ]
    set total-membership-strength total-membership-strength + ms
  ]
end

to manage-community
  if onboard = True [
    ask managers [ do-onboarding ]
  ]
  if engage = True [
    ask managers [ do-engagement ]
  ]
end

to do-onboarding
  if ticks > 0 [
    create-interaction-links-to members with [ join-date = ticks - 1 ] [
      set latest ticks
      set comments 1
    ]
    create-intimacy-links-to members with [ join-date = ticks - 1  ] [
      set strength 1
    ]
    set my-comments my-comments + count members with [ join-date = ticks - 1 ] ;; in this model this is always 1.
  ]
end

to do-engagement
  if ticks > 0 [ ;; to avoid generalized engagement in the first tick. In this version of the code, this is never a problem.
    ;; first, allocate capacity according to priority

    if priority = "most active" [ ;; I do not use ifelse because I could add more choices later on
      let effort 0
      while [ effort < capacity ] [ ;; this loop is executed until the community manager runs out of capacity
        if one-of members with-max [ my-comments ] with [ latest-interaction = ticks - 1  and done? = False] != nobody [
          ask one-of members with-max [ my-comments ] with [ latest-interaction = ticks - 1  and done? = False] [
            create-interaction-link-from myself [ set color 93 ]
            create-intimacy-link-from myself
            set done? True
            set effort effort + 1
            ]
          ]
        ]
      ]

      if priority = "newer" [
        set thismember one-of members with-max [ who ] with [ latest-interaction = ticks - 1  and done? = False]
;        create-interaction-link-to thismember  [ set color 93 ] ;; as above.
;        create-intimacy-link-to thismember ;; ditto
;        ask thismember [set done? True]
        ]
;      if thismember != nobody [
;        create-interaction-link-to thismember  [ set color 93 ] ;; as above.
;        create-intimacy-link-to thismember ;; ditto
;        ask thismember [set done? True]
;      ]
      ;; this loop does two things. It updates the latest-interaction variable in interaction-links
      ;; and computes the number of comments authored by the community manager in this tick (stored in my-comments of turtle 0)
      let this-tick-comms 0
      ask members with [ latest-interaction = ticks - 1 ] [
        ;; testing with manual input of command lines seems to work, but when I go automated it breaks here.
        ask in-interaction-link-from turtle 0 [ ;; "turtle 0" here is a bit of a hack
          set latest ticks
          set comments comments + 1
          set this-tick-comms this-tick-comms + 1
        ]
        ;; the following updates the intimacy links from the manager to each member targeted in this tick
        ask in-intimacy-link-from myself [ set strength strength + 1 ]
      ]
      set my-comments my-comments + this-tick-comms
    ask members [ set done? False ]
  ]
end


;; ============ REPORTERS ========================

;; start with system-level reporters. Two are simply global variables (total-membership-strength total-comments).

to-report dropouts
  report count members -  count members with [ active? ]
end

;; next, report membership strength and number of communications per each individual turtle.
;; Gini indices are computed in Stata. This is because I need to compute the standard error of Gini.

to-report mslist [in]
  report [ membership-strength ] of one-of members with [ self = in ]
end

to-report nclist [in]
  report [my-comments] of one-of members with [self = in ]
end

to-report idlist [in]
  report [who] of one-of members with [self = in]
end
@#$#@#$#@
GRAPHICS-WINDOW
275
10
714
470
16
16
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
21
378
87
411
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
20
50
215
83
founders
founders
2
50
2
1
1
NIL
HORIZONTAL

BUTTON
112
379
191
413
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
113
425
177
459
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
20
235
115
268
onboard
onboard
1
1
-1000

SWITCH
126
235
216
268
engage
engage
0
1
-1000

PLOT
734
13
1143
405
Membership strength of members
Members birth date
Membership strength
0.0
10.0
-1.0
10.0
true
false
"" ""
PENS
"pen-0" 1.0 2 -7500403 true "" ";; if not plot? [ stop ]\n\nplot-pen-reset  ;; erase what we plotted before\n\nask members [\n   ifelse active? [\n     ifelse chatty? [\n       set-plot-pen-color red ;; to visually distinguish very chatty people\n       ]\n       [\n       set-plot-pen-color blue\n       ]\n     plotxy who\n     membership-strength\n     ]\n     [\n     set-plot-pen-color red\n     plotxy who\n     membership-strength\n     ]\n  ]"

SLIDER
18
144
213
177
num-members
num-members
100
1000
650
50
1
NIL
HORIZONTAL

SLIDER
20
10
215
43
intimacy-strength
intimacy-strength
0
50
11
1
1
NIL
HORIZONTAL

MONITOR
736
424
796
469
NIL
dropouts
17
1
11

MONITOR
807
424
992
469
Tot. memb. strength
total-membership-strength / 1000
2
1
11

MONITOR
1003
425
1143
470
Tot. comments
sum [my-comments] of members
17
1
11

SLIDER
20
190
215
223
threshold
threshold
0
5
4
0.2
1
NIL
HORIZONTAL

CHOOSER
27
100
165
145
global-chattiness
global-chattiness
0.1 0.2 0.4
2

SWITCH
20
280
217
313
randomised-chattiness
randomised-chattiness
0
1
-1000

CHOOSER
21
324
113
369
capacity
capacity
1 100 500 1000
0

CHOOSER
125
324
217
369
priority
priority
"newer" "most active"
1

@#$#@#$#@
## WHAT IS IT?

Online communities are a mix of bottom-up dynamics and top-down constraints and nudges. This is fundamental: they are often run (and paid for) organisations, seeking a return on their investment. At the same time, they derive their properties of speed and self-organisation from the freedom enjoyed by their members, within the framework set by the software and the social contract underpinning it.

Reflecting this dualism, agents in online community are also of two very different kinds. Most are ordinary members, who pursue their own individual objectives. A few are online community managers, who get paid to further the organisation's goal by creating engagement and mediating conflict. In doing so, the latter follow protocols: for example "leave a welcome comment to all new users".

We assume that community managers are trying to make the community (a) more active (more throughput) (b) more inclusive (a more even distribution of network connectivity); (c) more diverse in its contributions (a more even distribution of the number of comments authored by each member). We also assume that ordinary users prefer to interact with their friends. Friendships are created by interacting on the community. In the model, we represent this phenomenon by a network of intimacy, following the approach in [2]. Intimacy is additive, and it decreases with time (unless a new communication event refreshes it).

We model the online community as a network of interaction, in turn underpinned by the aforementioned network of intimacy. Next, we explore how different community management protocols (henceforth "policies") affect the shape of both networks.

Note that community management has a cost. I represent this in the model with the number of comments authored by the community manager. This allows us to think about efficiency: how much extra effort is required to manage the community vis-a-vis leaving it alone? And what does the extra effort buy in terms of activity, inclusivity, diversity?

## HOW IT WORKS

There are two types of agents: participants and managers.

Upon initialization, we create one community manager, and a small number of community members (at least 2). We assume the latter to all be connected to each other by intimacy links of weight greater than zero.

At each time step, the following happens.

1. Zero or more members join the community.
2. Members decide whether to engage in communication. We assume this choice depends on their own chattiness (time-invariant propensity to intervene online), responsiveness (time-invariant propensity to engage when addressed by others) and the number of comments received in the previous period. This is based on empirical results in [1].
3. Members who have decided to engage in communication now must choose one other member to communicate with. We assume that their choice depends on pairwise intimacy; the closer A feels towards B, the more likely she will choose B as the target of their communication. Communication events are encoded in communication links.
4. The community manager engages in her own communication events, depending on the policies being enacted. Two policies are modeled: onboarding and engagement. In onboarding, she leaves a comment to each member who joined the community in the previous period. In engagement, she leaves one comment to each member who has authored a comment in the previous period. The community manager can also do both, or neither.
5. The values of intimacy links are updated.
6. Members decide whether to leave the community. They leave if the overall weight of their incoming intimacy links is below a certain threshold.


## HOW TO USE IT AND MODEL INPUTS

This version of the model is meant to be used with Behavior Space. The user interface is stripped to the barebones, so that the code can run faster. Try <a href ="https://github.com/albertocottica/community-management-simulator">version 2</a> for a "playable" version.

The world becomes very crowded very fast. Try running the model with updates turned off and at maximimum speed.

## Control parameters:

intimacy-strength: the preference members have to interact with their existing friends, as opposed to making new ones.
founders: the number of "founding members". These members are created during setup and are all connected to each other by "intimacy links representing friends.
chattiness: the baseline propensity of members to participate in the online conversation at each tick. If a member receives a comment now, she will be  20% more likely to write her own comment at the next tick.
num-members: the number of members the community is supposed to reach. When it has reached this level, the model stops.
onboard: tell the community manager to leave a welcome comment to every new member, at the date at which they join.
engage: tell the community member to leave a feedback comment to every member that has left one or more comment during the previous tick.

# Agent properties

<strong>Members</strong> have a join date; a time-variant membership strength; they can acquire temporarily extra chattiness when they receive comments from other members or the community manager. There are also properties keeping track of the member's latest activity and whether or not she is stil active.

# Link properties

<strong>Interaction links</strong> have a property storing the number of time member i has left a comment to member j. Another property keeps track of when i and j last communicated.

<strong>Intimacy links</strong> have a strength property. Members use it to decide who they should leave a comment to at each step.


## THINGS TO NOTICE AND MODEL OUTPUTS

Some scatterplots and monitors have been turned off. Refer to <a href ="https://github.com/albertocottica/community-management-simulator">version 2</a> for an interactive version.

## THINGS TO TRY

Turn the policies of the community manager on and off. Do you see any improvement in the evaluation metrics? How is the improvement related to the parameters?


## EXTENDING THE MODEL

Make chattiness and responsiveness agent-specific variables. The expected (not very interesting) microlevel consequence is that the least chatty, least responsive people drop out earlier: self-selection is at work, and people who stay engage in the community are those who enjoy online debate most. There could, however, be more interesting  consequences on the level of activity.


## NETLOGO FEATURES

In online communities, it is normal for two members to interact many times over time. This would be better modeled in a framework that accepts parallel edges (like Tulip, a Python library for network analysis).

Also, link primitives "source of link" and "target of link" would make programming easier. Making the model led to an interesting discussion on programming with link properties in NetLogo: https://www.complexityexplorer.org/courses/23-introduction-to-agent-based-modeling/forum#!/23/-project:link-source-and-target-as-i

Noteworthy: I implemented a version of this model in Python, using the Tulip network library. The NetLogo model appears to be about 10 times faster to compute than the Python one. I doubt I might have done something wrong. Feedback would be welcome.

## RELATED MODELS

I am building a version of this model in Python. Check back in https://github.com/albertocottica

## CREDITS AND REFERENCES

[1] Alberto Cottica. The economic logic of online community management: an empirical study. 2016.
[2] Kibum Kim, Woo Seong Jo, and Beom Jun Kim. Group intimacy and network formation. In 2015 11th International Conference on Signal-Image Technology & Internet-Based Systems (SITIS), pages 366–370. IEEE, 2015.
<ul>
<li>The layout procedure is adapted from Wilensky, U. (2005). NetLogo Preferential Attachment model. http://ccl.northwestern.edu/netlogo/models/PreferentialAttachment. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL. </li>
<li>The procedure to compute the Lorenz curve and Gini coefficient is adapted from Wilensky, U. (1998). NetLogo Wealth Distribution model.
http://ccl.northwestern.edu/netlogo/models/WealthDistribution.</li>
<li>Thanks is due to Bart Wauters, Aabir, Miguel Pessanha and Evgeniy Kuzmin, all fellow students of the Complexity Explorer MOOC "Introduction to Agent-Based Modelling", Fall 2016</li>
</ul>
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="intimacy-strength vs. policies" repetitions="24" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>total-membership-strength</metric>
    <metric>total-comments</metric>
    <metric>dropouts</metric>
    <metric>[my-comments] of turtle 0</metric>
    <metric>map jdlist sort members</metric>
    <metric>map mslist sort members</metric>
    <metric>map nclist sort members</metric>
    <enumeratedValueSet variable="founders">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chattiness">
      <value value="0.1"/>
      <value value="0.15"/>
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-members">
      <value value="700"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="onboard">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intimacy-strength">
      <value value="1"/>
      <value value="5"/>
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engage">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="intimacy-strength vs. policies all turtles" repetitions="4" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>total-membership-strength</metric>
    <metric>total-comments</metric>
    <metric>dropouts</metric>
    <metric>[my-comments] of turtle 0</metric>
    <metric>map idlist sort members</metric>
    <metric>map mslist sort members</metric>
    <metric>map nclist sort members</metric>
    <enumeratedValueSet variable="founders">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chattiness">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-members">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="onboard">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intimacy-strength">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engage">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
1
@#$#@#$#@
