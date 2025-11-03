Need to add fish

what's the core prototype slice?

- round start: I have a fixed roster of fish (2x1, 2x2, 1x3, T shape)
- I place these on the map (rotation allowed), then start match
- each turn, decide which ability to use and where
    - select which of my fish to use
    - select where on enemy map to activate (also need rotation, so we want a cursor too)
- abilities have cooldowns
- goal is to destroy all the enemy's fish

Next phase:

- I am dealt a "hand" of N fish at the beginning. I select K of these
- more fish types and abilities
- add fish selection in between rounds (progression/deck system)
- an AI to play against, or just pure RNG maybe (other side has perfect info, and can randomly be intentionally dumb)

# The player's grid

There are many possible shapes of fish
We want the ability to rotate them (step 2)

So we need a way to check that fish don't overlap
And validate we fit inside map bounds

Some approaches:

1: each cell is a button + sprite
there is a grid class creating/containing these
click on cell -> then tell the grid to do checks

2: no individual cells, just a grid
totally programmatic to query mouse position relative to grid
potentially less "wiring"

3: collision based
The fish is literally a physics body, and on click we check which cells it intersects
fish might itself have sub-boxes
doesn't work unless we always snap, but maybe fine!
pros is we don't need to define a shape in code

Any simpler way? eh not seeing one really
the collision one like maybe, but something doesn't feel quite right with that
I guess it's just sort of indirect, but nothing stands out as super wrong right now

Seeing that we will want hover preview + snap in the future, what makes sense hmm...
I like event driven with the buttons/colliders. it's a familiar pattern

Let's try NOT looking at the internet/AI for the "answers" - just overcome the fear of being wrong and go

Maybe let's even do the most uncomfortable option as an exercise?

Hmm ok, I'm trying 3. Started out with a tilemap, but there's a challenge
The player needs to have separate area2ds! in order to detect that each one overlaps the tilemap
this works mostly ok

but eh...given some thought, we'll want an accessible grid representation as data
because later we may need some more complex calcs - search, expanding circle, etc.

Also I think it's better to have a bunch of independent tiles, not a tilemap
Easier to do things like animations etc. Tilemap isn't super extensible

# Theme!

Had a fever dream of an idea session last night. Here's my vision:

You start at a low-level field engineer at a military contractor corp working for the US dept. of war
You are building a fish bioweapon with the express goal of obliterating the Chinese
Specifically, by unleashing the fish to do ecological terrorism, which crashes China's fish markets and derivatives,
which the all-seeing USA military analysts have predicted will lead to the downfall of the CCP

According to the infallible principles of efficient markets and competition, employees put their organisms
to the test through competition. The company founders in their infinite wisdom have decided that employees must
purchase their own materials from the company (in a bid to recoup costs). Due to supply chain issues, there are no
guarantees on what supplies will be available - make do with what you have, dummy!

The characters:

- Debbie Ding ("the chump") - the protagonist
- Dudley Doorknob ("the supe") - her boss
- Deonte Doofus ("") - lab store manager
- DengXiaoPingRequiem - Chinese espion (known only by username)

This is going to be a deeply silly, slightly dystopian game

I'm inspired by the real-life issue of engineers who work on missiles for shady companies which just end up bombing
a Yemeni hospital or something. Not going to go too far with the allegory as it's a heavier subject

I'll call it: "Morally Bankrupt Weaponized Fish Engineer"
or "Perfectly Adequate Weaponized Fish Engineer"

The corporation will be called STRIKE FIRST Defense - a reference to the concept of a "first strike" in military policy

Setting will be early 2000's / late 90's tech - computers are just starting to get ubiquitous, but aren't good

---

Polish/feel ideas:

- The main menu buttons have dramatic and overly long flavor text
- Wallpapers for main menu:
    - A graph plotting "How close we are to defeating China" vs "Your DEDICATION and SACRIFICE via UNPAID overtime"
    - A long list of alarmingly worded emails about how China is only 2 months behind (going back to 2001...)
    - A performance review with ridiculous 1984-style criteria
    - A scenic image of Debbie, Dudley, and Deonte standing in front of a US flag, very patriotic
    - An employee of the week award for each, with flavor text
- Every time China, chinese, Beijing mentioned, the text is juiced as fuck and the screen shakes (menacing music)
- Talk to the boss via a "live Tucker reaction" - style monitor in a corner
    - The chinese espion can appear here
    - You can cover up the screen/audio using an organ (it counts as part of your inventory, so no need to do checks)
- When spinning an organ by press and hold, it eventually speeds up an does a dust cloud
- Organs have very squishy noises and kind of balloon outwards in a bouncy way when dropped
- Organ personalities! Don't think they will have faces, but maybe some kind of name / flavor text.
- A button to "give up" - if you press it, the screen goes black

Ok, now that's out of the way we need to focus on mechanics

# Art direction

Mood board: https://mood.site/Q3BnFyGk?edit=1nVZ1ZUc

Think: Pizza Tower but bad
Pizza tower art takes a ton of skill actually. Unlikely we will fully replicate it (yet)
Maybe we can find a good artist. Or 70% will be good enough?

Hesitant to use AI. Part of this is stubborn-ness. I WANT to be good enough to crank that
I think with a month of consistent practice, I can make bad but passable pizza tower style art

# Keyboard-shortcut-friendly UI

Nice to navigate IDE's, vim and the such with just keypresses
Imagine I can place organs just by typing a number, then I can move it with arrow keys!
I'd love to add something like that, maybe Debbie can type on a small keyboard to make it diegetic??
And a robot surgeon arm can do the actual moving? Eh maybe too far

# Implement drag and drop of a fish

We can use the built-in API, or use our own.
Quick recap - only works for control nodes. Implement methods that the system will do callbacks for
One limitation: what if we actually want sticky click, not a drag?

Let's say I just purchased an item. Good UX -> can immediately place it without needing to drag and drop
Actually eh, not the worst thing ever
Separately, not great if we allow purchase when there's no space, but can fix that later

Just go with this don't think too much.

The components we need:

- The ice box. This is our "inventory" where organs are stored
-

The preview object:

- rotate when we press
- ideally, points/rotation are here too so we don't need to duplicate data
- later, maybe we can highlight it if we're hovering over good
    - means we need some way to talk from the drag target -> the preview
    - the cleanest way is usually signals
    - ok so the drag data object can be a signal router type affair

What happens when I click?

FishItem -> get_drag_data()
and add preview

DragData:

- Points
- Rotation

Need to change rotation when mouse is clicked. hmm...

For the check:

- Given mouse position (local) and the DragData
- Figure out where the organ tiles are

Don't like duplicating knowledge - the sprite, the rotation, the body tile offsets
Later we can represent item data as a resource - not needed right now maybe.

# Ok now to place the items

We can probably make another preview object, with that rotation right?

# Prio-ing OCT 11

The goal - the core framework, in a playable PoC.
Looks ugly, UI jank, but the mechanical systems are in place
We don't need much content or even for the game to be fun at this stage
We have 3 days! Let's break down the problem:

- Selection menu
    - Placing base layers + organs, legal placements and such
    - Add an inventory area and a weight limit
    - Dragging items -> Inventory
    - Save/load config and inventory state
    - Transition between selection -> battle
- Card system
    - Foundation of item stats, ability types, etc. : start with just damage
    - Proximity effect system
- The auto-battler loop
    - What's the main loop? Implement time-based progression
    - Stamina system
    - Health and damage
    - Win condition
- Auto battler UI
    - Self and enemy display grids (can be identical component)
    - Showing cooldowns for items if applicable
    - Per-item hover UI
        - Item description and stats
        - Current status (maybe - we can also use color or visuals to convey)
    - Dashboard-type UI
        - Top level stats: Stamina, HP

Realistic cutoff is here!
---

- Store economy mechanism
    - Compute how much COINS to get at end of match
    - Adding the store UI component
    - Figure out which items to display in that UI
    - Do we need an algo to sort varied shapes in a good way?
        - nah, just a few big squares, make pretty later. Or even just icons
    - Checkout mechanism - ensure we stop if overweight!

^^ cut above for scope
---

- The art!
    - TBD
- Enemy AI (optimization algo)
    - Simulating battles
    - The fitness function
    - Balance: how good an enemy to pit the player against
- Minimal content: add cards!
- Gluing the game together

Today, I'll focus on wrapping up select menu and building the core logical systems for cards and battles

Hopefully, Sunday we can build out most of a UI for the auto battler, and some work on the store

Monday will be art, enemy AI, and glue

Man, we're gonna have to cut scope!

# Legality checks

Items define rules - config telling us what to enforce

- types not allowed to overlap. generally, should not overlap own type
    - maybe we even make this a bool "can overlap own type"
    - types will be a tag system for flexibility
    - Tag has a TagClass (layer-level, item-level, other?) and a value
- disallowed_neighbor_types: horizontally same as above. what can't be in adjacent cell?
- types must overlap: organ MUST be atop a substrate
    - note: there isn't really an "above/below", just care which items exist in one cell
- required_neighbor_types: horizontal equivalent to above
    - Substrate must be next to other
- For protrusions, required_normal, to enforce it's perpendicular to outside of fish
    - Not MVP!

Each item also has its (rotated) positions, item id, and type

The grid defines the systems which process these rules. Grid has knowledge of graph relations and all item pos

# Adding another item!

Preview should be decoupled from ItemData
Should we separate out the pure data (offsets, type, placement rule, stats, etc) from the node?
Yes definitely. Pure data easy to pass around. The parts of the node which matter are:

