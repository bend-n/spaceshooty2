extends Node

const title = "spaceshooty2"

var keyboard = true


func _process(_delta):
	OS.set_window_title(title + " | fps: " + str(Engine.get_frames_per_second()))


func instance_scene_on_main(scene, position):
	var main = get_tree().current_scene
	var instance = scene.instance()
	main.add_child(instance)
	instance.global_position = position
	return instance


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion and keyboard == true:
		self.keyboard = false
	elif event is InputEventKey and keyboard == false:
		self.keyboard = true


func set_keyboard(new_keyboard):
	keyboard = new_keyboard
#	if new_keyboard == true:
#		get_tree().call_group("gamepad", "hide")
#		get_tree().call_group("keyboard"	, "show")
#	elif new_keyboard == false:
#		get_tree().call_group("keyboard", "hide")
#		get_tree().call_group("gamepad", "show")
