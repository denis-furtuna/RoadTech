extends Node2D

# --- INVENTARUL DE TRUPE ---
# Tragem referințe către soldații noștri de pe front!
@onready var carte_ui = $InterfataUI/CarteUi
@onready var quiz_ui = $InterfataUI/QuizUi
@onready var ai_manager = $ManagerAI # PUNE NUMELE EXACT AL NODULUI TĂU AI AICI!
signal date_gata(json_data)
# Ranița în care ținem datele primite de la Groq până le terminăm de folosit
var munitie_ai = {} 

func _ready():
	# 1. Camuflăm interfețele la startul misiunii
	carte_ui.hide()
	quiz_ui.hide()
	
	# 2. CABLĂM STAȚIILE RADIO (Semnalele)
	# Când AI-ul termină de descărcat datele, ne anunță:
	ai_manager.date_gata.connect(_pe_raport_ai_primit) 
	
	# Când jucătorul dă ultima pagină la carte, ne anunță:
	carte_ui.carte_citita_complet.connect(_pe_carte_terminata)
	
	# Când jucătorul termină testul, ne dă scorul:
	quiz_ui.test_terminat.connect(_pe_quiz_terminat)

# --- ORDIN DE ATAC (Apelezi asta când jucătorul atinge cufărul!) ---
func declanseaza_invatarea(subiect: String):
	print("COMANDAMENT: Cerem suport aerian pentru subiectul: ", subiect)
	# Apelezi funcția ta din scriptul de AI care face request-ul la Groq!
	# (Modifică numele funcției de mai jos cu cel real din scriptul tău AI)
	ai_manager.cere_date_de_la_api(subiect) 

# --- REACȚII LA RAPOARTELE DE PE FRONT ---

# Pasul A: AI-ul s-a întors cu prada!
func _pe_raport_ai_primit(json_procesat: Dictionary):
	print("COMANDAMENT: Am primit materia! Deschidem cartea!")
	munitie_ai = json_procesat # Salvăm datele
	
	# Trimitem datele la carte! (Atenție să folosești cheile exacte din JSON-ul tău!)
	var titlu = munitie_ai["titlu"]
	var teorie = munitie_ai["teorie"]
	carte_ui.incarca_materia(titlu, teorie)

# Pasul B: Soldatul a citit tot. Începe interogatoriul!
func _pe_carte_terminata():
	print("COMANDAMENT: Cartea a fost citită. Se ascunde!")
	carte_ui.hide()
	
	print("COMANDAMENT: Se lansează bombardamentul cu întrebări!")
	var intrebari = munitie_ai["intrebari"]
	quiz_ui.incepe_interogatoriul(intrebari)

# Pasul C: Supraviețuitorul a terminat quiz-ul!
func _pe_quiz_terminat(scor: int):
	print("COMANDAMENT: Misiune încheiată! Scor obținut: ", scor)
	quiz_ui.hide()

	# AICI DAI RECOMPENSA: deschizi ușa, îi dai o cheie de aur, îl lași să meargă mai departe!