- The bounding box area. Is this needed? Nice to define such a thing from UI in node (visual)
- The points. Also nice to see represented visually. Can be worked around but should we?

So it's just a matter of using the node for ease of configuration eh?
Then we can do: Use the scene as a config tool -> static item data. Load that somehow at runtime
Register it in a central map. PACKED.instantiate().get_static_item_data() ->

We can still have that scene be an actual node in game - placed item and preview use it!
Because it's also nice to share the visuals and any animation or whatnot

Should we make it an abstract class? Uhh whatever bro uh uh @pbashsho @ekoopman your opinion???
FUCK ABSTRACTION

Really we're planning for a future problem of: what if we need to change something for all items
Ex: Adding a UI element (hover text perhaps?). Nice to define that in one place
Rather than PlacedItem, Preview, and battle item.

I'm in a thinking trap. Should decide soon and just do it, maybe it's bad whatever

Item's interface:

- Interactable area for drag drop - it's item-specific data
- Defined area for allow to drop -> Inventory area
- The points, basically we only care the data
- Placement rule
- Item type enums - layer, which item, etc.
- A shared UUID eventually
- Static data - one day we shall use I swear hngggg!!!
- The sprite

PlacedItem

[X] Add item 2 (inherited)
[X] change PlacedItem to use itemdata's dragged thing
[X] Item enum and factory registrar thing
[X] Pull out item 1 to another inherited scene
[X] rename silly named classes

# Improving placement rules system

Broadly, both things would be nice, but we only absolutely need one:

- Verify total state legality
    - If we introduce "WIP" mode in future - allowing partial illegal
- Verify that one change is legal
    - Probably nicer for genetic algo?

Can we do both in one way? Maybe, verifying individual piece can be generalized
to verifying the full board? What about constraints like max count or required on board?

I guess what we can do is compute the intermediate structures required for validating constraints
Like board-wide item <-> count dicts, per-tile stuff, etc.
Then it's quite fast to check

Also, why do we need to be fast? No reason to believe it's a requirement...

- let's ditch the config for now, just hardcode assumptions b/c it's easy
- instead of separate for loops - one loop, eval each item
- then the per-item check is its own thing?

# Tiny todo list - placement UI

[X] Placement rule system - fix bugs
[X] Implement adjacency system
[X] Item area items delegate drag drop operations upwards
[X] Item drag drop on item area feels really clunky (feedback + more lenience + reasonable default?)
[X] Singleton signal for drag end (success vs fail)? Cleaner that way
[X] Want to fix bug where if my mouse is on
[X] Drag item around board again
[X] Fix some bugs with rotation of preview
[X] Multiple items, check overlap
[X] Dragging placed item back to an item area
[X] Dragging atop existing item should delegate to grid
[X] Define/code up the basic API for legality
[X] Implement overlap system
[X] Improve overlap system

I've really been feeling the limitations of the drag and drop system!

- We can't decide when/which control will be called - forced to do delegation
- How do we integrate with other input schemes, like keyboard, or single click to pick up and drop?

When we revisit UI later, can try to make our own, will reveal the tradeoffs, what are we losing?

# More nice tempting juicy not core scope scope creep ideas

Explicit and emergent synergies

- Explicit: Item X gives +10% if item Y also owned
- Emergent: Hitting some combo within 1 second -> + coins. Anything making ball faster or combo more common

Look at https://luck-be-a-landlord.fandom.com/wiki/Items
And nubby number factory for ideas and inspiration!

> Every 3 spins, all symbols are considered adjacent.

Generally, something making restrictive but powerful triggers not so restrictive

> The conditional effects of essences must happen 2 times for them to be destroyed.

> Re roll the board

> More options / cheaper cost in store

> Transform common item -> super rare one

> Changing the probability distribution

> Dud item, added as a challenge on later levels, or as a negative effect

> Items with across-round state, like "only usable 5 times"

# Roller 2025-10-25 Planning

Remember the goal! We want something minimally playable, not even "fun" per-se
The art direction not important right now. Don't need super fancy mechanics

Let's boil it down to a handful of core mechanics first

Let's first make a couple items
Then add a store
Then the rest of the items

# Making a clearer item system design

Now we have real problems to solve!

- If I want to tune an ability, I have to jump across some combo of 5 classes. Cognitive load
- We're writing a bunch of same boilerplate for similar abilities (i.e. on a timer)
- Anything requiring data about both player + grid means we need to add signals/method calls between those
- Cross-item interactions will necessitate some hacks
- Implementations are hardcoded right alongside game board/player ball class
    - This is a bit wishy-washy, but feels wrong
- Player / TileObject config is also ehh...

Putting it more concretely - the point of this is that we can add novel and deep mechanics
For the end user. That's it! They don't care about spaghetti.

- We need something flexible to add new mechanics
- And to be EASY TO TUNE - lot of iteration may be needed, not just stats but which trigger/actions
- Clear code reduce chance of bugs. Functional core imperative shell is actually awesome

I still believe in the original conditions/actions framework, we just generalize this.
Input state: Board, PlayerBall, Item
Output:

# Item system refactor 1 Impl notes

Maybe before that, we can represent items as separate classes, each duplicated
Then deduplicate parts. That way we incrementally improve. Monolithic change = not smart idea
Hell, each item can be just a method: Given state + events, do whatever mods / return events. But class nice for state
And then we can imagine patterns in the "actions" and "triggers"

Maybe we don't need events for hitting and the such? Can the player / crop just have methods for onHit?
A crop IS an item, that's the weird thing. But player maybe doesn't make sense as an item?

We can decouple the physical crop collider/sprite object from the crop item logic maybe?
Well, why? That actually makes sense to be defined in one place IMO. If the crop grows, and we want to trigger
animation,
why should we have to pass that as an event through some external system?
A couple possible benefits:

- Event interception. Effect: "Ignore hit" or "count hit as two" or "count hit as hit on all squares" etc
- Fully decoupling the core logic from the nastier side-effect-y parts
    - But we'll need a way to talk back to them!

On the flipside, for something like snail trail, we want to spawn it where the player's position is
How will that flow? Each trail segment probably should be an item, since it has triggers/effects and a physical body

```
SnailTrailSpawner
- distanceSinceLastSpawned
::evaluateTriggers(tick, player, inventory, board)
    distanceSince += player distance moved
    if it's over threshold, reset that shit and spawn a segment @ player loc
    where should it go? I dunno, we can make some shared node or add to board for now

SnailTrailSegment
- lastTriggerTick
::evaluateTriggers(tick, player, inventory, board)
    if periodic timer passed,
    generate a LevelUp event with a TargetingConfig = AOE circle?
...outside, some logic to translate events with TargetingConfig -> an event per grid item?
    If everything's a circle, this is pretty much ok
    or maybe crops decide for themselves if such a thing applies?
    latter simpler for now I guess
    
Crop
::evaluateTriggers
    we can look for LevelUpEvent with an applicable targeting
    and then I decide if I'm next to that I guess...
```

```
OverlapEvent
    Source: an object or enum?
    OverlapShape: 

PlayerBall
::doTick
    send back a PlayerOverlapEvent with position + radius, which bounce count

~~HarvestCropItem (hidden)~~
or hmm...should it be part of the crop? Like each item defines its interaction, yeah

Also in our beloved crop class
- 
::evaluateTriggers(tick, player, inventory, board, events)
    if there's an overlap event, we must check if it's in same bounce as before
    if indeed it's a new bounce, then we need to down-level
    We'll do queue_free at end in a cleanup method
```

What about grow on hit? Also on PlayerOverlapEvent I guess? But it needs to target crops
Ah ok this can send a LevelUpEvent with whatever chance, same deal really
It listens for PlayerOverlap and turns it into LevelUp

Trigger types:

- Round start: Generate initial crops, ADD_STAMINA
- On bounce: SPAWN_RANDOM_TILE_OBJECT
- On hit: LEVEL_UP_ITEM_ON_TOUCH
- On dist travel?: SNAIL_TRAIL_OF_LEVEL_UP_SLIME
    - Seems a good fit for state - this item should track player state changes...
- On kill: SPAWN_BOUNCE_PILLAR, SPEED_BUFF_ON_DESTROY, INCREASE_SIZE (need counter)
- Timer: BOUNCE_OFF_EVERYTHING, SNAIL_TRAIL_OF_LEVEL_UP_SLIME_TIME_BASED

We may want to factor out config into some central place no?

### More nice design realizations:

***
Really nice simplification.
One problem giving me a headache: If one item triggers off event X, and another item can produce event X,
do we need to eval that 2nd item before? Otherwise, we might end up never triggering first item.
That would necessitate either a DAG algo or manually deciding prios.
A simpler way: Base all triggers off the events from LAST TICK.
All events spawned this round are counted as spawning at the same time, and ignored for trigger eval
Exceptions/caveats:

- Physics events in same tick are used (we discard those from last round)
- Event effect still applies same round, ex: apply status effect, spawn item

***
The player SHOULD be an item - there is nothing truly special about player ball
Other items can bounce/overlap/etc. too! Other items have colliders and sprites and anims too!
The only special part (point count) should not even be player state, it's game state

***
Also - don't worry that it's "inelegant" for overlap event to include a bounce count / overlapper id.
We're doing this because we want the player's overlap to be counted once per bounce (by some griditems)
But this system is general! If we want to trigger a chance check every frame we overlap, this system allows!

***
GridItem, Inventory item, etc. are only different in the location we specify.
Same item framework for all

***

