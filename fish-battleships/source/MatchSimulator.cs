using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

namespace FishBattleships.source;

public class MatchSimulator
{
    // Some kind of player config? or we hardcode that
    // Definitely the item configs and their placements

    private readonly MatchState _matchState;
    private MatchOutcome _matchOutcome = MatchOutcome.InProgress;

    public MatchSimulator(IReadOnlyList<Item> ownItems, IReadOnlyList<Item> otherItems)
    {
        var ownItemStates = ownItems.Select(item => new ItemState(item, 0)).ToList();
        var otherItemStates = otherItems.Select(item => new ItemState(item, 0)).ToList();
        _matchState = new MatchState(
            0,
            new PlayerState("Own", 100, 100, 10, 10, ownItemStates),
            new PlayerState("TheOther", 100, 100, 10, 10, otherItemStates));
    }


    public bool MainLoop()
    {
        if (_matchOutcome == MatchOutcome.InProgress)
        {
            _matchState.Tick += 1;
            ActivateItems(_matchState);
            GD.Print(_matchState);
            _matchOutcome = EvaluateWinCondition(_matchState);
            if (_matchOutcome != MatchOutcome.InProgress) GD.Print("Match outcome is ", _matchOutcome);
            return true;
        }

        return false;
    }

    private (Events events, MatchState matchState) ActivateItems(MatchState matchState)
    {
        ProcessItems(matchState, matchState.OwnPlayerState, matchState.OtherPlayerState);
        ProcessItems(matchState, matchState.OtherPlayerState, matchState.OwnPlayerState);
        return (null, null);
    }

    private static void ProcessItems(MatchState matchState, PlayerState thisPlayerState, PlayerState otherPlayerState)
    {
        foreach (var item in thisPlayerState.Items)
        foreach (var behavior in item.Item.Behaviors)
        {
            var shouldDoAction = true;
            foreach (var trigger in behavior.Triggers)
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
                GD.Print("I'm doing the action from ", thisPlayerState.Name);
                item.LastActivatedTick = matchState.Tick;
                foreach (var action in behavior.Actions)
                    switch (action.ActionType)
                    {
                        case ActionType.Damage:
                            // TODO: Stop hardocding it dumbass!
                            // TODO: should be a damageEvent hnnggg!
                            otherPlayerState.Health = Math.Max(0, otherPlayerState.Health - 20);
                            break;
                        default:
                            throw new ArgumentOutOfRangeException();
                    }
            }
        }
    }

    private static int secondsToTicks(double seconds)
    {
        return (int)(seconds * 60.0);
    }

    private MatchState ProcessEvents(Events events, MatchState matchState)
    {
        return matchState;
    }

    private MatchOutcome EvaluateWinCondition(MatchState matchState)
    {
        if (matchState.OwnPlayerState.Health == 0)
            return matchState.OtherPlayerState.Health switch
            {
                > 0 => MatchOutcome.Lost,
                < 0 => MatchOutcome.Won,
                _ => MatchOutcome.Tie
            };

        return matchState.OtherPlayerState.Health switch
        {
            > 0 => MatchOutcome.InProgress,
            0 => MatchOutcome.Won,
            _ => throw new ArgumentOutOfRangeException()
        };
    }

    private enum MatchOutcome
    {
        InProgress,
        Tie,
        Won,
        Lost
    }
}

internal class MatchState(int tick, PlayerState ownPlayerState, PlayerState otherPlayerState)
{
    public int Tick { get; set; } = tick;
    public PlayerState OwnPlayerState { get; set; } = ownPlayerState;
    public PlayerState OtherPlayerState { get; set; } = otherPlayerState;

    public override string ToString()
    {
        return
            $"{nameof(Tick)}: {Tick}, {nameof(OwnPlayerState)}: {OwnPlayerState}, {nameof(OtherPlayerState)}: {OtherPlayerState}";
    }
}

internal record Events(List<ModifyStateEvent> ModifyStateEvents, List<DamageEvent> DamageEvents);

internal record ModifyStateEvent(string Path, string Operation, string Value);

internal record DamageEvent(int Damage);

internal class PlayerState(string name, int health, int maxHealth, int stamina, int maxStamina, List<ItemState> items)
{
    public string Name { get; } = name;
    public int Health { get; set; } = health;
    public int MaxHealth { get; } = maxHealth;
    public int Stamina { get; } = stamina;
    public int MaxStamina { get; } = maxStamina;
    public List<ItemState> Items { get; } = items;

    public override string ToString()
    {
        return
            $"{nameof(Name)}: {Name}, {nameof(Health)}: {Health}, {nameof(MaxHealth)}: {MaxHealth}, {nameof(Stamina)}: {Stamina}, {nameof(MaxStamina)}: {MaxStamina}, {nameof(Items)}: {Items}";
    }

    private PlayerState DeepCopy()
    {
        return new PlayerState(
            Name,
            Health,
            MaxHealth,
            Stamina,
            MaxStamina,
            [..Items]);
    }
}

internal class ItemState(Item item, int lastActivatedTick)
{
    public Item Item { get; } = item;

    // TODO: should be per behavior eventually
    public int LastActivatedTick { get; set; } = lastActivatedTick;

    public override string ToString()
    {
        return $"{nameof(Item)}: {Item}, {nameof(LastActivatedTick)}: {LastActivatedTick}";
    }
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