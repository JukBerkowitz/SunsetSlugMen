extends CharacterBody2D
@onready var anim: AnimatedSprite2D = $Player_Anim
@onready var collision_shape: CollisionShape2D = $Player_Collision
@onready var hit_box_collision_shape: CollisionShape2D = $Hitbox/HitBoxCollisionShape
@onready var left_wall_detector: RayCast2D = $LeftWallDetector
@onready var right_wall_detector: RayCast2D = $RightWallDetector



enum PlayerState{
		idle,
		walk,
		jump,
		fall,
		down_grade,
		slide,
		wall_slide,
		swimming,
		dead
	}

const JUMP_VELOCITY = -300.0

var status: PlayerState
var direction = 0
var jump_count = 0
var jump_by_wall = 70
var swimming_force = 70

@export var max_jump_count = 2
@export var max_speed = 180.0
@export var acceleration = 400
@export var deceleration = 400
@export var slide_deceleration = 100
@export var wall_acceleration = 40
@onready var reload_scene: Timer = $ReloadScene

func _ready() -> void:
	go_to_idle_state()
	set_defaut_collider()

func _physics_process(delta: float) -> void:
	match status:
		PlayerState.idle:
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.fall:
			fall_state(delta)
		PlayerState.down_grade:
			down_grade_state(delta)
		PlayerState.slide:
			slide_state(delta)
		PlayerState.wall_slide:
			wall_slide_state(delta)
		PlayerState.swimming:
			swimming_state(delta)
		PlayerState.dead:
			dead_state(delta)
	move_and_slide()
	
func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")
	
func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")
	
func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	if left_wall_detector.is_colliding():
		velocity.y = JUMP_VELOCITY
		velocity.x += jump_by_wall
	if right_wall_detector.is_colliding():
		velocity.y = JUMP_VELOCITY
		velocity.x -= jump_by_wall
	else:
		velocity.y = JUMP_VELOCITY
	jump_count += 1
	
func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall")
	
func go_to_down_grade_state():
	status = PlayerState.down_grade
	anim.play("down_grade")
	set_small_collider()	

func exit_from_down_grade_state():
	set_defaut_collider()

func go_to_wall_slide_state():
	status = PlayerState.wall_slide
	anim.play("wall_slide")
	velocity = Vector2.ZERO
	
func go_to_slide_state():
	status = PlayerState.slide
	anim.play("slide")
	set_small_collider()
	
func go_to_swimming_state():
	status = PlayerState.swimming
	anim.play("swimming")
	return
	
func go_to_dead_state():
	if status == PlayerState.dead:
		return
	status = PlayerState.dead
	anim.play("dead")
	velocity.x = 0
	reload_scene.start()
	
func exit_from_slide_state():
	set_defaut_collider()
	if is_on_floor():
		if velocity.x != 0:
			go_to_walk_state()
			return
		if velocity.x == 0 and Input.is_action_just_pressed("down_grade"):
			go_to_down_grade_state()
			return
		else:
			go_to_idle_state()
	else:
		go_to_fall_state()
		return
	
func idle_state(delta):
	apply_gravity(delta)
	move(delta)
	if velocity.x != 0:
		go_to_walk_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return		
	if Input.is_action_just_pressed("down_grade"):
		go_to_down_grade_state()
		return

func walk_state(delta):
	apply_gravity(delta)
	move(delta)
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return	
	if Input.is_action_just_pressed("down_grade"):
		go_to_slide_state()
		return
		
	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return
		
func jump_state(delta):
	apply_gravity(delta)
	move(delta)
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
	if velocity.y > 0:
		go_to_fall_state()
		return
	
func fall_state(delta):
	apply_gravity(delta)
	move(delta)
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
	if (left_wall_detector.is_colliding() or right_wall_detector.is_colliding()) && is_on_wall():
		go_to_wall_slide_state()
		return
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
			return
		else:
			go_to_walk_state()
			return
				
func down_grade_state(delta):
	apply_gravity(delta)
	if Input.is_action_just_released("down_grade") and velocity.x == 0:
		exit_from_down_grade_state()
		go_to_idle_state()
		return

func slide_state(delta):
	apply_gravity(delta)
	velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)
	if Input.is_action_just_released("down_grade") or velocity.x == 0:
		exit_from_slide_state()
	if Input.is_action_pressed("down_grade") and velocity.x == 0:
		go_to_down_grade_state()
		return
		
func wall_slide_state(delta):
	jump_count = 1
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
	if left_wall_detector.is_colliding():
		direction = 1
		anim.flip_h = false
	elif right_wall_detector.is_colliding():
		anim.flip_h = true
		direction = -1
	else:
		go_to_fall_state()
		return
	if is_on_floor():
		go_to_idle_state()
	velocity.y += wall_acceleration * delta

func swimming_state(delta):
	update_direction()
	
	if direction:
		velocity.x = move_toward(velocity.x, 100 * direction, 200 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, 200 * delta)
	var vertical_direction = Input.get_axis("jump","down_grade")
	if vertical_direction:
		velocity.y =  move_toward(velocity.y, 100 * vertical_direction, 200 * delta)
	else:
		velocity.y = move_toward(velocity.y, 0, 200 * delta)
	
func dead_state(delta):
	apply_gravity(delta)
	
func move(delta):
	update_direction()
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)

	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
func update_direction():
	direction = Input.get_axis("ui_left", "ui_right")
	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

func can_jump() -> bool:
	return jump_count < max_jump_count
	
func set_small_collider():
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3
	
	hit_box_collision_shape.shape.size.y = 10 
	hit_box_collision_shape.position.y = 3 
	
func set_defaut_collider():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0
	
	hit_box_collision_shape.shape.size.y = 15 
	hit_box_collision_shape.position.y = 1.5 

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		hit_letal_area()	
	

func hit_enemy(area: Area2D):
	if velocity.y > 0:
		area.get_parent().take_damage()
		go_to_jump_state()
	else:
		go_to_dead_state()
	
func hit_letal_area():
	go_to_dead_state()
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("LethalArea"):
		go_to_dead_state()
	elif body.is_in_group("Water"):
		go_to_swimming_state()
	
	
func _on_reload_scene_timeout() -> void:
	get_tree().reload_current_scene()
