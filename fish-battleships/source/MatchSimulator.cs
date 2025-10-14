using System.Collections.Generic;
using Godot;

namespace FishBattleships.source;

internal class MatchSimulator
{
    // Some kind of player config? or we hardcode that
    // Definitely the item configs and their placements

    private void MainLoop()
    {
        // for loop
        //   state = advance match state
        //   eval win condition(state) -> none, win, loss
    }

    // "tick" function
    // state in, new state out
    // public MatchState advance_one_tick(MatchState)
    // Or, we just make this a match? the input data is the constructor, and state is object properties?
    // From a design perspective, keeping data separate is elegant, but maybe it's not a great idea?
    // Let's go with the functional way because it's nice

    private MatchState AdvanceMatchState(MatchState lastMatchState)
    {
        // book-keeping. Increment tick
        var newMatchState = lastMatchState with
        {
            Tick = lastMatchState.Tick + 1
        };
        // Item stage
        var (eventsToProcess, postItemMatchState) = ActivateItems(newMatchState);
        // Process events
        return ProcessEvents(eventsToProcess, postItemMatchState);
    }

    private (Events events, MatchState matchState) ActivateItems(MatchState matchState)
    {
        var items = matchState.OwnPlayerState.Items;
        foreach (var item in items)
        foreach (var behavior in item.Behaviors)
        {
            // evaluate triggers (an "and")
            var shouldDoAction = true;
            foreach (var trigger in behavior.Triggers)
                // construct Trigger expression lang context
                // delegate to TriggerEvaluator
                if (!EvaluateTrigger(trigger))
                    shouldDoAction = false;

            if (shouldDoAction)
                foreach (var action in behavior.Actions)
                {
                    // delegate to ActionHandler
                }
        }

        return (null, null);
    }

    private bool EvaluateTrigger(ItemTrigger trigger)
    {
        return false;
    }

    private MatchState ProcessEvents(Events events, MatchState matchState)
    {
        return null;
    }

    private bool EvaluateWinCondition(MatchState matchState)
    {
        return false;
    }
}

internal record MatchState(int Tick, PlayerState OwnPlayerState, PlayerState OtherPlayerState);

internal record Events(List<ModifyStateEvent> ModifyStateEvents, List<DamageEvent> DamageEvents);

internal record ModifyStateEvent(string Path, string Operation, string Value);

internal record DamageEvent(int Damage);

internal record PlayerState(
    int Health,
    int MaxHealth,
    int Stamina,
    int MaxStamina,
    List<Item> Items
);

internal record StatusEffect;

/**
 * We'll eventually want an originalItem, list of mods, then the compiledItem
 * That way, if something changes mid-game which impacts the mods, it'll be reflected
 * Ex: maybe an adrenaline gland bumps up fire rate on nearby items when health low
 * actually, can't we solve that with status effects? haha
 * For all intents, the compiledItem has the stats we care about!
 */
internal record ItemInstance(Item Item, List<Vector2I> CoveredTiles);

internal record BehaviorState(int LastActivatedTick);

/**
 * How to solve this?
 * issue is, every interval trigger needs its own state
 * we'd have to identify each trigger uniquely, perhaps via its path: behavior_0/trigger_0/interval
 * and how to do that in a type safe way? maybe we mirror the structure, have one TriggerState with subsections
 * 
 * But is this needed? Why would we even want >1 interval trigger?
 * Or for that matter, more than 1 type of trigger?
 * I guess that last one maybe makes sense - trigger on interval or if health under some amount
 * An item just needs one behavior probably, right?
 * Well, what about items with a passive benefit and an active one?
 * 
 * It's honestly not that hard to do paths, and probably we'll need those later on. Maybe just do it?
 */
internal record TriggerState(int LastTriggerTick);