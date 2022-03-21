extends Label
class_name stopwatch

var time_elapsed := 0.0
var on := false setget set_on


func set_on(new_on):
	set_process(new_on)
	on = new_on


func start():
	set_on(true)


func get_time() -> float:
	return time_elapsed


func reset():
	time_elapsed = 0.0
	text = _format_seconds(time_elapsed, true)
	set_on(false)


func _process(delta):
	time_elapsed += delta
	text = _format_seconds(time_elapsed, true)


func _format_seconds(time: float, use_milliseconds: bool) -> String:
	var minutes := time / 60
	var seconds := fmod(time, 60)

	if not use_milliseconds:
		return "%02d:%02d" % [minutes, seconds]

	var milliseconds := fmod(time, 1) * 100

	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
