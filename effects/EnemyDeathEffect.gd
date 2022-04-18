extends Node2D


func _on_DustEffect9_tree_exited():
	queue_free()


func _ready():
	SoundFX.play("EnemyDie", -15)
