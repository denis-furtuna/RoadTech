extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var last_direction : Vector2 = Vector2.RIGHT
var is_interacting : bool = false # LACĂTUL TACTIC! 

const SPEED = 500.0

func _ready() -> void:
	# Când se termină ORICE animație, chemăm această funcție să verifice situația!
	animated_sprite_2d.animation_finished.connect(_pe_animatie_terminata)

func _physics_process(delta: float) -> void:
	# REGLA DE AUR: Dacă soldatul interacționează, NU ascultăm alte ordine!
	if is_interacting:
		move_and_slide() # Îl lăsăm să alunece dacă avea inerție, dar nu-i dăm comenzi noi
		return
		
	# VERIFICĂM ORDINUL DE INTERACȚIUNE (Tasta Enter/Space)
	if Input.is_action_just_pressed("accept"):
		declanseaza_interactiunea()
		return # Ieșim din funcție ca să nu mai procesăm mișcarea tura asta!

	process_movement()
	process_animation()
	move_and_slide()
	
func declanseaza_interactiunea() -> void:
	print("FRONTUL: Soldatul a inițiat interacțiunea!")
	is_interacting = true
	velocity = Vector2.ZERO # Oprește-l pe loc imediat!
	
	# ASIGURĂ-TE CĂ ANIMAȚIA SE NUMEȘTE EXACT AȘA ÎN EDITOR:
	animated_sprite_2d.play("interact") 

func _pe_animatie_terminata() -> void:
	# Dacă animația care tocmai s-a terminat este cea de interacțiune...
	if animated_sprite_2d.animation == "interact":
		print("FRONTUL: Interacțiune completă! Liber la mișcare!")
		is_interacting = false # Ridicăm lacătul!

# --- TRUPELE TALE VECHI RĂMÂN LA FEL ---
func process_movement() -> void:
	var direction := Input.get_vector("left","right","up","down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
	else:
		velocity = Vector2.ZERO	
	
func process_animation() -> void:
	if velocity != Vector2.ZERO:
		play_animation(last_direction)
	else:
		animated_sprite_2d.play("idle")
		
func play_animation(dir : Vector2) -> void:
	if dir.x > 0:
		animated_sprite_2d.play("run_right")
	elif dir.x < 0:
		animated_sprite_2d.play("run_left")
	elif dir.y < 0:
		animated_sprite_2d.play("run_up")
	elif dir.y > 0:
		animated_sprite_2d.play("run_down")
