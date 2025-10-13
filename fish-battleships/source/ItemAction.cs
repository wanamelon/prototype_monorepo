using Godot;

namespace FishBattleships.source;

[GlobalClass]
public partial class ItemAction : Resource
{
    [Export] public ActionType ActionType;
}

public enum ActionType
{
    ModifyPlayerState,
    ApplyStatusEffect
}