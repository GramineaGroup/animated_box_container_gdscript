using Godot;
using System;

public partial class Horizontal : PanelContainer
{
    private Container _animatedBoxContainer;
    private double _duration = 0.6;
    public override void _Ready()
    {
        _animatedBoxContainer = GetNode<Container>("%AnimatedBoxContainer");
    }

    private void OnExpandButtonPressed()
    {
        (_animatedBoxContainer.Call("set_ease", [(int)Tween.EaseType.InOut]).Obj as Container).Call("set_direction", [1, _duration]);
    }

    private void OnCollapseButtonPressed()
    {
        (_animatedBoxContainer.Call("set_ease", [(int)Tween.EaseType.InOut]).Obj as Container).Call("set_direction", [0, _duration]);
    }
}
