@tool
extends BTAction

var robot:Robot
var tolerance:float = 5

@export_enum("order","drill","tunnel_end") var target_name:String
var target_position:Vector2

func _generate_name() -> String:
	return "Move vertically towards %s" % target_name

func _setup() -> void:
	robot = agent as Robot

func _enter() -> void:
	target_position = robot._get_target_position(target_name)

func _tick(delta):
	var direction:Vector2 = target_position - robot.global_position
	direction.x = 0
	robot.velocity = direction.normalized() * robot.movespeed
	if robot.global_position.y > target_position.y - tolerance and robot.global_position.y < target_position.y + tolerance:
		return SUCCESS
	return RUNNING
