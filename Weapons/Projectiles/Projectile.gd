class_name Projectile
extends CharacterBody2D

@export var sprite: Sprite2D
@export var hitbox: Area2D
@export var animation_player: AnimationPlayer

@export var speed: float = 100.0
@export var damage: float = 1.0

var sender: Entity
# var move_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	velocity = velocity.lerp(Vector2.from_angle(rotation) * speed, 1)
	move_and_slide()