```
interface Item:
    _inject(physics_calc, location, etc.)
    spawn() # for user setup, like register static bodies and a sprite somewhere
    evaluate_status_effects() -> Array[ItemEvent]
    advance_physics(delta) -> Array[ItemEvent]
    evaluate_triggers(match_state) -> Array[ItemEvent]
    clean_up() -> bool should_deregister
```

How do we pass the external dependencies? Such as physics calculator, grid calculator, etc
Ideally we inject those at construction time. Items can't really share a constructor sadly
I'm not gonna build an entire DI framework haha. We can just do a javabeans style "call this method to init me"

Instead of externally creating a "trigger context" every time, we just inject it.
There's a universal context (all items, board, tick, last round events, etc.)
And then specifics like item's state including its location

***
Representing location

There are 3:

- Grid cell, just a Vector2() / Vector2i(): which?
- Inventory slot, probably just an int number
- Unplaced

Actually, maybe scratch that: What about the player balls, slime trails?
Do we make a fourth, or just replace GridCell with PhysicalLocation or BoardLocation?

Like I feel like it makes sense to have some concept of a grid not just areas
At the same time, we can do adjacency etc. with an AABB check against real positions.

Go with simplest for now, just one type. Later can add another if we need

***

How to do status effects really?
Each item can have and original and current state, plus status effects
Near start of each tick, we will apply the status effects to impact the current state?

***
Item layout: composition or inheritance?
Composition: ItemLogic and state is separated from the physics calc and animations
Inherit: Item is a Node2D in the world. Do we lose anything? I guess queue free-ing may be a bit complex?
Eh, I like separate logic.

- A, it's great for testing, so a good heuristic for low dependencies / logic is concentrated in one place
- B, makes it really easy to sim if we do gen algo in the future, just get rid of random BS

Will admit those are weaker reasons.
Inheritance seems strong - then we can manipulate everything in one node and one class
Hmm. No, there are real benefits to disentangling animation/sprite logic
Physics logic is a bit trickier. We directly depend on that for bounce events. It's not super avoidable?
Oh but is it? Can a ShapeQuery2D do the same thing? eh, that's a bit low level nay? And for multi ball...

Perhaps we can define the Item class as a static inner class in the true Node2D item?
Weird but I think it works? 2 classes also isn't the worst thing ever. A bit nasty to jump around I guess

I bet we can abstract the physics part a bit.
Overlaps we don't even have to worry about - that's just simple math because everything's circle
So it's just StaticBody and CharacterBody.
these even have be entangled to a given item?
I mean yeah, the lifecycle (spawn, queue free) is tied together, state (position, speed) etc.
Boil it down. The bare minimum we need. Those bodies are effectively just tools we're hijacking in order to do
collision calculations. They don't need special state, just expose an interface
Similar to the idea with the multiplayer game. There is some "singleton-esque" object managing all physics bodies.

Items can have a "spawn" method creating + returning the associated display node + physics node(s)
Track those nodes in a StatefulPhysicsCalculator (just a Node2D)
In each item's advance_physics(), it'll just ask StatefulPhysicsCalculator for a collision result from some item
In clean_up, we need to de-register those somehow (how to guarantee no leaks eh??) - for now, manual
Maybe we emit a signal on item cleanup?

CoinItem:
Status effects
OriginalState (includes config and parts which vary later)
CurrentState
CoinInGameBody

or CoinItem Node2D:
...status effects, state, etc.
...item methods
area2d
sprite
etc.

What if CropItem is just a script we attach to the scene?
Then it won't be decoupled. If we say want to run the sim without creating full game w/ sprites etc., we can't!
Maybe we can attach it to a dummy node with expected node paths? That seems like a not great solution
because if some of that animation logic expectes real values...

Better would be to separate the scene display logic into its own fella.
And we can connect the Item <-> its scene via signals perhaps. That is the most decoupled.
It's annoying to write signals ofc. Much quicker to go $AudioPlayer.play
I don't really see a use case for that level of decoupling

Like, it's theoretically elegant but THE USER DOES NOT CARE!!!
What will deliver the most fun game the quickest?

I guess in that case we just want Item = Node2D, and attach that script to the scene.
For creating items, will just be a scene init, add to tree, and we call _inject and spawn

yeah no, that's the engineer in me talking. this is the good pragmatic way for now
I do like the idea to keep the physics separated
No shot I'm doing Item extends CharacterBody haha, so the PlayerBallItem must "has a" characterbody, not is a, in that
case
Which is just as unclean and weird, like we're moving a characterbody under a node2d, can that node2d move, wtf?

It makes perfect sense to have some level of separation between the player's visual and physics body, for example what
if we want to implement a smoothed visual interpolation, or some slug ball shaking?

I guess the one not so nice thing is we have to take care of physics body lifecycle manually, rather than it being part
of
the scenes. No yeah good arg, let's just make Playerball HAVE A characterbody, make that one top level though

***

Event order. I still like the idea of not doing explicit order.
For trigger evaluation, it should be based on a read-only view of the events/state at the start of the tick,
aka the events created the last tick + the frozen state at frame begin

One question is: Can item activation modify the item's state. I'd argue YES
Otherwise literally every change needs to be driven by events which feels restrictive.
Events represent stuff that other things would want to react to, not literally every time we increment some internal
counter

I think a good balance is something like this:

```
Item
    baseState <- contains the base stats and other state relevant to other parts of system
    tickStartState <- immutable deep copy, used for trigger evaluation
        ex: Item which does a speed boost for every player ball with < 25% stamina
        to figure out which items to target with that status effect event, we base it off their tickStartState!
        this tickStartState includes all status effects etc. (because those can change stats relevant to
    currentState <- mutable, will be used to compute next tickStartState
        specifically function(baseState, last currentState, status effects) -> next tickStartState
    maybe there can also be internal vars (book-keeping etc.) which aren't really "game state"        
```

It's a little complicated, but only a little. It gives us a lot of predictability and flexibility

Should we treat physics events separately? I'm a little torn. On the one hand, it's nice to react immediately to these.
Taken at an extreme, we don't want the user to see an overlap and then wait a noticeable pause before anything happens
On the other, 1/60th second isn't that noticeable, and treating everything consistently might be simpler
Go with simpler if it's not going to affect the user

^^ revisiting. It actually is noticeable having a gap between physics event and reactions.
For example, a player clearly hits/bounces something but there's just a tiny gap until I hear audio
ah never mind, it's more that the player sprite is too large compared to the area2d
this is not that noticeable at higher speeds. and when I made the phys event change, it didn't help
real problem, wrong diagnosis

kk thought experiment. crop level up on hit
T1: generate player overlap event
T2: levelUp item sees that event -> level up event. Also, crop sees it -> level down event
T3: Crop sees changeLevel events -> give points, etc.. Same frame, give points applied?

So that's a 3 frame delay, not the best? 200ms is "slow" for a human, but even at 60ms it is a bit sad
The ideal situation is to see all three in one frame. That's achievable with a for-loop, but then one tick != phys
frame.
Maybe that's a fine solution though? The issue is we need to account for time delta correctly

like yeah the actual problem is we want items to define how we react to events, but it gets super hairy if we
allow items to react to events spawned by OTHER ITEMS in the same tick. There are all sorts of ordering issues
it's nicer to just define a set of reactions and let the game loop handle sorting out the "trigger dependencies"
but at the same time, there are some cases that produces an unnatural effect, specifically if:

- Event A triggers item X -> level up a crop (event for next frame?)
- Event A ALSO triggers the crop -> level down (in same frame)
- So we quickly level down and up, when it's maybe a bit cleaner to do one atomic operation
- Sure, we may want 2 sfx to both play, but that's for sure doable (like we add up all level downs and ups separately)

the easy way is make level down also an event, but that just feels so wrong for some reason? Like we could just
mod our state but instead we vomit up this event like hnnng

Also question should reacting to a level down event be part of the item? I think that's sensible
What is the alternative? We define something like a "modifyStateEvent", where something outside manipulates item state?

***

A few patterns I noticed:

events which have a chance to happen vs. it definitely happened
Do we need this "chance" to be part of the event data, or should each item do the probability check?
It smells like "needless boilerplate" to have a "ChanceOfLevelUp" and "LevelUp", same for spawns

I think either:

- we make it generic
    - a "ChanceEvent" has a levelup
    - or a LevelUp has a "Chance" field which can also represent "done"
- we just don't. Items do that check and spawn a yep 100% happened event

The real catch is spawns I guess. There might be a bunch of spawners competing for limited space, and we still want each
to have a fair ish chance. But in that case, maybe just randomizing spawn order is enough, and we can add "weights" in
the
future if it's absolutely a pain point for users. Simplicity!

***

Overall structure draft 5


***

Feeling shenanigans

esteemed sewer earl I
esteemed sewer earl II
ye olde slug balle
the four humours: the black bile
rotting sock
the TITHE
my liege!

***

migrating to new system

[ ] inventory slots
[ ] pass events back via a signal / private instance method (no need for return array)
[ ] move game board to new system
[ ] crop sounds -> shared audio player node?
[ ] reduce boilerplate/general unreliability in overlap event
[ ] kill off spawn chance shenanigans
[ ] solve trying to call methods on freed item instances in events
[ ] clean up old crop code
[X] basic wiring item spawn
[X] move around
[X] Stamina system
[X] fix progress bar gone?
[X] signal for round end (stamina gone)
[X] eliminate refs to old player_ball
[X] generate bounces events
[X] spawn the ball in a sane place
[X] decide how to wire item destroyed event
[X] speed buff on kill
[X] add grow on kill
[X] bouncing mode sprite
[X] stamina as status effect?
[X] spawn bounce pillar
[X] more damage item?
[X] implement grow from snail trail
[X] ball: plan out the migration
[X] make that bouncy more generic
[X] BOUNCE: destroying static bodies when gone
[X] BOUNCE: basic triggering + creating static bodies for all items
[X] crop: level up chance
[X] make overlap event not have change
[X] Clean up levelup on hit
[X] grow on hit chance
[X] fresh hit overlap system
[X] spawner
[X] random level
[X] points on hit
[X] downlevel on hit
[X] despawn on level zero

