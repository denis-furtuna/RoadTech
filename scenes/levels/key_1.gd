extends StaticBody2D # Schimbat din StaticBody2D pentru a avea acces la semnale de intrare
	

func _on_area_2d_body_entered(body: Node2D) -> void:
# Verificăm dacă cel care a intrat este jucătorul
	if body.name == "Player": 
		# Căutăm ușa în scenă pentru a-i spune că avem cheia
		# Folosim 'unique_id' dacă este setat sau calea directă
		var usa = get_tree().root.find_child("Usa1", true, false)
		
		if usa:
			usa.keytaken = true # Setăm variabila în scriptul ușii
			print("Cheia a fost luata, poti deschide Usa1")
		
		queue_free() # Ștergem cheia de pe hartă
