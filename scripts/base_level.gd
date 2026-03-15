extends Node2D 

# --- INVENTARUL DE TRUPE ---
@onready var carte_ui = $InterfataUI/CarteUi
@onready var quiz_ui = $InterfataUI/QuizUi
@onready var ai_manager = $ManagerAI

# --- RANIȚA LOGISTICĂ ---
var munitie_ai = {} 
var cufar_curent_activ = null 
var toate_titlurile_capitolelor = [] # Memoria noastră tactică

func _ready():
	# Ascundem interfețele la start
	if carte_ui != null: carte_ui.hide()
	if quiz_ui != null: quiz_ui.hide()
	
	# Conectăm semnalele de la AI
	ai_manager.date_gata.connect(_pe_raport_ai_primit)
	ai_manager.roadmap_gata.connect(_pe_roadmap_primit) 
	quiz_ui.test_terminat.connect(_pe_quiz_terminat)
	
	# --- ÎNROLAREA INTELIGENTĂ A TRUPELOR ---
	var toate_cuferele = get_tree().get_nodes_in_group("Cufere")
	var mese_tactice = []
	
	# 1. Separăm mesele de cufere
	for obiect in toate_cuferele:
		if obiect.has_signal("deschide_cartea"):
			mese_tactice.append(obiect)
		elif obiect.has_signal("cufar_accesat"):
			if not obiect.cufar_accesat.is_connected(_pe_cufar_solicita_quiz):
				obiect.cufar_accesat.connect(_pe_cufar_solicita_quiz)
				
	# 2. Sortăm mesele alfabetic (MasaCuCarte1, MasaCuCarte2...)
	mese_tactice.sort_custom(func(a, b): return a.name < b.name)
	
	# 3. Le legăm la sistem, dându-le fiecăreia "ID-ul" (indexul)
	for i in range(mese_tactice.size()):
		var masa = mese_tactice[i]
		if not masa.deschide_cartea.is_connected(_on_masa_deschisa_cu_index):
			masa.deschide_cartea.connect(func(continut): _on_masa_deschisa_cu_index(i, continut))
			print("BAZĂ: ", masa.name, " a primit ID-ul ", i)

	# --- ATACUL IMEDIAT ---
	if DateGlobale.subiect_ales_de_jucator != "":
		print("COMANDAMENT: Solicităm roadmap pentru: ", DateGlobale.subiect_ales_de_jucator)
		ai_manager.cere_roadmap_materie(DateGlobale.subiect_ales_de_jucator)

# ==========================================
# CÂND O MASĂ SE DESCHIDE (ȘTIE CE NUMĂR ARE!)
# ==========================================
func _on_masa_deschisa_cu_index(index: int, continut_text: String):
	print("BAZA: Deschid cartea pentru sectorul ", index + 1)
	if carte_ui != null:
		var titlu = "DOCUMENTE CLASIFICATE"
		if index < toate_titlurile_capitolelor.size():
			titlu = toate_titlurile_capitolelor[index]
			
		carte_ui.incarca_materia(titlu, continut_text)

# ==========================================
# CÂND SE ÎNTOARCE AI-UL CU CELE 6 CAPITOLE
# ==========================================
func _pe_roadmap_primit(date_primite):
	print("COMANDAMENT: Distribuim datele tactice în cele 6 sectoare!")
	
	var lista_finala = []
	if date_primite.has("capitole"): lista_finala = date_primite["capitole"]
	elif date_primite.has("chapters"): lista_finala = date_primite["chapters"]
	
	if lista_finala.size() < 6:
		print("EROARE CRITICĂ: AI-ul a eșuat la numărătoare!")
		return

	# Salvăm titlurile
	toate_titlurile_capitolelor.clear()
	for p in lista_finala:
		toate_titlurile_capitolelor.append(p.get("title", "Capitol"))

	# --- DISTRIBUȚIA ANTIGLONȚ ---
	var mese_tactice = []
	for obiect in get_tree().get_nodes_in_group("Cufere"):
		if obiect.has_signal("deschide_cartea"):
			mese_tactice.append(obiect)
			
	# Sortăm ca să fim siguri că Masa 1 primește Capitolul 1
	mese_tactice.sort_custom(func(a, b): return a.name < b.name)
	
	# Pompăm textul direct pe țeavă în fiecare masă găsită
	for i in range(min(mese_tactice.size(), lista_finala.size())):
		mese_tactice[i].documentatie_camera = lista_finala[i].get("content", "")
		print("LOGISTICĂ: ", mese_tactice[i].name, " a fost încărcată cu textul din Capitolul ", i + 1)

# ==========================================
# CÂND UN CUFĂR CERE QUIZ ȘI CÂND SE TERMINĂ
# ==========================================
func _pe_cufar_solicita_quiz(subiectul_primit, referinta_cufar):
	cufar_curent_activ = referinta_cufar 
	ai_manager.cere_date_de_la_api(subiectul_primit)

func _pe_raport_ai_primit(date_procesate: Dictionary):
	var intrebari_ai = date_procesate["intrebari"]
	if carte_ui != null: carte_ui.hide()
	if quiz_ui != null:
		quiz_ui.show() 
		quiz_ui.incepe_interogatoriul(intrebari_ai)

# ==========================================
# CÂND SE TERMINĂ TESTUL LA UN CUFĂR
# ==========================================
func _pe_quiz_terminat(scor: int):
	if quiz_ui != null: quiz_ui.hide()
	
	if scor > 0:
		print("COMANDAMENT: Jucătorul a trecut testul!")
		if cufar_curent_activ != null:
			# Salvăm numele înainte să-l distrugem, ca să știm cine era!
			var nume_cufar = cufar_curent_activ.name 
			
			print("PULVERIZĂM CUFĂRUL: ", nume_cufar)
			cufar_curent_activ.distruge_cufarul() 
			cufar_curent_activ = null
			
			# VERIFICARE TACTICĂ: A fost ultimul cufăr?!
			# ATENȚIE: Pune aici numele EXACT al cufărului 6 din editorul tău!
			if nume_cufar == "Cufar6" or nume_cufar == "Cufarul6":
				print("ALARMĂ DE GRADUL ZERO!!! DRAGONUL S-A TREZIT!")
				# AICI POȚI SĂ DAI SHOW() LA O POZĂ/ANIMAȚIE CU DRAGONUL PE HARTĂ!
				_initiaza_transferul_spre_arena()
	else:
		print("COMANDAMENT: AI PICAT! Mai citește documentația și revino!")
		cufar_curent_activ = null

# --- MANEVRA DE AȘTEPTARE ȘI EVACUARE ---
func _initiaza_transferul_spre_arena():
	print("FRONTUL: Așteptăm 3 secunde pentru efect dramatic...")
	
	# Înghețăm execuția acestui script pentru fix 3 secunde!
	await get_tree().create_timer(3.0).timeout 
	
	print("COMANDAMENT: TELEPORTARE ÎN ARENA BOSS-ULUI!")
	# Schimbăm scena. Asigură-te că vei crea o scenă cu numele ăsta!
	get_tree().change_scene_to_file("res://scenes/boss_arena.tscn")
