extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.





func _on_player_change_crosshair(target_spot):
	if target_spot != null:
		self.global_position = target_spot
		self.visible = true
	else:
		self.visible = false
