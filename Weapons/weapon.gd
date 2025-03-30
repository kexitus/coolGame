class_name Weapon
extends Node

@export var display_name: String = self.name

@export var icon: Texture2D
@export var animation_player: AnimationPlayer
@export var projectile: PackedScene
@export var player: EntityPlayer

@export var damage: float = 1.0

signal attack_started()
signal attack_ended()

func attack(from: Vector2, to: Vector2) -> void:
	pass
