extends Node2D

onready var navigation = $Navigation2D/NavigationPolygonInstance
onready var missile = $Missile
onready var debug_panel = $DebugPanel


func _ready() -> void:
	var islands = find_node("Islands")
	
	for island in islands.get_children():
		var island_navigation = island.get_node("NavigationPolygonInstance")
		island_navigation.hide()
		var transform = island.get_global_transform()
		var vertices = PoolVector2Array()
		
		for vertex in island_navigation.navpoly.get_vertices():
			vertices.append(transform.xform(vertex))
		
		navigation.navpoly.add_outline(vertices)
	
	navigation.navpoly.make_polygons_from_outlines()
		
	
	
# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	$Line2D.points = missile.path
	$Line2D.add_point(missile.position, 0)
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().paused = not get_tree().paused
	if Input.is_action_just_pressed("E"):
		missile.ray.visible = not missile.ray.visible
		missile.get_node("Icon").visible = not missile.get_node("Icon").visible
		missile.cross.visible = not missile.cross.visible
		$Line2D.visible = not $Line2D.visible
		debug_panel.visible = not debug_panel.visible
		missile.probe.visible = not missile.probe.visible
