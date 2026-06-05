extends Label

var health_display = 99
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_player_health_changed(health):
	health_display = health
	text = "Health: %s" % health_display
	if health < 0:
		text = "Life Support System Failure"
