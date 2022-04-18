extends Node

var sounds_path = "res://sfx/"

var sounds = {
	"Bullet": load(sounds_path + "Bullet.wav"),
	"Click": load(sounds_path + "Click.wav"),
	"EnemyDie": load(sounds_path + "EnemyDie.wav"),
	"Explosion": load(sounds_path + "Explosion.wav"),
	"Hurt": load(sounds_path + "Hurt.wav"),
	"Pause": load(sounds_path + "Pause.wav"),
	"Powerup": load(sounds_path + "Powerup.wav"),
	"Unpause": load(sounds_path + "Unpause.wav"),
}

onready var sound_players = get_children()


func play(sound_string, volume_db = -10, pitch_scale = randf() + 0.4):
	for soundPlayer in sound_players:
		if not soundPlayer.playing:
			soundPlayer.pitch_scale = pitch_scale
			soundPlayer.volume_db = volume_db
			soundPlayer.stream = sounds[sound_string]
			soundPlayer.play()
			return
	print(sound_players)
	print("TOO MANY SOUNDS")
