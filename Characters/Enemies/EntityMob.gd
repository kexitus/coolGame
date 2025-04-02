class_name EntityMob
extends Entity


@export var navigation_agent: NavigationAgent2D
@export var aggro_area: Area2D

@export var drop: int = 0
@export var is_aggressive: bool = true

@export_group("Attack")
@export var attack_speed: float = 1.0 # in attacks per second
@export var attack_damage: float = 1.0
@export_group("")

var player_chase: bool = false
var alive: bool = true
var target_node: Node2D = null

signal aggroed(target: Entity)


func _ready() -> void:
	$Label.set_text(str(hp))
	navigation_agent.path_desired_distance = 4
	navigation_agent.target_desired_distance = 4


func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	handle_ai(delta)
	move_and_slide()


func handle_ai(delta: float) -> void:
	if alive:
		handle_movement(delta)
		handle_look()

func attack() -> void:
	pass


func handle_look() -> void:
	var target_direction := to_local(navigation_agent.get_next_path_position())
	facing_direction = target_direction.normalized()
	var angle := snappedf(-target_direction.angle(), PI/4) / (PI/4)
	angle = wrapi(int(angle), 0, 8)
	var frame := wrapi(int(angle - 6.0), 0, 8)
	sprite.frame = frame


# :Entity.
func handle_movement(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		return
		
	if player_chase:
		var axis = to_local(navigation_agent.get_next_path_position()).normalized()
		position += axis * movement_speed * delta
		velocity = velocity.lerp(axis * movement_speed * delta, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)


# :Entity.
func take_damage(amount: float) -> void:
	print(str(hp) + " " + str(amount) + " hit!")
	hp -= amount
	$Label.set_text(str(hp))
	
	damage_taken.emit(amount)
	
	if hp <= 0 and alive:
		die()


# :Entity.
func die() -> void:
	alive = false
	target_node = null
	navigation_agent.target_position = position
	$Aggr/AggroRange.set_collision_mask_value(2, false)
	set_collision_layer_value(3, false)
	died.emit()


func _on_recalculate_timer_timeout() -> void:
	recalc_path()


func recalc_path() -> void:
	if target_node:
		navigation_agent.target_position = target_node.global_position


func _on_aggro_range_area_entered(area: Node2D) -> void:
	target_node = area.owner
	player_chase = true

func _on_aggro_range_area_exited(area: Node2D) -> void:
	if area.owner == target_node:
		target_node = null
	player_chase = false

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.take_damage(1)
