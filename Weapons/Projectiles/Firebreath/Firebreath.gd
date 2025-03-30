class_name PrjFirebreath
extends Projectile

@onready var hold_sfx: AudioStreamPlayer2D = $Audio/Hold

@export var damage_tick_rate: float = 0.1  # Как часто наносить урон (10 раз в секунду)
var targets: Array[EntityMob] = []
var damage_timer: float = 0.0

func _physics_process(delta: float) -> void:
	if !visible:
		hold_sfx.stop()
		return
	if ! hold_sfx.playing:
		hold_sfx.play()
	damage_timer += delta
	if damage_timer >= damage_tick_rate:
		damage_timer = 0.0
		for target in targets:
			if is_instance_valid(target):
				target.take_damage(damage)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is EntityMob:
		targets.append(body)

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body is EntityMob:
		var index = targets.find(body)
		if index != -1:
			targets.remove_at(index)
