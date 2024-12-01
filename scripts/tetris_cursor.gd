class_name TetrisCursor

enum Kind {EMPTY, BLUE, ORANGE, YELLOW, GREEN, RED, PURPLE, CYAN}

static var kind_array = [
	Kind.BLUE,
	Kind.ORANGE,
	Kind.YELLOW,
	Kind.GREEN,
	Kind.RED,
	Kind.PURPLE,
	Kind.CYAN,
]

var _x: int = 0
var _y: int = 0
var _rotation: int = 0
var _kind: Kind = Kind.BLUE

@export var rotation: int:
	get: return self._rotation
	set(value):
		self._rotation = value
		
@export var kind: Kind:
	get: return self._kind
	set(value): self._kind = value

@export var width: int:
	get: 
		var min_val: int = 0
		var max_val = 0
		for xy in get_shape().get_parts():
			if min_val > xy[0]:
				min_val = xy[0]
			if max_val < xy[0]:
				max_val = xy[0]
		return (max_val + 5) - (min_val + 5) + 1

@export var height: int:
	get: 
		var min_val = 0
		var max_val = 0
		for xy in get_shape().get_parts():
			if min_val > xy[1]:
				min_val = xy[1]
			if max_val < xy[1]:
				max_val = xy[1]
		return (max_val + 5) - (min_val + 5) + 1
		
func _init(x: int, y: int, kind: Kind, rotation: int):
	self._x = x
	self._y = y
	self._rotation = rotation
	self._kind = kind

func get_leftmost_position() -> int:
	var shape = get_shape()
	var parts = shape.get_parts()
	var result = 0
	for i in parts.size():
		if parts[i][0] < result:
			result = parts[i][0]
	return _x + result
	
func get_rightmost_position() -> int:
	var shape = get_shape()
	var parts = shape.get_parts()
	var result = 0
	for i in parts.size():
		if parts[i][0] > result:
			result = parts[i][0]
	return _x + result
	
func get_bottommost_position() -> int:
	var shape = get_shape()
	var result = 0
	var parts = shape.get_parts()
	for i in parts.size():
		if parts[i][1] > result:
			result = parts[i][1]
	return _y + result
	
func get_cursor_color() -> Color:
	return get_color_by_kind(_kind)

func get_shape() -> TetrisCursorShape:
	var shapes : Array = get_cursor_shapes(_kind)
	var shape = shapes[_rotation % shapes.size()]
	return TetrisCursorShape.new(_kind, shape)

func set_position_silently(x: int, y: int) -> void:
	_x = x
	_y = y

static func get_cursor_shapes(cursor_type: Kind) -> Array:
	if cursor_type == Kind.BLUE:
		# #
		# #
		# ##
		return [
			[[0, 0], [-1, 0], [-1, -1], [1, 0]],
			[[0, 0], [1, -1], [0, -1], [0, 1]],
			[[0, 0], [-1, 0], [1, 0], [1, 1]],
			[[0, -1], [0, 0], [0, 1], [-1, 1]],
		]
		
	if cursor_type == Kind.ORANGE:
		#  #
		#  #
		# ##
		return [
			[[1, -1], [-1, 0], [0, 0], [1, 0]],
			[[0, -1], [0, 0], [0, 1], [1, 1]],
			[[-1, 1], [-1, 0], [0, 0], [1, 0]],
			[[0, -1], [0, 0], [0, 1], [-1, -1]],
		]
		
	if cursor_type == Kind.YELLOW:
		# ##
		# ##
		return [
			[[0, 0], [0, -1], [-1, -1], [-1, 0]]
		]
		
	if cursor_type == Kind.CYAN:
		# ####
		return [
			[[-1, 0], [0, 0], [1, 0], [2, 0]],
			[[0, -1], [0, 0], [0, 1], [0, 2]],
		]
		
	if cursor_type == Kind.GREEN:
		# ##
		#  ##
		return [
			[[-1, -1], [0, -1], [0, 0], [1, 0]],
			[[-1, 0], [-1, 1], [0, -1], [0, 0]],
		]
		
	if cursor_type == Kind.RED:
		#  ##
		# ##	
		return [
			[[0, -1], [1, -1], [-1, 0], [0, 0]],
			[[-1, -1], [-1, 0], [0, 0], [0, 1]],
		]
	
	# CursorType.PURPLE	
	# ###
	#  #
	return [
		[[-1, 0], [0, 0], [1, 0], [0, -1]],
		[[0, -1], [0, 0], [0, 1], [-1, 0]],
		[[-1, 0], [0, 0], [1, 0], [0, 1]],
		[[0, -1], [0, 0], [0, 1], [1, 0]],
	]

static func get_color_by_kind(kind: Kind):
	if kind == Kind.BLUE:
		return Color.BLUE

	if kind == Kind.RED:
		return Color.RED

	if kind == Kind.YELLOW:
		return Color.YELLOW

	if kind == Kind.GREEN:
		return Color.GREEN

	if kind == Kind.ORANGE:
		return Color.ORANGE

	if kind == Kind.PURPLE:
		return Color.PURPLE

	return Color.CYAN

static func get_kind_by_id(id: int) -> Kind:
	return kind_array[id % kind_array.size()]
