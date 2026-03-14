extends StaticBody2D

signal door_opened

var keytaken = false
var in_door_zone = false

func _ready() -> void:
	# Ne asigurăm că ușa pornește în starea corectă
	$Inchisa.show()
	$Deschisa.hide()

# Această funcție trebuie conectată la semnalul body_entered al Area2D-ului copil
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		in_door_zone = true

# Această funcție trebuie conectată la semnalul body_exited al Area2D-ului copil
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		in_door_zone = false

func _process(_delta: float) -> void:
	# Verificăm dacă jucătorul are cheia (presupunând că ai variabila has_key pe jucător)
	# Sau poți folosi variabila ta 'keytaken' dacă o setezi undeva
	if in_door_zone and Input.is_action_just_pressed("accept") and keytaken:
		open_door()

func open_door():
	$Inchisa.hide() 
	$Deschisa.show() 
	# Dezactivăm coliziunea ca jucătorul să poată trece
	$CollisionShape2D.disabled = true 
	emit_signal("door_opened")
