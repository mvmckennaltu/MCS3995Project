extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("uid://c31ipobv0fvba")




func _on_test_room_pressed() -> void:
	get_tree().change_scene_to_file("uid://c4tu16fkkqs1g")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("uid://dujys586sxf6y")


func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_file("uid://c4tu16fkkqs1g")
