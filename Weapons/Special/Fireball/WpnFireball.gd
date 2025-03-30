extends WeaponSpecial


func attack(from: Vector2, to: Vector2) -> void:
	attack_started.emit()
	spawn_projectile(from, (to - from).angle())
	attack_ended.emit()

func spawn_projectile(start_position: Vector2, direction_angle: float) -> void:
	var projectile_instance: Projectile = projectile.instantiate()

	projectile_instance.global_position = start_position
	projectile_instance.rotation = direction_angle
	
	projectile_instance.damage = damage
	projectile_instance.entity_blacklist.append(player)

	get_tree().current_scene.add_child(projectile_instance)