---

solve trying to call methods on freed item instances in events
new item system is "working" but not fully robust and battle tested
the deferred event system, while a massive win over computing dependencies

it's also not super ergonomic to filter/cast events manually - lots of sad boilerplate
nice thing is it's all isolated, so now comes the juicy reduction refactoring phase! pattern brain gooo (i am prml)

ok we're thinking of too many problems at once. if I actually break it down - what ends up impacting our players?
ideally, we react to physics events right away. This will feel snappier, I also think it's more intuitive!
Same goes for applying spawns/despawns/other events - this should be same frame!

our system is not broken. Nor is it super complex right now! Like I can easily imagine adding 20 weird items without
issue!

as a general rule, keeping events as pure data is the most predictable.
when we have object references and stuff, it's like we're letting the other parts of the system do sad things
like null dereferences or calling methods on that object which feels antithetical to our design

---

solving despawn null ref issue
we still need the info of which item types! enum a bit nicer than making N classes! tags an extra generification ha
make these refs item obj ids (or some identifier) instead

---

Solving make overlaps simpler
we are dependent on order of first/second item (bad)
eliminate item references
easy way to distinguish what "kind" of overlap it is. We'll have many items (roller, slime trail now, later more)

Different classes for each type? aka roller -> X overlaps?

- Roller has special logic for fresh overlap, so maybe yes
- At the same time, that's maybe annoying to filter, and feels less generic
- If I want to react to any overlap, do I need to specify multiple classes to filter? (tag system can solve this?)

wait take a step back. Overlaps even need to be events?
it's trivial for each item to figure out its own overlaps
and what we want to react to is usually not a direct overlap, but the resultant event yeah?
having overlap=event is perhaps most generic way

player generating "hits" feels better to me tbh
one problem: what about "level up on hit"? hmm that could work
likely nice as a physics event, so we can instant-react in same tick?

why don't we just expose multiple phases for reaction? like item.activate1, activate2...
then this is just the ordering problem again. There's a fundamental tradeoff between the simple approach
and the one which reacts the fastest to events. I spot a mental trap here. Let's go with simple until it's an issue
like...we can literally just 8x the tick speed and the problem magically "goes away"
of course that comes with its own problems but eh
actually having a few distinct phases feels ok to me. like a pre phase, main, and post
where pre-phase generates events likely to be used for the main, including physics etc.
and post-phase is more about applying events at a per-item level, such as level down despawning
like yeah it is basically not that different from looping 3x, but it's a bit more explicit
this allows us to easily avoid duplicate triggers. within the code for one item, easy to see we handle only once

```
trigger_events = last_tick_events.copy()
trigger_events.append(..call pre-phase...)
new_events = call main phase (trigger_events)
new_events.append( call post phase (new events, trigger_events) )
```

hmm but what about event interceptions, is that needed?
one example is events with a targeting config - we want to "resolve" that to a list of specific items/positions
because that's more useful for triggering. like "added status effect to item X" vs. "added status effect to all items
with tag"
if you want to trigger off of added status effects for adjacent items, for example

I think that could be done in a parallel system to the items, just at the end with like spawn despawn etc.
One idea was the items could resolve the targeting and always spit out a list, but for things that have path dependency
like you can't spawn 2 things in the same cell, that could be annoying? I mean there are workarounds, but it's cleaner
IMO for the item to shoot out a targetingConfig and something else resolves all these

there is something elegant about events being contained to one tick
at the same time, I think that's a false "ideal" - real world complex systems often do have a lag between reactions
consider a rube goldberg machine, or kubernetes with its operator loops.
each item basically just moves the state more towards the desired state, incrementally

---

I like to have some general heuristics for what *should* be an event
we're using these to represent "do this thing" AND "thing was done"
there's no point in event unless something needs to react to it
which is why internal state changes like "velocity changed" aren't events yet

like yeah sadly no great heuristic yet. We need more problems to reveal the true shape
the loose guideline is only "does anything else in system need to react?"

I guess it is a bit hairy if we can change state via direct calls + events

events are basically signals but more data driven so we can intercept

---

Status effects

examples:

- speed buff / size buff work basically the same
    - modify some property by some amount
    - have a duration
    - can stack

The easiest for now is something like { effectType, duration }
maybe a max stack size, but that can be done on player side tbh

later, we'll want an ItemTarget config (one specific item, many items)
but for now AddStatusEffect will hardcode to one specific item

and I think a more generic version would be a PropertyModifier with some expression
And even more generically, properties can be objects with tags, clamp bounds, signals on change, etc.
but that's not needed for now. Generate the "data" (bad repetitive code) and then see the pattern. Code is alive!

---

About handling item spawns...

2 cases:

- the items we start out with (all inventory or hidden)
- adding new items in midst of a round

Right now, former we are handling purely via "add child"
But for roller, we need to put that in map somewhere, or perhaps even have the player place it!
And later on when we have inventory slots, will need to spawn items there

Should we keep the 2 system separate or unify?

- Maybe a "spawnOnBegin" item which inits/places all our start items
- or make spawns totally config-driven rather than code-driven
    - the start-of-round items will just be an item enum + a location? hmm but we need params also (crop level?)

like yeah we'd want to influence what level crops spawn with, that's a core item mechanic. hmm but doable via system 2
other cases: items with a consumable amount of lives, persisting across rounds like the soul from luck landlord
yeah but that's not necessary yet

ok what if:

```
ItemDef
    ItemId enum
    Location
    params dict { ... } ( used for instancing )
```

Or perhaps ItemDef has subclasses, rather than protobuf-style enum? do we need that though?
then all we need is a way to decide the position
hehe just hardcoded it for now, solves problem

---

"I too want a wound that I can say you gave me" huge line ty Casca

esteemed sewer earl
esteemed sewer earl (REAL)

one thing annoying is we need to kind of keep track of "novel" overlaps
aka area entered / exited. The point of this is:

- First time we contact a crop, we should do some actions
- But if I'm between two bouncies and rolling over a crop constantly, feels bad if we never count as hitting it
- So a nice solution is on each bounce of the ball, anything we overlap after that (until next bounce) is a hit
- And we'll have some tiny bit of throttling to ensure we don't hit 60 times/second

This is actually quite a bit to replicate in every item. Problem I'm solving is "LevelUpOnHit"
So this needs to keep track of all the player balls, all the crops, the last hit/tick per combo
It's probably not that bad tbh but why duplicate this everywhere, it's sad, we should just handle it generically
For example by doing those physics events in a central place! FreshOverlapEvent { first item, second item }

Let's try that! But how hmm...
With a stateful physics calculator it is fairly easy, but if we don't know all objects it's a bit tougher...
Eh, maybe let's go by convention. A "hitbox" always an area2D, and we just collect those
The sad part is it's not quite safe if we misname. Also what if an object needs >1?
No that's not a huge concern. We can do a warn log if needed

Draft 1 done, but it feels brittle. We shouldn't assume it's just player overlaps right?
Well, why not make different classes? Like a SnailTrailOverlap etc.? That's fairly easy for search...
eh, because it's inheritance vs composition? Frankly I like the idea of one overlap class with flavors
Such as "fresh" vs "any overlap", and just a first/second item
the tough part is how do we filter those? actually not that hard! consider the real use cases:

> I'm a crop. Find all overlap events with (me + a player ball) which are fresh. -> give points, level down
> I'm a LevelUpOnHit item. I'm looking for all new overlaps between crops, player balls which are fresh...
> I'm SnailTrailItem. Looking for all (not new) overlaps between a snail trail segment and a crop -> try level up
> eh for that last one, it's maybe simpler for SnailTrailSegment to do an overlap check
> but I can imagine an item that's like "look for all overlaps of XYZ on crops, spawn a laser"
> A "looking glass" hovering over the board

Maybe on area enter/exit is a good enough? Do we really need the extra checks?
Simpler is better, but we shouldn't give up a core design feature for the sake of slightly simpler logic

just build it dude. don't solve phantasm problems

---

What's the bare minimum functionality?
Well, we need the sprite to show up
Means we also need a crop spawner item!
Imagine we only care about the round start one
simple enough. many ways to implement trigger, cheese way is have a state for hasBeenActivated
as discussed, should create a SpawnEvent, and those are all handled together near frame end by separate code
For that, we need a way to instance this scene
When player overlaps it, give some points and downlevel -> PointsEvent
big question: how to represent such an overlap? should I think or just try something?
I mean definitely we will query player for overlap event(s)
But from there, we need to figure out which crop it applies to.
should all that logic be inside our crop class? Or perhaps the player generates not one overlap but multi
based on which areas it detects etc. And then each one is like Overlap { itemRef, bounce_count, ... }
or we generate both? eh, in that case it's possible for inconsistent state no?
I like to have more logic inside individual items to begin, and if we see pattern we can extract. that's flexible

So to sum up:
player physics event -> return a OverlapEvent(originator, size, etc.)
in crop tick activate, filter for such events which are from a PlayerBall (or perhaps with a given tags)
and for each one, we do our downlevel and generate a GivePointsEvent(), play whatever effects
we'll also maintain some internal state!

