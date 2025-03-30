extends EntityMob

@export var bottle: Node2D

var attack_cooldown:float = 1.0
var attack_cooldown_timer: float = 0.0

# Флаги для отслеживания нахождения в разных зонах
var in_scary_range: bool = false
var in_optimal_range: bool = false

# Приоритеты зон (чем больше число, тем выше приоритет)
const SCARY_RANGE_PRIORITY = 3
const OPTIMAL_RANGE_PRIORITY = 2
const AGGRO_RANGE_PRIORITY = 1

func _ready() -> void:
	super()
	# Подключаем сигналы для новых областей только если они еще не подключены
	if not $Aggr/ScaryRange.area_entered.is_connected(_on_scary_range_area_entered):
		$Aggr/ScaryRange.area_entered.connect(_on_scary_range_area_entered)
	if not $Aggr/ScaryRange.area_exited.is_connected(_on_scary_range_area_exited):
		$Aggr/ScaryRange.area_exited.connect(_on_scary_range_area_exited)
	if not $Aggr/OptimalRange.area_entered.is_connected(_on_optimal_range_area_entered):
		$Aggr/OptimalRange.area_entered.connect(_on_optimal_range_area_entered)
	if not $Aggr/OptimalRange.area_exited.is_connected(_on_optimal_range_area_exited):
		$Aggr/OptimalRange.area_exited.connect(_on_optimal_range_area_exited)

func _physics_process(delta: float) -> void:
	if not player_chase or not alive:
		super(delta)
		return
	
	# Проверяем возможность атаки
	if attack_cooldown_timer <= 0:
		bottle.shoot((target_node.position - position).angle())
		attack_cooldown_timer = attack_cooldown
	
	# Определяем текущий приоритет зоны и обрабатываем движение
	if in_scary_range:
		# Убегаем от игрока
		var run_direction = position - target_node.position
		run_direction = run_direction.normalized()
		position += run_direction * movement_speed * delta
		velocity = velocity.lerp(run_direction * movement_speed, acceleration)
	elif in_optimal_range:
		# Останавливаемся
		velocity = velocity.lerp(Vector2.ZERO, friction)
	else:
		# Используем стандартное поведение из EntityMob
		super(delta)
	
	attack_cooldown_timer -= delta

# Обработчики сигналов для ScaryRange
func _on_scary_range_area_entered(area: Area2D) -> void:
	if area.owner == target_node:
		in_scary_range = true
		# Сбрасываем навигацию при входе в зону страха
		navigation_agent.target_position = position
		# Принудительно останавливаем предыдущее движение
		velocity = Vector2.ZERO

func _on_scary_range_area_exited(area: Area2D) -> void:
	if area.owner == target_node:
		in_scary_range = false

# Обработчики сигналов для OptimalRange
func _on_optimal_range_area_entered(area: Area2D) -> void:
	if area.owner == target_node:
		in_optimal_range = true
		# Сбрасываем навигацию при входе в оптимальную зону
		navigation_agent.target_position = position
		# Принудительно останавливаем предыдущее движение
		velocity = Vector2.ZERO

func _on_optimal_range_area_exited(area: Area2D) -> void:
	if area.owner == target_node:
		in_optimal_range = false

# :EntityMob.
func update_ai() -> void:
	pass

# :EntityMob.
func attack() -> void:
	pass

# :Entity.
func update_animation(_delta: float) -> void:
	pass

# :Entity.
func get_interaction() -> void:
	pass
