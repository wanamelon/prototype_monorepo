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