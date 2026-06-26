extends CharacterBody3D
@export var run_speed = 7
@export var gravity = 15
@export var jump_impulse = 10
@export var jump_buffer_time = 0.2
@export var player_max_health = 99
@export var player_turn_speed = 15.0
@export var infhealth = false
@onready var animation_tree = $Pivot/PlayerModel/AnimationTree
@onready var anim_player = $Pivot/PlayerModel/AnimationPlayer
@onready var playback = animation_tree["parameters/playback"]
@onready var shoot_point = $Pivot/PlayerModel/ShootPoint
@onready var current_checkpoint : Vector3
@onready var checkpoint_health = 99
@onready var pivot = $Pivot
var can_unmorph = true
var current_target = null
var bullet = load("uid://cuwyd17sil1h2")
var control_locked = false
var player_health = 99
var target_velocity = Vector3.ZERO
var input_direction = Vector2.ZERO
var targets : Array[Node3D] = []
@onready var camera = get_viewport().get_camera_3d()
enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	FALL,
	WALK,
	DAMAGE
}
enum FormState {
	NORMAL,
	BALL
}
signal health_changed
signal change_crosshair
var state = PlayerState.IDLE
var form = FormState.NORMAL
var direction = Vector3.ZERO
func _ready():
	pass
func _physics_process(delta):
	direction = Vector3.ZERO
	update_movement(delta)
	handle_targeting()
	handle_shooting()
	update_state()
	check_ball()
	if infhealth:
		player_health = player_max_health
		health_changed.emit(player_health)
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (gravity * delta)
	if is_on_floor() and Input.is_action_just_pressed("jump") and not control_locked:
		jump()
	health_changed.emit(player_health)
func check_closest():
	current_target = get_closest_target()
	# Debug output for targeting
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
	#Health cap
	if player_health > player_max_health:
		player_health = player_max_health
	if player_health < 0:
		die()
	elif change < 0:
		$EnemyCollider.set_deferred("monitoring", false)
		direction = Vector3.ZERO
		state = PlayerState.DAMAGE
		print(player_health)
		control_locked = true
		#Gets the damage animation for the timer
		var damage_anim = anim_player.get_animation("Player/damage")
		await get_tree().create_timer(damage_anim.length).timeout
		control_locked = false
		await get_tree().create_timer(0.5).timeout
		$EnemyCollider.set_deferred("monitoring", true)


func _on_area_3d_area_entered(area: Area3D) -> void:
	print("Collided")
	#Gets the parent node of the Area3D
	var source = area.get_parent()
	if source.has_method("get_damage"):
		on_hp_changed(source.get_damage())
	elif area.has_method("get_damage"):
		on_hp_changed(area.get_damage())
func die():
	#Ensures the checkpoint is the default value of Vector3.ZERO
	if current_checkpoint != Vector3.ZERO:
		control_locked = true
		velocity = Vector3.ZERO
		target_velocity = Vector3.ZERO
		await Fade.fade_out(1.0).finished
		self.global_position = current_checkpoint
		state = PlayerState.IDLE
		player_health = checkpoint_health
		await get_tree().physics_frame
		await Fade.fade_in(0.25).finished
		control_locked = false
	else:
		#Reloads current scene if the player doesn't have a valid checkpoint
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
	# Sets the default closest distance to infinite, to ensure the targets are always closer than the default
	var closest_distance = INF
	for target in targets:
		# Checks which target is closest to the player
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


func _on_checkpoint_entered_checkpoint(checkpoint_location) -> void:
	current_checkpoint = checkpoint_location
	if player_health > 0:
		checkpoint_health = player_health
	else:
		checkpoint_health = player_max_health
	print("Checkpoint! Location: ", current_checkpoint)

func enter_ball_mode() -> void:
	$Pivot/PlayerModel.visible = false
	$CollisionShape3D.set_deferred("disabled", true)
	$BallCollider.set_deferred("disabled", false)
	$Pivot/BallMode.visible = true
	form = FormState.BALL
	print("Ball Mode entered")
func update_movement(delta) -> void:
	direction = Vector3.ZERO
	if control_locked:
		return
	# We check for each move input and update the direction accordingly.

	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.15)
	direction.x = input_direction.x
	direction.z = input_direction.y
	
	if direction != Vector3.ZERO && control_locked == false:
			var facing_dir = direction.normalized()
			var target_basis = Basis.looking_at(facing_dir)
			pivot.basis = pivot.basis.slerp(target_basis, delta * player_turn_speed)
	# Ground Velocity
	target_velocity.x = direction.x * run_speed
	target_velocity.z = direction.z * run_speed
	if not control_locked:
		velocity = target_velocity
		move_and_slide()
func handle_targeting() -> void:
	if current_target != null:
		var screen_pos = camera.unproject_position(current_target.global_position)
		change_crosshair.emit(screen_pos)
	else:
		change_crosshair.emit(null)
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
func handle_shooting() -> void:
	if Input.is_action_just_pressed("shoot") and not control_locked and form == FormState.NORMAL:
		var bullet_instance = bullet.instantiate()
		var spawn_pos = shoot_point.global_position
		bullet_instance.position = spawn_pos
		if current_target != null:
			var target_pos = current_target.global_position
			
			bullet_instance.direction = (target_pos - spawn_pos).normalized()
		else:
			bullet_instance.direction = shoot_point.global_basis.z
		get_parent().add_child(bullet_instance)
func update_state():
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
			if control_locked == false:
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
		PlayerState.DAMAGE:
			playback.travel("Damage")
func exit_ball_mode():
	$Pivot/PlayerModel.visible = true
	$CollisionShape3D.set_deferred("disabled", false)
	$BallCollider.set_deferred("disabled", true)
	$Pivot/BallMode.visible = false
	form = FormState.NORMAL
	print("Ball Mode exited")
func check_ball():
	if !control_locked && Input.is_action_just_pressed("morph"):
		match form:
			FormState.NORMAL:
				enter_ball_mode()
			FormState.BALL:
				if $BallChecker.can_unmorph():
					exit_ball_mode()
