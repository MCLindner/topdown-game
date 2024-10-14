extends RigidBody2D

@export var speed = 3
@export var accel = 2
@onready var player = get_parent().get_node("Player")
# Called when the node enters the scene tree for the first time.
func _ready():
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(mob_types[randi() % mob_types.size()])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_pos = player.get_position()
	var target_pos = (player_pos - position).normalized()
	linear_velocity = linear_velocity.lerp(target_pos * speed, accel * delta)



func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
