@tool
extends BTAction

var robot:Robot
var tolerance:float = 5

@export_enum("order","drill","tunnel_end") var target_name:String
var target_position:Vector2

func _generate_name() -> String:
	return "Move horizontally towards %s" % target_name

func _setup() -> void:
	robot = agent as Robot

func _enter() -> void:
	target_position = robot._get_target_position(target_name)

func _tick(delta):
	robot.velocity = target_position - robot.global_position
	robot.velocity.y = 0
	robot.velocity = robot.velocity.normalized() * robot.movespeed
	if robot.global_position.x > target_position.x - tolerance and robot.global_position.x < target_position.x + tolerance:
		return SUCCESS
	return RUNNING
