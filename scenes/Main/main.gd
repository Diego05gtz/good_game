extends Node2D

signal coin_changed(current: int, target: int)

@export var coin_target: int = 10
var coin_count: int = 0

var can_restart: bool = false       # habilita R tras win/lose
var end_state: String = ""          # "win" | "lose" | ""

var elapsed: float = 0.0            # tiempo transcurrido
var timer_running: bool = true      # activo mientras se juega

func _ready() -> void:
	add_to_group("game")
	if has_node("HUD"):
		$HUD.set_coins(coin_count, coin_target)
		$HUD.set_time(elapsed)
	coin_changed.connect(_on_coin_changed)

func _process(delta: float) -> void:
	if timer_running:
		elapsed += delta
		if has_node("HUD"):
			$HUD.set_time(elapsed)

func add_coin(n: int = 1) -> void:
	coin_count += n
	emit_signal("coin_changed", coin_count, coin_target)

func _on_coin_changed(curr: int, targ: int) -> void:
	if has_node("HUD"):
		$HUD.set_coins(curr, targ)

# --- derrota (llamado por Player.die) ---
func on_player_died(reason: String = "void") -> void:
	end_state = "lose"
	timer_running = false
	can_restart = true
	if has_node("HUD"):
		$HUD.show_message("YOU DIED — press R", Color(1, 0.2, 0.2), 9999.0)

# --- victoria (solo por bandera) ---
func win_by_flag() -> void:
	end_state = "win"
	timer_running = false
	can_restart = true
	if has_node("HUD"):
		$HUD.show_message("YOU WIN! — press R", Color(0.2, 1, 0.2), 9999.0)

func _input(event: InputEvent) -> void:
	if can_restart and event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
