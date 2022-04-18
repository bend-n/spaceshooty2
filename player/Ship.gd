extends RigidBody2D

export(int) var engine_thrust = 150
export(int) var MAX_SPEED = 150
export(int) var MAX_FUEL = 15  # in seconds

var fuel: float = 0

var thrust := Vector2()
var raw_input := Vector2()

var last_position := global_position
var trails_enabled := true
var out_of_fuel := true

export(bool) var fuel_enabled := false
export(float) var shoot_delay := .15
export(float) var max_speed := 100
export(float) var min_speed := 75

var thrust_state = idle

enum { idle, thrusting }

onready var screensize := get_viewport().get_visible_rect().size
onready var fire := $Fire
onready var tween := $Tween
onready var trails := $trails
onready var backfire := $BackFire
onready var animationPlayer := $AnimationTree
onready var radial_progressbar = $shipui/fuelbar
onready var sprite := $Sprite
onready var timer := $BulletSpawner/Timer
onready var shooter = $BulletSpawner

func _ready():
	radial_progressbar.visible = fuel_enabled
	animationPlayer.active = true

func get_input(delta):
	if out_of_fuel:
		if Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") == Vector2.ZERO: #  cant just mash buttons
			out_of_fuel = false
		else:
			handle_fuel(idle, delta)  # regenerate
			return
	stop_slide()
	raw_input.x = Input.get_axis("ui_left", "ui_right")
	raw_input.y = Input.get_axis("ui_up", "ui_down")
	thrust = raw_input.normalized() * engine_thrust
	limit_speed()
	animationPlayer.set("parameters/motion/blend_position", raw_input)
	last_position = global_position

	if Input.is_action_pressed("ui_accept") and timer.time_left == 0:
		shooter.arc_rotation_degrees = (rand_range(-1, 1) + (raw_input.x * 2) + (raw_input.y * 2)) * 2  # barely distinguishable rotation effect 
		var scalerand := rand_range(.75, 1.25)
		shooter.bullet_type.scale = Vector2(scalerand, scalerand)
		
		shooter.bullet_type.speed = rand_range(min_speed, max_speed)
		shooter.fire()
		timer.start(shoot_delay)
		for _i in range(shooter.shot_count):
			SoundFX.play("Bullet")
		
	if fuel_enabled:
		if fuel < .02:
			raw_input = Vector2.ZERO
			thrust = Vector2.ZERO
			Console.Log("Out of fuel!", 1, 2, "red")
			out_of_fuel = true

		if raw_input == Vector2.ZERO:  # wheels are still
			handle_fuel(idle, delta)
		else:  # wheels are in motion
			handle_fuel(thrusting, delta)


func handle_fuel(nstate: int, delta):
	if thrust_state != nstate:
		thrust_state = nstate
	if nstate == idle:
		increment_fuel(delta)
	else:
		decrement_fuel(delta)
	display_fuel()


func increment_fuel(delta):
	fuel += delta
	fuel = clamp(fuel, 0, MAX_FUEL)

func decrement_fuel(delta):
	fuel -= delta
	fuel = clamp(fuel, 0, MAX_FUEL)
	
func display_fuel():
	if !tween.is_active():
		var value = range_lerp(fuel, 0, MAX_FUEL, 0, 100)
		tween.interpolate_property(radial_progressbar, "value", radial_progressbar.value, value, .1)  # object  # property  # initial value  # final value  # duration
		tween.start()

func stop_slide():
	if (  # 4k ifsa
		raw_input == Vector2()
		and linear_velocity.length() < 4
		and linear_velocity.length() != 0
		and last_position != global_position
		and not tween.is_active()
	):
		sleeping = true
	elif sleeping == true:
		sleeping = false


func limit_speed():
	if linear_velocity.length() > MAX_SPEED:
		linear_velocity = linear_velocity.normalized() * MAX_SPEED


func _physics_process(delta):
	get_input(delta)
	handle_flames()
	update_trails()
	last_position = global_position


func update_trails():
	for trail in trails.get_children():
		trail.THICKNESS = clamp(linear_velocity.length() * .05, 1, 3)
		trail.run = trails_enabled
		if !trails_enabled:
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
