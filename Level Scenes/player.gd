extends CharacterBody3D
@export var run_speed = 7
@export var gravity = 15
@export var jump_impulse = 10
var target_velocity = Vector3.ZERO
var input_direction = Vector2.ZERO
func _physics_process(delta):
	var direction = Vector3.ZERO
	# We check for each move input and update the direction accordingly.
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction.x = input_direction.x
	direction.z = input_direction.y
	#if Input.is_action_pressed("move_right"):
		#direction.x += 1
	#if Input.is_action_pressed("move_left"):
		#direction.x -= 1
	#if Input.is_action_pressed("move_down"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		#direction.z += 1
	#if Input.is_action_pressed("move_up"):
		#direction.z -= 1
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Setting the basis property will affect the rotation of the node.
		$Pivot.basis = Basis.looking_at(direction)
	# Ground Velocity
	target_velocity.x = direction.x * run_speed
	target_velocity.z = direction.z * run_speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (gravity * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
	print("Input_direction " , direction.x," ", direction.z)
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
