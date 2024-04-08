extends CharacterBody2D

const JUMP_VELOCITY = -700.0
const gravity = 1600

func _physics_process(delta):
	velocity.y += gravity * delta
	if is_on_floor():
		if not get_parent().is_game_running:
			$AnimatedSprite2D.play("idle")
		else:
			$coll_running.disabled = false
			if Input.is_action_pressed("ui_accept"):
				velocity.y = JUMP_VELOCITY
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("crouch")
				$coll_running.disabled = true
			else:
				$AnimatedSprite2D.play("running")
	else:
		$AnimatedSprite2D.play("jump")
	move_and_slide()