hmm ok if there are 2 events level up and level down, but we are at level 0, then order matters
we would always want to evaluate the level up event first. but that knowledge can live isolated here!
Fair, don't need a system level solution
It should try and level up each tick, with some percent
For that, we should create a level up event, but also directly mod our state
The point of the event is only for triggering other stuff
If we need to truly "intercept" / change that level up

Stretch (afterwards):
chance grow on hit
ideally this lives in a different item entirely?
that item listens for player overlap events and creates attempt level up events
Ah, one tricky thing: If we modify the level within crop.activate, then we might despawn before we can ever
trigger such a level up event. Would be better if crop creates a ChangeLevelEvent, defer both -> next round
that also helps us I guess for "Increase hit damage" modifier maybe? many ways to achieve that though
like it could be a status effect on the player which impacts their "damage" state var
or it could be an event modifier which makes every hit-triggered negative ChangeLevelEvent from a crop more big
like, one of these seems suspiciously more simple...

ok actually, that brings up an idea - should even leveling down/taking damage on hit be defined as a different
item? well, the crop has the context about what it's overlapping etc. because it has the hitbox
but presumably we could have another item just querying X overlaps Y and generating events

It feels a bit bad to have too much behavior in crop because then to influence that we only have 2 options:
status effect or events. Hmm at the same time, what is simpler? What will end up mattering for end user?

If we have a real ability idea we want to add, and it necessitates that, sure go ahead! Let's come at it with
the real motivation, not theoreticals which are exhausting. No mental cycles wasted on speculation.
enabling player bouncy
a status effect on crop for isEnableCollision. then each frame we try and declaratively move the real state
of the collision object closer to that desired, however this may fail if for example state is false but player
is overlapping us and we're not allowed. Quite easy to check, we can use our hitbox no? or phys query
Snail trail

***
Overall structure

```
Given (tick, score, [EquippedItem{ Item, Slot }])

Apply item status effects -> new events
Advance physics -> new events
Eval trigger groups for items -> new events
    Create trigger context
    Evaluate triggers
    Apply actions
Apply events ([de]-spawn, add status effect)
Clean up (if level <= 0, queue free())
```

---

# Item impls round 2 yeee

### Mini ball hitting coins

We just want a basic one. It's not a second roller
Idea is: every 20 give points, we spawn a miniball which can hit and kill crops, bounce off stuff etc.
item interactions will be interesting. Anything using bounce event we must switch perhaps...oh wait we're good!

Ok, firstly this FreshOverlap thing is overrated. It should just be "hit" and
explicitly have an aggressor and a receiver
how to have the mini ball also do hits (and maybe bounces)? hmm good q...
should it collide with the player / walls? walls easy, player eh
speed buff -> players, not miniball?

walls on different layer okie dokie

let's set up basic skellington...

extract ProjectileBody
defined as collisionBody which can bounce and hit
is NOT an item, just regular old Godot composition

# Crop idea (bankrolled bazillionaire)

[ ] Ball: damage numbers
[ ] auto-add source trace (like stack trace) for ALL events
[ ] Tags as method, not field (ez to override), also "hasAny/hasAll"
[ ] Bug fix: stuck between colliders at high speeds
[ ] Item stacking (ex: more slime trail item -> increase level up chance, NOT)
[ ] Items: coin level up time is decreased
[ ] Items: temporarily do ZERO damage
[ ] Items: when killing a coin, may level up the lowest value coin = highest value
[ ] Items: Combo - hit N ascending count values in row gives value = N x last (each time)
[ ] Items: PiggyBank. Every hit on adjacent adds its value to the bank, has interest. Boom after 10 hits
[ ] Items: higher base spawn level of coins
[ ] Items: the lower your stamina, the higher your speed
[ ] Items: reduce all cooldowns
[ ] Items: Status effects last longer
[ ] Items: Mini ball which briefly hits other coins (can trigger events)
[X] ~~Item IS itemref? nah queue free~~
[X] Items: Crop code could be a lot simpler!
[X] Design: Item system design more generic
[X] Design: Clean up unused code in item system and related
[X] Items: Count overlap while bounce as hit also?
[X] Design: Basic framework for status effects (dedupe)
[X] Design: Migrate player ball to item system
[X] Design: Migrate crop to item system
[X] Design: Implement for add stamina
[X] Design: Rough sketch of architecture
[X] Bug fix: only 2 lives not 3?
[X] Bug fix: overlapping items spawn
[X] SFX: Roll, bounce, crop hit (+coins), crop grow, crop spawn
[X] UX: Display full item value (formatted), not exponent
[X] Round: Rogue choose item between
[X] Round: Multiple "spins" to hit quota (3 tries?)
[X] Items: We deal more "damage" (downlevel coin more)
[X] Items: Trail is distance based, not time? oohh speed vs. slow synergy...
[X] Items: Trail of fertilizer
[X] Items: Ball bouncy off crops for a moment
[X] Items: don't spawn collider in same square as ball! (check would overlap?)
[X] Items: Increase our hitbox size status effect
[X] Items: Spawn a bounce pillar
[X] Items: Chance grow the crop you roll over
[X] Items: Chance to spawn a new crop when ball bounce
[X] Items: Speed on kill a crop
[X] Items: Increase stamina
[X] Level: Basic multi-level + permadeath
[X] Board: crop glow up
[X] Board: crop growth
[X] Board: Generate level with random crops
[X] Ball: ensure launches at close to diagonal angle (else stuck)
[X] Ball: randomize bounce angle, and/or random curve motion?
[X] Board: visual grid
[X] Ball: Decide rigid vs character
[X] Board: Crop per square
[X] Ball: Implement just bouncing off walls
[X] Ball: Detect hit on a crop
[X] Ball: Get points when hit crop
[X] Ball: stamina system
[X] Ball: game quota, win/lose

# Item system challenge items!

> Items: coin level up time is decreased

Simple enough - a status effect -> levelUpFactor
levelUpFactor used in level up probability expression

> Items: higher base spawn level of coins

hmm, a bit trickier:

- status effect on spawner? too narrow, what about ones spawned by other items
- could be status effect on any item which spawns crop, but how to know?
- a central status effect paramvar, everything references. could work! bit more lift
    - I like this the most. Simple but job done!
- an interceptor in the spawn handling code? doesn't feel very generic, but requires no wiring
- give items capacity to intercept events in a final stage. maybe they're given a mutable list, and each modifies it...
    - but spawning is done via lambdas right now. we will need it to be pure data in order to be interceptable
    - this is a pretty ok generic solution, but requires extending our overall system
- coin itself handles? wouldn't exactly work, we need a status effect applied instantly right...

> Items: temporarily do ZERO damage

- status effect and/or paramvar effect?
    - how does this interact with "more damage" status effect? do we need ordering?
    - or maybe that can be implicit in the damage equation. EnableFactor (1 or 0) * ( base + moreDamageEffects )?
- Event interceptor fits nicely. Hits have an "intensity" -> we just set that to zero
    - but then we need an interceptor after the pre-step event calc phase (i.e. physics phase), seems a bit much?
    - let's imagine there's no multi-stage, only two methods. then yeah this is clean enough

Central paramvar approach still feels nice to me?
It can even be done using the same framework tbh. Like the variable holder can be an item with status effects
and each variable a property obj with tags

---

status effect/item modifier - can it be done more centrally? similar to paramvars
for solving the problem of impacting "everything" from one place - ex: reduce ALL cooldowns
and also not having to keep track of which items we already added some effect to
could have something like a global cooldown factor defaults to 1.
but we can subtract from it

this might not fully replace item status effects though.
also it's a bit less flexible by design. per-item effects work nicely with tags
ex: reduce cooldowns for all bible-related items

I guess what I'm really worried about is how to do the tagging
and how to do exactly-once application semantics, even for items added AFTER the initial apply

I think these are pointing me towards: central system, but item-level config
an item would still just have state variables with tags, and not have to care about how many status effects etc.
from the item logic's POV, I just see my "desired" speed/size, and can move my state to reflect that (velocity etc)
for any special status effects, can be handled by a totally separate item, such as creating a bubble shield (fictional!)
all our current status effects can be done that way methink

just make it config: AddStatusEffect { ... effectId, addNewEveryFrame }
then status effect system just checks if one with the id already exists
and the status effect itself can have `isOneShot` and track if it's been applied

addNewEveryFrame is super easy, just modify the duration = 0, and add sfx after counting down timers
we don't even need an effectId, hell we don't need a param, just a named constant or a static factory
oh wait, but then how do we do both:

- updating the effect in place (maybe we change its intensity function)
- also one-shot

Those are intrinsically not compatible. The behavior *should* be that we respect oneshot, and any further
addStatusEffect will fail, updated or not. But for this, we can't use the elegant system and will need an ID
or else each source item will need to track ids it's applied to (nightmarish, sad, bad)
adding a trigger UUID is not that hard

example:

- not applyOnce, but oneShot: stamina instant boost (like "heal hp")
- applyOnce, not oneshot: dynamic speed boost based on remaining hp (aka an intensity function, which can vary)
- both: bump level of every spawned crop exactly one time a bit after it spawns
- neither: a typical temp buff like add speed on kill, or add size on hit

> Items: the lower your stamina, the higher your speed

fascinating. I dunno actually haha

- add one-frame status effects for speed based on stamina remaining for each roller?
    - pretty good, simple, easy
    - but it does feel a tiny bit hacky - it achieves the goal very indirectly
    - broadly the issue then is how to dynamically adjust some property on an item based on conditions
    - nice thing: if something increases the intensity of THIS item, then the next status effects it applies will
      reflect
