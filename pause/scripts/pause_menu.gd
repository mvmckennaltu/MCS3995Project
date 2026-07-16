class_name pause_menu extends Control

@export var children : MarginContainer
@export var exitButton : Button
@export var resumeButton : Button
var ui_enabled : bool = false
var is_paused = false
@onready var scene_root = get_tree().current_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS 
	disableUI()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event):
	if event.is_action_pressed("pause"):
		if ui_enabled:
			disableUI()
			unpause()
		else:
			enableUI()
			pause()


func enableUI() -> void:
	ui_enabled = true
	get_tree().paused = true
	self.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func disableUI() -> void:
	ui_enabled = false
	get_tree().paused = false
	self.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func exitGame() -> void:
	get_tree().quit()


func _on_resume_pressed() -> void:
	ui_enabled = false
	disableUI()


func _on_exit_pressed() -> void:
	exitGame()


func _on_menu_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("uid://bsi4fqqdam1qu")


func pause() -> void:
	get_tree().paused = true
	is_paused = true
	
func unpause() -> void:
	get_tree().paused = false
	is_paused = false
