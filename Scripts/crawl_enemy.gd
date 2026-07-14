extends EnemyBase


@onready var hurtbox = $Hurtbox
@export var patrol_a : Node3D
@export var patrol_b : Node3D
@export var attack_damage = -25
var patrol_target_position : Vector3
signal searching
func _ready():
	animation_tree = $AnimationTree
	anim_player = $AnimationPlayer
	nav = $NavigationAgent3D
	playback = null
	damage_type = "enemy"
	patrol_target_position = patrol_a.global_position
func update_idle(delta):
	
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
