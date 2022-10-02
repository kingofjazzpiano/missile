extends Sprite

const DEAD_ZONE_LIMIT = 50

var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0  # скорость по локальной оси X
var acceleration: float = 1.05  # постоянное ускорение движения
var max_forward_speed: float = 130.0  # максимальная скорость вперёд
var max_backward_speed: float = -100.0  # максимальная скорость назад
var max_rotation_speed: float = 0.4  # максимальная скорость поворота Rad/s
var rotation_acceleration: float = 0.01  # постоянное ускорение при повороте
var current_rotation_speed: float = 0.0 # текущяя скорость вращения Rad/s


func _physics_process(delta: float) -> void:
	direction = Vector2.ZERO
	calculate_speed()
	calculate_rotation(delta)
	
	direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta


func calculate_speed() -> void:
	if Input.is_action_pressed("w"):
		speed += acceleration
	elif Input.is_action_pressed("s"):
		speed -= acceleration
	# Если скорость меньше DEAD_ZONE_LIMIT, судно остановится
	elif speed and abs(speed) < DEAD_ZONE_LIMIT:
		speed = lerp(speed, 0, abs(acceleration / speed))
	speed = clamp(speed, max_backward_speed, max_forward_speed)


func calculate_rotation(delta: float) -> void:
	if Input.is_action_pressed("a"):
		current_rotation_speed = max(current_rotation_speed - rotation_acceleration, -max_rotation_speed)
	elif Input.is_action_pressed("d"):
		current_rotation_speed = min(current_rotation_speed + rotation_acceleration, max_rotation_speed)
	elif current_rotation_speed:
		current_rotation_speed = lerp(current_rotation_speed, 0, abs(rotation_acceleration / current_rotation_speed))
	rotation += current_rotation_speed * delta
