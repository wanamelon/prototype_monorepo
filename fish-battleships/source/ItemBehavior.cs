using Godot;

namespace FishBattleships.source;

[GlobalClass]
public partial class ItemBehavior : Resource
{
    [Export] public ItemAction[] Actions;
    [Export] public ItemTrigger[] Triggers;
}