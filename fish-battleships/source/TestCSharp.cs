using FishBattleships.source;
using Godot;
using Godot.Collections;

public partial class TestCSharp : Node2D
{
    private MatchSimulator _matchSimulator;
    [Export] public Item Item;

    [Export] public Array<Item> OtherPlayerItems = new();

    [Export] public Array<Item> OwnPlayerItems = new();


    public override void _Ready()
    {
        GD.Print("I am alive!");
        _matchSimulator = new MatchSimulator(OwnPlayerItems, OtherPlayerItems);
    }

    public override void _PhysicsProcess(double delta)
    {
        if (!_matchSimulator.MainLoop()) GetTree().Quit();
    }
}