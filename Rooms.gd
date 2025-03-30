extends Node2D

const SPAWN_ROOMS: Array = [preload("res://Rooms/Slums/SpawnRoom1.tscn")]
const END_ROOMS: Array = [preload("res://Rooms/Slums/EndRoom1T.tscn"), preload("res://Rooms/Slums/EndRoom1R.tscn"), 
							preload("res://Rooms/Slums/EndRoom1B.tscn"), preload("res://Rooms/Slums/EndRoom1L.tscn")]
const TOP_ROOMS: Array = [preload("res://Rooms/Slums/RoomT1.tscn"), preload("res://Rooms/Slums/RoomT2.tscn"),
							preload("res://Rooms/Slums/RoomT3.tscn"), preload("res://Rooms/Slums/RoomT4.tscn"),
							preload("res://Rooms/Slums/RoomT5.tscn")]
const LEFT_ROOMS: Array = [preload("res://Rooms/Slums/RoomL1.tscn"), preload("res://Rooms/Slums/RoomL2.tscn"),
							preload("res://Rooms/Slums/RoomL3.tscn"), preload("res://Rooms/Slums/RoomL4.tscn"),
							preload("res://Rooms/Slums/RoomL5.tscn")]
const RIGHT_ROOMS: Array = [preload("res://Rooms/Slums/RoomR1.tscn"), preload("res://Rooms/Slums/RoomR2.tscn"),
							preload("res://Rooms/Slums/RoomR3.tscn"), preload("res://Rooms/Slums/RoomR4.tscn"),
							preload("res://Rooms/Slums/RoomR5.tscn")]
const BOTTOM_ROOMS: Array = [preload("res://Rooms/Slums/RoomB1.tscn"), preload("res://Rooms/Slums/RoomB2.tscn"),
							preload("res://Rooms/Slums/RoomB3.tscn"), preload("res://Rooms/Slums/RoomB4.tscn"),
							preload("res://Rooms/Slums/RoomB5.tscn")]

const TILE_SIZE: int = 16

const WALL_TOP_WOODEN_TILE_COORDS: Array[Vector2i] = [Vector2i(2, 6), Vector2i(3, 6), Vector2i(4, 6), Vector2i(5, 6),
													Vector2i(6, 6), Vector2i(7, 6), Vector2i(8, 6)]
const WALL_CENTER_WOODEN_TILE_COORDS: Array[Vector2i] = [Vector2i(2, 7), Vector2i(3, 7), Vector2i(4, 7), Vector2i(5, 7),
													Vector2i(6, 7), Vector2i(7, 7), Vector2i(8, 7)]
const WALL_BOTTOM_WOODEN_TILE_COORDS: Array[Vector2i] = [Vector2i(2, 8), Vector2i(3, 8), Vector2i(4, 8), Vector2i(5, 8),
													Vector2i(6, 8), Vector2i(7, 8), Vector2i(8, 8)]
const WALL_TOP_BRICK_TILE_COORDS: Array[Vector2i] = [Vector2i(1, 10), Vector2i(2, 10), Vector2i(3, 10), Vector2i(4, 10),
													Vector2i(5, 10), Vector2i(6, 10), Vector2i(7, 10)]
const WALL_CENTER_BRICK_TILE_COORDS: Array[Vector2i] = [Vector2i(1, 11), Vector2i(2, 11), Vector2i(3, 11), Vector2i(4, 11),
													Vector2i(5, 11), Vector2i(6, 11), Vector2i(7, 11)]
const WALL_BOTTOM_BRICK_TILE_COORDS: Array[Vector2i] = [Vector2i(1, 12), Vector2i(2, 12), Vector2i(3, 12), Vector2i(4, 12),
													Vector2i(5, 12), Vector2i(6, 12), Vector2i(7, 12)]

const FLOOR_TILE_COORDS: Vector2i = Vector2i(10, 10)
const ROOF_TILE_COORDS: Array[Vector2i] = [Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5), Vector2i(5, 5), 
											Vector2i(6, 5), Vector2i(7, 5), Vector2i(8, 5)]
const WALL_WOODEN_TILE_COORDS: Array = [WALL_TOP_WOODEN_TILE_COORDS, WALL_CENTER_WOODEN_TILE_COORDS, WALL_BOTTOM_WOODEN_TILE_COORDS]
const WALL_BRICK_TILE_COORDS: Array = [WALL_TOP_BRICK_TILE_COORDS, WALL_CENTER_BRICK_TILE_COORDS, WALL_BOTTOM_BRICK_TILE_COORDS]

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@onready var rng_seed: int #= 5751331530851104281

