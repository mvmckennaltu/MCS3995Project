extends EnemyBase



@export var hand_damage = 25
@onready var hurtbox = $Pivot/EnemyModel/Skeleton3D/BoneAttachment3D/EnemyHurtBox
var sound_played = false
func update_idle(delta):
	velocity.x = 0
	velocity.z = 0
	if player:
		
		state = EnemyState.CHASE
		$SightPlayer.play()

func update_chase(delta):
	if player == null:
		state = EnemyState.IDLE
		return
	nav.target_position = player.global_position
	if nav.is_navigation_finished():
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
	if can_attack():
		state = EnemyState.ATTACK
		velocity.x = 0
		velocity.z = 0
		hurtbox.set_deferred("monitorable", true)
		$AttackPlayer.play()

func update_attack(delta):

	if player == null:
		state = EnemyState.IDLE
		hurtbox.set_deferred("monitorable", false)
		return
	if global_position.distance_to(player.global_position) > attack_range:
		state = EnemyState.CHASE
		hurtbox.set_deferred("monitorable", false)
		return

func can_attack() -> bool:
	return $EnemyHitbox.global_position.distance_to(player.global_position) <= attack_range
func _on_navigation_agent_3d_target_reached() -> void:
	state = EnemyState.ATTACK


func update_dying(delta):
	if sound_played == true:
		return
	else:
		$DiePlayer.play()
		sound_played = true

func get_damage():
	return hand_damage

func get_damage_type():
	return damage_type
