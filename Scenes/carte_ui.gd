extends Control

# --- INVENTARUL VIZUAL ---
@onready var left_page = $BookPanel/LeftPageText
@onready var right_page = $BookPanel/RightPageText
@onready var btn_next = $BookPanel/BtnNext
@onready var btn_prev = $BookPanel/BtnPrev

# MUNIȚIA ȘI LOGISTICA (Astea îți lipseau ție!)
var pagini_text = []
var pagina_curenta = 0

# --- SEMNAL DE COMUNICARE ---
signal carte_citita_complet

func _ready():
	# Conectăm butoanele la armament
	btn_next.pressed.connect(_pe_pagina_urmatoare)
	btn_prev.pressed.connect(_pe_pagina_anterioara)
	
	# ANULĂM CAMUFLAJUL PENTRU TEST (Lăsăm comentat hide-ul ca să vezi direct)
	# hide() 
	
	# TEST DE ARTILERIE:
	incarca_materia("Manual de Supraviețuire", "Aceasta este prima ta lecție pe front. Trebuie să citești cu atenție fiecare cuvânt. Dacă nu ești atent, inamicul te va prinde și vei pierde puncte prețioase. Soldații de elită știu să folosească interfața. Apasă pe butoanele de navigare ca să mergi mai departe și să dovedești că ești pregătit pentru hackathon. ceasta este prima ta lecție pe front. Trebuie să citești cu atenție fiecare cuvânt. Dacă nu ești atent, inamicul te va prinde și vei pierde puncte prețioase. Soldații de elită știu să folosească interfața. Apasă pe butoanele de navigare ca să mergi mai departe și să dovedești că ești pregătit pentru hackathon.")

# --- ORDINUL DE DESCHIDERE A CĂRȚII (VERSIUNEA BLINDATĂ) ---
func incarca_materia(titlu: String, descriere_ampla: String):
	show() 
	pagina_curenta = 0
	pagini_text.clear()
	
	# Pagina 1 rămâne rege - Doar Titlul!
	pagini_text.append("[center][b][font_size=32]" + titlu + "[/font_size][/b][/center]\n\nRead carefully, soldier!")
	
	# TRATAMENT DE ȘOC: Eliminăm Enter-urile inamice
	var text_curat = descriere_ampla.replace("\n", " ")
	
	# TACTICA SUPREMĂ: Tăiem cu laserul doar acolo unde este PUNCT și SPAȚIU!
	var propozitii = text_curat.split(". ")
	var text_temporar = ""
	
	# Setează o limită generoasă, ca să încapă 2-3 propoziții pe pagină
	var limita_caractere_per_pagina = 330
	
	for prop in propozitii:
		if prop.strip_edges() == "":
			continue # Ignorăm gloanțele oarbe (spațiile goale)
			
		# Punem punctul înapoi, pentru că funcția 'split' l-a distrus când a tăiat!
		var prop_completa = prop + ". "
		
		# Dacă adăugarea acestei propoziții face pagina să explodeze...
		if text_temporar.length() + prop_completa.length() > limita_caractere_per_pagina and text_temporar != "":
			# Salvăm pagina curentă EXACT la finalul propoziției anterioare!
			pagini_text.append(text_temporar) 
			# Începem o pagină nouă curată cu propoziția care nu a încăput
			text_temporar = prop_completa     
		else:
			# Dacă mai e loc, îndesăm propoziția pe pagina curentă
			text_temporar += prop_completa    
	
	# Curățăm ultimele resturi de muniție
	if text_temporar.strip_edges() != "":
		pagini_text.append(text_temporar)

	actualizeaza_vizualul()

# --- MECANICA DE RĂSFOIRE ---
func actualizeaza_vizualul():
	if pagina_curenta < pagini_text.size():
		left_page.text = pagini_text[pagina_curenta]
	else:
		left_page.text = ""

	if pagina_curenta + 1 < pagini_text.size():
		right_page.text = pagini_text[pagina_curenta + 1]
	else:
		right_page.text = ""

	btn_prev.visible = (pagina_curenta > 0)
	
	if pagina_curenta + 2 >= pagini_text.size():
		btn_next.hide()
		carte_citita_complet.emit() # Strigăm prin stație că s-a terminat cartea!
	else:
		btn_next.show()

func _pe_pagina_urmatoare():
	pagina_curenta += 2 
	actualizeaza_vizualul()

func _pe_pagina_anterioara():
	pagina_curenta -= 2
	actualizeaza_vizualul()
