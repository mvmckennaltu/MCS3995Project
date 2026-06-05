extends CharacterBody3D
@export var run_speed = 7
@export var gravity = 15
@export var jump_impulse = 10
@export var jump_buffer_time = 0.2
@export var player_max_health = 99
@export var player_turn_speed = 15.0
@onready var animation_tree = $Pivot/PlayerModel/AnimationTree
@onready var playback = animation_tree["parameters/playback"]
var current_target = null
var bullet = load("res://Player/bullet.tscn")
var control_locked = false
var player_health = 99
var target_velocity = Vector3.ZERO
var input_direction = Vector2.ZERO
var targets : Array[Node3D] = []
@onready var camera = get_node("/root/TestRoomRoot/CameraPivot/Camera3D")
enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	FALL,
	WALK
}

signal health_changed
signal change_crosshair
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
	if current_target != null:
		var screen_pos = camera.unproject_position(current_target.global_position)
		change_crosshair.emit(screen_pos)
	else:
		change_crosshair.emit(null)
	if Input.is_action_just_pressed("shoot") and not control_locked:
		var bullet_instance = bullet.instantiate()
		var spawn_pos = $Pivot/PlayerModel/ShootPoint.global_position
		bullet_instance.position = spawn_pos
		if current_target != null:
			var target_pos = current_target.global_position
			bullet_instance.direction = (target_pos - spawn_pos).normalized()
		else:
			bullet_instance.direction = $Pivot/PlayerModel/ShootPoint.global_basis.z
		get_parent().add_child(bullet_instance)
	if Input.is_action_just_pressed("switch_target_right"):
		var new_target = get_lateral_target(true)
		if new_target:
			current_target = new_target
	if Input.is_action_just_pressed("switch_target_left"):
		var new_target = get_lateral_target(false)
		if new_target:
			current_target = new_target
	if !is_instance_valid(current_target):
		current_target = get_closest_target()
func check_closest():
	current_target = get_closest_target()

	if current_target:
		print("Target:", current_target.name)
	else:
		print("No target")
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


func _on_targeting_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("targetable"):
		targets.append(body)
		check_closest()


func _on_targeting_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("targetable"):
		targets.erase(body)
		check_closest()
func get_closest_target():
	var closest = null
	var closest_distance = INF
	for target in targets:
		var distance = global_position.distance_to(target.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = target
	return closest
func get_lateral_target(go_right: bool):

	if current_target == null:
		return null
	var best_target = null
	var smallest_angle = INF
	var current_dir = current_target.global_position - global_position
	current_dir.y = 0
	current_dir = current_dir.normalized()
	for target in targets:
		if target == current_target:
			continue
		var reference_dir = camera.global_basis.z
		reference_dir.y = 0
		reference_dir = reference_dir.normalized()
		var target_dir = target.global_position - global_position
		var angle = reference_dir.signed_angle_to(target_dir,Vector3.UP)
		if go_right:
			if angle > 0 and angle < smallest_angle:
				smallest_angle = angle
				best_target = target
		else:
			if angle < 0 and abs(angle) < smallest_angle:
				smallest_angle = abs(angle)
				best_target = target
	return best_target
