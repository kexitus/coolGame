extends Node2D

const SPAWN_ROOMS: Array = [preload("res://Rooms/Slums/SpawnRoom1.tscn")]
const END_ROOMS: Array = [preload("res://Rooms/Slums/EndRoom1T.tscn"), preload("res://Rooms/Slums/EndRoom1R.tscn"), 
							preload("res://Rooms/Slums/EndRoom1B.tscn"), preload("res://Rooms/Slums/EndRoom1L.tscn")]
const TOP_ROOMS: Array = [preload("res://Rooms/Slums/Room01T.tscn"), preload("res://Rooms/Slums/Room02T.tscn")]
const LEFT_ROOMS: Array = [preload("res://Rooms/Slums/Room01L.tscn"), preload("res://Rooms/Slums/Room02L.tscn")]
const RIGHT_ROOMS: Array = [preload("res://Rooms/Slums/Room01R.tscn"), preload("res://Rooms/Slums/Room02R.tscn")]
const BOTTOM_ROOMS: Array = [preload("res://Rooms/Slums/Room01B.tscn"), preload("res://Rooms/Slums/Room02B.tscn")]

const TILE_SIZE: int = 16
const FLOOR_TILE_COORDS: Vector2i = Vector2i(10, 10)
const RIGHT_WALL_TILE_COORDS: Vector2i = Vector2i(7, 13)
const LEFT_WALL_TILE_COORDS: Vector2i = Vector2i(8, 14)

var metamap: Array[Vector2]

@export var num_rooms: int = 15

@onready var player: CharacterBody2D = get_parent().get_node("Player")

func _ready() -> void:
	SavedData.current_floor += 1	
	if SavedData.current_floor == 3:
		num_rooms = 3
	_spawn_rooms()
	print("Generated rooms.")
	print(metamap)

func _spawn_rooms() -> void:
	var previous_room: Node2D
	metamap.resize(num_rooms)

	for i in num_rooms:
		var room: Node2D

		# SPAWN ROOM
		if i == 0: 
			room = SPAWN_ROOMS[randi() % SPAWN_ROOMS.size()].instantiate()
			player.position = room.get_node("PlayerSpawnPosition").position
			metamap[i] = Vector2.ZERO
		else:
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
						metamap[i] = metamap[i-1] + Vector2(0, 1)
					"Right":
						room = _roll_room(i, LEFT_ROOMS)
						metamap[i] = metamap[i-1] + Vector2(1, 0)
					"Bottom":
						room = _roll_room(i, TOP_ROOMS)
						metamap[i] = metamap[i-1] + Vector2(0, -1)
					"Left":
						room = _roll_room(i, RIGHT_ROOMS)
						metamap[i] = metamap[i-1] + Vector2(-1, 0)

			_connect_room(room, previous_room)

		add_child(room)
		previous_room = room


func _roll_room(index: int, rooms: Array):
	var roll_count: int = 0
	while true:
		roll_count += 1
		var rolled = rooms[randi() % rooms.size()].instantiate()
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

		if roll_count >= 50:
			push_error("ROLLED TOO MUCH ROOMS") #BUG Я хз как это говно всё ещё себе позволяет закручиваться в уробороса, мб надо вести глобал переменную для пошагового отката генерации
			return


func _connect_room(room, previous_room):
	var previous_room_tilemap: TileMap = previous_room.get_node("TileMap")
	var previous_room_exit: Marker2D = previous_room.get_node("Exits").get_child(0)
	var entrance_pos = room.get_node("Entrance/Position").position
	var direction: Vector2

	match previous_room_exit.name:
		"Top":
			direction = Vector2.UP * TILE_SIZE
		"Right":
			direction = Vector2.RIGHT * TILE_SIZE
		"Bottom":
			direction = Vector2.DOWN * TILE_SIZE
		"Left":
			direction = Vector2.LEFT * TILE_SIZE

	var corridor_offset = _generate_corridor(previous_room_tilemap, previous_room_exit)

	var entrance_offset = Vector2(-entrance_pos.x, -entrance_pos.y) + direction
	var entrance_coords = previous_room.global_position + previous_room_exit.global_position

	room.position = entrance_coords + entrance_offset + corridor_offset



func _generate_corridor(tilemap: TileMap, exit: Marker2D) -> Vector2:
	var length: int = randi() % 5 + 2
	var direction: Vector2i
	
	match exit.name:
		"Top":
			direction = Vector2.UP

			var exit_tile_pos: Vector2i = tilemap.local_to_map(exit.position + Vector2(-TILE_SIZE / 2.0, TILE_SIZE / 2.0)) + direction

			for y in length:
				tilemap.set_cell(0, exit_tile_pos + Vector2i(-1, -y), 1, LEFT_WALL_TILE_COORDS)
				tilemap.set_cell(1, exit_tile_pos + Vector2i(0, -y), 1, FLOOR_TILE_COORDS)
				tilemap.set_cell(1, exit_tile_pos + Vector2i(1, -y), 1, FLOOR_TILE_COORDS)
				tilemap.set_cell(0, exit_tile_pos + Vector2i(2, -y), 1, RIGHT_WALL_TILE_COORDS)

		"Right":
			direction = Vector2.RIGHT

			var exit_tile_pos: Vector2i = tilemap.local_to_map(exit.position + Vector2(-TILE_SIZE / 2.0, -TILE_SIZE / 2.0)) + direction

			for x in length:
				tilemap.set_cell(0, exit_tile_pos + Vector2i(x, -1), 1, LEFT_WALL_TILE_COORDS)
				tilemap.set_cell(1, exit_tile_pos + Vector2i(x, 0), 1, FLOOR_TILE_COORDS)
				tilemap.set_cell(1, exit_tile_pos + Vector2i(x, 1), 1, FLOOR_TILE_COORDS)
				tilemap.set_cell(0, exit_tile_pos + Vector2i(x, 2), 1, RIGHT_WALL_TILE_COORDS)
		"Bottom":
			direction = Vector2.DOWN

			var exit_tile_pos: Vector2i = tilemap.local_to_map(exit.position + Vector2(TILE_SIZE / 2.0, -TILE_SIZE / 2.0)) + direction

			for y in length:
				tilemap.set_cell(0, exit_tile_pos + Vector2i(1, y), 1, LEFT_WALL_TILE_COORDS)
				tilemap.set_cell(1, exit_tile_pos + Vector2i(0, y), 1, FLOOR_TILE_COORDS)
				tilemap.set_cell(1, exit_tile_pos + Vector2i(-1, y), 1, FLOOR_TILE_COORDS)
				tilemap.set_cell(0, exit_tile_pos + Vector2i(-2, y), 1, RIGHT_WALL_TILE_COORDS)
		"Left":
			direction = Vector2.LEFT

			var exit_tile_pos: Vector2i = tilemap.local_to_map(exit.position + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)) + direction

			for x in length:
				tilemap.set_cell(0, exit_tile_pos + Vector2i(-x, 1), 1, LEFT_WALL_TILE_COORDS)
				tilemap.set_cell(1, exit_tile_pos + Vector2i(-x, 0), 1, FLOOR_TILE_COORDS)
				tilemap.set_cell(1, exit_tile_pos + Vector2i(-x, -1), 1, FLOOR_TILE_COORDS)
				tilemap.set_cell(0, exit_tile_pos + Vector2i(-x, -2), 1, RIGHT_WALL_TILE_COORDS)

	var corridor_offset = direction * (-1 + length) * TILE_SIZE
	return corridor_offset
