extends Sprite

onready var debug_line_1 = get_node("/root/Main/DebugPanel/VBoxContainer/Label1")
onready var debug_line_2 = get_node("/root/Main/DebugPanel/VBoxContainer/Label2")
onready var debug_line_3 = get_node("/root/Main/DebugPanel/VBoxContainer/Label3")
onready var debug_line_4 = get_node("/root/Main/DebugPanel/VBoxContainer/Label4")
onready var debug_line_5 = get_node("/root/Main/DebugPanel/VBoxContainer/Label5")
onready var debug_line_6 = get_node("/root/Main/DebugPanel/VBoxContainer/Label6")
onready var debug_line_7 = get_node("/root/Main/DebugPanel/VBoxContainer/Label7")
onready var debug_line_8 = get_node("/root/Main/DebugPanel/VBoxContainer/Label8")
onready var debug_line_9 = get_node("/root/Main/DebugPanel/VBoxContainer/Label9")
onready var debug_line_10 = get_node("/root/Main/DebugPanel/VBoxContainer/Label10")
onready var fps_label = get_node("/root/Main/DebugPanel/FPS")

onready var navigation = get_node("/root/Main").find_node("Navigation2D")
onready var player = get_node("/root/Main/Player")
onready var cross = get_node("/root/Main/Cross")
onready var reaction_timer = $ReactionTimer
onready var ray = $RayCast2D
onready var probe = preload("res://Probe.tscn").instance()
onready var right_area = get_node("/root/Main/Player/RightArea")
onready var left_area = get_node("/root/Main/Player/LeftArea")

enum { LEFT, RIGHT, STRAIGHT }

var player_state: int = STRAIGHT

const RAY_LENGTH = 300.0
const MAX_REACTION_TIME = 2.0

var direction: Vector2 = Vector2.ZERO
var min_speed: float = 5.0
var max_speed: float = 150.0  # Pixels per seond
var current_speed: float = max_speed  # Pixels per seond
var acceleration: float = 0.25
var max_rotation_speed: float = 0.4  # Radians per second
var current_rotation_speed: float = max_rotation_speed  # Radians per second

var path: PoolVector2Array = []
var target_position: Vector2

var last_target: Vector2 = Vector2.ZERO
var old_path: PoolVector2Array = []


func _ready() -> void:
	randomize()
	get_parent().call_deferred("add_child", probe)
	ray.set_cast_to(Vector2(RAY_LENGTH, 0))


func _physics_process(delta: float) -> void:
	fps_label.text = str(round(1.0 / delta))
	var old_player_state: int = player_state
	if Input.is_action_pressed("a"):
		debug_line_10.text = "player_state: LEFT"
		player_state = LEFT
	elif Input.is_action_pressed("d"):
		debug_line_10.text = "player_state: RIGHT"
		player_state = RIGHT
	else:
		debug_line_10.text = "player_state: STRAIGHT"
		player_state = STRAIGHT
	
	if old_player_state != player_state and reaction_timer.is_stopped():
		reaction_timer.start(rand_range(0.0, MAX_REACTION_TIME))

	target_position = player.position
	
	var sight_line: Vector2 = position.direction_to(target_position)
	var alpha: float = player.direction.angle_to(-sight_line)
	
	var beta: float
	var tmp: float = 0
	if current_speed:
		tmp = sin(alpha) * player.speed / current_speed
	
	if current_speed > player.speed or abs(alpha) < PI * 0.5 and abs(tmp) <= 1.0:
		beta = asin(tmp)
	else:
		beta = asin(sin(alpha))

	var gamma: float =  PI - alpha - beta
	var l: float = 0
	if alpha:
		l = current_speed * sin(gamma) / sin(alpha)
	var proportional_coefficient: float = 0
	if l:
		proportional_coefficient = position.distance_to(target_position) / l
	if player.direction != Vector2.ZERO:
		if abs(current_speed * proportional_coefficient) > 1000 or proportional_coefficient == 0:
			cross.position = position + Vector2.RIGHT.rotated(sight_line.angle() + beta) * 1000
		else:
			cross.position = position + Vector2.RIGHT.rotated(sight_line.angle() + beta) * current_speed * proportional_coefficient
	else:
		cross.position = target_position
	
#	update_navigation_path(position, cross.position)

	probe.global_position = global_position
	probe.cast_to.x = global_position.distance_to(cross.position)
	probe.rotation = position.direction_to(cross.position).angle()
	
	if Input.is_action_just_pressed("middle_mouse"):
		print("")

	if path.size() > 1 and is_straight_line():
		path = [path[-1]]

	if path.size() > 1 and position.distance_to(path[0]) < 50.0:
		path.remove(0)

	if path.size() > 1:
		last_target = path[0]
		old_path = PoolVector2Array() + path
	else:
		last_target = Vector2.ZERO

	if path.size() < 2 or Input.is_action_pressed("x") \
			or not probe.is_colliding() \
			or abs(Vector2.RIGHT.rotated(rotation).angle_to(position.direction_to(path[0]))) > PI * 0.5:
		update_navigation_path(position, cross.position)
	elif path.size() > 1 and last_target and last_target != path[0]:
		path = PoolVector2Array() + old_path

	
	var desired_rotation = 0
	if path.size():
		desired_rotation = Vector2.RIGHT.rotated(rotation).angle_to(position.direction_to(path[0]))
	if desired_rotation and reaction_timer.is_stopped():
		rotation = lerp_angle(rotation,
			position.direction_to(path[0]).angle(),
			abs((current_rotation_speed * delta) / desired_rotation))
	position += Vector2.RIGHT.rotated(rotation) * current_speed * delta
	
	if ray.is_colliding():
		current_rotation_speed = max_rotation_speed * 1.2
		var estimated_speed: float = position.distance_to(ray.get_collision_point()) * max_speed / RAY_LENGTH
		if estimated_speed and estimated_speed < current_speed:
			current_speed = estimated_speed
		else:
			current_speed += acceleration
	else:
		if sight_line.dot(Vector2.RIGHT.rotated(rotation)) < 0:
			current_rotation_speed = max_rotation_speed * 1.2
		else:
			current_rotation_speed = max_rotation_speed
		current_rotation_speed = max_rotation_speed
		current_speed += acceleration
#		current_speed += acceleration * sign(sight_line.dot(Vector2.RIGHT.rotated(rotation)))
	current_speed = clamp(current_speed, min_speed, max_speed)
	
	debug_line_1.text = "alpha: " + str(rad2deg(alpha))
	debug_line_2.text = "beta: " + str(rad2deg(beta))
	debug_line_3.text = "cross.position: " + str(cross.position)
	debug_line_4.text = "ray.is_colliding(): " + str(ray.is_colliding())
	debug_line_5.text = "current_speed: " + str(current_speed)
	debug_line_6.text = "sign(sight_line.dot(Vector2.RIGHT.rotated(rotation))): " + str(sign(sight_line.dot(Vector2.RIGHT.rotated(rotation))))
	debug_line_7.text = "reaction_timer.time_left: " + str(reaction_timer.time_left)


func update_navigation_path(start_position, end_position):
	path = navigation.get_simple_path(start_position, end_position, true)
	if path.size():
		path.remove(0)


func is_straight_line() -> bool:
	var angle: float = abs((path[0] - global_position).angle_to(path[1] - path[0]))
	if angle > deg2rad(20.0):
		return false
	for i in range(path.size() - 2):
		angle = abs((path[i + 1] - path[i]).angle_to(path[i + 2] - path[i + 1]))
		if angle > deg2rad(20.0):
			return false
	return true
