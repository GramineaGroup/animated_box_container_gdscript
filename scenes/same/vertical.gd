class_name Vertical
extends PanelContainer

var _progressbar_container: AnimatedPanelContainer
var _content_label_container: AnimatedPanelContainer
var _left_button_panel_container: AnimatedPanelContainer
var _right_button_panel_container: AnimatedPanelContainer
var _animated_box_container: AnimatedBoxContainer
var _center_panel_container: AnimatedPanelContainer
var _size: Vector2
var _is_expanded: bool = true
var _duration: float = 0.6

func _ready():
	_progressbar_container = %ProgressBarContainer
	_content_label_container = %ContentLabelContainer
	_left_button_panel_container = %LeftButtonPanelContainer
	_right_button_panel_container = %RightButtonPanelContainer
	_animated_box_container = %AnimatedBoxContainer
	_center_panel_container = %CenterPanelContainer

func _on_expand_button_pressed() -> void:
	_left_button_panel_container.create_new_tween().animated_transparent_show(_duration)
	_right_button_panel_container.create_new_tween().animated_transparent_show(_duration)
	_content_label_container.create_new_tween().animated_show(_duration)
	_progressbar_container.create_new_tween().animated_scale(Vector2(1, 1), _duration)
	_center_panel_container.create_new_tween().animated_expand(_duration, Vector2(303, 133))
	_animated_box_container.set_ease(Tween.EaseType.EASE_IN_OUT).set_direction(AnimatedBoxContainer.AnimatedBoxContainerDirection.Vertical, _duration)

func _on_collapse_button_pressed() -> void:
	_left_button_panel_container.create_new_tween().animated_transparent_hide(_duration)
	_right_button_panel_container.create_new_tween().animated_transparent_hide(_duration)
	_content_label_container.create_new_tween().animated_hide(_duration)
	_progressbar_container.create_new_tween().animated_scale(Vector2(0.34, 0.34), _duration)
	# setting a known size is recommended for propery animation
	_center_panel_container.create_new_tween().animated_collapse(_duration, Vector2(224, 84))
	_animated_box_container.set_ease(Tween.EaseType.EASE_IN_OUT).set_direction(AnimatedBoxContainer.AnimatedBoxContainerDirection.Horizontal, _duration)
