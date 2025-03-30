extends Node2D

@export var projectile: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Shoots projectile
func shoot(angle: float) -> void:
	var animationPlayer = get_node_or_null("AnimationPlayer")
	if animationPlayer:
		$AnimationPlayer.play("shoot")
	var current_proj:Node2D = projectile.instantiate()
	current_proj.position = self.position
	current_proj.visible = true
	current_proj.rotation = angle
	current_proj.global_position = self.global_position
	get_tree().current_scene.add_child(current_proj)
	if animationPlayer:
		$AnimationPlayer.play("shoot_recovery")
