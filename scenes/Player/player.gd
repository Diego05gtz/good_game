extends CharacterBody2D

# ===== Constantes =====
const SPEED: float = 140.0
const GRAVITY: float = 980.0
const JUMP_VELOCITY: float = -320.0

# ===== Nodos =====
@onready var spr: AnimatedSprite2D = $Sprite
@onready var feet: RayCast2D = $Feet
@onready var col: CollisionShape2D = $Collision
@onready var cam: Camera2D = $Cam

# ===== Estado =====
var input_dir: float = 0.0
var is_dying: bool = false

@export var death_anim: String = "dead"
@export var death_duration: float = 1   # súbelo a ~1.0–1.2 si tu anim es más larga

func _ready() -> void:
	if cam:
		cam.make_current()

func _physics_process(delta: float) -> void:
	# Si está muriendo: sin input, solo gravedad y movimiento
	if is_dying:
		return
		velocity.y += GRAVITY * delta
		move_and_slide()
		return

	# Gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Entrada horizontal
	input_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.x = input_dir * SPEED

	# Salto (solo en piso)
	if (is_on_floor() or (feet and feet.is_colliding())) and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	# Mover con físicas
	move_and_slide()

	# Voltear sprite
	if input_dir != 0.0:
		spr.flip_h = input_dir < 0.0

	# Animación por estado
	_update_animation()

func _update_animation() -> void:
	if is_dying:
		return
	if not is_on_floor():
		if spr.animation != "jump":
			spr.play("jump")
	elif abs(velocity.x) > 1.0:
		if spr.animation != "run":
			spr.play("run")
	else:
		if spr.animation != "idle":
			spr.play("idle")

# ===== Interacciones =====
func take_side_hit_from_enemy(enemy: Node) -> void:
	die("enemy")

func die(reason: String = "void") -> void:
	if is_dying:
		return
	is_dying = true

	# Desactiva colisiones para no recibir más golpes
	set_collision_layer(0)
	set_collision_mask(0)

	# Congela en lugar (que no se deslice)
	velocity = Vector2.ZERO

	# Reproduce la animación si existe
	if spr and spr.sprite_frames and spr.sprite_frames.has_animation(death_anim):
		spr.play(death_anim)
	else:
		spr.modulate.a = 0.7

	# Espera fija y luego notifica al Game
	await get_tree().create_timer(death_duration).timeout
	var game = get_tree().get_first_node_in_group("game")
	if game and game.has_method("on_player_died"):
		game.on_player_died(reason)
	else:
		get_tree().reload_current_scene()


func bounce_from_stomp(strength: float = 260.0) -> void:
	velocity.y = -abs(strength)
