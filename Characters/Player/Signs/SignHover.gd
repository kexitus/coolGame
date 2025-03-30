extends Node2D
class_name SignHover

@export var index: int
@export var current_sign: GlobalData.SIGNS
@export var sign_sprite: Sprite2D	
@export var animation_player: AnimationPlayer

@onready var animation_player2: AnimationPlayer = $AnimationPlayer2

func _ready() -> void:
	sign_sprite.frame = current_sign

	match index:
		0:
			animation_player.play("spawn_left")
		1:
			animation_player.play("spawn_middle")
		2:
			animation_player.play("spawn_right")

	animation_player.animation_finished.connect(_on_animation_finished)


func disappear() -> void:
	animation_player2.stop()
	match index:
		0:
			animation_player.play("disappear_left")
		1:
			animation_player.play("disappear_middle")
		2:
			animation_player.play("disappear_right")


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn_left" || anim_name == "spawn_middle" || anim_name == "spawn_right":
		animation_player2.play("loop")
		match index:
			0:
				animation_player.play("loop_left")
			1:
				animation_player.play("loop_middle")
			2:
				animation_player.play("loop_right")
	elif anim_name == "disappear_left" || anim_name == "disappear_middle" || anim_name == "disappear_right":
		queue_free()
