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
    _inject(physics_calc, etc., location?)
    spawn()
    evaluate_status_effects() -> Array[ItemEvent]
    advance_physics(delta) -> Array[ItemEvent]
    evaluate_triggers(match_state) -> Array[ItemEvent]
    clean_up()
```

How do we pass the external dependencies? Such as physics calculator, grid calculator, etc
Ideally we inject those at construction time. Items can't really share a constructor sadly
I'm not gonna build an entire DI framework haha. We can just do a javabeans style "call this method to init me"



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

# Crop idea (bankrolled bazillionaire)

[ ] Ball: damage numbers
[ ] Bug fix: stuck between colliders at high speeds
[ ] Items: coin level up time is decreased
[ ] Items: higher base spawn level of coins
[ ] Items: temporarily do ZERO damage
[ ] Items: the lower your stamina, the higher your speed
[ ] Items: when killing a coin, may level up the lowest value coin = highest value
[ ] Items: Future: Mark price equal to adjacent items on spawn. Make 10x Delta value on expire
[ ] Items: PiggyBank. Every hit on adjacent adds its value to the bank, has interest. Boom after 10 hits
[ ] Items: Combo - hit N ascending count values in row gives value = N x last (each time)
[ ] Items: Status effects last longer
[ ] Items: Count overlap while bounce as hit also?
[ ] Items: Mini ball which briefly hits other coins (can trigger events)
[ ] Design: Item system design more generic
[ ] Design: Clean up unused code in item system and related
[ ] Design: Basic framework for status effects (dedupe)
[ ] Design: Migrate player ball to item system
[ ] Design: Migrate crop to item system
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