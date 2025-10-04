extends Node2D

func _on_kill_zone_bottom_body_entered(body: Node2D) -> void:
	print("KillZone hit by: ", body.name)  # debug opcional
	if body is CharacterBody2D and body.has_method("die"):
		body.die("void")
	pass # Replace with function body.
