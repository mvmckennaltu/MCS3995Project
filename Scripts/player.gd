extends CharacterBody3D
@export var run_speed = 7
@export var gravity = 15
@export var jump_impulse = 10
@export var jump_buffer_time = 0.2
@export var player_max_health = 99
var player_health = 99
var target_velocity = Vector3.ZERO
var input_direction = Vector2.ZERO
enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	FALL
}
var state = PlayerState.IDLE
func _physics_process(delta):
	var direction = Vector3.ZERO
	# We check for each move input and update the direction accordingly.
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.15)
	direction.x = input_direction.x
	direction.z = input_direction.y
	if direction != Vector3.ZERO:
			var facing_dir = direction.normalized()
			$Pivot.basis = Basis.looking_at(facing_dir)
	# Ground Velocity
	target_velocity.x = direction.x * run_speed
	target_velocity.z = direction.z * run_speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (gravity * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		jump()
	if is_on_floor():
		if input_direction.length() > 0.1:
			state = PlayerState.RUN
		else:
			state = PlayerState.IDLE
		
	match state:
		PlayerState.IDLE:
			play_anim("Player/idle")
		PlayerState.RUN:
			play_anim("Player/running")
		PlayerState.FALL:
			play_anim("Player/idle")
func jump():
	target_velocity.y = jump_impulse
	state = PlayerState.JUMP
	play_anim("Player/jumpup")

func play_anim(anim_name):
	var anim = $Pivot/PlayerModel/AnimationPlayer
	if anim.current_animation != anim_name:
		anim.play(anim_name)
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Player/jumpup":
		state = PlayerState.FALL
