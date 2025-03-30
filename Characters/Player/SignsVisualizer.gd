extends Node2D
class_name SignsVisualizer

@onready var player: EntityPlayer = get_parent()
var sign_hover_scene: PackedScene = preload("res://Characters/Player/Signs/SignHover.tscn")
var sign_hovers: Array[SignHover] = []

func _ready() -> void:
	player.signs_changed.connect(_on_signs_changed)


func _on_signs_changed(signs: Array[GlobalData.SIGNS]) -> void:
	if signs.size() == 0:
		clear_signs()
	else:
		var current_index: int = signs.size() - 1
		spawn_sign(signs[current_index], current_index)

func spawn_sign(new_sign: GlobalData.SIGNS, index: int) -> void:
	var sign_instance = sign_hover_scene.instantiate()
	sign_hovers.append(sign_instance)
	sign_instance.index = index
	sign_instance.current_sign = new_sign
	add_child(sign_instance)


func clear_signs() -> void:
	for sign_item in sign_hovers:
		sign_item.disappear()
	sign_hovers.clear()
