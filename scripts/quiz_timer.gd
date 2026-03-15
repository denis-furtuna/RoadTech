extends ProgressBar

signal timp_expirat # Semnalul pe care îl vom trimite către boss_arena

@onready var timer = $Timer

func porneste(secunde: float):
	max_value = secunde
	value = secunde
	timer.wait_time = secunde
	timer.start()
	show() # Afișăm bara

func opreste():
	timer.stop()
	hide() # Ascundem bara când s-a răspuns

#Actualizăm vizual bara în fiecare cadru
func _process(_delta: float) -> void:
	if not timer.is_stopped():
		value = timer.time_left

#Conectează semnalul "timeout" al nodului Timer la această funcție (din panoul Node -> Signals)
func _on_timer_timeout() -> void:
	emit_signal("timp_expirat")
	hide()
