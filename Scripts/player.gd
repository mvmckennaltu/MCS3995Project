extends CharacterBody3D
@export var run_speed = 7
@export var gravity = 15
@export var jump_impulse = 10
@export var jump_buffer_time = 0.2
@export var player_max_health = 99
@export var player_turn_speed = 15.0
@onready var animation_tree = $Pivot/PlayerModel/AnimationTree
@onready var playback = animation_tree["parameters/playback"]
var control_locked = false
var player_health = 99
var target_velocity = Vector3.ZERO
var input_direction = Vector2.ZERO
enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	FALL,
	WALK
}

signal health_changed
var state = PlayerState.IDLE
func _physics_process(delta):
	var direction = Vector3.ZERO
	# We check for each move input and update the direction accordingly.
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.15)
	direction.x = input_direction.x
	direction.z = input_direction.y
	if direction != Vector3.ZERO:
			var facing_dir = direction.normalized()
			var target_basis = Basis.looking_at(facing_dir)
			$Pivot.basis = $Pivot.basis.slerp(target_basis, delta * player_turn_speed)
	# Ground Velocity
	target_velocity.x = direction.x * run_speed
	target_velocity.z = direction.z * run_speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (gravity * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
	
	if is_on_floor() and Input.is_action_just_pressed("jump") and not control_locked:
		jump()
	if not is_on_floor():
		if velocity.y > 0:
			state = PlayerState.JUMP
		else:
			state = PlayerState.FALL
	else:
		if input_direction.length() > 0.5:
			state = PlayerState.RUN
		elif input_direction.length() < 0.001:
			state = PlayerState.IDLE
		else:
			state = PlayerState.WALK
		
	match state:
		PlayerState.IDLE:
			playback.travel("Idle")
		PlayerState.RUN:
			playback.travel("Run")
		PlayerState.JUMP:
			playback.travel("Jump")
		PlayerState.FALL:
			playback.travel("Fall")
		PlayerState.WALK:
			playback.travel("Walk")
			
func jump():
	target_velocity.y = jump_impulse
	state = PlayerState.JUMP

func on_hp_changed(change):
	print("Damage Emitted!")
	player_health = (player_health + change)
	print(player_health)
	health_changed.emit(player_health)
	if player_health < 0:
		die()
	if player_health > player_max_health:
		player_health = player_max_health


func _on_area_3d_area_entered(area: Area3D) -> void:
	print("Collided") # Replace with function body.
	var source = area.get_parent()
	if source.has_method("get_damage"):
		on_hp_changed(source.get_damage())
func die():
	get_tree().reload_current_scene()
