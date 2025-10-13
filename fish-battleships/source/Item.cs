using Godot;
using Godot.Collections;

namespace FishBattleships.source;

[GlobalClass]
public partial class Item : Resource
{
    [Export] public Array<ItemBehavior> Behaviors;
    [Export] public ItemId ItemId;
    [Export] public string Name;
}

public enum ItemId
{
    BaseBone,
    BaseScale,
    BaseJelly,
    Tooth,
    Claw,
    Spike,
    Heart,
    Fat,
    Stomach
}