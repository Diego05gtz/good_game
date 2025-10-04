extends Area2D

@onready var spr: AnimatedSprite2D = $Sprite
@onready var sfx: AudioStreamPlayer2D = $SFX
@onready var pfx: GPUParticles2D = $PFX

var picked: bool = false

func _ready() -> void:
	spr.play("spin")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if picked:
		return
	if body is CharacterBody2D and body.name.begins_with("Player"): # sencillo y seguro
		picked = true
		# suma al contador
		var game = get_tree().get_first_node_in_group("game")
		if game and game.has_method("add_coin"):
			game.add_coin(1)
		# feedback
		if sfx.stream:
			sfx.play()
		if pfx:
			pfx.emitting = true
		# oculta y desactiva
		$Hitbox.disabled = true
		monitoring = false
		if spr: spr.visible = false
		# da tiempo al SFX/partículas y se elimina
		await get_tree().create_timer(0.4).timeout
		queue_free()
