extends CharacterBody2D

var movespeed:float = 600

func _process(delta):
	var direction:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	velocity = direction * movespeed
	move_and_slide()
	handle_animation()

func handle_animation():
	var sprite:AnimatedSprite2D = $AnimatedSprite2D
	if Input.get_action_strength("move_up") > 0:
		sprite.frame = 1
	elif Input.get_action_strength("move_down") > 0:
		sprite.frame = 2
	elif Input.get_action_strength("move_left") > 0:
		sprite.frame = 3
	elif Input.get_action_strength("move_right") > 0:
		sprite.frame = 4
	else:
		sprite.frame = 0
