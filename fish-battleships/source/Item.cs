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
    Tooth,  // faster, low damage
    Claw,   // big damage
    Spike,  // Apply bleed
    Heart,  // Nearby items trigger faster 
    Fat,    // Nearby have lower stam cost, and boost max stamina
    Shell,  // apply shield effects sometimes
    Stomach // Stamina regen?
}