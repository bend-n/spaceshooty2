extends Node

export(Array, AudioStream) var music_list = []

var music_index = 0

onready var musicPlayer = $AudioStreamPlayer


func _ready():
	music_list.shuffle()


func list_play():
	assert(music_list.size() > 0)
	musicPlayer.stream = music_list[music_index]
	musicPlayer.play()
	music_index += 1
	if music_index == music_list.size():
		music_index = 0


func list_stop():
	musicPlayer.stop()


func _on_AudioStreamPlayer_finished():
	music_list.shuffle()
	list_play()


func _on_Timer_timeout():
	musicPlayer.volume_db = rand_range(-8, -12)
	musicPlayer.pitch_scale = rand_range(1, 1.4)
