extends TileMapLayer

@onready var cable_ground: TileMapLayer = self
@export var source_id: int = 0             
@export var atlas_coords: Vector2i = Vector2i(0, 0)   
@export var alternative_tile: int = 0

const EMPTY_CELL: Vector2i = Vector2i(-1, -1)

func _calculate_bitmask(surrounding_cells: Array[Vector2i]) -> int:
	var bitmask: int = 0
	for i in surrounding_cells.size():
		if cable_ground.get_cell_atlas_coords(surrounding_cells[i]) != EMPTY_CELL:
			bitmask |= (1 << i)
	return bitmask

func _update_tile(map_pos: Vector2i, is_erasing: bool) -> void:
	if is_erasing:
		cable_ground.erase_cell(map_pos)
	else:
		var surrounding_cells: Array[Vector2i] = cable_ground.get_surrounding_cells(map_pos)
		var bitmask: int = _calculate_bitmask(surrounding_cells)
		cable_ground.set_cell(map_pos, source_id, Vector2i(bitmask, 0), alternative_tile)

func _update_neighbors(map_pos: Vector2i) -> void:
	var surrounding_cells: Array[Vector2i] = cable_ground.get_surrounding_cells(map_pos)
	
	for cell in surrounding_cells:
		if cable_ground.get_cell_atlas_coords(cell) != EMPTY_CELL:
			_update_tile(cell, false)

func check_nearby_cols(map_pos: Vector2i, check_secondary: bool, is_erasing: bool) -> void:
	_update_tile(map_pos, is_erasing)
	
	if check_secondary:
		_update_neighbors(map_pos)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var cell: Vector2i = local_to_map(mouse_pos)
		
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				check_nearby_cols(cell, true, false)
			MOUSE_BUTTON_RIGHT:
				check_nearby_cols(cell, true, true)
