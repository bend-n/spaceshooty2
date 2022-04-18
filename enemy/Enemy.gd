class_name Enemy extends Sprite

export(int) var speed = 20
export(float) var shootspeed = 2
export(int) var max_health = 2

onready var hurtbox = $Hurtbox
var health = max_health


func kill():
	queue_free()


func shoot():
	pass


func move():
	pass


func take_damage(damage):
	Fx.fx("Explosion", global_position)
	health -= damage
	if health < 0:
		kill()
		Fx.fx("EnemyDeath", global_position)


func handle_collision(_bullet, colliders):
	if hurtbox in colliders:
		take_damage(1)
		# bullet.queue_free() # not necessary, due to pop_on_collide
		


func _on_Hurtbox_body_entered(_body):
	take_damage(1)


func _ready():
	Server.connect("collision_detected", self, "handle_collision")
