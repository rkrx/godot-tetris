extends Node2D

@export var expl: CPUParticles2D

func show_at(x: int, y: int, w: int, h: int):
	expl.position.x = x
	expl.position.y = y
	expl.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	expl.emission_rect_extents = Vector2(w, h)
	print("Extends w: %.2f, h: %.2f" % [w, h])
	expl.emitting = true
	expl.one_shot = true

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
