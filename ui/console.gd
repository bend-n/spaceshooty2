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
	color_outline = "alpha",
	color_text = "white"
):
	if tween.is_active():
		return false
	var outline = colors[name_of_colors.find(color_outline)]
	var text = colors[name_of_colors.find(color_text)]

	label.add_color_override("font_color", text)
	label.add_color_override("font_outline_modulate", outline)
	label.percent_visible = 0
	label.text = new_text
	tween_(0, 1, time)
	yield(tween, "tween_all_completed")
	tween_(1, 0, time, length)
	return true


func tween_(from, to, time, delay = 0):
	tween.interpolate_property($Label, "percent_visible", from, to, time, tween.TRANS_LINEAR, tween.EASE_IN_OUT, delay)
	tween.start()
