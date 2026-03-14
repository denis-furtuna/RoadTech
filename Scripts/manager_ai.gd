extends Node

# =========================================================
# 1. ANTENA RADIO: Asta declară semnalul suprem!
# Se pune SUS DE TOT, imediat sub "extends Node"!
# =========================================================
signal date_gata(json_date)


# Să presupunem că ai o funcție prin care ceri date de la Groq
func cere_date_de_la_api(subiect: String):
	print("AI: Am primit ordinul! Contactez satelitul Groq pentru subiectul: ", subiect)
	
	# AICI ESTE CODUL TĂU EXISTENT DE REQUEST HTTP (URL, Headers, Body etc.)
	# ...
	# http_request.request(url, headers, HTTPClient.METHOD_POST, body)


# =========================================================
# 2. DECLANȘAREA RAKETEI DE SEMNALIZARE!
# Asta e funcția ta care se apelează când Groq îți răspunde.
# =========================================================
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		print("AI: Am primit pachetul de la Groq! Decodificăm...")
		
		# Aici tu deja îți transformi răspunsul din body în text și apoi în JSON
		var json_primit = JSON.parse_string(body.get_string_from_utf8())
		
		# Extragi fix bucata de JSON pe care ne-a generat-o AI-ul 
		# (Depinde de structura ta de la Groq, de obicei e în "choices"[0]["message"]["content"])
		var continut_text = json_primit["choices"][0]["message"]["content"]
		
		# Transformăm textul AI-ului într-un Dicționar Godot ca să-l putem citi ușor
		var date_procesate = JSON.parse_string(continut_text)
		
		# ---------------------------------------------------------
		# ORDINUL SUPREM: AICI EMITEM SEMNALUL CĂTRE MANAGER!
		# Aruncăm datele procesate în aer, iar Managerul le va prinde!
		# ---------------------------------------------------------
		date_gata.emit(date_procesate)
		print("AI: Rachetă de semnalizare lansată! Datele au fost trimise către UI!")
		
	else:
		print("AI: EROARE DE COMUNICAȚIE! Cod: ", response_code)
