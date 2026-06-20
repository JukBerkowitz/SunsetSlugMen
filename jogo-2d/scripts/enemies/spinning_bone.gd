extends Area2D

var speed = 100
var direction = 1

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta: float) -> void:
	position.x += speed * delta * direction

func set_direction(skeleton_direction):
	self.direction = skeleton_direction
	if direction < 0:
		anim.flip_h = true
		


func _on_self_destruct_timeout() -> void:
	queue_free()


func _on_area_entered(_area: Area2D) -> void:
	queue_free()


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
