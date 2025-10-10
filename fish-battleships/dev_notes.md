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

# Tiny todo list

[X] Want to fix bug where if my mouse is on
[X] Drag item around board again
[ ] Multiple items, check overlap
[ ] Dragging placed item back to an item area
[ ] Singleton signal for drag end (success vs fail)? Cleaner that way

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