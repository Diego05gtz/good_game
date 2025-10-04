extends CharacterBody2D

# ===== Parámetros =====
@export var speed: float = 40.0
@export var gravity: float = 980.0
@export var start_facing_right: bool = true
@export var tile_is_32px: bool = true          # false si tus tiles son de 16px
@export var stomp_bounce: float = 260.0
@export var base_sprite_faces_right: bool = false  # pon false si tu sprite base mira a la IZQUIERDA

# ===== Cache de nodos =====
@onready var spr: AnimatedSprite2D          = $Sprite
@onready var body_col: CollisionShape2D     = $BodyCollision
@onready var rc_ground: RayCast2D           = $GroundCheck
@onready var rc_wall: RayCast2D             = $WallCheck
@onready var dmg_area: Area2D               = $DamageArea
@onready var dmg_shape: CollisionShape2D    = $DamageArea/DamageShape
@onready var stomp_area: Area2D             = $StompArea

# ===== Estado =====
var dir: int = 1            # 1 = derecha, -1 = izquierda
var dead: bool = false

func _ready() -> void:
	dir = 1 if start_facing_right else -1
	_update_raycast_directions()
	spr.play("walk")

	# Señales
	dmg_area.body_entered.connect(_on_damage_body_entered)
	stomp_area.body_entered.connect(_on_stomp_body_entered)

	# Evita “nacer” encajado
	position.y -= 1.0

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# Movimiento horizontal
	velocity.x = dir * speed

	# Gira por borde o pared
	if not rc_ground.is_colliding() or rc_wall.is_colliding():
		_turn()

	move_and_slide()

	# Volteo visual según cómo mira el sprite base
	if base_sprite_faces_right:
		spr.flip_h = (dir < 0)
	else:
		spr.flip_h = (dir > 0)

func _turn() -> void:
	dir *= -1
	_update_raycast_directions()

func _update_raycast_directions() -> void:
	var ahead: float
	var down: float
	if tile_is_32px:
		ahead = 16.0 * dir   # frente
		down  = 28.0         # abajo
	else:
		ahead = 10.0 * dir
		down  = 20.0
	rc_ground.target_position = Vector2(ahead, down)   # diagonal al frente-abajo
	rc_wall.target_position   = Vector2(ahead, 0.0)    # frente

# --- Daño lateral al jugador ---
func _on_damage_body_entered(body: Node) -> void:
	if dead:
		return
	if body is CharacterBody2D:
		var p := body as CharacterBody2D
		# solo si están a similar altura (no si cae desde arriba)
		var vertical_gap: float = p.global_position.y - global_position.y
		if absf(vertical_gap) < 24.0 and p.has_method("take_side_hit_from_enemy"):
			p.take_side_hit_from_enemy(self)

# --- Stomp (muerte si le caen arriba) ---
func _on_stomp_body_entered(body: Node) -> void:
	if dead:
		return
	if body is CharacterBody2D:
		var p := body as CharacterBody2D
		var coming_down := p.velocity.y > 0.0
		var above := p.global_position.y < global_position.y - 2.0
		if coming_down and above:
			_die_by_stomp(p)

func _die_by_stomp(player: CharacterBody2D) -> void:
	dead = true

	# Desactiva daño y colisiones
	dmg_area.monitoring = false
	if is_instance_valid(dmg_shape):
		dmg_shape.disabled = true
	if is_instance_valid(body_col):
		body_col.disabled = true

# Feedback visual
	var frames := spr.sprite_frames
	if frames and frames.has_animation("dead"):
		spr.play("dead")
	else:
		spr.modulate.a = 0.65

	# Rebote del jugador
	if player.has_method("bounce_from_stomp"):
		player.bounce_from_stomp(stomp_bounce)

	# Detén al enemigo y bórralo
	velocity = Vector2.ZERO
	set_physics_process(false)   # <- añade esto
	await get_tree().create_timer(0.35).timeout
	queue_free()
