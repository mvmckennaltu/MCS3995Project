extends MeshInstance3D
var material = get_surface_override_material(0)
@export var override_color = Color(0.0,0,0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.albedo_color = Color(override_color) # Replace with function body.
