extends EnemyBase


@onready var hurtbox = $Hurtbox
@export var patrol_a : Node3D
@export var patrol_b : Node3D
@export var attack_damage = -25
@onready var sight_player = $SightPlayer
@onready var die_player = $DiePlayer
var sound_played = false
var chosen_target : String
var patrol_target_position : Vector3
signal searching
func _ready():
	animation_tree = $AnimationTree
	anim_player = $AnimationPlayer
	nav = $NavigationAgent3D
	playback = null
	damage_type = "enemy"
	if patrol_a != null:
		patrol_target_position = patrol_a.global_position
		chosen_target = "A"
func update_idle(delta):
	if state == EnemyState.DYING:
		velocity = Vector3.ZERO
		return
	if patrol_a && patrol_b != null:
		var patrol_a_distance = (patrol_a.global_position - global_position)
		var patrol_b_distance = (patrol_b.global_position - global_position)
		if nav.is_navigation_finished():
			
			if chosen_target == "B":
				velocity.x = 0
				velocity.y = 0
				await get_tree().create_timer(1.25).timeout
				nav.target_position = patrol_a.global_position
				chosen_target = "A"
			else: 
				velocity.x = 0
				velocity.z = 0
				await get_tree().create_timer(1.25).timeout
				nav.target_position = patrol_b.global_position
				chosen_target = "B"
	var next = nav.get_next_path_position()
	var direction = next - global_position
	direction.y = 0
	if direction.length() > 0.01:
		look_at(global_position - direction, Vector3.UP)
	direction = direction.normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	if player:
		state = EnemyState.CHASE

func update_chase(delta):
	print("chasing")
	if player == null:
		print("player is null")
		state = EnemyState.IDLE
		return
	nav.target_position = player.global_position
	if nav.is_navigation_finished():
		print("nav finished")
		velocity.x = 0
		velocity.z = 0
		return
	var next = nav.get_next_path_position()
	var direction = next - global_position
	direction.y = 0
	if direction.length() > 0.01:
		look_at(global_position - direction, Vector3.UP)
	direction = direction.normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	#if can_attack():
		#state = EnemyState.ATTACK
		#velocity.x = 0
		#velocity.z = 0
		#hurtbox.set_deferred("monitorable", true)

func update_attack(delta):
	pass
	#print("attempting to attack")
	#if player == null:
		#state = EnemyState.IDLE
		#hurtbox.set_deferred("monitorable", false)
		#return
	#if global_position.distance_to(player.global_position) > attack_range:
		#state = EnemyState.CHASE
		#hurtbox.set_deferred("monitorable", false)
		#return

#func can_attack() -> bool:
	#return $EnemyHitbox.global_position.distance_to(player.global_position) <= attack_range
func _on_navigation_agent_3d_target_reached() -> void:
	state = EnemyState.ATTACK


func play_state_animation():
	pass

func get_damage():
	return attack_damage

func get_damage_type():
	return damage_type
func update_dying(delta):
	if sound_played == true:
		return
	else:
		die_player.play()
		sound_played = true
