extends Node

signal boss_gata(json_date) # Semnalul suprem!
signal date_gata(json_date)          # Semnalul pentru Quiz
signal roadmap_gata(lista_capitole)  # Semnalul pentru Roadmap (cele 6 capitole)

var racheta_in_aer = false
var mod_operare = "QUIZ"             # Comutatorul tactic!

# ==========================================
# 0. INITIALIZARE
# ==========================================
func _ready():
	$HTTPRequest.request_completed.connect(_on_request_completed)

# ==========================================
# 1. FUNCȚIA DE ROADMAP (Cele 6 capitole)
# ==========================================
func cere_roadmap_materie(subiect: String):
	if racheta_in_aer == true:
		return
		
	racheta_in_aer = true
	mod_operare = "ROADMAP"
	print("AI: Cerem împărțirea tactică în 6 capitole pentru: ", subiect)
	
	# PROMPT-UL PENTRU ROADMAP
	var prompt_roadmap = """You are a friendly, patient, and magical teacher for 2nd-grade children. 
Divide the subject '%s' into EXACTLY 6 progressive subchapters.
The theory MUST be engaging, using metaphors and simple words.

STRICT FORMATTING RULES:
1. Each subchapter must have a 'title' (maximum 5 words) and a 'content'.
2. The 'content' text MUST be indented: start every new paragraph with 4 spaces.
3. Use '\\n' for new lines to keep the text airy.
4. Respond STRICTLY with a valid JSON object. No markdown.
5. NO DOUBLE QUOTES (") INSIDE THE TEXT! Use single quotes (') instead.
6. WARINING IF YOU DON'T GIVE ME 6 OBJECTS THE PROCCESS WILL FAIL

EXPECTED JSON STRUCTURE:
{
	"capitole": [
		{
			"title": "The Magic of Numbers",
			"content": "    Once upon a time..."
		},
		... (exactly 6 objects)
	]
}""" % subiect
	
	_trimite_racheta_http(prompt_roadmap)

# ==========================================
# 2. FUNCȚIA DE QUIZ (Pentru Cufere)
# ==========================================
func cere_date_de_la_api(material_primit: String):
	if racheta_in_aer == true:
		return
		
	racheta_in_aer = true
	mod_operare = "QUIZ"
	print("AI: Trimitem dosarul secret la decodificare pentru quiz!")
	
	# PROMPT-UL PENTRU QUIZ
	var prompt_sever = "You are a gentle and encouraging teacher for 2nd-grade children. Read the document: \n\n" + material_primit + "\n\n Generate 4 simple, very easy-to-understand multiple-choice questions based STRICTLY on it. The generated output MUST be in ENGLISH. Respond ONLY with valid JSON, no markdown! Format: {\"intrebari\": [{\"question_text\": \"Simple question in English?\", \"options\": [\"Ans 1\", \"Ans 2\", \"Ans 3\", \"Ans 4\"], \"correct_answer\": \"Ans 2\"}]}"
	_trimite_racheta_http(prompt_sever)

# ==========================================
# 3. MOTORUL HTTP (Comun pentru ambele funcții)
# ==========================================
# ==========================================
# 3. MOTORUL HTTP (REPARAT ȘI BLINDAT)
# ==========================================
func _trimite_racheta_http(prompt_text: String):
	var url = "https://api.groq.com/openai/v1/chat/completions"
	
	# AICI ERA OAIA! Trebuie OBLIGATORIU să o declarăm ca PackedStringArray!
	var headers = PackedStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer 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" 
	])
	
	var body_dictionar = {
		"model": "llama-3.1-8b-instant",
		"messages": [{"role": "user", "content": prompt_text}],
		"temperature": 0.3
	}
	
	var json_body = JSON.stringify(body_dictionar)
	var eroare = $HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, json_body)
	
	if eroare != OK:
		# Am pus radarul pe ea! Dacă mai crapă, ne va spune EXACT codul de eroare!
		print("COMANDAMENT: EROARE FATALĂ! Cod eroare Godot: ", eroare)
		racheta_in_aer = false

# ==========================================
# 4. RECEPȚIA ȘI CURĂȚAREA DATELOR
# ==========================================
# ==========================================
# 4. RECEPȚIA ȘI CURĂȚAREA DATELOR (BLINDAT SILENȚIOS)
# ==========================================
func _on_request_completed(result, response_code, headers, body):
	racheta_in_aer = false
	
	if response_code != 200:
		print("EROARE DE COMUNICAȚIE! Cod: ", response_code)
		return
		
	var response_body = body.get_string_from_utf8()
	
	# --- PARSARE INIȚIALĂ SILENȚIOASĂ ---
	var parser_global = JSON.new()
	if parser_global.parse(response_body) != OK:
		print("COMANDAMENT: Pachetul de la Groq e corupt global!")
		return
		
	var json_primit = parser_global.data
	
	if typeof(json_primit) != TYPE_DICTIONARY or not json_primit.has("choices"):
		print("COMANDAMENT: Lipsesc datele din pachet!")
		return
		
	var continut_text = json_primit["choices"][0]["message"]["content"]
	# print("TEXT BRUT AI: ", continut_text) # Oprește print-ul ăsta dacă îți face prea mult spam în consolă!
	
	# --- LUNETISTUL DE DATE (Tăierea chirurgicală) ---
	var start_index = continut_text.find("{")
	var end_index = continut_text.rfind("}")
	
	var date_procesate = null
	
	if start_index != -1 and end_index != -1:
		var json_taiat_chirurgical = continut_text.substr(start_index, end_index - start_index + 1)
		
		# --- PARSARE UTILĂ SILENȚIOASĂ (Aici evitam eroarea EOF!) ---
		var parser_util = JSON.new()
		var eroare_parsare = parser_util.parse(json_taiat_chirurgical)
		
		if eroare_parsare == OK:
			date_procesate = parser_util.data
		else:
			print("INFORMAȚIE: AI-ul a pus un caracter invizibil la linia ", parser_util.get_error_line(), ". Trecem peste!")
			# Chiar dacă dă o mică eroare la final, încercăm să forțăm salvarea dacă a extras ceva!
			date_procesate = parser_util.data
			
	if date_procesate == null:
		print("ALARMĂ! Textul nu a putut fi extras în niciun fel!")
		return
		
	# --- MACAZUL TACTIC ---
	if mod_operare == "ROADMAP":
		print("COMANDAMENT: Roadmap extras cu succes!")
		roadmap_gata.emit(date_procesate)
	elif mod_operare == "QUIZ":
		print("COMANDAMENT: Quiz extras cu succes!")
		date_gata.emit(date_procesate)
	elif mod_operare == "BOSS_FIGHT":
		print("COMANDAMENT: Muniția grea a sosit!")
		boss_gata.emit(date_procesate)
	
func cere_intrebari_boss(subiect: String):
	if racheta_in_aer: return
	racheta_in_aer = true
	mod_operare = "BOSS_FIGHT"
	print("AI: INIȚIEM PROTOCOLUL BOSS PENTRU: ", subiect)
	var prompt_boss = """You are a final Boss testing a 2nd-grade student on '%s'. 
    Generate EXACTLY 5 challenging but age-appropriate multiple-choice questions covering the subject. 
    The output MUST be in ENGLISH. Respond ONLY with valid JSON. 
	Format: {"intrebari": [{"question_text": "Q?", "options": ["A1", "A2", "A3", "A4"], "correct_answer": "A2"}]}""" % subiect
	_trimite_racheta_http(prompt_boss)
