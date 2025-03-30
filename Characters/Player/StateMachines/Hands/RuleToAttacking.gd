extends Transition

var is_attacking: bool = false

var connected_weapon: WeaponSpecial

func _ready() -> void:
	super._ready()
	source_state.character.using_special_weapon.connect(on_using_special_weapon)

func can_transition(_character: Entity) -> bool:
	if is_attacking:
		is_attacking = false
		return true
	return false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("controls_base_attack"):
		is_attacking = true
		
func on_using_special_weapon(weapon: WeaponSpecial) -> void:
	connected_weapon = weapon
	connected_weapon.attack_started.connect(on_attack_started)

func on_attack_started() -> void:
	is_attacking = true
	connected_weapon.attack_started.disconnect(on_attack_started)