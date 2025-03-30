extends Projectile
class_name PrjFireball

@onready var fireball_sprite: Sprite2D = $FireballSprite
@onready var explosion_sprite: Sprite2D = $ExplosionSprite
@onready var fireball_hitbox: Area2D = $FireballHitbox
@onready var explosion_hitbox: Area2D = $ExplosionHitbox
@onready var fireball_collision: CollisionShape2D = $FireballHitbox/FireballCollision
@onready var explosion_collision: CollisionShape2D = $ExplosionHitbox/ExplosionCollision

var entity_blacklist: Array[Entity] = []

func _ready() -> void:
	fireball_collision.disabled = false
	fireball_sprite.visible = true
	explosion_sprite.visible = false
	
	animation_player.play("loop")


func explode() -> void:
	fireball_collision.disabled = true
	fireball_sprite.visible = false
	explosion_sprite.visible = true
	speed = 0
	rotation = 0

	animation_player.play("explosion")

	for body in explosion_hitbox.get_overlapping_bodies():
		if body is Entity and !entity_blacklist.has(body):
			body.take_damage(damage)


func _on_fireball_hitbox_body_entered(body:Node2D) -> void:
	if body is Entity and entity_blacklist.has(body):
		return
	explode()


func _on_removal_timer_timeout() -> void:
	explode()
	