- a custom status effect which adds to speed based on a multiple?
    - maybe can be generic: an expression var for intensity? but based upon what...property name substitution maybe?
    - more elegant and direct
    - what if we want to modify that custom status effect? like, increase the factor? hmm
        - use a shared unique id, and use computeIfAbsent semantics + mutate the effect? hmm...that works!

probably both fine. it's not super conclusive? Former feels easier (no EL), but EL not THAT hard
it could even be a lambda function(targetItem, statusFxState) -> float intensity, not an EL
in fact that seems like a generally nice thing we'd want to do for attenuating effect by duration, anyhow
an expression is cool for visibility, but isn't terrifically important. and it's less flexible/more boiler

ok yeah then the above 2 choices aren't total dichotomies. the real difference is:

- keep one status effect, and computeIfAbsent
- new status effect each frame

easy to see latter is simpler

> Item: force trigger another

- ForceTrigger(ItemRef) event -> every item handles it optionally
    - simple, but boilerplate
    - can we somehow reduce the boiler? I.e. separate the action into a private method, then it's quite simple nah?
- Break items into TriggerGroups with triggers/actions
    - TriggerGroups can opt-in to allowing force trigger
    - does this break for cases where the trigger is used to compute values the action uses?
    - for example, passing the source of a despawn -> downstream ppl. hmm yeah
    - but it's a a possible major refactor!
- Expose actions as lambdas (with names / opt in flag etc.) - and handle force triggers via their own way
    - Not all that generic. I think the wider problem is "runtime modification of trigger conditions"
- Turn a forceTrigger event into exactly the conditions that would cause a trigger normally
    - This seems very jank and overly complex
