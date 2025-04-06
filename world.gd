extends Node2D

#Tile atlas references
const TILE_BEDROCK:Vector2i = Vector2i(0,1)
const TILE_DIRT:Vector2i = Vector2i(0,0)
const TILE_STONE:Vector2i = Vector2i(1,0)
const TILE_DARK:Vector2i = Vector2i(2,0)
const TILE_EVIL:Vector2i = Vector2i(3,0)
const TILE_DAMAGE_1:Vector2i = Vector2i(1,1)
const TILE_DAMAGE_2:Vector2i = Vector2i(2,1)
const TILE_DAMAGE_3:Vector2i = Vector2i(3,1)
const TILE_METAL:Vector2i = Vector2i(0, 2)
const TILE_FUEL:Vector2i = Vector2i(1, 2)
const TILE_CRYSTAL:Vector2i = Vector2i(2, 2)

const DRILL_STOP:PackedScene = preload("res://drill_stop.tscn")

var damage_matrix:Array
# World generator settings
var dirt_size:Vector2i = Vector2i(16, 16)
var stone_size:Vector2i = Vector2i(24, 24)
var dark_size:Vector2i = Vector2i(36, 36)
var evil_size:Vector2i = Vector2i(48, 48)
var total_size:Vector2i

@export var drill:Node2D

func _ready():
	generate_world()
	drill.position.x = total_size.x / 2 * 32
	$Observer.position = drill.position

func generate_biome(biome_size:Vector2i, starting_y:int, tile_atlas:Vector2i):
	for i in range(starting_y, biome_size.y + starting_y):
		for j in range(total_size.x):
			if j >= (total_size.x / 2) - (biome_size.x / 2) and j < (total_size.x / 2) + (biome_size.x / 2):
				if i < biome_size.y + starting_y - 1:
					$Ground.set_cell(Vector2i(j, i), 1, tile_atlas)
				else:
					$Ground.set_cell(Vector2i(j, i), 1, TILE_BEDROCK)
	var drillstop:Area2D = DRILL_STOP.instantiate()
	drillstop.global_position.x = (total_size.x / 2) * 32
	drillstop.global_position.y = (biome_size.y + starting_y - 2) * 32
	add_child(drillstop)

func generate_world():
	total_size.x = max(dirt_size.x, stone_size.x, dark_size.x, evil_size.x)
	total_size.y = dirt_size.y + stone_size.y + dark_size.y + evil_size.y
	for i in range(total_size.x):
		damage_matrix.append([])
		for j in range(total_size.y):
			damage_matrix[i].append(0)
	var gen_y:int = 0
	var biome_sizes:Array[Vector2i] = [
		dirt_size,
		stone_size,
		dark_size,
		evil_size,
	]
	var biome_tiles:Array[Vector2i] = [
		TILE_DIRT,
		TILE_STONE,
		TILE_DARK,
		TILE_EVIL,
	]
	for i in range(4):
		generate_biome(biome_sizes[i], gen_y, biome_tiles[i])
		gen_y += biome_sizes[i].y

func damage_tile(world_position:Vector2, break_bedrock:bool = false, amount:int = 1) -> void:
	if not is_ground_breakable(world_position, break_bedrock):
		return
	var grid_position:Vector2i = $Ground.local_to_map(to_local(world_position))
	var tile_damage:int = damage_matrix[grid_position.x][grid_position.y] + amount
	damage_matrix[grid_position.x][grid_position.y] = tile_damage
	match tile_damage:
		1:
			$Damage.set_cell(grid_position, 1, TILE_DAMAGE_1)
		2:
			$Damage.set_cell(grid_position, 1, TILE_DAMAGE_2)
		3:
			$Damage.set_cell(grid_position, 1, TILE_DAMAGE_3)
		_:
			$Damage.set_cell(grid_position, -1)
			$Ground.set_cell(grid_position, -1)

#Input position must be global
func snap_to_grid(raw_position:Vector2) -> Vector2:
	var local_position:Vector2 = $Ground.to_local(raw_position)
	var snapped_position:Vector2 = ($Ground.local_to_map(local_position) as Vector2) * 32 + Vector2(16, 16)
	return $Ground.to_global(snapped_position)

func get_drill() -> Node2D:
	return drill

func is_ground_breakable(world_position:Vector2, break_bedrock:bool = false):
	var grid_position:Vector2i = $Ground.local_to_map(to_local(world_position))
	var ground_atlas:Vector2i = $Ground.get_cell_atlas_coords(grid_position)
	if ground_atlas == Vector2i(-1, -1) or (ground_atlas == TILE_BEDROCK and !break_bedrock):
		return false
	return true
	
func get_damage(world_position:Vector2):
	var grid_position:Vector2i = $Ground.local_to_map(to_local(world_position))
	return damage_matrix[grid_position.x][grid_position.y]

func _unhandled_input(event:InputEvent):
	if event.is_action_pressed("lmb"):
		var grid_position = $Resources.local_to_map(to_local(get_global_mouse_position()))
		$Resources.set_cell(grid_position, 1, Vector2i(randi_range(0,2), 2))
