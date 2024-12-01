class_name Grid

var grid: Array
var listeners: Array

@export var width: int = 10
@export var height: int = 20

func _init(w: int, h: int) -> void:
	self.width = w
	self.height = h
	for x in width:
		var line = []
		grid.append(line)
		for y in height:
			line.append(TetrisCursor.Kind.EMPTY)

func add_listener(fn) -> void:
	listeners.append(fn)

func is_empty(x: int, y: int) -> bool:
	return get_value(x, y) == TetrisCursor.Kind.EMPTY

func all_empty(x: int, y: int, shape: TetrisCursorShape) -> bool:
	for xy in shape.get_parts():
		if not is_empty(x + xy[0], y + xy[1]):
			return false
	return true

func row_filled(y: int) -> bool:
	for x in width:
		if is_empty(x, y):
			return false
	return true

func get_value(x: int, y: int) -> TetrisCursor.Kind:
	x = clampi(x, 0, width - 1)
	y = clampi(y, 0, height - 1)
	return grid[x][y]

func set_value(x: int, y: int, kind: TetrisCursor.Kind) -> void:
	x = clampi(x, 0, width - 1)
	y = clampi(y, 0, height - 1)
	grid[x][y] = kind
	for listener in listeners:
		listener.call(x, y, kind)

func set_all_by_shape(xy_array: Array, kind: TetrisCursor.Kind) -> void:
	for xy in xy_array:
		set_value(xy[0], xy[1], kind)

func set_all(kind: TetrisCursor.Kind):
	for x in width:
		for y in height:
			set_value(x, y, kind)
			
func collapse_row(y: int) -> void:
	for ny in y - 1:
		for x in width:
			set_value(x, y - ny, get_value(x, y - ny - 1))
	for x in width:
		set_value(x, 0, TetrisCursor.Kind.EMPTY)

func has_collision(x: int, y: int, shape: TetrisCursorShape) -> bool:
	for xy in shape.get_parts():
		if not is_empty(x + xy[0], y + xy[1]):
			return true
	return false
