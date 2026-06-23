extends Node3D
@export var health = 30

# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func get_damage():
	destroy_self()
	return health

func destroy_self():
	visible = false
	queue_free()
