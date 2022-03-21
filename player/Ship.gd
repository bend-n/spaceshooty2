extends RigidBody2D

export(int) var engine_thrust = 150
export(int) var MAX_SPEED = 150
export(int) var MAX_FUEL = 15  # in seconds

var fuel: float = 0

var thrust := Vector2()
var raw_input := Vector2()

var last_position := global_position
var trails_enabled := true
var last_timer_read := 0.0  # for decrement
var out_of_fuel := true
var thrust_state = idle
enum { idle, thrusting }

onready var screensize := get_viewport().get_visible_rect().size
onready var stopwatch = $Stopwatch
onready var fire := $Fire
onready var tween := $Tween
onready var trails := $trails
onready var backfire := $BackFire
onready var animationPlayer := $AnimationTree
onready var radial_progressbar = $shipui/fuelbar
onready var sprite := $Sprite


func get_input():
	if out_of_fuel:
		if Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") == Vector2.ZERO:
			out_of_fuel = false
		else:
			handle_fuel(idle)  # regenerate
			return
	stop_slide()
	raw_input.x = Input.get_axis("ui_left", "ui_right")
	raw_input.y = Input.get_axis("ui_up", "ui_down")
	thrust = raw_input.normalized() * engine_thrust
	limit_speed()
	animationPlayer.set("parameters/motion/blend_position", raw_input)
	last_position = global_position
	if fuel < .02:
		raw_input = Vector2.ZERO
		thrust = Vector2.ZERO
		out_of_fuel = true

	if raw_input == Vector2.ZERO:  # wheels are still
		handle_fuel(idle)
	else:  # wheels are in motion
		handle_fuel(thrusting)


func handle_fuel(nstate: int):
	if thrust_state != nstate:
		stopwatch.reset()
		thrust_state = nstate
		last_timer_read = 0
		print("switching state to: ", nstate)
	if stopwatch.get_time() == 0:
		stopwatch.start()
	if nstate == idle:
		increment_fuel()
	else:
		decrement_fuel()
	display_fuel()


func increment_fuel():
	var time_elapsed = stopwatch.get_time() - last_timer_read
	fuel += time_elapsed
	fuel = clamp(fuel, 0, MAX_FUEL)
	last_timer_read = stopwatch.get_time()


func decrement_fuel():
	var time_elapsed = stopwatch.get_time() - last_timer_read
#	print("decrementing fuel by ", time_elapsed, "| last_timer_read: ")
	fuel -= time_elapsed
	fuel = clamp(fuel, 0, MAX_FUEL)
	last_timer_read = stopwatch.get_time()


#	if typeof(last_timer_read) == TYPE_NIL or typeof(stopwatch.get_time()) == TYPE_NIL:
#		assert(false)
#	if last_timer_read == 0 and stopwatch.on and stopwatch.time_elapsed != 0:
#		assert(false, "what")
#	print(last_timer_read, "|", stopwatch.time_elapsed)


func display_fuel():
	if !tween.is_active():
		var value = range_lerp(fuel, 0, MAX_FUEL, 0, 100)
		tween.interpolate_property(radial_progressbar, "value", radial_progressbar.value, value, .1)  # object  # property  # initial value  # final value  # duration
		tween.start()


# func map(value, rangemin, rangemax, orangemin, orangemax):
# 	return(value - rangemin) / (rangemax - rangemin) * (orangemax - orangemin) + orangemin


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


func _process(_delta):
	get_input()
	handle_flames()
	update_trails()
	last_position = global_position


func update_trails():
	for trail in trails.get_children():
		trail.THICKNESS = clamp(linear_velocity.length() * .05, .5, 3)
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
