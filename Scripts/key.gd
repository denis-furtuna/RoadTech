extends StaticBody2D

signal door_opened

var keytaken = false
var in_door_zone = false


func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if keytaken == false :
		keytaken = true
		$Sprite.queue_free()
func _process(delta: float) -> void:
	if keytaken == true :
		if in_door_zone == true:
			if Input.is_action_just_pressed("accept"):
				emit_signal("door_opened")