- Triggers/actions as pure config, which we can modify at runtime
    - Definitely the most generic way. This allows us to basically reprogram an item on the fly which is cool
    - however, that's maybe not necessary? I think status effects + a bit of smart design get us 90% of the way
    - but without the work of fully generifying triggers (maybe that's simpler than I thought?)

> Item: Kaboom

There's a bomb, when it blows up it sets the ball's direction and gives it a short speed buff, and obliterate self
and also counts as a hit on adjacent cells

the novel problems:
First: changing ball direction?

- new event type?
- directly modify ball dir? big nono, very sad no I not no pls no
- trigger blow up off bounce - that way ball definitely gets blasted?
    - that does not solve impacting OTHER balls
      Partial to an "ImpulseEvent" - anything can react to this!

Second:

AOE could be a modifiable. Maybe even a random number of cells?
EASILY solved - itemParam with some tags, ye hwee

> Items: when killing a coin, may level up the lowest value coin = highest value

Pretty easy! Trigger despawn with tag crop, find lowest and highest value existing crop,
then a level up event on the lowest crop

> Items: Future: Mark price equal to adjacent items on spawn. Make 10x Delta value on expire

> Items: PiggyBank. Every hit on adjacent adds its value to the bank, has interest. Boom after 10 hits

I suppose we'll need a spawner for this too. Maybe generify the spawner actually
There's gonna be a ton of things that need spawners...
At the same time, an item is fine and not THAT much boilerplate.
We can even define it as an inner class to avoid needing more files...

> Items: Dominoes - hit N ascending count values in row gives value = N x last (each time)

Maintains some state per roller. Each time there's a hit on a crop, we track the value in some array
we take the last value of the array, looking backwards to find current combo length
then we iterate through the new events, looking for the next value, give points
If we can find then ext, then keep going...
Sort events in same frame to maximize value to player?

This is the kind of state I think doesn't make sense to force trigger...
like how would we do that? maybe just give the points again but like...

> Items: Status effects last longer

- Event interception (when?)
- Special thing in status effect system (change delta, or add time on create?)
- ParamVar multiplier
- Yet another status effect?
- status effects on status effects (ugh yucky!)

> Items: Count overlap while bounce as hit also?

Pretty easy - an item looks for when player overlaps stuff -> it's a hit!
maybe with some throttling to not be tremendously overwhelming haha

> Items: Mini ball which briefly hits other coins (can trigger events)

easy enough - spawn a bilbo balbo belbo bulbo ballbo
Would rather not replicate all the roller code
so maybe it shouldn't have speed buffs?

One thing - do we want to replicate hitting and overlap code? That also feels annoying
I imagine we'll want many types of projectiles
It might be good to extract shared logic for these, eventually:

- Motion
- Safe-spawning / safe enabling
- What counts as a "new hit"
- Producing overlap events / being overlapped
- Reacting to impulses

> Every 3 spins, all symbols are considered adjacent.

Generally, something making restrictive but powerful triggers not so restrictive

This one, I'm genuinely not sure.

- Adjacency checks delegate to some central object, which we can change to return true always or be more lenient?
- Make adjacency an event, and manufacture events (so many events ahhh!! not really a perf concern, just logically...)

What about something which "triggers adjacent items" or whatnot. We'd need to return the full list of items or
more items which match a wider AOE, something like...

And uh it would be nice to do this more granularly than "100% of items"
So in that central approach, we can maybe check if the caller matches certain tags or whatnot

> The conditional effects of essences must happen 2 times for them to be destroyed.



> Re roll the board (en masse despawn)

Trivial

> Randomize triggers for all items?

Ok that's a little extreme. Feels like quite a pickle when you have unique triggers like for me
In Nubby, there's only like a handful of triggers which makes it a bit simpler: Pop, halve, double, etc.
They are quite context agnostic - so a trigger is literally just an enum with no extra data (or so I believe)

Still, it's doable. We'd want to separate trigger and action code
And we'll also need to make sure actions don't require trigger context to perform.
I.e. killing a crop -> speed buff on the ball that killed it, this doesn't work. We don't know which ball (if force
trigger)
the action should instead apply a status to maybe the nearest ball (even under regular trigger)
or we can define special defaults for the force trigger case. feels not very generic though.
like what if we aren't force triggering but just broadening the conditions for regular trigger hnng...

But all that work for what amounts to a cheap laugh isn't a great feeling
It would need to be a more interesting item, like: when I possess this, any item triggering off of
a crop being destroyed will now also have a chance to trigger on a level down
that's achievable already by something like "when I see level down, create a fake kill event"

> Changing probability distributions

Don't need to be too fancy. Just modifying chances fits decently into status effects

Ah ok maybe we can stick with dicts for now. It's just...super easy yeah, and we can dupe
A status effect could look at all these + its own state (duration, base duration, etc.)
Rather than doing properties which require a bit more thought

- speed
  - 
- stamina
  - 
- size
  - 

hmm but is it bad to have properties?

```
ItemParam
    name: "roller_speed"
    baseValue: 15.0 # using a float, we can represent float, int, and bool (0 vs other)
    tags: ["physical", "speed"]
    validator: callable(value) -> validatedValue, ex: clamp
    value():

status effects just make it go up or down I guess

Roller:
    stamina: ItemParam
    speed: ItemParam
    damage: ItemParam
```

> Dud item, added as a challenge on later levels, or as a negative effect

Pretty darn easy. We already have bounce pillar. We can make an item like that but with infinite HP

> Items: Drop stuff in middle of round (with some limit)?

Will require a new system somewhat.
Could be drag and drop. While deciding, ideally match should slow down.
Feels doable by adjusting delta? but lots of things trigger based on tick, not delta!

> Items with across-round state, like "only usable 5 times"

> More options / cheaper cost in store

> Transform common item -> super rare one

# Looking at some competitors in this genre

Loosely defined as roguelike deckbuilding auto-battler
Distinct from games like slay the spire - you don't choose the moves per round, only the layout of your deck

https://www.kaggle.com/datasets/fronkongames/steam-games-dataset/data
https://howtomarketagame.com/2019/12/11/how-i-do-competitive-analysis-for-my-game/

### Top level insights/takeaways

### Big one is backpack battles

### 9 kings my beloved

### SuperTaxCity

# The pivot aeugh

I think I've overscoped a bit.
But we can step back! We can do better!

I am deeply inspired by the Nubby number factory
I think this is the direction I can take my pig ball chumibuletmas game from last year
Give it a deckbuilding element!

Item system should be largely identical/reusable

How do we differentiate?
Hmm do we have to? The goal is to make something fun and deliver it widely
I think freshness is good!

A few thematic ideas:

- Suppressing peasants to ensure taxes collected
    - Thematically pretty fresh and there's room to be funny / tongue-in-cheek.
    - I definitely think more of a gritty / gore filled theme will appeal to rogue audiences
    - Question is: Can we really go crazy with synergies this way?
- Harvesting crops by rolling over them
    - More logically consistent but maybe less funny. Easier to justify "new plant grew" vs "new person popped up?"
    - Futures/options on the crops? Haha jkjk unless
    - Aeugh organ farmer yeess
    - Nah crops good. I can think of a lot of nice stuff that fits, it's coherent in a nice way, but chaotic enough!
    - Oh ho ho wait...we're an enforcer punishing condemned souls in some kind of afterlife, embodied as organ plants
- Fishing
- Something other, and highly absurd
- Accounting/Data Entry/ some menial desk job (retain Debby and the CHINESE motivation?)

Cute, but also kind of ugly and lopsided
The great power of chitch my queen
The taxation element: we must MEET the tithe, not collect it
How much can we attain hmm

Alright round 2. Actually I'm a bit opposed to the crops thing.
That just feels so hard to differentiate from the 10 billion farming games. Like why would I see that and click?

We want something ideally that:

- Stands out visually / narratively
- I'm genuinely passionate about
- Potential for a lot of depth
- Fits with a simple art style
- Makes some lick of logical sense, this is a loose requirement

- Organ farmer - just crops but weird!
- Punishing sinners in hell (by rolling over them)
- Tax collector medieval
- Tax collector modern financial (the fed)
- Fishing - sand dollar etc.
- Literal garbage, rolling around in garbage
- In a sewer, a little rat/gremlin thing rolling over susshrooms
- A rolling pin rolling over dough (food theme). What does leveling up mean?

Visually I'm so impressed by cruelty squad and nubby.
Those assets take very little time to make, but they are ultimately very unique and nice!

HROT and any David Szcymanski game are also decent visual guides - those styles are harder than they look though!
I should know, I tried...But that's maybe my own perfectionism

The fuck is this?
https://store.steampowered.com/app/3139570/Coop_Kaiju_Horror_Cooking/?curator_clanid=41064705
It's actually charming kind of hehe

I like the medieval vibe and retro graphics. I'm definitely very passionate about the ye olde aesthetic

aeugh too much to think about, let's pivot to SWE

### Crops ideas

As always we have a grid (my beloved shape!)
The pigball rolls OVER crops by default, doesn't bounce
Crops have levels like in nubby - they grow some % value each level, but rolling over knocks down the level
There's limited stamina, so it's a challenge to fill the quota within that time (or we can upgrade stamina)
We equip items / relics.
We start with only a very basic crop, but cards can add more

The experience we aim for is similar to the weaponized fish game, the main difference is lower scope:

- Items don't do inventory tetris -> placement UI can be much simpler to start
- Don't need to balance for competitive human v human play
- Don't need to implement multiplayer at all, or the genetic algo (though the latter maybe can be fun/balance tool!)

hoho I'm the ideas ~~guy~~ (NOT) I have the BEST ideas - can I pay you 5 bucks to create?
AI, AI ML, the entrepreneur - non technical founder building quick quciker than ever before

Need to be self aware of limiting the scope. APPLY the lessons we earned hard from last time

What's the bare minimum we need to be fun?

- Bounce system
    - It's super rewarding to bounce between a bunch of close-together items. Quick payoff
    - But it might also destroy the crops faster

More on differentiation

- Lean into the mechanics we can achieve by having cards generate the board, not "be" the board
- Offer some degree of control over positioning? Ex: we can have card slots correspond to board segments
- We want to pick a thematic and art style which stands out. It need not be "beautiful" so much as eye catching
- Some kind of challenge/curse system randomized per round

# Auto battle logic system

[X] Definitions for item config (keep it basic!)
[X] Design high level API for round / turns (no Godot yet!)
[X] Add player class
[ ] Do just enough to add a tooth item
[ ] Impl timer as expression language

### Implementing just the periodic trigger weapon

Timer is just a shortcut for the condition where `if (match.tick - trigger.last_tick) > PERIOD`
And then an action resetting trigger.last_tick = match.tick
^^ Important because: what if another required trigger is not met? action doesn't happen, should we reset?
^^ I guess we can make that configurable. Makes sense to still count as a "try" if reason is out of stamina
I think we'll have a "compile" stage where we expand our a periodic trigger into basically the above
But for now, we can build a more specialized one just 2b a happy bee

We DO need some concept of a trigger accessing its own last state

Probably trigger evaluation will happen in some kind of context
Maybe the trigger itself can even modify the context? Not needed right now

```
interface TriggerHandler<TriggerT>:
    bool EvaluateTriggerCondition(TriggerContext)

TriggerContext
    // hnngg we can even have tiger pricing lookback style expression vars. Prolly just "prev tick" haha
    // All these States are immutable!
    // Do we need this strict structure, or just a string map/enum map is fine?
    MatchState { CurrentTick }
    PlayerState { Health }
    ItemState {  }
    BehaviorState { LastTriggerTick }
    TriggerState { }
    // a temp area for holding short-lived vars!
    // or maybe we should have one per each above scope?
    TempState { }

class ModifyStateVariableActionHandler
    // This will just generate events - maybe doesn't even need to be 
    // It's nice if all changes to state happen in events
    // Despite the indirection, it's consistent and simple

class ModifyStateVariableEvent
    Path: str or maybe an enum? // 'behavior.last_trigger_tick'
    Operation: enum { ADD, SET, SUBTRACT }
    Value: '10%' '5' '18'
```

### Item modifiers

Say we have an adrenaline gland, meant to speed up fire rate as long as health is below some amount
How would we implement this? Well, the triggering part is trivial, but for the action...
We can't just say "Reduce cooldown by 0.1s" - what happens when health goes above threshold then down again?
Sure, we could add some framework for "reversing" an action, but do we want to have to define this for every action?
And what about actions which aren't straightforward to reverse? ex:

- Let's assume cooldown for X right now is 0.5s
- Item Z applies a modifier, changes x cooldown to 1.0s
- But another one brought it down to 0.1
- Now Z is deactivated. Should we subtract 0.5 from the cooldown? we'd be capped at 0
- And later, we add back the 0.9, now we're at a higher baseline? hmm

This one example can be worked around, but fundamental problem is state mods are maybe lossy

So a better solution is to keep a separate object, the ItemModifier (or Item Status Effect)
And an item with passive adjacency effect is just adding a modifier (1 tick duration) at start of each turn
And it's triggering onEveryTick

---

### Overall pipeline structure

```
Tick Start (input MatchState)

Book-keeping: Increment tick

Iterate items, evaluate triggers, apply actions
    First, break up behaviors into groups based on priority rules
        Ex: Behaviors with item modifier actions must go first
        So that we can apply those modifiers before other stuff happens
    In each group, evaluate triggers and spit out the events/action results
    Apply some actions now (item mods etc), or defer to later

Iterate status effects, generate events

Process events
    Apply any event modifiers (status effects, or in the future any special bonuses)

Evaluate win loss
```

### Initial thoughts

What should the items do (mvp)?

- Damage/consume stamina, Stamina regen rate
- For now, POC, not trying to design the real cards. Just enough to strain the brain!
- For the substrates, armor value vs. stam drain
- 1-2 position effect: adipose block for stam, muscle for +str
    - These will be a "modifier" system
    - Also impl a way to check for nearby squares
- Weapon stat variation: default, light fast, heavy and slow
- Weapon with bleed, and something which stops bleed effects (coagulator)
- Health regen: Heart
- Most items limit base speed
- Shield / shell effect - absorb some amount of damage then self destruct

State and win condition

- Health and stamina
- Static attributes, or fully buff debuff based?
    - I.e. does a tail give you a temp speed buff per trigger, or permanent?
    - Why not both? base speed + temp buffs
    - Temp is good b/c higher fire rate or more strong -> more speed, or disabling opponent's tail

Defining item configuration

```
ItemConfig:
    triggers[]:
        trigger (oneof):
            interval:
                wait_times[]: usually just one (period), but can define a cycle
            round_start: for passive effects
            on_status_effect: # if I have more than 10 bleed stacks, etc.
            on_state: # hp < 25% of max
    effects { id <-> effect }:
        modify_stamina (for stam drain):
        deal_damage ():
        apply_status_effect: # ex: bleed, temp speed boost
            target
            status_effect
            amount (can be negative!)
        apply_item_modifier: # ex: reduce stam cost of nearby items
            targeting_config:
                distance
            item_modifier:
                
        apply_passive_effect: # ex: item ups max hp
            target
            passive_effect

ItemModifierConfig:
    
 
PassiveEffectConfig:
    set_passive_stat:
        stat_type: base HP, max stam?
        modify_amt: # +10, -20

# Bleed damage
StatusEffectConfig:
    duration
```

Overall, we will have a pipeline wherein:

- The ItemConfig is immutable. Everything is an effect atop the base
- Each turn,
- Instanced item
- Generate events

---

Good ideas post feedback from Gemini:

> > Map from trigger <-> action forces a 1-to-1 constraint

- Instead, make another object which can have n triggers, n actions (call it a behavior?)

```
  behaviors:
    - trigger:
        type: "interval"
        period: 2.0 # seconds
      actions:
        - type: "StaminaCost" # First, pay the cost
          amount: "@param.stamina_cost" # Reference this item's own state
        - type: "Damage"
          target: "Enemy"
          amount: 15
          damage_type: "slashing"
```

> > How do we define cost constraints?

- Not allowed to trigger this unless current stamina > 10
- One idea: add a "conditions"

```
behaviors:
- trigger:
    type: "interval"
    period: 2.0 # seconds
  conditions:
    type: "Stamina"
    threshold: "@param.stamina_cost" 
  actions:
    - type: "StaminaCost" # First, pay the cost
      amount: "@param.stamina_cost" # Reference this item's own state
```

- A little inconvenient! Would be nicer to do this implicitly
- Perhaps actions can be configured as a cost or not
- When evaluating an action, it first returns whether it can happen?
- So we do that for every action, and finally

Yeah this is C# territory probably. I'm kind of scared but let's do?

> > For item modifiers:

- Complex (and not easily reversible) to make something that walks the tree and directly modifies the definition
- Flip the problem around: take the fields you want to modify and make them centrally defined per item instance

```
ItemDefinition:
  id: "whetstone"
  name: "Whetstone"
  tags: ["utility", "enhancer"]
  behaviors:
    - trigger:
        type: "RoundStart"
      actions:
        - type: "ModifyItemComponent"
          target: "AdjacentItemsWithTag(weapon)" # Target adjacent items which = weapon
          component_to_modify: "@damage.amount" # Reference the central var
          operation: "+10%" # we do an expression lang here! quite powerful
```

> > Expression language

Powerful - we can modify central parameters

```
ItemDefinition:
  # We'll have an enum with possible values
  parameters:
    cooldown_duration: 5
    current_cooldown: 0
  behaviors:
    - trigger:
        type: "interval"
        period: "@cooldown_duration"
```

Godot has an `Expression` class

```
var expression = Expression.new()
expression.parse("20 + 10*2 - 5/2.0")
var result = expression.execute()
print(result)  # 37.5
```

We can imagine composing this with modifiers and relative things like 'percent of base stat'

`((@parameters.base_damage + 10%) * 3) + 15`

Hmm maybe too complex? haha, we maybe don't need this yet?

> > Targeting config can be made first class

```
"SelfPlayer", "EnemyPlayer", "SelfItem", "AdjacentItems(distance)", "ItemsWithTag(healing)",
```

Idea from backpack battles - rather than distance, specify particular relative item positions.
Each relative position can also have a "type" (star vs diamond) - say, we apply a different effect per

> > Open Close principle - ensure adding new action != change too many if branches

- Enums for actions and triggers
- Specialized handler class / method system
    - ApplyStatusEffect handler - knows it == ENUM.ACTIONS.APPLY_STATUS_EFFECT
- The config for an action will be an enum + a bunch of sections, each one for one enum value
    - Similar to Dripper config with constrainingStrategy
- Runtime registration, look up by enum
    - In game, we instance items and pass them through an ItemProcessor
    - This processor only knows how to generically handle triggers and actions
    - It delegates any specifics to the handler classes, looked up by enum

```
ProcessAction(ActionConfig action, ItemInstance source) {
    actionHandler = ACTION_HANDLER_MAP.get(ActionConfig.action_type)
    result = actionHandler.execute(source, action.parameters);
    storeStateFromResult()
}
```

> > Status effects ARE items??

- Saves us needing to reinvent a trigger system and all that
- It's also super generic!

> > Consuming buffs

- Ex: shell buff. After taking a hit (and reducing hit damage), they go away
- How do we define this in ItemConfig?

```
ShellItem:
    triggers:
        - take damage
    actions:
        - add one hp
        - destroy self
```

Hmm, but that's not quiiiite enough...
Because in that case, all shells will be consumed every time we take damage

1. Special system just for shells. Simple, but is it scalable for more types?
2. Expose damage state variable which is mutable?
3. Status effects as a separate thing, not items (maybe fine?)
4. Damage is an event, an editable object available to trigger/action API

This last one, I like. We probably want that anyways because event log good
Ok, but how do we evaluate this kind of thing correctly?
Like, let's say one of our items generates self damage events, and we also have shields
We can't just go through all triggers, what if we eval shields first?

I feel like we need one stage to generate all events, then another where we only eval event triggers
We can use some prioritization order to ensure reasonable evaluation within each stage
We'll need to make the assumption that those event triggers don't produce more events, hnnnggg
Hmm, or perhaps we can just check for new events and run again? eh seems bad.

Also this level of granularity isn't what the user would care to see in the event log I feel

They'd just want to know:

- "I took X damage, here are the sources"
- "X damage from Y blocked by Z"

We can make configurable LOD and other nice search goodies (for later!)

What status effects do we need? Do they really HAVE to be items?

- Shield (turtle shell?)
- Metabolism
- Momentum
- Stun
- Poison

Status effect *can* add another effect, like a poison crit could cause a stun

```
StatusEffect:
    hit_points:
    
```

Beware of monolithitis!
At the same time, a generic event system could prove useful!
Maybe a regular organ could be a damage absorber or whatever, and have item HP, and we'd want to display that...

```
DamageEvent:
    type: blunt
    amt: 30
    source: crab_claw

DamageAbsorberItem:
    item_hp: 20
    trigger:
        damage_event:
            types: [] # means any
        action:
            take_item_damage:
                amount: '@event.damage'
                actions_on_zero:
                    remove_item?
            modify_damage_event:
                '@take_item_damage'

ItemRepresentation:
    on_item_health_changed(old, new) -> some animation/visuals
    on_removal -> etc.
```

```
for each item:
    

```

> > Dodge chance from speed?


> > Criticals

---

Save/load data between creation -> battle

Overall flow:

- Match start, compute static passive bonuses (stat modifiers, and overall)

# Differentiating from other roguelike autobattlers

A few concepts to explore:

- Does it have to be unique to be worth it?
- Organ health and positional targeting - position on board matters more
    - There isn't just one player - you are fully the composition of your elements
    - There is then a natural way to place shields, weapons, propellers, eyes, etc.
    - Redundancies are necessary - and theorycrafting is deep because you account for round progress
- The setting and concept are themselves quite unique!
    - You are building a biopunk abomination out of organs and cannons
    - The art can and should be kind of gross!
- A stronger programmatic element
    - Actions are collectible, but conditions are user-customized
    - Actions need to be powerful tradeoffs, desirable only in niche situations
    - Autocannibalism, shutting an organ off, growing an organ
- Creatures can generate more creatures
    - My design might be good as a whole, but if we make a modular part which is itself strong, is that good?

# Pep talk

oh my god the existing games in this genre are good!
If I think about competing with those in the marketplace, it's super daunting, and emotionally exhausting!

I'd invite you to ask: what's important now?

By far the most important: This is a hobby, and we do it because it's fun (with learning being a welcome bonus)
I can't control what those people are doing, or how good they are. Only how quickly I improve
Moreover, it isn't a competition at all! And we can see this proven by the fact that far "worse" games in terms of
execution can still have a community and people who enjoy it.

The fact that good things exist doesn't change the baseline of what "fun" is
And ultimately, if you have a concrete goal, let it be that I want to make a fun game for a niche audience!

Consider that even the full monetary returns of a pretty wild success are still like maybe 300k ish?
And spread between multiple people, over multiple years...like in terms of finances, is that really so much?

Also - you are an indie, solo dev without that much experience!

# Random knowledge: delta step in movement calc!

```
def final_pos(steps):
    pos = 0.0
    vel = 0.0
    delta_t = 1.0 / steps # 1 second broken up into steps
    accel = 5
    for i in range(steps):
        # If we don't do this, resutls will be a bit different depending on how many steps
        # Ultimate goal: compute the same end position given the same change in real world time
        next_vel = vel + (accel * delta_t)
        mean_vel  =(vel + next_vel) / 2.0
        pos = pos + mean_vel * delta_t
        vel = next_vel
    print(pos)
print([final_pos(x) for x in range(1,10)])
```

# Selection menu

Simple way - use an ItemList for our menu
Once selected, a fish preview will appear
if we click and it's a valid position, then:

- fish is registered to grid
- fish appears there
- we remove / grey out from itemlist -> prevent placing again

and want a signal when all fish have been placed
easy enough to wire "placed" back from our grid

At start of round, we have some representation of our "deck" - pretty much pure data
good use of a "resource"?
We can bind each one to an item in that list programatically

# The opponent's grid

Squares need to be hidden at first
Once attacked, they should reveal if the square is empty or not

# Adding the fish

Just start with one!

A fish is really the emergent phenomenon of:

- A sprite
- A "shape" for the grid
- An ability
- Item in inventory

# Turn system

# Evolving the enemy

# Interesting idea! Can we add a programming element to this?

The backpack battler style is very static.
What if we could dynamically swap our own design, or choose actions?
Sounds fricking complicated!

Designing something like that, it should probably be the focus, nah?
Well it's basically an extension, but might be tough to balance.
I am SURE it can be done, and maybe it'll be fun.
Let's make a minimal one first though. Cool idea syndrome haha
I'm inspired by a game I just saw called Evolve Lab. Looks super fun! Bet we can do something like it hmm...

Agreed a state machine is the way to go
Their state machine is essentially a loop of actions, separated by some time distance
Why do they do it that way, and how does it contribute to the fun?
What are other ways to add a programmatic element? Ex: a node/flow state machine?

What is different about that vs. the "Everything at once" approach of the auto-battler style I'm doing?
Hmm. It's not totally clear to me either. I guess it lets you organize things into stages?
Which is a kind of programming for sure.

I guess timing in this one represents "positioning" in my idea. It's the "how" of combining the components.

IMO it makes not much sense to directly graft that onto my game

But I like the idea of a dynamic layer atop the static one we have with creature design
It can potentially open the door for highly unbalanced designs to shine
In the roguelike structure, your fish needs to be general enough to win consistently

Ah hmm, right like instead of states being "tracks" of sequential actions, they are configurations
And we program some kind of transition between these

The tough part - there's so much configuration!
Can parts be reused? How many states can you have

It feels like this doesn't quite scale. Managing more than 3 of these...ehhh yeah that's not going to hold haha

Ah, composition over inheritance mayhaps hmm yes.
Like each body segment can be a module, and we mix/match these within a round?
According to some conditions

No idea how we'd do this heehee

Designing sub-creatures? It just seems cool to me hehe. I launched a missile which has a mind and a heart
huh yeah that seems compelling and a bit more extensible.

Endocrine-style programming. Classic example: I'm near death, shut down combat systems so that more resources
go to health recovery / fins / avoidance and navigation.

That is more manageable - perhaps we swap out damage modules for something else

Maybe the conditions can even be meta-level like: What is the enemy config like?

Ok yeah this is scope creep. And makes sense to explore after we're finished, or as a separate game
It's hard to have the maturity to fully do that of course, but that's part of the challenge too!

Suffice to say, building the bones will enable us to do that

# The theme

The theme MUST center around taxation, fish, and being a little "bio punk" whatever that means?

I like having a competitive aspect. The "async multiplayer" is chef's kiss for that.