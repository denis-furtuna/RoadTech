extends Control

signal test_terminat(scor_final)

# --- INVENTARUL VIZUAL (Căi directe sub rădăcină) ---
@onready var text_intrebare = $FundalQuiz/TextIntrebare
@onready var btn_a =$FundalQuiz/ContainerRaspunsuri/BtnA
@onready var btn_b = $FundalQuiz/ContainerRaspunsuri/BtnB
@onready var btn_c = $FundalQuiz/ContainerRaspunsuri/BtnC
@onready var btn_d = $FundalQuiz/ContainerRaspunsuri/BtnD

# --- LOGISTICA ---
var lista_intrebari = []
var index_curent = 0
var scor_batalie = 0
var foc_permis = true 
var buton_tinta_corecta: Button # Aici e laserul nostru!

func _ready():
	# Conectăm trăgaciul butoanelor
	btn_a.pressed.connect(_pe_raspuns_apasat.bind(btn_a))
	btn_b.pressed.connect(_pe_raspuns_apasat.bind(btn_b))
	btn_c.pressed.connect(_pe_raspuns_apasat.bind(btn_c))
	btn_d.pressed.connect(_pe_raspuns_apasat.bind(btn_d))

func incepe_interogatoriul(intrebari_primite):
	lista_intrebari = intrebari_primite
	index_curent = 0
	scor_batalie = 0
	show()
	incarca_intrebarea_curenta()

func incarca_intrebarea_curenta():
	if index_curent >= lista_intrebari.size():
		hide()
		test_terminat.emit(scor_batalie)
		return

	foc_permis = true 
	buton_tinta_corecta = null # Resetăm ținta!
	
	var toate_butoanele = [btn_a, btn_b, btn_c, btn_d]
	for btn in toate_butoanele:
		btn.modulate = Color.WHITE

	var date_intrebare = lista_intrebari[index_curent]
	
	# Afișăm întrebarea
	text_intrebare.text = "[center]" + date_intrebare["question_text"].replace(" ", "   ") + "[/center]"

	var variante = date_intrebare["options"]
	var raspuns_corect_ai = str(date_intrebare["correct_answer"]).to_lower().strip_edges()

	# --- IDENTIFICAREA BUTONULUI CORECT (Laserul) ---
	for i in range(4):
		var btn = toate_butoanele[i]
		var text_varianta = str(variante[i])
		
		# Punem textul pe buton (vizual)
		btn.text = text_varianta.replace(" ", "   ")
		
		# Verificăm dacă ASTA e varianta corectă
		# Folosim o comparație simplă: dacă varianta se regăsește în răspunsul corect sau invers
		var text_varianta_curat = text_varianta.to_lower().strip_edges()
		
		if text_varianta_curat == raspuns_corect_ai or raspuns_corect_ai.contains(text_varianta_curat):
			if buton_tinta_corecta == null: # Îl luăm pe primul care se potrivește
				buton_tinta_corecta = btn
				print("LUNETIST: Am marcat butonul ", i, " ca fiind cel CORECT.")

	# FAILSAFE: Dacă AI-ul a trimis ceva atât de ciudat încât nu s-a potrivit nimic
	if buton_tinta_corecta == null:
		print("EROARE: Nu s-a putut identifica butonul corect! AI-ul a trimis: ", raspuns_corect_ai)
		buton_tinta_corecta = btn_a # Siguranță de ultimă instanță

func _pe_raspuns_apasat(buton_apasat: Button):
	if foc_permis == false:
		return 

	foc_permis = false 
	
	var verde_nuclear = Color("00ff00") 
	var rosu_sangeriu = Color("ff0000") 

	# LOGICA SUPREMĂ: Ești pe butonul pe care l-am marcat anterior ca fiind corect?
	if buton_apasat == buton_tinta_corecta:
		print("VICTORIE: Ai nimerit butonul marcat!")
		buton_apasat.modulate = verde_nuclear 
		scor_batalie += 1
	else:
		print("RATEU: Buton greșit.")
		buton_apasat.modulate = rosu_sangeriu 
		# Arătăm OBLIGATORIU butonul corect
		if buton_tinta_corecta != null:
			buton_tinta_corecta.modulate = verde_nuclear

	# Așteptăm 1.5 secunde pentru recruți
	await get_tree().create_timer(1.5).timeout

	index_curent += 1
	incarca_intrebarea_curenta()
