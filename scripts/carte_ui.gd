extends Control

# --- INVENTARUL VIZUAL ---
@onready var left_page = $BookPanel/LeftPageText
@onready var right_page = $BookPanel/RightPageText
@onready var btn_next =$BtnNext
@onready var btn_prev =$BtnPrev
@onready var animatie_carte = $BookPanel/AnimatedSprite2D

# MUNIȚIA ȘI LOGISTICA (Astea îți lipseau ție!)
var pagini_text = []
var pagina_curenta = 0


# --- SEMNAL DE COMUNICARE ---
signal carte_citita_complet


func incarca_materia(titlu: String, text_teorie_capitol: String):
	show() 
	pagina_curenta = 0
	pagini_text.clear()
	
	# --- PAGINA 1: COPERTA INTERIOARĂ ---
	# Adăugăm câteva linii goale (\n) pentru a-l coborî spre mijlocul paginii
	var coperta = "\n\n\n\n[center][b][font_size=50]" + titlu.to_upper() + "[/font_size][/b][/center]"
	pagini_text.append(coperta)
	
	# --- PAGINAREA TEORIEI (ÎNCEPE DE LA PAGINA 2) ---
	var text_curat = text_teorie_capitol.replace("\n", "  ") # Păstrăm un pic de spațiu între paragrafe
	var cuvinte = text_curat.split(" ") # TĂIEM DUPĂ FIECARE CUVÂNT!
	var text_temporar = ""
	var limita_caractere = 300 # PUNE 50 AICI CA SĂ TESTEZI ANIMAȚIA!
	
	for cuvant in cuvinte:
		if cuvant.strip_edges() == "": continue
		
		# Dacă adăugând acest cuvânt depășim limita, salvăm pagina și începem una nouă!
		if text_temporar.length() + cuvant.length() + 1 > limita_caractere and text_temporar != "":
			pagini_text.append(text_temporar.strip_edges())
			text_temporar = cuvant + " "
		else:
			text_temporar += cuvant + " "
	
	# Băgăm și ultimul rest de text rămas
	if text_temporar.strip_edges() != "":
		pagini_text.append(text_temporar.strip_edges())

	print("LOGISTICĂ: Am generat în total ", pagini_text.size(), " pagini de muniție!")
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

func _ready():
	
	# FĂRĂ ASTEA, BUTOANELE SUNT DOAR DECORAȚIUNI:
	btn_next.pressed.connect(_pe_pagina_urmatoare)
	btn_prev.pressed.connect(_pe_pagina_anterioara)
	
	btn_next.modulate = Color.RED
	btn_prev.modulate = Color.RED
	
	if animatie_carte != null:
		animatie_carte.hide() 
		if not animatie_carte.animation_finished.is_connected(_pe_animatie_terminata):
			animatie_carte.animation_finished.connect(_pe_animatie_terminata)
	btn_next.modulate = Color.RED
	btn_prev.modulate = Color.RED
	# ASCUNDEM FANTOMA LA ÎNCEPUT!
	if animatie_carte != null:
		animatie_carte.hide() 
		# Nu uita să conectezi semnalul (dacă nu l-ai conectat deja din editor)
		if not animatie_carte.animation_finished.is_connected(_pe_animatie_terminata):
			animatie_carte.animation_finished.connect(_pe_animatie_terminata)

# --- CÂND APĂSĂM NEXT ---
func _pe_pagina_urmatoare():
	# 1. Schimbăm imediat textul în fundal
	pagina_curenta += 2 
	actualizeaza_vizualul()
	
	# 2. Aruncăm grenada cu fum (pornim animația peste text)
	if animatie_carte != null:
		animatie_carte.show()
		animatie_carte.play("forward") # Verifică să se numească EXACT așa în editor!

# --- CÂND APĂSĂM PREV ---
func _pe_pagina_anterioara():
	pagina_curenta -= 2
	actualizeaza_vizualul()
	
	if animatie_carte != null:
		animatie_carte.show()
		 #Jucăm animația (dacă n-ai "backward", o dăm cu spatele pe "forward")
		if animatie_carte.sprite_frames.has_animation("backward"):
			animatie_carte.play("backward")
		else:
			animatie_carte.play("forward", -1.0, true)

# --- ORDINUL DE RETRAGERE ---
func _pe_animatie_terminata():
	if animatie_carte != null:
		# Ascundem animația
		animatie_carte.hide()
		# TACTICĂ DE ELITĂ: Resetăm cadrul la 0, altfel data viitoare când îi dai show() 
		# s-ar putea să o vezi blocată pe ultimul cadru o fracțiune de secundă!
		animatie_carte.frame = 0





func ascunde_cartea():
	hide()
	print("UI: Ne-am retras în tranșee!")

# --- BUTONUL DE EVACUARE (ESC) ---
func _input(event):
	# Verificăm două lucruri:
	# 1. Cartea este deschisă pe ecran? (visible)
	# 2. A apăsat soldatul tasta ESC? (ui_cancel)
	if visible and event.is_action_pressed("ui_cancel"):
		print("UI: ORDIN DE EVACUARE PRIMIT! Tasta ESC a fost lovită!")
		ascunde_cartea()
		
		# TACTICĂ AVANSATĂ: Oprim semnalul aici ca să nu se ducă mai departe
		# (să nu deschidă din greșeală un alt meniu de pauză în fundal)
		get_viewport().set_input_as_handled()
