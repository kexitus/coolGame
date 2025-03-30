extends CanvasLayer


@export var player: EntityPlayer
@onready var basic_weapon_icon: TextureRect = $WeaponBar/SlotIcon/BasicWeaponIcon
@onready var special_weapon_icon_1: TextureRect = $WeaponBar/SlotIcon2/SpecialWeaponIcon
@onready var special_weapon_icon_2: TextureRect = $WeaponBar/SlotIcon3/SpecialWeaponIcon
@onready var special_weapon_icon_3: TextureRect = $WeaponBar/SlotIcon4/SpecialWeaponIcon

var heart_dictionary: Dictionary = {
	"RED": Rect2(Vector2(0, 0), Vector2(16, 16)),
	"RED_SEMI": Rect2(Vector2(16, 0), Vector2(16, 16)),
	"CURSED": Rect2(Vector2(0, 16), Vector2(16, 16)),
	"CURSED_SEMI": Rect2(Vector2(16, 16), Vector2(16, 16)),
	"POISONED": Rect2(Vector2(0, 32), Vector2(16, 16)),
	"POISONED_SEMI": Rect2(Vector2(16, 32), Vector2(16, 16)),
	}

var atlas = AtlasTexture.new()

@export var atlas_image: CompressedTexture2D

@onready var health_bar = $HealthBar

func draw_heart(heart_name: String):
	var heart_atlas = atlas.duplicate()
	var heart_icon = TextureRect.new()	
	heart_atlas.region = heart_dictionary[heart_name]
	heart_icon.add_to_group("hearts")
	heart_icon.expand_mode = 2
	heart_icon.stretch_mode = 4
	heart_icon.texture = heart_atlas
	health_bar.add_child(heart_icon)


func remove_health():
	for i in health_bar.get_children():
		i.queue_free()


func set_health_icon(health_count: Dictionary, order: Array[String]):
	remove_health()
	for type_health in order:
		for i in range(health_count[type_health]/2):
			draw_heart(type_health)
		if health_count[type_health] % 2 == 1:
			draw_heart(type_health + "_SEMI")
	print(str(health_bar.get_children()))


func change_heart(heart: int):
	var hearts = get_tree().get_nodes_in_group("hearts")
	var heart_curr = hearts[heart - 1]
	var test = atlas.duplicate()
	test.region = Rect2(Vector2(0, 32), Vector2(16, 16))
	heart_curr.texture = test

	#health_bar.heart_icon[heart]

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(str(atlas_image.get_load_path()))
	atlas.atlas = atlas_image
	#var region = Rect2(Vector2(0, 0), Vector2(16, 16))  

	player.basic_weapon_changed.connect(func(new_weapon: WeaponBasic):
		basic_weapon_icon.texture = new_weapon.icon
	)
	player.special_weapon_changed.connect(func(new_weapon: WeaponSpecial, index: int):
		match index:
			0:
				special_weapon_icon_1.texture = new_weapon.icon
			1:
				special_weapon_icon_2.texture = new_weapon.icon
			2:
				special_weapon_icon_3.texture = new_weapon.icon
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
