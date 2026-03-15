extends Node2D 

# --- INVENTARUL DE TRUPE ---
@onready var carte_ui = $InterfataUI/CarteUi
@onready var quiz_ui = $InterfataUI/QuizUi
@onready var ai_manager = $ManagerAI

# --- RANIȚA LOGISTICĂ ---
var munitie_ai = {} 
var cufar_curent_activ = null 
var toate_titlurile_capitolelor = []

func _ready():
	if carte_ui != null: carte_ui.hide()
	if quiz_ui != null: quiz_ui.hide()
	
	ai_manager.date_gata.connect(_pe_raport_ai_primit)
	ai_manager.roadmap_gata.connect(_pe_roadmap_primit) 
	quiz_ui.test_terminat.connect(_pe_quiz_terminat)
	
	var toate_cuferele = get_tree().get_nodes_in_group("Cufere")
	var mese_tactice = []
	
	for obiect in toate_cuferele:
		if obiect.has_signal("deschide_cartea"):
			mese_tactice.append(obiect)
		elif obiect.has_signal("cufar_accesat"):
			if not obiect.cufar_accesat.is_connected(_pe_cufar_solicita_quiz):
				obiect.cufar_accesat.connect(_pe_cufar_solicita_quiz)
				
	mese_tactice.sort_custom(func(a, b): return a.name < b.name)
	
	for i in range(mese_tactice.size()):
		var masa = mese_tactice[i]
		if not masa.deschide_cartea.is_connected(_on_masa_deschisa_cu_index):
			masa.deschide_cartea.connect(func(continut): _on_masa_deschisa_cu_index(i, continut))

	if DateGlobale.subiect_ales_de_jucator != "":
		ai_manager.cere_roadmap_materie(DateGlobale.subiect_ales_de_jucator)

func _on_masa_deschisa_cu_index(index: int, continut_text: String):
	# Dacă jucătorul a apăsat Start și acum interacționează cu masa:
	if carte_ui != null:
		# 2. ORDIN DE APARIȚIE: Scoatem harta la lumină!
		carte_ui.show() 
		
		var titlu = "CLASSIFIED DOCUMENTS"
		if index < toate_titlurile_capitolelor.size():
			titlu = toate_titlurile_capitolelor[index]
		
		# Încărcăm textul lung (cel generat masiv de Python acum!)
		carte_ui.incarca_materia(titlu, continut_text)

# ==========================================
# CÂND SE ÎNTOARCE AI-UL CU CELE 6 CAPITOLE
# ==========================================
func _pe_roadmap_primit(date_primite):
	print("COMANDAMENT: Extragem datele tactice din pachetul Python!")
	
	var lista_finala = []
	
	# --- EXTRACTORUL INTELIGENT (RADARUL DE LISTE) ---
	# Nu ne mai interesează cum a botezat AI-ul lista ("capitole", "chapters", "data").
	# Căutăm direct prima listă (Array) pe care o găsim în JSON!
	for cheie in date_primite.keys():
		if typeof(date_primite[cheie]) == TYPE_ARRAY:
			lista_finala = date_primite[cheie]
			break
			
	# Verificăm dacă inamicul ne-a trimis o cutie complet goală
	if lista_finala.size() == 0:
		print("EROARE FATALĂ: Python a trimis un JSON fără nicio listă!")
		return

	# TACTICA DE UMPLERE: Dacă a trimis mai puține de 6, le clonăm pe ultimele!
	if lista_finala.size() < 6:
		print("AVERTISMENT: AI-ul a fost leneș! Multiplicăm muniția pentru a acoperi 6 mese!")
		var ultimul_capitol = lista_finala[lista_finala.size() - 1]
		while lista_finala.size() < 6:
			lista_finala.append(ultimul_capitol)

	# SALVĂM TITLURILE INTELIGENT (căutăm "title" sau "titlu")
	toate_titlurile_capitolelor.clear()
	for p in lista_finala:
		toate_titlurile_capitolelor.append(p.get("title", p.get("titlu", "Capitol Clasificat")))

	# DISTRIBUȚIA PE TEREN
	var mese_tactice = []
	var cufere_de_lupta = []
	
	for obiect in get_tree().get_nodes_in_group("Cufere"):
		if obiect.has_signal("deschide_cartea"):
			mese_tactice.append(obiect)
		elif obiect.has_signal("cufar_accesat"):
			cufere_de_lupta.append(obiect)
			
	mese_tactice.sort_custom(func(a, b): return a.name < b.name)
	cufere_de_lupta.sort_custom(func(a, b): return a.name < b.name)
	
	for i in range(min(mese_tactice.size(), lista_finala.size())):
		var p = lista_finala[i]
		var text_capitol = "Eroare la decriptare text."
		
		# --- EXTRACTORUL DE TEXT ---
		# Căutăm textul indiferent cum l-a ascuns AI-ul!
		if p.has("content"): text_capitol = p["content"]
		elif p.has("text"): text_capitol = p["text"]
		elif p.has("teorie"): text_capitol = p["teorie"]
		
		# Încărcăm Masa
		mese_tactice[i].documentatie_camera = text_capitol
		# Încărcăm Cufărul (dar atenție, acum Cufărul oricum nu mai folosește textul ăsta, fiindcă extrage Python direct, dar îl lăsăm pentru siguranță!)
		if i < cufere_de_lupta.size():
			cufere_de_lupta[i].documentatie_camera = text_capitol
			
	print("LOGISTICĂ: Toate cele 6 cărți au fost încărcate cu succes!")

func _pe_cufar_solicita_quiz(text_capitol_primit, referinta_cufar):
	cufar_curent_activ = referinta_cufar 
	# Trimitem textul capitolului (text_capitol_primit) către AI!
	ai_manager.cere_date_de_la_api(text_capitol_primit)

func _pe_raport_ai_primit(date_procesate: Dictionary):
	var intrebari_ai = date_procesate["intrebari"]
	if carte_ui != null: carte_ui.hide()
	if quiz_ui != null:
		quiz_ui.show() 
		quiz_ui.incepe_interogatoriul(intrebari_ai)

func _pe_quiz_terminat(scor: int):
	if quiz_ui != null: quiz_ui.hide()
	
	if scor > 0:
		if cufar_curent_activ != null:
			var nume_cufar = cufar_curent_activ.name 
			cufar_curent_activ.distruge_cufarul() 
			cufar_curent_activ = null
			
			if nume_cufar == "Cufar6" or nume_cufar == "Cufarul6":
				_initiaza_transferul_spre_arena()
	else:
		cufar_curent_activ = null

func _initiaza_transferul_spre_arena():
	await get_tree().create_timer(1.5).timeout 
	get_tree().change_scene_to_file("res://scenes/boss_arena.tscn")
