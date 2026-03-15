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
@onready var quiz_timer = $FundalQuiz/QuizTimer
@onready var death_screen = "res://scenes/death_screen.tscn"
@onready var animated_sprite_2d_2: AnimatedSprite2D = $AnimatedSprite2D2
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
	$AnimatedSprite2D3.hide()
	$Sprite2D.hide()
	$AnimatedSprite2D4.hide()
	text_intrebare.text = "The Dragon awakens... Prepare for battle!"
	
	if quiz_timer:
		quiz_timer.timp_expirat.connect(_pe_timp_expirat)
	
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
		
	if quiz_timer:
		quiz_timer.porneste(10.0)

func _pe_timp_expirat():
	print("TIMP EXPIRAT! Dragonul te-a făcut grătar în timp ce te gândeai!")
	
	text_intrebare.text = "TIME'S UP! CRITICAL DEFEAT!"
	hp_jucator.value = 0 # Forțăm viața la 0 ca să fim siguri
	
	# Oprim butoanele
	_final_de_lupta()
	
	# Efect dramatic de 2 secunde
	await get_tree().create_timer(2.0).timeout
	
	# TELEPORTAREA CĂTRE ECRANUL DE MOARTE
	var calea_spre_moarte = "res://scenes/death_screen.tscn"
	
	if FileAccess.file_exists(calea_spre_moarte):
		print("SYSTEM: Timpul a expirat. Evacuare către Death Screen!")
		get_tree().change_scene_to_file(calea_spre_moarte)
	else:
		print("CRITICAL ERROR: Nu găsesc fișierul la: ", calea_spre_moarte)
		
func _pe_buton_apasat(buton_apasat: Button):
	if quiz_timer:
		quiz_timer.opreste()
	# Blocăm butoanele imediat ca să nu dea soldatul click de 10 ori
	for btn in butoane:
		btn.disabled = true
	if buton_apasat.text == raspuns_corect_curent:
		print("BOOM! Critical hit on the Dragon!")
		hp_boss.value -= damage_step
		text_intrebare.text = "CORRECT! The Dragon is losing health!"
		$AnimatedSprite2D2.hide()    
		$AnimatedSprite2D3.show()
		$AnimatedSprite2D3.frame = 0 # Ne asigurăm că începe de la prima imagine
		$AnimatedSprite2D3.play("default") 

		await get_tree().create_timer(1.0).timeout
	
		$AnimatedSprite2D3.hide()
		$AnimatedSprite2D2.show()
		$AnimatedSprite2D2.play("default") # Boss-ul revine la starea normală
	else:
		print("OUCH! Dragon's fire hit us!")
		hp_jucator.value -= damage_step
		text_intrebare.text = "WRONG! You took heavy damage!"
		$AnimatedSprite2D.hide()
		$Sprite2D.show()
		
		await get_tree().create_timer(1.0).timeout
		
		$AnimatedSprite2D.show()
		$Sprite2D.hide()
		$AnimatedSprite2D.play("default")
		

	# Așteptăm 2 secunde pentru efectul dramatic
	await get_tree().create_timer(2.0).timeout
	
	# Verificăm dacă s-a terminat măcelul
	# Verificăm dacă s-a terminat măcelul
	if hp_boss.value <= 0:
		text_intrebare.text = "SUPREME VICTORY! THE DRAGON IS DEFEATED!"
		_final_de_lupta()
		
		# Animația ta de victorie
		$AnimatedSprite2D2.hide()
		$AnimatedSprite2D4.show()
		$AnimatedSprite2D4.frame = 0
		$AnimatedSprite2D4.play("default")
		
		print("SYSTEM: Eroul a învins! Chemăm elicopterul de extracție în 4 secunde...")
		
		# Așteptăm 4 secunde ca jucătorul să vadă animația și mesajul de glorie!
		await get_tree().create_timer(4.0).timeout
		
		# TACTICA DE RETRAGERE: Schimbăm scena înapoi la Meniu
		# ATENȚIE: Verifică dacă fișierul tău se numește 'main.tscn' sau 'meniu_principal.tscn'
		var calea_meniu = "res://scenes/meniu_principal.tscn"
		
		if FileAccess.file_exists(calea_meniu):
			print("SYSTEM: Evacuare reușită! Ne întoarcem la bază.")
			get_tree().change_scene_to_file(calea_meniu)
		else:
			print("CRITICAL ERROR: Nu găsesc Meniul Principal la coordonatele: ", calea_meniu)
			
	elif hp_jucator.value <= 0:
		# ... (Aici rămâne codul tău de Death Screen pe care l-am reparat adineauri) ...
		# 1. ANUNȚĂM DECESUL ÎN CONSOLĂ
		print("SOLDIER DOWN! Initiating emergency evacuation to Death Screen...")
		text_intrebare.text = "CRITICAL DEFEAT! YOU HAVE BEEN DEFEATED!"
		
		# 2. BLOCĂM TOATE BUTOANELE CA SĂ NU MAI APESE JUCĂTORUL DIN DISPERARE
		_final_de_lupta()
		
		# 3. EFECT DRAMATIC: Așteptăm 2 secunde să simtă gustul înfrângerii
		await get_tree().create_timer(2.0).timeout
		
		# 4. LANSAREA CĂTRE MOARTE (SCHIMBĂM SCENA!)
		# ATENȚIE: Verifică în FileSystem dacă drumul e exact ăsta! 
		# Dacă e în folderul 'scenes', pui "res://scenes/death_screen.tscn"
		var calea_spre_moarte = "res://scenes/death_screen.tscn"
		
		if FileAccess.file_exists(calea_spre_moarte):
			print("SYSTEM: Path confirmed. Teleporting now!")
			get_tree().change_scene_to_file(calea_spre_moarte)
		else:
			print("CRITICAL ERROR: I can't find the Death Screen file at: ", calea_spre_moarte)
			text_intrebare.text = "ERROR: Death Scene file is missing from the base!"
	else:
		index_curent += 1
		_incarca_intrebarea()

func _final_de_lupta():
	for btn in butoane:
		btn.hide()
	print("Lupta s-a încheiat. Raportează rezultatul!")

func _defeat():
	for btn in butoane:
		btn.hide()
	print("Lupta s-a încheiat. Raportează rezultatul!")
