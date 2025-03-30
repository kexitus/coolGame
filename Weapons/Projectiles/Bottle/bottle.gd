extends Projectile



func _ready() -> void:
	animation_player.play("spin")


func _process(delta: float) -> void:
	pass


func _physics_process(_delta) -> void:
	velocity = velocity.lerp(Vector2.from_angle(rotation) * speed, 1)
	move_and_slide()


func _on_hitbox_body_entered(body) -> void:
	if body.visibility_layer == 0:
		queue_free()
	if body is EntityPlayer:
		body.take_damage(damage)


func _on_removal_timer_timeout() -> void:
	queue_free()
