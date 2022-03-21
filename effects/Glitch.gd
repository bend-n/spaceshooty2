extends CanvasLayer

onready var timer = $Timer


func apply(length, off = 1):
	$shaderholder.visible = true
	$shaderholder.get_material().set_shader_param("offset", off)
	timer.start(length)


func _on_Timer_timeout():
	$shaderholder.visible = false
	$shaderholder.get_material().set_shader_param("offset", 1)
