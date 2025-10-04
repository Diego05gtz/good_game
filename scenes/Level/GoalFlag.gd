extends Area2D

@onready var spr: AnimatedSprite2D = $Sprite

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if spr and spr.sprite_frames and spr.sprite_frames.has_animation("wave"):
		spr.play("wave")

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		var game = get_tree().get_first_node_in_group("game")
		if game and game.has_method("win_by_flag"):
			game.win_by_flag()

@onready var time_label: Label = $TimeLabel

func set_time(seconds: float) -> void:
	if time_label:
		time_label.text = _format_time(seconds)

func _format_time(t: float) -> String:
	var total: float = maxf(t, 0.0)          # <- usa maxf (o float(max(...)))
	var m: int = int(total / 60.0)           # minutos
	var s: int = int(total) % 60             # segundos
	var cs: int = int((total - floor(total)) * 100.0)  # centésimas
	return "%02d:%02d.%02d" % [m, s, cs]
