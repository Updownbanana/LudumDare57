extends Node2D

@onready var world = get_node("/root/World")

func _ready() -> void:
	var tunnel_direction:int = global_position.x - world.get_drill().global_position.x
	tunnel_direction = tunnel_direction / abs(tunnel_direction)
	while world.is_ground_breakable($TunnelEnd.global_position) or world.get_damage($TunnelEnd.global_position) > 0:
		$TunnelEnd.position.x += 32 * tunnel_direction
	$TunnelEnd.position.x -= 32 * tunnel_direction
