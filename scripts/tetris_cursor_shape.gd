class_name TetrisCursorShape

var _kind: TetrisCursor.Kind
var _parts: Array

func _init(kind: TetrisCursor.Kind, parts: Array):
	self._parts = parts
	self._kind = kind
	
func get_kind() -> TetrisCursor.Kind:
	return _kind
	
func get_parts() -> Array:
	return _parts
