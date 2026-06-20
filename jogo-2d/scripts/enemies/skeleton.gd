extends CharacterBody2D

enum SkeletonState{
	walk,
	attack,
	dead
}

const SPINNING_BONE = preload("uid://bgcw24wljo5v0")


@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box : Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector

const SPEED = 6.0
const JUMP_VELOCITY = -400.0

var atual_state = SkeletonState
var direction = 1
var bone_qnt = 1

func _ready() -> void:
	go_to_walk_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match atual_state:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.attack:
			attack_state(delta)
		SkeletonState.dead:
			dead_state(delta)

	move_and_slide()
	if atual_state == SkeletonState.attack:
		if anim.frame == 2 and bone_qnt >= 1:
			throw_bone()

func go_to_walk_state():
	atual_state = SkeletonState.walk
	anim.play("walk")
	
func go_to_attack_state():
	bone_qnt = 1
	atual_state = SkeletonState.attack
	anim.play("attack")
	velocity = Vector2.ZERO
	
func go_to_dead_state():
	atual_state = SkeletonState.dead
	anim.play("dead")
	hit_box.process_mode = Node.PROCESS_MODE_DISABLED

func walk_state(_delta):
	if anim.frame == 3 or anim.frame == 4:
		velocity.x = SPEED * direction
	else:
		velocity.x = 0
	if wall_detector.is_colliding() or !ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1
	if player_detector.is_colliding():
		go_to_attack_state()
		return
		
func attack_state(_delta):
	pass
		
func dead_state(_delta):
	pass
	
func take_damage():
	velocity.x = 0
	go_to_dead_state()

func throw_bone():
	bone_qnt = 0
	var new_bone = SPINNING_BONE.instantiate()
	add_sibling(new_bone)
	new_bone.set_direction(self.direction)
	new_bone.position = Vector2(self.position.x + 7, self.position.y - 12)
		
func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		go_to_walk_state()
		return
