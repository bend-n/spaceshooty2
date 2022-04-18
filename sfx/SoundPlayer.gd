extends Node

export(String) var sound_string = ""
export(float) var volume_db
export(float) var minpitch_scale = .9
export(float) var maxpitch_scale = 1.1


func _ready():
	if sound_string != "":
		SoundFX.play(sound_string, volume_db, rand_range(minpitch_scale, maxpitch_scale))
