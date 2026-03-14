extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var last_direction : Vector2 = Vector2.RIGHT

const SPEED = 500.0

func _physics_process(delta: float) -> void:
	process_movement()
	process_animation()
	move_and_slide()
	
func process_movement() -> void:
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left","right","up","down")
	if direction != Vector2.ZERO:
		velocity=direction * SPEED
		last_direction=direction
	else:
		velocity=Vector2.ZERO	
	
func process_animation() -> void:
	if velocity != Vector2.ZERO :
		play_animation(last_direction)
	else :
		animated_sprite_2d.play("idle")
	
		
func play_animation(dir : Vector2) -> void:
	if dir.x > 0 :
		animated_sprite_2d.play("run_right")
	elif dir.x < 0:
		animated_sprite_2d.play("run_left")
	elif dir.y < 0:
		animated_sprite_2d.play("run_up")
	elif dir.y >0:
		animated_sprite_2d.play("run_down")
