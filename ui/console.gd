extends CanvasLayer

export(Array, Color) var colors
export(Array, String) var name_of_colors

onready var label = $Label
onready var tween = $Tween

func _ready():
	label.percent_visible = 0
	Log("console loaded")


func Log(
	new_text: String,
	time := .5,
	length := 2.5,
	color_outline = Color.transparent,
	color_text = Color.white
):
	if tween.is_active():
		return false
	label.add_color_override("font_color", color_text)
	label.add_color_override("font_outline_modulate", color_outline)
	label.percent_visible = 0
	label.text = new_text
	tween_(0, 1, time)
	yield(tween, "tween_all_completed")
	yield(get_tree().create_timer(length), "timeout")
	tween_(1, 0, time)
	return true


func tween_(from, to, time):
	tween.interpolate_property($Label, "percent_visible", from, to, time)
	tween.start()
