extends Node

var fx_path = "res://effects/"

var effects = {
	"EnemyDeath": load(fx_path + "EnemyDeathEffect.tscn"),
	"Explosion": load(fx_path + "ExplosionEffect.tscn"),
	# "PlayerDeath": load(fx_path + "PlayerDeathEffect.tscn"),
	"Dust": load(fx_path + "DustEffect.tscn"),
}



func fx(key: String, pos: Vector2):
	Utils.instance_scene_on_main(effects[key], pos)
	
