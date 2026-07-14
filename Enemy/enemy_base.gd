extends CharacterBody3D
class_name EnemyBase
var player : CharacterBody3D
enum EnemyState {
	CHASE,
	ATTACK,
	DAMAGE,
	DYING,
	IDLE
}
@onready var anim_player = $Pivot/EnemyModel/AnimationPlayer
@onready var animation_tree = $Pivot/EnemyModel/AnimationTree
@onready var nav = $NavigationAgent3D
@export var max_health = 150
@export var move_speed := 4.0
@export var attack_range := 6.0
@export var idle_animation = "Idle"
@export var run_animation = "Run"
@export var attack_animation = "Attack"
@export var death_animation = "Die"
var damage_type = "enemy"
signal died
var dying_started = false
var state : EnemyState = EnemyState.IDLE
@onready var playback = animation_tree["parameters/playback"]
var health = max_health
var spawn_position

func _ready():
	spawn_position = global_position
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if !is_on_floor() or !state == EnemyState.DYING:
		velocity += get_gravity() * delta
	match state:
		EnemyState.IDLE:
			update_idle(delta)
		EnemyState.CHASE:
			update_chase(delta)
		EnemyState.ATTACK:
			update_attack(delta)
		EnemyState.DAMAGE:
			update_damage(delta)
		EnemyState.DYING:
			update_dying(delta)
	play_state_animation()
	move_and_slide()
func damage(amount):
	health = health - amount
	print(health)
	if health <= 0:
		die()
	else:
		state = EnemyState.DAMAGE
		



func _on_sight_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") && state != EnemyState.DYING:
		player = body
		state = EnemyState.CHASE
func update_chase(delta):
	pass
func update_idle(delta):
	velocity.x = 0
	velocity.z = 0
	if player:
		$RayCast3D.look_at(player.global_position)
		if $RayCast3D.get_collider() == player:
			state = EnemyState.CHASE
func update_attack(delta):
	pass
func update_damage(delta):
	pass
func update_dying(delta):
	pass
	
func play_state_animation():
	match state:
		EnemyState.IDLE:
			playback.travel(idle_animation)
		EnemyState.CHASE:
			playback.travel(run_animation)
		EnemyState.ATTACK:
			playback.travel(attack_animation)
		EnemyState.DYING:
			playback.travel(death_animation)


func _on_sight_range_body_exited(body: Node3D) -> void:
	if body == player:
		player = null
		state = EnemyState.IDLE

func _on_enemy_hitbox_area_entered(area: Area3D) -> void:
	print("area entered")
	if area.is_in_group("bullet"):
		var source = area.get_parent()
		if source.has_method("get_bullet_damage"):
			damage(source.get_bullet_damage())
			source.queue_free()

func die():
	if state == EnemyState.DYING:
		state = EnemyState.DYING
	set_collision_layer_value(2, false)
	state = EnemyState.DYING
	$EnemyHitbox.set_collision_mask_value(1,false)
	$EnemyHitbox/CollisionShape3D2.disabled = true
	self.set_collision_mask_value(1,false)
	velocity = Vector3.ZERO
	nav.target_position = global_position
	died.emit(self)
	remove_from_group("targetable")
	player = null

	
	await get_tree().create_timer(5.0).timeout
	queue_free()
	

	
