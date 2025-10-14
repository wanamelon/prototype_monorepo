using System;
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
        foreach (var behavior in item.Item.Behaviors)
        {
            var shouldDoAction = true;
            foreach (var trigger in behavior.Triggers)
                // construct Trigger expression lang context
                // delegate to TriggerEvaluator
                switch (trigger.TriggerType)
                {
                    case TriggerType.Interval:
                        // TODO: is this off by one?
                        if (matchState.Tick - item.LastActivatedTick <
                            secondsToTicks(trigger.IntervalTrigger.IntervalSeconds))
                            shouldDoAction = false;
                        break;
                }

            if (shouldDoAction)
            {
                item.LastActivatedTick = matchState.Tick;
                foreach (var action in behavior.Actions)
                    switch (action.ActionType)
                    {
                        case ActionType.Damage:
                            // TODO: Stop hardocding it dumbass!
                            // TODO: should be a damageEvent hnnggg!
                            matchState.OwnPlayerState.Health = Math.Max(0, matchState.OwnPlayerState.Health - 5);
                            break;
                        default:
                            throw new ArgumentOutOfRangeException();
                    }
            }
        }

        return (null, null);
    }

    private static int secondsToTicks(double seconds)
    {
        return (int)(seconds * 60.0);
    }

    private MatchState ProcessEvents(Events events, MatchState matchState)
    {
        return matchState;
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

internal class PlayerState(int health, int maxHealth, int stamina, int maxStamina, List<ItemState> items)
{
    public int Health { get; set; } = health;
    public int MaxHealth { get; } = maxHealth;
    public int Stamina { get; } = stamina;
    public int MaxStamina { get; } = maxStamina;
    public List<ItemState> Items { get; } = items;

    private PlayerState DeepCopy()
    {
        return new PlayerState(
            Health,
            MaxHealth,
            Stamina,
            MaxStamina,
            [..Items]);
    }
}

internal class ItemState
{
    public Item Item { get; }

    // TODO: should be per behavior eventually
    public int LastActivatedTick { get; set; }
}

internal record StatusEffect;

/**
 * We'll eventually want an originalItem, list of mods, then the compiledItem
 * That way, if something changes mid-game which impacts the mods, it'll be reflected
 * Ex: maybe an adrenaline gland bumps up fire rate on nearby items when health low
 * actually, can't we solve that with status effects? haha
 * For all intents, the compiledItem has the stats we care about!
 */
internal record ItemInstance(Item Item, List<Vector2I> CoveredTiles);