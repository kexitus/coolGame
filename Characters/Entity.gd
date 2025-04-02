class_name Entity
extends CharacterBody2D

@export var sprite: Sprite2D
@export var hitbox: CollisionShape2D
@export var state_machine: FiniteStateMachine
@export var animation_player: AnimationPlayer

@export var display_name: String = self.name

@export_group("Movement")
@export var movement_speed: float = 100.0
@export var friction: float = 0.3
@export var acceleration: float = 0.5

@export_group("Health")
@export var max_hp: float = 10.0
@export var invulnerability_duration: float = 1 # in seconds

@export_group("")

@onready var hp: float = max_hp
var facing_direction: Vector2 = Vector2.ZERO
var is_active: bool = true
var is_invulnerable: bool = false

signal direction_changed(new_direction: Vector2)
signal damage_taken(amount: float)
signal died()


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func handle_movement(delta: float) -> void:
	pass


func handle_look() -> void:
	pass


func take_damage(amount: float) -> void:
	pass


func die() -> void:
	pass
