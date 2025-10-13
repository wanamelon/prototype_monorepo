using Godot;

namespace FishBattleships.source;

[GlobalClass]
public partial class IntervalTrigger : Resource
{
    [Export] public double IntervalSeconds;
}