extends Node2D

enum ORDER_TYPES {
	TUNNEL,
	SCAN,
	COMBAT,
}

var available_excavators = 4
var available_scanners = 0
var available_gunners = 0

const TUNNEL_ORDER:PackedScene = preload("res://orders/tunnel_order.tscn")
const EXCAVATOR:PackedScene = preload("res://robots/excavator.tscn")

var movespeed = 100

var drill_active:bool = true
@onready var world:Node2D = get_parent()

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if drill_active:
		global_position.y += movespeed * delta
		drill_tiles()

func drill_tiles() -> void:
	var width:int = $DrillArea/CollisionShape2D.shape.size.x
	var height:int = $DrillArea/CollisionShape2D.shape.size.y
	var i:int = -(width / 2) + 16
	var j:int = -(height / 2) + 16
	while i < width / 2:
		while j < height:
			world.damage_tile(Vector2i($DrillArea.global_position.x + i, $DrillArea.global_position.y + j), true)
			j += 32
		i += 32
		j = -(height / 2) + 16

func create_order(order_position:Vector2, type:int):
	var new_order:Node2D
	var new_robot:Robot
	if type == ORDER_TYPES.TUNNEL:
		if available_excavators == 0:
			return
		new_order = TUNNEL_ORDER.instantiate()
		new_robot = EXCAVATOR.instantiate()
		available_excavators -= 1
	new_order.global_position = world.snap_to_grid(order_position)
	new_robot.global_position = world.snap_to_grid($RobotSpawner.global_position)
	new_robot.order = new_order
	new_robot.drill = self
	world.add_child(new_order)
	world.add_child(new_robot)

func _on_drill_area_area_entered(area: Area2D) -> void:
	drill_active = false


func _on_pod_area_body_entered(body: Node2D) -> void:
	if body is Robot:
		body._retire()
