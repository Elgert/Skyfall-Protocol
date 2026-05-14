class_name Projectile
extends Area2D
## A bullet/missile/etc. Moves in a straight line, lives for a fixed time,
## dies when it runs out of pierces or its lifetime expires.

@onready var hurtbox: HurtboxComponent = $HurtboxComponent

var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 1.2
var pierces_remaining: int = 1


func _ready() -> void:
	hurtbox.hit_landed.connect(_on_hit_landed)


func setup(direction: Vector2, speed: float, damage: float, life: float, pierces: int) -> void:
	velocity = direction.normalized() * speed
	rotation = velocity.angle()
	lifetime = life
	pierces_remaining = max(1, pierces)
	# Defer in case setup() is called before _ready ran.
	if is_node_ready():
		hurtbox.damage = damage
	else:
		ready.connect(func(): hurtbox.damage = damage, CONNECT_ONE_SHOT)


func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_hit_landed(_hitbox: HitboxComponent, _damage: float) -> void:
	pierces_remaining -= 1
	if pierces_remaining <= 0:
		queue_free()
