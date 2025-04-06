extends Robot

@onready var world:Node2D = get_parent()

var tunnel_end:Node2D

func _ready():
	movespeed = 70
	tunnel_end = order.get_node("TunnelEnd")

func _physics_process(delta):
	look_at(global_position + velocity)
	move_and_slide()

func _on_timer_timeout() -> void:
	world.damage_tile($DrillPoint.global_position)

func _get_target_position(target_name:String) -> Vector2:
	if target_name == "order":
		return order.global_position
	elif target_name == "drill":
		return drill.global_position
	elif target_name == "tunnel_end":
		return tunnel_end.global_position
	assert(false)
	return Vector2()

func _retire() -> void:
	drill.available_excavators += 1
	order.queue_free()
	queue_free()
