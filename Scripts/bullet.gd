extends Node3D

@export var bullet_speed = 40.0
@export var max_distance = 150.0
var direction = Vector3.FORWARD
var start_position : Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = global_position # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	global_position += direction * bullet_speed * delta
	if global_position.distance_to(start_position) > max_distance:
		queue_free()


func _on_area_3d_body_entered(_body: Node3D) -> void:
	queue_free()
