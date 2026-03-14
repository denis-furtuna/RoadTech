extends Control

signal test_terminat(scor_final)
# --- INVENTARUL VIZUAL ---
@onready var text_intrebare = $FundalQuiz/TextIntrebare
@onready var btn_a = $FundalQuiz/ContainerRaspunsuri/BtnA
@onready var btn_b = $FundalQuiz/ContainerRaspunsuri/BtnB
@onready var btn_c = $FundalQuiz/ContainerRaspunsuri/BtnC
@onready var btn_d = $FundalQuiz/ContainerRaspunsuri/BtnD

# --- MUNIȚIA ȘI LOGISTICA ---
var lista_intrebari = []
var index_curent = 0
var scor_batalie = 0
var foc_permis = true # Siguranța armei!
# --- STAȚIA RADIO ---
# Când se termină întrebările, trimitem scorul către comandament!


func _ready():
	# Legăm trăgaciul fiecărui buton de funcția de verificare!
	# Folosim .bind() ca să știm EXACT ce buton a fost apăsat.
	btn_a.pressed.connect(_pe_raspuns_apasat.bind(btn_a))
	btn_b.pressed.connect(_pe_raspuns_apasat.bind(btn_b))
	btn_c.pressed.connect(_pe_raspuns_apasat.bind(btn_c))
	btn_d.pressed.connect(_pe_raspuns_apasat.bind(btn_d))
	
	# Camuflăm interfața la pornire
	# hide()
	
	# TEST DE ARTILERIE (Scoate diez-ul de la liniile de mai jos ca să testezi direct)
	var intrebari_test = [
	{"question_text": "Care este capitala Franței?", "options": ["Londra", "Paris", "Berlin", "Roma"], "correct_answer": "Paris"},
	{"question_text": "Cât face 2 + 2?", "options": ["3", "4", "5", "6"], "correct_answer": "4"}
	]
	incepe_interogatoriul(intrebari_test)

# --- ORDINUL DE ATAC ---
func incepe_interogatoriul(intrebari_primite):
	lista_intrebari = intrebari_primite
	index_curent = 0
	scor_batalie = 0
	show()
	incarca_intrebarea_curenta()

# --- REÎNCĂRCAREA ARMEI ---
func incarca_intrebarea_curenta():
	# Verificăm dacă am rămas fără muniție (fără întrebări)
	if index_curent >= lista_intrebari.size():
		hide()
		test_terminat.emit(scor_batalie) # Trimitem scorul!
		return

	# Deblocăm arma și curățăm vopseaua!
	foc_permis = true 
	var toate_butoanele = [btn_a, btn_b, btn_c, btn_d]
	for btn in toate_butoanele:
		btn.modulate = Color.WHITE
		# AM ȘTERS btn.disabled = false DE AICI!

	# --- ÎNCĂRCĂM ȘI LĂȚIM TEXTUL INAMIC ---
	var date_intrebare = lista_intrebari[index_curent]
	var text_primit = date_intrebare["question_text"]
	
	# INJECTĂM SPAȚII: Înlocuim fiecare spațiu normal cu TREI spații!
	var text_spatiat = text_primit.replace(" ", "  ")
	text_intrebare.text = "[center]" + text_spatiat + "[/center]"

	# Lățește și variantele de pe butoane!
	var variante = date_intrebare["options"]
	btn_a.text = variante[0].replace(" ", "  ")
	btn_b.text = variante[1].replace(" ", "  ")
	btn_c.text = variante[2].replace(" ", "  ")
	btn_d.text = variante[3].replace(" ", "  ")

# --- VERIFICAREA ȚINTEI ---
# --- VERIFICAREA ȚINTEI (FĂRĂ PIERDERE DE CONTRAST!) ---
func _pe_raspuns_apasat(buton_apasat: Button):
	# Dacă siguranța e pusă (a tras deja), ignorăm click-ul complet!
	if foc_permis == false:
		return 

	# Jucătorul a apăsat! PUNEM SIGURANȚA ca să nu mai poată apăsa de două ori!
	foc_permis = false 

	var raspuns_corect = lista_intrebari[index_curent]["correct_answer"]

	# MUNIȚIE VIZUALĂ DE CALIBRU GREU (Culori HEX pure, 100% opace)
	var verde_nuclear = Color("00ff00") 
	var rosu_sangeriu = Color("ff0000") 

	if buton_apasat.text == raspuns_corect:
		# VICTORIE TOTALĂ!
		buton_apasat.modulate = verde_nuclear 
		scor_batalie += 1
	else:
		# ÎNFRÂNGERE DEVASTATOARE!
		buton_apasat.modulate = rosu_sangeriu 
		var toate_butoanele = [btn_a, btn_b, btn_c, btn_d]
		for btn in toate_butoanele:
			if btn.text == raspuns_corect:
				btn.modulate = verde_nuclear

	# Așteptăm 1.5 secunde ca să vadă rezultatul și să-i intre bine în cap
	await get_tree().create_timer(1.5).timeout

	# Trecem la următoarea țintă!
	index_curent += 1
	incarca_intrebarea_curenta()
	
