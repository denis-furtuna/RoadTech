extends Node

signal boss_gata(json_date) 
signal date_gata(json_date)          
signal roadmap_gata(lista_capitole)  

var racheta_in_aer = false
var mod_operare = ""             

func _ready():
	$HTTPRequest.request_completed.connect(_pe_raspuns_primit)

# ==========================================
# 1. CEREM CELE 6 CAPITOLE (La începutul nivelului)
# ==========================================
func cere_roadmap_materie(subiect: String):
	if racheta_in_aer: return
	racheta_in_aer = true
	mod_operare = "ROADMAP"
	
	var url = "http://127.0.0.1:5000/roadmap?subiect=" + subiect.uri_encode() + "&varsta=" + DateGlobale.varsta_aleasa_de_jucator.uri_encode()
	print("GODOT -> PYTHON: Solicităm Roadmap pentru vârsta ", DateGlobale.varsta_aleasa_de_jucator)
	$HTTPRequest.request(url)

# ==========================================
# 2. CEREM QUIZ-UL (Când deschizi un Cufăr)
# ==========================================
# ÎNLOCUIEȘTE FUNCȚIA cere_date_de_la_api ÎN manager_ai.gd
func cere_date_de_la_api(text_capitol: String):
	if racheta_in_aer: return
	racheta_in_aer = true
	mod_operare = "QUIZ"
	
	var url = "http://127.0.0.1:5000/quiz"
	var headers = ["Content-Type: application/json"]
	
	# Pregătim pachetul de date (Textul Capitolului + Vârsta)
	var date_pachet = {
		"text_capitol": text_capitol,
		"varsta": DateGlobale.varsta_aleasa_de_jucator
	}
	
	var query = JSON.stringify(date_pachet)
	
	print("GODOT -> PYTHON: Trimitem TEXTUL CAPITOLULUI pentru interogare strictă...")
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, query)

# ==========================================
# 3. CEREM BOSS FIGHT-UL
# ==========================================
func cere_intrebari_boss(subiect: String):
	if racheta_in_aer: return
	racheta_in_aer = true
	mod_operare = "BOSS_FIGHT"
	
	var url = "http://127.0.0.1:5000/boss?subiect=" + subiect.uri_encode() + "&varsta=" + DateGlobale.varsta_aleasa_de_jucator.uri_encode()
	$HTTPRequest.request(url)

# ==========================================
# 4. RECEPȚIA DATELOR DE LA PYTHON
# ==========================================
func _pe_raspuns_primit(result, response_code, headers, body):
	racheta_in_aer = false
	
	if response_code != 200:
		print("EROARE CRITICĂ: Serverul Python e oprit sau bruiat! Cod: ", response_code)
		_aplica_plan_de_urgenta()
		return
		
	var json_string = body.get_string_from_utf8()
	var parser = JSON.new()
	
	# Acum parsarea nu va mai crăpa niciodată, pentru că Python a făcut deja curățenia!
	if parser.parse(json_string) == OK:
		var date_procesate = parser.data
		
		# Verificăm dacă Python a întâmpinat o eroare cu AI-ul
		if date_procesate.has("error"):
			print("PYTHON RAPORTEAZĂ: ", date_procesate["error"])
			_aplica_plan_de_urgenta()
			return
			
		print("GODOT: Am primit JSON perfect de la Python!")
		if mod_operare == "ROADMAP": roadmap_gata.emit(date_procesate)
		elif mod_operare == "QUIZ": date_gata.emit(date_procesate)
		elif mod_operare == "BOSS_FIGHT": boss_gata.emit(date_procesate)
	else:
		print("EROARE: JSON corupt primit de la Python!")
		_aplica_plan_de_urgenta()

# ==========================================
# 5. PROTOCOLUL DE SIGURANȚĂ
# ==========================================
func _aplica_plan_de_urgenta():
	racheta_in_aer = false
	var date_urgenta = {}
	if mod_operare == "ROADMAP":
		date_urgenta = {"capitole": []}
		for i in range(6): date_urgenta["capitole"].append({"title": "System Error " + str(i+1), "content": "Communication with Python lost."})
		roadmap_gata.emit(date_urgenta)
	elif mod_operare == "QUIZ":
		date_gata.emit({"intrebari": [{"question_text": "SYSTEM OVERRIDE!", "options": ["Accept", "Accept", "Accept", "Accept"], "correct_answer": "Accept"}]})
	else:
		boss_gata.emit({"intrebari": [{"question_text": "SYSTEM OVERRIDE!", "options": ["Accept", "Accept", "Accept", "Accept"], "correct_answer": "Accept"}]})
