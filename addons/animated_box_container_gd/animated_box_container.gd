@tool
class_name AnimatedBoxContainer
extends Container

class MiniSizeCache:
	var mini_size: float;
	var will_stretch: bool;
	var final_size: float;

class TweenMiniSizeCache:
	var tween: Tween;
	var mini_size_cache: MiniSizeCache;

enum AnimatedBoxContainerAlignment {
	Begin,
	Center,
	End
}

enum AnimatedBoxContainerDirection {
	Vertical,
	Horizontal
}

var _direction: AnimatedBoxContainerDirection
@export var container_direction: AnimatedBoxContainerDirection:
	get:
		return _direction
	set(value):
		_direction = value
		queue_sort()

var _alignment: AnimatedBoxContainerAlignment
@export var container_alignment: AnimatedBoxContainerAlignment:
	get:
		return _alignment
	set(value):
		_alignment = value
		queue_sort()

var _separation: int = 0
@export var separation: int:
	get:
		return _separation
	set(value):
		_separation = value
		queue_sort()

var _delay: float = 0
var _current_duration: float = 0
@export var DefaultTrans: Tween.TransitionType
var _trans: Tween.TransitionType
@export var DefaultEase: Tween.EaseType
var _ease: Tween.EaseType
var _use_tween: bool = false
var _tween_list = {} # Control, TweenMiniSizeCache
var _size: Vector2

func _enter_tree() -> void:
	_ease = DefaultEase
	_trans = DefaultTrans
	mouse_filter = Control.MOUSE_FILTER_PASS

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_update_minimum_size()
			_resort()
		NOTIFICATION_TRANSLATION_CHANGED, NOTIFICATION_LAYOUT_DIRECTION_CHANGED:
			queue_sort()

func _resort() -> void:
	var new_size = Vector2(_size.x, _size.y)
	var rtl = is_layout_rtl()
	var children_count = get_child_count()
	var stretch_min = 0.0
	var stretch_avail = 0.0
	var stretch_ratio_total = 0.0
	var min_size_cache = {} # Control, MiniSizeCache

	for c: Control in get_children():
		var v = _tween_list.get(c)
		var tween_mini_size_cache = TweenMiniSizeCache.new()
		if v != null:
			tween_mini_size_cache = v
		var msc = tween_mini_size_cache.mini_size_cache

		if tween_mini_size_cache.tween == null:
			var size = _get_child_minimum_size(c)
			msc = MiniSizeCache.new()

			if _direction == AnimatedBoxContainerDirection.Vertical:
				stretch_min += size.y
				msc.mini_size = size.y
				msc.will_stretch = c.size_flags_vertical & SizeFlags.SIZE_EXPAND == SizeFlags.SIZE_EXPAND
			else:
				stretch_min += size.x
				msc.mini_size = size.x
				msc.will_stretch = c.size_flags_horizontal & SizeFlags.SIZE_EXPAND == SizeFlags.SIZE_EXPAND

			if msc.will_stretch:
				stretch_avail += msc.mini_size
				stretch_ratio_total += c.size_flags_stretch_ratio

			msc.final_size = msc.mini_size

		min_size_cache[c] = msc

	if children_count == 0:
		return

	var stretch_max = 0
	if _direction == AnimatedBoxContainerDirection.Vertical:
		stretch_max = new_size.y
	else:
		stretch_max = new_size.x
	stretch_max -= (children_count - 1) * _separation
	var stretch_diff = max(0, stretch_max - stretch_min)

	stretch_avail += stretch_diff

	var has_stretched = false
	while stretch_ratio_total > 0:
		has_stretched = true
		var refit_successful = true
		var error = 0.0
		
		for c: Control in get_children():
			var msc: MiniSizeCache = min_size_cache[c]
			
			if msc.will_stretch:
				var final_pixel_size = stretch_avail * c.size_flags_stretch_ratio / stretch_ratio_total
				error += final_pixel_size - int(final_pixel_size)
				if final_pixel_size < msc.min_size:
					msc.will_stretch = false
					stretch_ratio_total -= c.size_flags_stretch_ratio
					refit_successful = false
					stretch_avail -= msc.min_size
					msc.final_size = msc.mini_size
					break
				else:
					msc.final_size = final_pixel_size
					if error >= 1:
						msc.final_size += 1
						error -= 1

		if refit_successful:
			break

	var ofs: float = 0.0
	if not has_stretched:
		if _direction == AnimatedBoxContainerDirection.Vertical:
			match _alignment:
				AnimatedBoxContainerAlignment.Begin:
					if rtl:
						ofs = stretch_diff
				AnimatedBoxContainerAlignment.Center:
					ofs = stretch_diff / 2
				AnimatedBoxContainerAlignment.End:
					if not rtl:
						ofs = stretch_diff
		else:
			match _alignment:
				AnimatedBoxContainerAlignment.Center:
					ofs = stretch_diff / 2
				AnimatedBoxContainerAlignment.End:
					ofs = stretch_diff

	var first: bool = true
	var idx = 0
	var delta = 0

	var start: int = 0
	var end: int = 0
	if not rtl or _direction == AnimatedBoxContainerDirection.Vertical:
		start = 0
		end = get_child_count()
		delta += 1
	else:
		start = get_child_count() - 1
		end = -1
		delta = -1

	var i = start
	while i != end:
		var child = get_child(i)
		if child is Control:
			var c = child as Control
			var msc: MiniSizeCache = min_size_cache[c]

			if first:
				first = false
			else:
				ofs += _separation

			var from = ofs
			var to = ofs + msc.final_size

			if msc.will_stretch and idx == children_count - 1:
				if _direction == AnimatedBoxContainerDirection.Vertical:
					to = new_size.y
				else:
					to = new_size.x

			var size = to - from
			var rect: Rect2
			
			if _direction == AnimatedBoxContainerDirection.Vertical:
				rect = Rect2(0, from, new_size.x, size)
			else:
				rect = Rect2(from, 0, size, new_size.y)
			_fit_child_in_rect(c, rect, msc)

			ofs = to
			idx += 1
		i += delta

