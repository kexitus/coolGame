extends WeaponBasic

@export var attack_timer: Timer
@export var damage_per_tick: float = 1.0
@export var attack_duration: float = 0.5
@export var cooldown: float = 0.1

var is_active: bool = false
var can_attack: bool = true

var projectile_instance: Projectile
var projectile_animation: AnimationPlayer

func _ready() -> void:
	attack_timer.one_shot = true
	projectile_instance = projectile.instantiate()
	projectile_animation = projectile_instance.animation_player
	projectile_instance.scale = Vector2(2, 2)
	projectile_instance.visible = false

	add_child(projectile_instance)


func _physics_process(_delta: float) -> void:
	if !is_active:
		return
	
	# Обновляем позицию и поворот огня относительно игрока
	projectile_instance.position = player.facing_direction * 24  # Увеличил отступ
	projectile_instance.rotation = player.facing_direction.angle() + PI/2


func attack(_from: Vector2, _to: Vector2) -> void:
	if !can_attack:
		return
		
	if !is_active:
		# Начинаем атаку
		projectile_instance.visible = true
		is_active = true
		if projectile_animation.has_animation("start"):
			projectile_animation.play("start")
	
	if !projectile_animation.is_playing():
		if projectile_animation.has_animation("loop"):
			projectile_animation.play("loop")
	# Сбрасываем таймер, пока кнопка зажата
	attack_timer.stop()


func stop_attack() -> void:
	if !is_active:
		return
		
	is_active = false
	can_attack = false
	attack_timer.start(cooldown)
	if projectile_animation.has_animation("end"):
		projectile_animation.play("end")


func _on_attack_timer_timeout() -> void:
	can_attack = true
