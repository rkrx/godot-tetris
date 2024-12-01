extends Node2D

var grid: Grid = Grid.new(10, 20)
var grid_nodes: Grid = Grid.new(10, 20)

var settled_bricks: Array

var offset_x : float = 30.0
var offset_y : float = 30.0
var size_scale : float = 25.0

var fast_forward: bool = false
var fast_forward_disabled: bool = false

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var cur : TetrisCursor

var cursor_rects : Array[ColorRect]

var lr_move_start: int = Time.get_ticks_msec()
var last_move: int = Time.get_ticks_msec()
var pause_until: int = 0

var queue: Array = []

var process_queue: Array = []

@export var base: Node2D
@export var materialized_bricks: Node
@export var background: ColorRect
@export var explosion: Node2D
@export var debug: ColorRect

@export var sound_hit: AudioStreamPlayer2D
@export var sound_row_removal: AudioStreamPlayer2D

func _ready() -> void:
	rng.set_seed(Time.get_unix_time_from_system())
	var _kind_id = rng.randi_range(1, 7)
	var _kind = TetrisCursor.get_kind_by_id(1)
	cur = TetrisCursor.new(5, 1, _kind, 0)
	
	for i in 5:
		_kind_id = rng.randi_range(1, 7)
		_kind = TetrisCursor.get_kind_by_id(1)
		queue.append(_kind)
	
	grid = Grid.new(10, 20)
	grid.set_all(TetrisCursor.Kind.EMPTY)
	grid.add_listener(set_materialized_brick)

	for i in 4:
		var block = ColorRect.new()
		cursor_rects.append(block)
		base.add_child(block)
	
	background.position = Vector2(offset_x, offset_y)
	background.size.x = grid.width * size_scale
	background.size.y = grid.height * size_scale
	background.color = Color.WEB_GRAY

func _process(_delta: float) -> void:
	if not TimeUtils.is_past(pause_until):
		return
	
	if process_queue.size() > 0:
		process_queue.pop_front().call()
		return
	
	if Input.is_action_just_pressed("up"):
		cur.rotation += 1

	if Input.is_action_pressed("down"):
		if not fast_forward_disabled:
			add_y(1)
	else:
		fast_forward_disabled = false

	if Input.is_action_just_pressed("left"):
		add_x(-1)
		lr_move_start = Time.get_ticks_msec() + 250

	if TimeUtils.is_past(lr_move_start) and Input.is_action_pressed("left"):
		add_x(-1)
		lr_move_start = Time.get_ticks_msec() + 50

	if Input.is_action_just_pressed("right"):
		add_x(1)
		lr_move_start = Time.get_ticks_msec() + 250

	if TimeUtils.is_past(lr_move_start) and Input.is_action_pressed("right"):
		add_x(1)
		
		lr_move_start = Time.get_ticks_msec() + 50
		
	if cur.get_leftmost_position() < 0:
		add_x(-cur.get_leftmost_position())
		
	if cur.get_rightmost_position() > 9:
		add_x(9 - cur.get_rightmost_position())
	
	if cur.get_bottommost_position() > 19:
		add_y(19 - cur.get_bottommost_position())
		fast_forward_disabled = true
		materialize(cur._x, cur._y, cur.get_shape())
		hide_cursor()
		process_queue.append(func(): pause_until = TimeUtils.wait_for_ms(300))
		process_queue.append(func(): reset_cursor())

	if Time.get_ticks_msec() - (last_move + 1200) > 0:
		add_y(1)
		last_move = Time.get_ticks_msec()
	
	put_cursor_shape_at(cur, cursor_rects)

func put_cursor_shape_at(cursor: TetrisCursor, _cursor_rects: Array[ColorRect]):
	var shape = cur.get_shape()
	var parts = shape.get_parts()
	for i in _cursor_rects.size():
		var _cx = parts[i][0] + cursor._x
		var _cy = parts[i][1] + cursor._y
		var _color = cursor.get_cursor_color()
		set_rect_props(cursor_rects[i], _cx, _cy, _color)

func set_materialized_brick(x: int, y: int, kind: TetrisCursor.Kind):
	var children = materialized_bricks.get_children()
	for child in children:
		if child.get_meta("x") == x and child.get_meta("y") == y:
			materialized_bricks.remove_child(child)
	
	if kind != TetrisCursor.Kind.EMPTY:
		var cr = ColorRect.new()
		set_rect_props(cr, x, y, TetrisCursor.get_color_by_kind(kind))
		materialized_bricks.add_child(cr)

func set_rect_props(rect: ColorRect, x: int, y: int, color: Color):
	rect.position = Vector2(offset_x + x * size_scale, offset_y + y * size_scale)
	rect.size = Vector2(size_scale, size_scale)
	rect.color = color
	rect.set_meta("x", x)
	rect.set_meta("y", y)

func hide_cursor():
	for rect in cursor_rects:
		rect.visible = false
		rect.set_position(Vector2(-500, -500))

func reset_cursor():
	cur.set_position_silently(5, 0)
	cur._rotation = 0
	
	var kind_id = rng.randi_range(1, 7)
	var kind = TetrisCursor.get_kind_by_id(kind_id)
	cur.kind = kind
	
	for rect in cursor_rects:
		rect.visible = true

func materialize(x: int, y: int, shape: TetrisCursorShape):
	explosion.show_at(screen_x(x), screen_y(y), screen_x(cur.width), screen_y(cur.height))
	#print("v2 x: %.2f, y: %.2f" % [cur.width, cur.height])
	#debug.position = Vector2(screen_x(cur._x), screen_y(cur._y))
	#debug.size = Vector2(screen_x(cur.width), screen_y(cur.height))
	
	sound_hit.play()
	
	for coord in shape.get_parts():
		grid.set_value(cur._x + coord[0], cur._y + coord[1], cur.kind)
	
	for gy in grid.height:
		if grid.row_filled(gy):
			process_queue.append(
				func():
					grid.collapse_row(gy)
					sound_row_removal.play()
					pause_until = TimeUtils.wait_for_ms(500)
			)

func add_x(rx: int) -> void:
	cur._x += rx
	if grid.has_collision(cur._x, cur._y, cur.get_shape()):
		cur._x -= rx

func add_y(ry: int) -> void:
	cur._y += ry
	var shape = cur.get_shape()
	if grid.has_collision(cur._x, cur._y, shape):
		cur._y -= 1
		fast_forward_disabled = true
		materialize(cur._x, cur._y, shape)
		hide_cursor()
		process_queue.append(func(): pause_until = TimeUtils.wait_for_ms(300))
		process_queue.append(func(): reset_cursor())


func add_r(rr: int) -> void:
	cur._rotation += rr
	if grid.has_collision(cur._x, cur._y, cur.get_shape()):
		cur._rotation -= rr

func screen_x(x: int) -> float:
	return x * size_scale

func screen_y(y: int) -> float:
	return y * size_scale
