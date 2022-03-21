extends RigidBody2D

export var engine_thrust = 150
export var MAX_SPEED = 150

var thrust = Vector2()
var raw_input = Vector2()

var last_position = global_position
var trails_enabled = true

onready var screensize = get_viewport().get_visible_rect().size

onready var fire = $Fire
onready var tween = $Tween
onready var trails = $trails
onready var backfire = $BackFire
onready var animationPlayer = $AnimationTree
onready var sprite: Sprite = $Sprite


func get_input():
	raw_input.x = Input.get_axis("ui_left", "ui_right")
	raw_input.y = Input.get_axis("ui_up", "ui_down")
	thrust = raw_input.normalized() * engine_thrust
	limit_speed()
	stop_slide()
	animationPlayer.set("parameters/motion/blend_position", raw_input)
	last_position = global_position


func stop_slide():
	if ( # 4k ifs
		raw_input == Vector2() and
		linear_velocity.length() < 4
		and linear_velocity.length() != 0
		and last_position != global_position
		and not tween.is_active()
	):
		sleeping = true
	elif sleeping == true: sleeping = false


func limit_speed():
	if linear_velocity.length() > MAX_SPEED:
		linear_velocity = linear_velocity.normalized() * MAX_SPEED


func _process(_delta):
	get_input()
	handle_flames()
	update_trails()
	last_position = global_position

func update_trails():
	for trail in trails.get_children():
		trail.THICKNESS = clamp(linear_velocity.length() * .05, .5, 3)
		trail.run = trails_enabled
		if ! trails_enabled:
			trail.points.clear()


func handle_flames():
	# var difference = (global_position - last_position).normalized()
	var difference = linear_velocity.normalized()

	if raw_input != Vector2.ZERO:
		if raw_input.x > 0 or raw_input.y != 0:
			fire.direction = difference * -1
			fire.emitting = true
			backfire.emitting = false
			fire.initial_velocity = difference.x * 20 * raw_input.x
		else:  # pressing backwards
			fire.emitting = false
			backfire.emitting = true
			backfire.direction = difference * -1

			backfire.initial_velocity = difference.x * 100 * raw_input.x
			# print("curr velocity: ", backfire.initial_velocity, " curr direction: ", backfire.direction, " difference: ", difference)
			# make absolutely sure it fires from the front
	else:
		backfire.emitting = false
		fire.emitting = false


func _integrate_forces(state):
	applied_force = thrust
	if position.y > screensize.y + 13:
		state.transform.origin.y = 0
		trails_enabled = false
		update_trails()
	elif position.y < 0 - 13:
		state.transform.origin.y = screensize.y
		trails_enabled = false
		update_trails()
	else:
		trails_enabled = true
