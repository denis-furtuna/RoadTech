extends Control

@onready var manager_ai = $ManagerAI
@onready var text_intrebare = $FundalQuiz/TextIntrebare
@onready var hp_boss = $HpBoss
@onready var hp_jucator = $HpJucator
@onready var butoane = [
	$FundalQuiz/CutieButoane/BtnA, 
	$FundalQuiz/CutieButoane/BtnB, 
	$FundalQuiz/CutieButoane/BtnC, 
	$FundalQuiz/CutieButoane/BtnD
]

var intrebari_lista = []
var index_curent = 0
var raspuns_corect_curent = ""

# CONFIGURAȚIE DE LUPTĂ
var hp_maxim = 100
var damage_step = 34 

func _ready():
	# SETĂM BARELE DE VIAȚĂ LA MAXIM
	hp_boss.max_value = hp_maxim
	hp_boss.value = hp_maxim
	hp_jucator.max_value = hp_maxim
	hp_jucator.value = hp_maxim

	text_intrebare.text = "The Dragon awakens... Prepare for battle!"
	
	for btn in butoane:
		btn.hide()

	# CONECTARE AI
	if not manager_ai.boss_gata.is_connected(_pe_intrebari_primite):
		manager_ai.boss_gata.connect(_pe_intrebari_primite)
	
	# CONECTARE BUTOANE (Folosim un loop inteligent ca să nu scriem 4 funcții)
	for btn in butoane:
		if not btn.pressed.is_connected(_pe_buton_apasat):
			btn.pressed.connect(_pe_buton_apasat.bind(btn))

	# LANSAREA PROIECTILULUI CĂTRE AI
	if DateGlobale.subiect_ales_de_jucator != "":
		manager_ai.cere_intrebari_boss(DateGlobale.subiect_ales_de_jucator)
	else:
		text_intrebare.text = "ERROR: No subject found in memory!"

func _pe_intrebari_primite(date_procesate: Dictionary):
	intrebari_lista = date_procesate["intrebari"]
	index_curent = 0
	_incarca_intrebarea()

func _incarca_intrebarea():
	# Verificăm dacă mai avem muniție sau dacă cineva e deja la pământ
	if index_curent >= intrebari_lista.size() or hp_boss.value <= 0 or hp_jucator.value <= 0:
		_final_de_lupta()
		return

	var q = intrebari_lista[index_curent]
	text_intrebare.text = q["question_text"]
	raspuns_corect_curent = q["correct_answer"]
	
	var optiuni = q["options"]
	optiuni.shuffle()
	
	for i in range(4):
		butoane[i].show()
		butoane[i].text = optiuni[i]
		butoane[i].disabled = false # Deblocăm butoanele pentru runda nouă

func _pe_buton_apasat(buton_apasat: Button):
	# Blocăm butoanele imediat ca să nu dea soldatul click de 10 ori
	for btn in butoane:
		btn.disabled = true

	if buton_apasat.text == raspuns_corect_curent:
		print("BOOM! Critical hit on the Dragon!")
		hp_boss.value -= damage_step
		text_intrebare.text = "CORRECT! The Dragon is losing health!"
	else:
		print("OUCH! Dragon's fire hit us!")
		hp_jucator.value -= damage_step
		text_intrebare.text = "WRONG! You took heavy damage!"

	# Așteptăm 2 secunde pentru efectul dramatic
	await get_tree().create_timer(2.0).timeout
	
	# Verificăm dacă s-a terminat măcelul
	if hp_boss.value <= 0:
		text_intrebare.text = "SUPREME VICTORY! THE DRAGON IS DEFEATED!"
		_final_de_lupta()
	elif hp_jucator.value <= 0:
		text_intrebare.text = "CRITICAL DEFEAT! YOU HAVE BEEN DEFEATED!"
		_final_de_lupta()
	else:
		index_curent += 1
		_incarca_intrebarea()

func _final_de_lupta():
	for btn in butoane:
		btn.hide()
	print("Lupta s-a încheiat. Raportează rezultatul!")
