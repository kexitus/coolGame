extends Transition

var is_passive: bool = false

var connected_weapon: WeaponSpecial

func _ready() -> void:
	super._ready()
	source_state.character.using_special_weapon.connect(on_using_special_weapon)

func can_transition(_character: Entity) -> bool:
	if is_passive:
		is_passive = false
		return true
	return false

func _input(event: InputEvent) -> void:
	if event.is_action_released("controls_base_attack"):
		is_passive = true

func on_using_special_weapon(weapon: WeaponSpecial) -> void:
	connected_weapon = weapon
	connected_weapon.attack_ended.connect(on_attack_ended)

func on_attack_ended() -> void:
	is_passive = true
	connected_weapon.attack_ended.disconnect(on_attack_ended)
