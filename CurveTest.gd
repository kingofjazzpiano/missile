extends Node2D

onready var line: Line2D = $Line2D
onready var line2: Line2D = $Line2D2


func _ready() -> void:
	var start: Vector2 = Vector2(600, 0)
	var end: Vector2 = Vector2(600, 600)
	var curvature: float = 200
	var s_point: Vector2 = end + end.direction_to(start) * curvature
	var x_point: Vector2 = s_point + (end - s_point) * 0.5 + s_point.direction_to(end).rotated(-PI * 0.5) * curvature
	line.add_point(start)
#	line.add_point(s_point)
	line.add_point(x_point)
	line.add_point(end)
	

	
	var curve2: Curve2D = Curve2D.new()
	var start2: Vector2 = Vector2(500, 400)
	var end2: Vector2 = Vector2(500, 600)
	var x2_point: Vector2 = (end2 - start2) + start2.direction_to(end2).rotated(-PI * 0.5) * curvature
	
	curve2.bake_interval = 20.0
	curve2.add_point(start2, Vector2.ZERO, x2_point)
	curve2.add_point(end2)
	print(curve2.get_baked_points().size())
	line2.points = curve2.get_baked_points()
