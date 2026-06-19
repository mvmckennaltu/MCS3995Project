extends Node
var is_paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and !get_tree().paused:
		if not is_paused:
			pause()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func pause() -> void:
	get_tree().paused = true
	is_paused = true
	
func unpause() -> void:
	get_tree().paused = false
	is_paused = false
