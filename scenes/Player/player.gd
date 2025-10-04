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
@export var death_duration: float = 1.0   # ajusta a la duración real de tu anim

func _ready() -> void:
	if cam:
		cam.make_current()

func _physics_process(delta: float) -> void:
	# Si está muriendo: no mover ni aplicar gravedad (que se vea la anim)
	if is_dying:
		return

	# Gravedad (cuando no está en piso)
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Entrada horizontal
	input_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.x = input_dir * SPEED

	# Salto (solo en piso o con raycast "feet")
	if (is_on_floor() or (feet and feet.is_colliding())) and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		# asegura que veas la anim de despegue al instante
		if spr.sprite_frames and spr.sprite_frames.has_animation("jump"):
			spr.play("jump")

	# Mover con físicas
	move_and_slide()

	# Voltear sprite según dirección
	if input_dir != 0.0:
		spr.flip_h = input_dir < 0.0

	# Animación por estado (aire/piso)
	_update_animation()

func _update_animation() -> void:
	if is_dying:
		return

	if not is_on_floor():
		# Aire: decide por subida vs caída (usa "fall" si la tienes)
		if velocity.y < -10.0:
			if spr.animation != "jump":
				spr.play("jump")          # Loop OFF recomendado
		else:
			if spr.sprite_frames and spr.sprite_frames.has_animation("fall"):
				if spr.animation != "fall":
					spr.play("fall")     # Loop OFF recomendado
			else:
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

	# Desactiva colisiones y congela en sitio
	set_collision_layer(0)
	set_collision_mask(0)
	velocity = Vector2.ZERO

	# Animación de muerte (no esperamos signal para evitar cuelgues)
	if spr and spr.sprite_frames and spr.sprite_frames.has_animation(death_anim):
		spr.play(death_anim)
	else:
		spr.modulate.a = 0.7

	await get_tree().create_timer(death_duration).timeout

	var game = get_tree().get_first_node_in_group("game")
	if game and game.has_method("on_player_died"):
		game.on_player_died(reason)
	else:
		get_tree().reload_current_scene()

func bounce_from_stomp(strength: float = 260.0) -> void:
	velocity.y = -abs(strength)
