extends CharacterBody2D

signal hit
signal game_over

@export var speed = 100 # How fast the player will move (pixels/sec).
@export var player_health = 3 # Player health duh
var player_max_health = player_health
var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#var velocity = Vector2.ZERO # The player's movement vector
	velocity.x = 0
	velocity.y = 0
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1	
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		
	move_and_slide()
	handle_collisions()
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if player_health > 0:
		if not $InvulnTimer.is_stopped():
			$AnimatedSprite2D.animation = "hit"
		elif velocity.x != 0:
			$AnimatedSprite2D.animation = "walk"
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.flip_h = velocity.x < 0
		elif velocity.y != 0:
			$AnimatedSprite2D.animation = "up"
			# $AnimatedSprite2D.flip_v = velocity.y > 0 

## Collision detection v2.
func handle_collisions():
	if player_health > 0:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			print("I collided with ", collision.get_collider().name)
			if collision.get_collider().name.begins_with("@RigidBody2D") == true:
				# HUD needs to receive this signal
				player_health -= 1
				hit.emit(player_health) 
				print(player_health)
				$CollisionShape2D.set_deferred("disabled", true)		
				
				if player_health == 0:
					game_over.emit(player_max_health)
					# hide() # Player disappears after being hit.
					# Must be deferred as we can't change physics properties on a physics callback.
					# Maybe disable the hitbox for a half a second for i frames
					$CollisionShape2D.set_deferred("disabled", true)
					$AnimatedSprite2D.animation = "hit"
				
				$InvulnTimer.start()
				# use $CollisionShape2D.set_deferred("disabled", true) perhaps
				# this needs to check for player health
				
# make an area2d, get the node, get the enemies colliding with area2d, determine closesst or get overlapping
# or use get overlapping
# not sure if using a colision shape will work
func get_nearest_target():
	return 0
				
		

## Collision detection.
#func _on_body_entered(body):
	#hide() # Player disappears after being hit.
	#hit.emit()
	## Must be deferred as we can't change physics properties on a physics callback.
	#$CollisionShape2D.set_deferred("disabled", true)
	

# Reset the player upon starting 
func start(pos):
	velocity.x = 0
	velocity.y = 0
	#player_health = player_max_health
	position = pos
	show()
	$CollisionShape2D.disabled = false


func _on_invuln_timer_timeout():
	$CollisionShape2D.set_deferred("disabled", false)
