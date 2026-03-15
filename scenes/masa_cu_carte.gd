extends StaticBody2D

signal deschide_cartea(continut_text)

@onready var carte_animata = $AnimatedSprite2D
var jucator_in_zona = false

# Baza (base_level.gd) va băga textul AI-ului direct aici!
var documentatie_camera = "Aștept datele de la satelitul Groq..." 

func _ready():
	carte_animata.stop()
	carte_animata.frame = 0 

func _on_zona_radar_body_entered(body):
	if body.is_in_group("Jucator"):
		jucator_in_zona = true
		print("RADAR: Am detectat prezență! Pornim magia cărții!")
		carte_animata.play("default") 

func _on_zona_radar_body_exited(body):
	if body.is_in_group("Jucator"):
		jucator_in_zona = false
		print("RADAR: Ținta a plecat. Închidem cartea.")
		carte_animata.stop()
		carte_animata.frame = 0

# UNICUL ȘI SUPREMUL INPUT! Fără duplicate!
func _input(event):
	if jucator_in_zona and event.is_action_pressed("accept"): 
		print("COMANDAMENT: Jucătorul citește! Transmit teoria: ", documentatie_camera)
		deschide_cartea.emit(documentatie_camera)
