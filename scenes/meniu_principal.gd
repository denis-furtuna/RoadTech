extends Control

# --- DOCUMENTELE DE PE BIROU ---
@onready var pergament = $PergamentPopUp                # Pergamentul tău (trebuie să fie copilul lui MeniuPrincipal)
@onready var input_subiect = $PergamentPopUp/LineEdit   # Câmpul de scris
@onready var selector_varsta = $PergamentPopUp/SelectorVarsta
@onready var btn_start_misiune = $PergamentPopUp/BtnStartMeniu # Butonul DE PE pergament

# --- BUTOANELE DE PE ECRANUL PRINCIPAL ---
# NOTĂ: Schimbă căile de mai jos dacă butoanele tale au alte nume în ierarhie!
@onready var btn_start_meniu = $SpriteSheetMenu/BtnStart          # Butonul de Start din Meniul Principal
@onready var btn_exit =  $SpriteSheetMenu/BtnExit                    # Butonul de Exit din Meniul Principal

func _ready():
	# 1. ORDIN DE CAMUFLAJ: Ascundem pergamentul imediat ce pornește jocul!
	if pergament:
		pergament.hide()
	
	# 2. ÎNCĂRCĂM VÂRSTELE
	selector_varsta.clear()
	selector_varsta.add_item("7-10 years old")
	selector_varsta.add_item("11-14 years old")
	selector_varsta.add_item("15-18 years old")
	selector_varsta.add_item("University level")
	selector_varsta.select(2)
	
	# 3. CONECTĂM FIRELE (Manual, ca să fim siguri că nu dau rateu!)
	
	# Butonul Start din Meniu (cel care arată pergamentul)
	if not btn_start_meniu.pressed.is_connected(_on_btn_start_meniu_pressed):
		btn_start_meniu.pressed.connect(_on_btn_start_meniu_pressed)
		
	# Butonul Start de pe Pergament (cel care lansează nivelul)
	if not btn_start_misiune.pressed.is_connected(_on_misiune_lansata):
		btn_start_misiune.pressed.connect(_on_misiune_lansata)
		
	# Butonul Exit
	if not btn_exit.pressed.is_connected(_on_btn_exit_pressed):
		btn_exit.pressed.connect(_on_btn_exit_pressed)
		
	# Tasta Enter din LineEdit
	if not input_subiect.text_submitted.is_connected(_on_enter_apasat):
		input_subiect.text_submitted.connect(_on_enter_apasat)

# --- LOGICA DE AFIȘARE ---

func _on_btn_start_meniu_pressed():
	print("MENIU: Desfacem pergamentul de recrutare!")
	pergament.show() # ACUM apare pergamentul, abia după click!
	input_subiect.grab_focus() # Punem stiloul în mână

# --- LOGICA DE LANSARE (PUNCH IT!) ---

func _on_enter_apasat(_text_nou):
	_on_misiune_lansata()

func _on_misiune_lansata():
	var subiect = input_subiect.text.strip_edges()
	
	# --- 1. WARNING STRICT ÎN ENGLEZĂ ---
	if subiect == "":
		print("WARNING: Subject name is empty! Mission aborted.")
		# Schimbăm textul de fundal (placeholder) în engleză
		input_subiect.placeholder_text = "SUBJECT REQUIRED TO START!"
		# Opțional: Poți face căsuța roșie sau să o faci să tremure aici
		return

	# --- 2. SALVAREA DATELOR ---
	DateGlobale.subiect_ales_de_jucator = subiect
	DateGlobale.varsta_aleasa_de_jucator = selector_varsta.get_item_text(selector_varsta.selected)
	
	print("SYSTEM: Launching mission for: ", subiect)
	
	# --- 3. VERIFICAREA COORDONATELOR (SCENA) ---
	# ATENȚIE: Dacă fișierul tău se numește 'main.tscn' și e în folderul 'scenes', 
	# calea trebuie să fie exact așa. Dacă e în rădăcină, e doar 'res://base_level.tscn'.
	var calea_catre_scena = "res://scenes/main.tscn"
	
	if FileAccess.file_exists(calea_catre_scena):
		get_tree().change_scene_to_file(calea_catre_scena)
	else:
		print("CRITICAL ERROR: Scene file NOT FOUND at ", calea_catre_scena)
		# Dacă te duce pe o scenă numită 'main', schimbă calea de mai sus!

func _on_btn_exit_pressed():
	print("MENIU: Retragere tactică!")
	get_tree().quit()