var metamap: Array[Vector2]

@export var num_rooms: int = 15

@onready var player: CharacterBody2D = get_parent().get_node("Player")

func _ready() -> void:
	if rng_seed:
		rng.seed = rng_seed
	else:
		rng.randomize()
		rng_seed = rng.seed

	SavedData.current_floor += 1	
	if SavedData.current_floor == 3:
		num_rooms = 3
	_spawn_rooms()
	print("Generated rooms.")
	print("Rooms RNG seed: %s" % rng_seed)
	print(metamap)

func _spawn_rooms() -> void:
	var previous_room: Node2D
	metamap.resize(num_rooms)
	var max_attempts = 3  # Максимальное количество попыток генерации всего уровня
	var success = false

	for attempt in max_attempts:
		metamap.clear()
		metamap.resize(num_rooms)
		success = true
		previous_room = null
		
		for i in num_rooms:
			var room: Node2D

			# SPAWN ROOM
			if i == 0: 
				room = SPAWN_ROOMS[rng.randi() % SPAWN_ROOMS.size()].instantiate()
				player.position = room.get_node("PlayerSpawnPosition").position
				metamap[i] = Vector2.ZERO
			else:
				if not previous_room:
					success = false
					break
					
				var previous_room_exit: Marker2D = previous_room.get_node("Exits").get_child(0)

				# END ROOM
				if i == num_rooms - 1:
					match previous_room_exit.name:
						"Top":
							room = END_ROOMS[2].instantiate()
							metamap[i] = metamap[i-1] + Vector2(0, 1)
						"Right":
							room = END_ROOMS[3].instantiate()
							metamap[i] = metamap[i-1] + Vector2(1, 0)
						"Bottom":
							room = END_ROOMS[0].instantiate()
							metamap[i] = metamap[i-1] + Vector2(0, -1)
						"Left":
							room = END_ROOMS[1].instantiate()
							metamap[i] = metamap[i-1] + Vector2(-1, 0)
				# DEFAULT ROOM
				else:
					match previous_room_exit.name:
						"Top":
							room = _roll_room(i, BOTTOM_ROOMS)
							if room:
								metamap[i] = metamap[i-1] + Vector2(0, 1)
							else:
								success = false
								break
						"Right":
							room = _roll_room(i, LEFT_ROOMS)
							if room:
								metamap[i] = metamap[i-1] + Vector2(1, 0)
							else:
								success = false
								break
						"Bottom":
							room = _roll_room(i, TOP_ROOMS)
							if room:
								metamap[i] = metamap[i-1] + Vector2(0, -1)
							else:
								success = false
								break
						"Left":
							room = _roll_room(i, RIGHT_ROOMS)
							if room:
								metamap[i] = metamap[i-1] + Vector2(-1, 0)
							else:
								success = false
								break

				if not success:
					break

				_connect_room(room, previous_room)

			if not success:
				# Очищаем все созданные комнаты
				for child in get_children():
					child.queue_free()
				continue

			add_child(room)
			previous_room = room

		if success:
			break  # Если генерация успешна, выходим из цикла попыток
		else:
			print("Generation attempt %d failed, retrying..." % (attempt + 1))

	if not success:
		push_error("Failed to generate level after %d attempts" % max_attempts)

func _roll_room(index: int, rooms: Array):
	var roll_count: int = 0
	var rolled: Node2D = null
	
	while true:
		roll_count += 1
		rolled = rooms[rng.randi() % rooms.size()].instantiate()
		var exit_name = rolled.get_node("Exits").get_child(0).name
		var direction: Vector2
		print("roll: %s %s %s" % [index, roll_count, exit_name])
		
		match exit_name:
			"Top":	
				direction = Vector2(0, 1)
			"Right":
				direction = Vector2(1, 0)
			"Bottom":
				direction = Vector2(0, -1)
			"Left":
				direction = Vector2(-1, 0)
				
		if !metamap.any(func(coords:Vector2): return coords == (metamap[index-1] + direction)):
			return rolled
			
		rolled.free()
		rolled = null

		if roll_count >= 50:
			push_error("ROLLED TOO MUCH ROOMS") #BUG Я хз как это говно всё ещё себе позволяет закручиваться в уробороса, мб надо вести глобал переменную для пошагового отката генерации
			return null

