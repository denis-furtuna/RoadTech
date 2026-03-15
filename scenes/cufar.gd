extends StaticBody2D 

# COMANDA MAGICĂ: @export_multiline îți va face o cutie MARE de text în Inspector!
@export_multiline var documentatie_camera: String = "Lipește aici tot textul din care vrei să dea test..." 

@onready var sprite = $Sprite2D
@onready var zona_senzor = $ZonaSenzor 

var jucator_in_raza = false
signal cufar_accesat(documentatie_trimisa, referinta_cufar)



func _ready():
	# Conectăm senzorii FIX de la copilul Area2D, nu de la rădăcină!
	zona_senzor.body_entered.connect(_pe_intrare_zona)
	zona_senzor.body_exited.connect(_pe_iesire_zona)

func _process(_delta):
	if jucator_in_raza and Input.is_action_just_pressed("ui_accept"):
		print("CUFĂR: Transmitem documentația secretă către bază!")
		# Acum trimitem TOT TEXTUL tău, nu doar un cuvânt!
		cufar_accesat.emit(documentatie_camera, self)

func _pe_intrare_zona(body):
	if body.name == "Player" or body.name == "player":
		jucator_in_raza = true
		sprite.modulate = Color(1.2, 1.2, 1.2) # Se luminează 

func _pe_iesire_zona(body):
	if body.name == "Player" or body.name == "player":
		jucator_in_raza = false
		sprite.modulate = Color.WHITE 

# ORDINUL DE AUTODISTRUGERE!
func distruge_cufarul():
	# Funcția supremă Godot pentru a șterge definitiv un obiect de pe hartă!
	# După ce rulăm asta, cufărul dispare și lasă cheia la vedere!
	queue_free()
