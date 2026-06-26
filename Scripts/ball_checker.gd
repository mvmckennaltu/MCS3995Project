extends Area3D
var obstacles : Array[Node3D] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass






func can_unmorph() -> bool:
	return get_overlapping_bodies().is_empty()
