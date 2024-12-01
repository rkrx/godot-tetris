extends SceneTree

func _init() -> void:
	var cursor = TetrisCursor.new(Vector2(5, 0), TetrisCursor.CursorType.BLUE, 1)
	var leftmost_position = cursor.get_leftmost_position()
	print(leftmost_position)
	var rightmost_position = cursor.get_rightmost_position()
	print(rightmost_position)
	quit()
