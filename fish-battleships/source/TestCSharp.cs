using FishBattleships.source;
using Godot;

public partial class TestCSharp : Node2D
{
    [Export] public Item Item;

    public override void _Ready()
    {
        GD.Print("I am alive!");
    }
}