extends CanvasLayer

@onready var coin_label: Label = $CoinLabel
@onready var time_label: Label = $TimeLabel
@onready var msg_label: Label  = $CenterMsg/MsgLabel

func set_coins(current: int, target: int) -> void:
	if coin_label:
		coin_label.text = "Coins: %d / %d" % [current, target]

func set_time(seconds: float) -> void:
	if time_label:
		time_label.text = _format_time(seconds)

func show_message(text: String, color: Color, duration: float = 1.2) -> void:
	if not msg_label:
		return
	msg_label.text = text
	msg_label.modulate = color
	msg_label.visible = true
	# Si duration es muy grande (lo usamos para "press R"), no lo ocultes automáticamente
	if duration < 9000.0:
		await get_tree().create_timer(duration).timeout
		msg_label.visible = false

func _format_time(t: float) -> String:
	var total: float = maxf(t, 0.0)                 # evita tipos Variant
	var m: int = int(total / 60.0)
	var s: int = int(total) % 60
	var cs: int = int((total - floor(total)) * 100.0)
	return "%02d:%02d.%02d" % [m, s, cs]
