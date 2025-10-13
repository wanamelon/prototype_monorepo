using Godot;

namespace FishBattleships.source;

[GlobalClass]
public partial class ItemTrigger : Resource
{
    [Export] public IntervalTrigger IntervalTrigger;
    [Export] public TriggerType TriggerType;
}

public enum TriggerType
{
    Interval
}