func _connect_room(room, previous_room):
	var previous_room_tilemap: TileMap = previous_room.get_node("TileMap")
	var previous_room_exit: Marker2D = previous_room.get_node("Exits").get_child(0)
	var room_entrance: Marker2D = room.get_node("Entrance/Position")
	
	# Получаем направление и смещение для коридора
	var direction: Vector2
	var corridor_offset: Vector2
	
	match previous_room_exit.name:
		"Top":
			direction = Vector2.UP
			corridor_offset = _generate_corridor(previous_room_tilemap, previous_room_exit, direction)
		"Right":
			direction = Vector2.RIGHT
			corridor_offset = _generate_corridor(previous_room_tilemap, previous_room_exit, direction)
		"Bottom":
			direction = Vector2.DOWN
			corridor_offset = _generate_corridor(previous_room_tilemap, previous_room_exit, direction)
		"Left":
			direction = Vector2.LEFT
			corridor_offset = _generate_corridor(previous_room_tilemap, previous_room_exit, direction)
	
	# Вычисляем позицию комнаты
	var exit_global_pos = previous_room_exit.global_position
	var entrance_global_pos = room_entrance.position
	
	# Устанавливаем позицию комнаты с учетом коридора
	room.position = previous_room.global_position + exit_global_pos + corridor_offset - entrance_global_pos

func _generate_corridor(tilemap: TileMap, exit: Marker2D, direction: Vector2) -> Vector2:
	var length: int = rng.randi() % 5 + 2
	var exit_tile_pos: Vector2i = tilemap.local_to_map(exit.position)
	var current_pos: Vector2i
	var final_tile_position: Array[Vector2i]
	var pos_modifiers: Array[Vector2i]
	match direction:
		Vector2.UP:
			pos_modifiers = [Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)]
		Vector2.DOWN:
			pos_modifiers = [Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)]
		Vector2.LEFT:
			pos_modifiers = [Vector2i(-1, -5), Vector2i(-1, -4), Vector2i(-1, -3), Vector2i(-1, -2),
							 Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1)]
		Vector2.RIGHT:
			pos_modifiers = [Vector2i(0, -5), Vector2i(0, -4), Vector2i(0, -3), Vector2i(0, -2),
							 Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1)]
	final_tile_position.resize(pos_modifiers.size())
	# Генерируем коридор
	for i in length:
		current_pos = exit_tile_pos + Vector2i(direction * i)
		for j in final_tile_position.size():
			final_tile_position[j] = current_pos + pos_modifiers[j]
		
		match direction:
			Vector2.UP, Vector2.DOWN:
				tilemap.set_cell(0, final_tile_position[0], 1, ROOF_TILE_COORDS[randi_range(0, ROOF_TILE_COORDS.size() - 1)], TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V)
				tilemap.set_cell(1, final_tile_position[1], 1, FLOOR_TILE_COORDS)
				tilemap.set_cell(1, final_tile_position[2], 1, FLOOR_TILE_COORDS)
				tilemap.set_cell(0, final_tile_position[3], 1, ROOF_TILE_COORDS[randi_range(0, ROOF_TILE_COORDS.size() - 1)], TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H)
			Vector2.LEFT, Vector2.RIGHT:
				tilemap.set_cell(0, final_tile_position[0], 1, ROOF_TILE_COORDS[randi_range(0, ROOF_TILE_COORDS.size() - 1)])
				tilemap.set_cell(1, final_tile_position[1], 1, WALL_WOODEN_TILE_COORDS[0][randi_range(0, WALL_WOODEN_TILE_COORDS[0].size() - 1)])
				tilemap.set_cell(1, final_tile_position[2], 1, WALL_WOODEN_TILE_COORDS[1][randi_range(0, WALL_WOODEN_TILE_COORDS[1].size() - 1)])
				tilemap.set_cell(0, final_tile_position[3], 1, WALL_WOODEN_TILE_COORDS[2][randi_range(0, WALL_WOODEN_TILE_COORDS[2].size() - 1)])
				tilemap.set_cell(1, final_tile_position[4], 1, FLOOR_TILE_COORDS)
				tilemap.set_cell(1, final_tile_position[5], 1, FLOOR_TILE_COORDS)
				tilemap.set_cell(1, final_tile_position[6], 1, ROOF_TILE_COORDS[randi_range(0, ROOF_TILE_COORDS.size() - 1)], TileSetAtlasSource.TRANSFORM_FLIP_V)
				
	
	# Возвращаем смещение коридора в пикселях
	return direction * (length) * TILE_SIZE
