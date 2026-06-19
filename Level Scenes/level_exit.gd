extends Node3D
@export var teleport_level : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area3D.body_entered.connect(_on_area_3d_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("collected!")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file(teleport_level)
		
