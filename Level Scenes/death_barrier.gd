extends StaticBody3D
@export var damage = -999
var damage_type = "deathbarrier"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func get_damage():
	print("Player should die here")
	return damage

func get_damage_type():
	return damage_type