func _fit_child_in_rect(c: Control, rect: Rect2, msc: MiniSizeCache) -> void:
	var rtl = is_layout_rtl()
	var minsize = _get_child_minimum_size(c)
	var r = rect
	if not (c.size_flags_horizontal & SizeFlags.SIZE_FILL == SizeFlags.SIZE_FILL):
		r.size = Vector2(minsize.x, r.size.y)
		if c.size_flags_horizontal & SizeFlags.SIZE_SHRINK_END == SizeFlags.SIZE_SHRINK_END:
			var temp = 0
			if not rtl:
				temp = rect.size.x - minsize.x
			r.position = Vector2(r.position.x + temp, r.position.y)
		elif c.size_flags_horizontal & SizeFlags.SIZE_SHRINK_CENTER == SizeFlags.SIZE_SHRINK_CENTER:
			r.position = Vector2(r.position.x + floorf((rect.size.x - minsize.x) / 2), r.position.y)
		else:
			var temp = rect.size.x - minsize.x
			if not rtl:
				temp = 0
			r.position = Vector2(r.position.x + temp, r.position.y)
	
	if not c.size_flags_vertical & SizeFlags.SIZE_FILL == SizeFlags.SIZE_FILL:
		r.size = Vector2(r.size.x, minsize.y)
		if c.size_flags_vertical & SizeFlags.SIZE_SHRINK_END == SizeFlags.SIZE_SHRINK_END:
			r.position = Vector2(r.position.x, r.position.y + (rect.size.y - minsize.y))
		elif c.size_flags_vertical & SizeFlags.SIZE_SHRINK_CENTER == SizeFlags.SIZE_SHRINK_CENTER:
			r.position = Vector2(r.position.x, r.position.y + floorf((rect.size.y - minsize.y) / 2));
		else:
			r.position = Vector2(r.position.x, r.position.y + 0)
	if not _use_tween:
		c.size = r.size
		c.position = r.position
	else:
		var v = _tween_list.get(c)
		var tween_mini_size_cache = TweenMiniSizeCache.new()
		if v != null:
			tween_mini_size_cache = v
		var tween = tween_mini_size_cache.tween
		if tween != null:
			return
		tween = create_tween().set_parallel(true).set_ease(_ease).set_trans(_trans)
		tween_mini_size_cache.tween = tween
		tween_mini_size_cache.mini_size_cache = msc
		_tween_list[c] = tween_mini_size_cache
		tween.tween_property(c, "size", r.size, _current_duration).from(c.size).set_delay(_delay)
		tween.tween_property(c, "position", r.position, _current_duration).from(c.position).set_delay(_delay)
		tween.finished.connect(_on_tween_finished.bind(c))

func get_minimum_size_override() -> Vector2:
	var minimum = Vector2.ZERO
	var first = true
	
	for c: Control in get_children():
		if not c.visible:
			continue
		var child_size = _get_child_minimum_size(c)
		if _direction == AnimatedBoxContainerDirection.Vertical:
			if child_size.x > minimum.x:
				minimum.x = child_size.x
			minimum.y += child_size.y
			if not first:
				minimum.y += _separation
		else:
			if child_size.y > minimum.y:
				minimum.y = child_size.y
			minimum.x += child_size.x
			if not first:
				minimum.x += _separation
		first = false
	return minimum

func _get_child_minimum_size(c: Control) -> Vector2:
	var v = c.get("_current_minimum_size")
	if v == null:
		return c.get_combined_minimum_size() * c.scale
	v = v as Vector2
	if c.get("_classname") as String == "AnimatedPanelContainer" and not v.is_equal_approx(Vector2.ZERO):
		return v
	else:
		return c.get_combined_minimum_size() * c.scale

func _update_minimum_size() -> void:
	var minimum = get_minimum_size_override()
	_size = minimum
	if _use_tween:
		var v = _tween_list.get(self)
		var tween_mini_size_cache = TweenMiniSizeCache.new()
		if v != null:
			tween_mini_size_cache = v
		var tween = tween_mini_size_cache.tween
		
		if tween != null:
			return
		tween = create_tween().set_parallel(true).set_ease(_ease).set_trans(_trans)
		tween_mini_size_cache.tween = tween
		_tween_list[self] = tween_mini_size_cache
		tween.tween_property(self, "custom_minimum_size", minimum, _current_duration).from(custom_minimum_size).set_delay(_delay)
		tween.finished.connect(_on_tween_finished.bind(self))
	else:
		custom_minimum_size = minimum

func _on_tween_finished(c: Control) -> void:
	_tween_list.erase(c)
	if _tween_list.size() == 0:
		_use_tween = false
		_ease = DefaultEase
		_trans = DefaultTrans

func set_delay(delay: float) -> AnimatedBoxContainer:
	_delay = delay
	return self

func set_trans(trans: Tween.TransitionType) -> AnimatedBoxContainer:
	_trans = trans
	return self

func set_ease(ease: Tween.EaseType) -> AnimatedBoxContainer:
	_ease = ease
	return self

func set_direction(direction: AnimatedBoxContainerDirection, duration: float) -> void:
	_use_tween = true
	_current_duration = duration
	container_direction = direction
