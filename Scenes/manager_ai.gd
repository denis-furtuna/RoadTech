extends Node

# --- NOUA BAZĂ DE OPERAȚIUNI: GROQ ---
const API_KEY = "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" 
const URL = "https://api.groq.com/openai/v1/chat/completions"

@onready var http_request = $HTTPRequest

func _ready():
	http_request.request_completed.connect(_la_primirea_pachetului)
	
	# Scoate comentariul de mai jos pentru a lansa racheta!
	cere_materie_de_la_ai("Istoria Imperiului Roman")

func cere_materie_de_la_ai(subiect: String):
	print("TACTICĂ NOUĂ! Atacăm cu viteză maximă subiectul: ", subiect)
	
	var prompt_ul_meu = "You are an expert educator and game designer. The user wants a learning roadmap for the subject: " + subiect + ". Generate a learning path divided into 6 progressive steps (rooms). Return a JSON object with a single key 'rooms' containing a list of 6 objects. For each room, provide: 'title' (catchy), 'detailed_description' (a comprehensive, educational text of 5-6 sentences teaching this step of the roadmap), and a list named 'quiz' with EXACTLY 2 questions to test the knowledge from the description. Each question must have 'question_text', a list of 4 'options', and 'correct_answer' (the exact text of the correct option). ALL TEXT MUST BE IN ENGLISH. Return ONLY valid JSON, no extra text."
	# Formatul OpenAI/Groq este puțin diferit, dar noi ne adaptăm instantaneu!
	var body = JSON.stringify({
		"model": "llama-3.1-8b-instant", # Un model blindat, extrem de rapid!
		"messages": [
			{
				"role": "user",
				"content": prompt_ul_meu
			}
		],
		"response_format": {"type": "json_object"} # Îl obligăm să vorbească limba JSON
	})
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + API_KEY # Aici ne prezentăm legitimația
	]
	
	var eroare = http_request.request(URL, headers, HTTPClient.METHOD_POST, body)
	if eroare != OK:
		print("DEZASTRU TACTIC! Nu pot lansa cererea spre serverele Groq!")

func _la_primirea_pachetului(result, response_code, headers, body):
	if response_code == 200:
		print("AM SPART FRONTUL! Datele au aterizat cu succes!")
		var raspuns_text = body.get_string_from_utf8()
		
		var json_parser = JSON.new()
		var eroare_parsare = json_parser.parse(raspuns_text)
		
		if eroare_parsare == OK:
			var date_brute = json_parser.data
			# Extragem prada de război din noua structură
			var text_generat_de_ai = date_brute["choices"][0]["message"]["content"]
			
			var date_pentru_joc = JSON.parse_string(text_generat_de_ai)
			
			if date_pentru_joc != null:
				print("VICTORIE! Baza de date a fost decodată:")
				print(date_pentru_joc) 
			else:
				print("Inamicul a trișat! Textul nu este un JSON valid.")
		else:
			print("Eroare la citirea plicului primit.")
			
	else:
		print("AM FOST RESPINȘI IAR! Cod inamic: ", response_code)
		print(body.get_string_from_utf8())
