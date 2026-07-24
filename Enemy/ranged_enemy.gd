extends EnemyBase
@export var preferred_distance := 10.0
@export var min_distance := 7.0
@export var max_distance := 20.0
@onready var bullet = load("uid://b5gulnbuw3xj7")
@onready var shoot_point = $Pivot/EnemyModel/ShootPoint
@export var attack_cooldown := 1.5
var sound_played = false
var can_attack := true
var distance
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_idle(delta):
	velocity.x = 0
	velocity.z = 0
	if player:
		$SightPlayer.play()
		state = EnemyState.CHASE

func update_chase(delta):
	if !player:
		state = EnemyState.IDLE
		return
	nav.target_position = player.global_position
	var away = (global_position - player.global_position).normalized()
	var retreat_position = player.global_position + away * preferred_distance
	nav.target_position = retreat_position
	var next = nav.get_next_path_position()
	var direction = next - global_position
	direction.y = 0
	if direction.length() > 0.01:
		look_at(global_position + direction, Vector3.UP)
	direction = direction.normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	if nav.is_navigation_finished():
		velocity = Vector3.ZERO
		state = EnemyState.ATTACK


func update_attack(delta):
	shoot()
	
func update_dying(delta):
	if sound_played == true:
		return
	else:
		$DiePlayer.play()
		sound_played = true
func shoot():
	if !can_attack:
		return
	var direction = player.global_position - global_position
	direction.y = 0
	if direction.length() > 0.01:
		look_at(global_position - direction, Vector3.UP)
	print("shooting")
	can_attack = false
	var bullet_instance = bullet.instantiate()
	var spawn_pos = shoot_point.global_position
	bullet_instance.position = spawn_pos
	var target_pos = player.get_node("LockOnPoint").global_position
	bullet_instance.direction = (target_pos - spawn_pos).normalized()
	get_parent().add_child(bullet_instance)
	$ShootPlayer.play()
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	if direction.length() < preferred_distance:
		state = EnemyState.CHASE
