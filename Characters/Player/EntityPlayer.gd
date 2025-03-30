class_name EntityPlayer
extends Entity

@export var body_state_machine: FiniteStateMachine
@export var invulnerability_state_machine: FiniteStateMachine
@export var hands_state_machine: FiniteStateMachine

@export var invulnerability_timer: Timer

@export var cast_marker: Marker2D

@onready var signs_visualizer: SignsVisualizer = $SignsVisualizer

@export var max_mana: float = 10.0
var mana: float = max_mana
var money: int = 0
var signs: Array[GlobalData.SIGNS] = []
var basic_weapons: Array[WeaponBasic] = []
var items: Array[Item] = []

@export_group("Weapons")
@export var basic_weapon: WeaponBasic # testing
@export var special_weapons: Array[WeaponSpecial] = []

@export_group("")

signal signs_changed(new_signs: Array[GlobalData.SIGNS])
signal basic_weapon_changed(new_weapon: WeaponBasic)
signal using_special_weapon(special_weapon: WeaponSpecial)


func _ready() -> void:
	if basic_weapon:
		basic_weapon_changed.emit(basic_weapon) # testing


func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if is_active:
		handle_movement(delta)
		handle_look()
		handle_basic_attack()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("controls_sign_shaka"):
		handle_sign(GlobalData.SIGNS.SHAKA)
	elif event.is_action_pressed("controls_sign_goat"):
		handle_sign(GlobalData.SIGNS.GOAT)
	elif event.is_action_pressed("controls_sign_you"):
		handle_sign(GlobalData.SIGNS.YOU)


#region Movement and Look
# :Entity.
func handle_movement(_delta: float) -> void:
	var direction = Input.get_vector("controls_left", "controls_right", "controls_up", "controls_down")
	
	var mult = 1
	if Input.is_physical_key_pressed(KEY_SHIFT):
		mult = 4
	
	if Input.is_action_just_pressed("controls_dash"):
		dodge(direction)
	
	if direction.length_squared() > 0:
		velocity = velocity.lerp(direction.normalized() * movement_speed * mult, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)
	
	move_and_slide()


func dodge(direction: Vector2) -> void:
	velocity = velocity.lerp(direction.normalized() * movement_speed * 100, acceleration)


func handle_look() -> void:
	var mouse := get_local_mouse_position()
	facing_direction = mouse.normalized()
	var angle := snappedf(-mouse.angle(), PI/4) / (PI/4)
	angle = wrapi(int(angle), 0, 8)
	var frame := wrapi(int(angle - 6.0), 0, 8)
	sprite.frame = frame

	#FIXME Временный зум
	if Input.is_action_just_released("controls_mouse_wheel_up"):
		$Camera2D.zoom += Vector2(0.1, 0.1)
	if Input.is_action_just_released("controls_mouse_wheel_down"):
		$Camera2D.zoom -= Vector2(0.1, 0.1)

#endregion


#region Battle system
# Handles basic attack input
func handle_basic_attack() -> void:
	if Input.is_action_pressed("controls_base_attack"):
		basic_weapon.attack(cast_marker.global_position, get_global_mouse_position())
	elif Input.is_action_just_released("controls_base_attack"):
		basic_weapon.stop_attack()


# Handles sign input
func handle_sign(new_sign: GlobalData.SIGNS) -> void:
	signs.append(new_sign)
	signs_changed.emit(signs)
	if signs.size() == 3:
		handle_special_attack(signs)
		signs.clear()
		signs_changed.emit(signs)


# Checks for owned special weapon and casts it
func handle_special_attack(combo: Array[GlobalData.SIGNS]) -> void:
	var weapon: WeaponSpecial = find_weapon(combo)
	if weapon:
		using_special_weapon.emit(weapon)
		weapon.attack(cast_marker.global_position, get_global_mouse_position())


# Finds special weapon by combo sequence
func find_weapon(combo: Array[GlobalData.SIGNS]) -> WeaponSpecial:
	var found_weapon: WeaponSpecial = null
	var combo_size: int = combo.size()
	var counter: int
	for special_weapon in special_weapons:
		if ! special_weapon:
			continue
		counter = 0
		for i in range(combo_size):
			if special_weapon.combo_sequence[i] != combo[i]:
				break
			counter += 1
		if counter == combo_size:
			found_weapon = special_weapon
			break
	return found_weapon

#endregion


#region Damage system
# :Entity.
func take_damage(amount: float) -> void:
	if is_invulnerable:
		print("Player skiped damage")
		return
		
	print("Player took damage: " + str(amount))
	
	hp -= amount
	
	damage_taken.emit(amount)
	
	if hp <= 0:
		die()
		return
	
	is_invulnerable = true
	invulnerability_timer.start(invulnerability_duration)


# :Entity.
func die() -> void:
	is_active = false
	died.emit()


func _on_invulnerabity_timer_timeout() -> void:
	is_invulnerable = false

#endregion


# :Entity.
func update_animation(_delta: float) -> void:
	pass


# :Entity.
func get_interaction() -> void:
	pass
