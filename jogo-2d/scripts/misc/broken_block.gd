extends StaticBody2D

@onready var area_2D: Area2D = $Area2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var broken_timer: Timer = $BrokenTimer
@onready var reset: Timer = $Reset
@onready var collision_body: CollisionShape2D = $CollisionBody
@onready var collision_area: CollisionShape2D = $Area2D/CollisionArea

var is_broken = false
var start_position: Vector2

func _ready() -> void:
	start_position = global_position

func _process(_delta: float) -> void:
	if is_broken:
		return
	var bodies = area_2D.get_overlapping_bodies()
	for body in bodies:
		var player: CharacterBody2D = body
		if player.is_on_floor():
			is_broken = true
			anim.play("broken")
			broken_timer.start()


func _on_broken_timer_timeout() -> void:
	anim.play("falling")
	collision_body.disabled = true
	collision_area.disabled = true
	var final_position = global_position + Vector2.DOWN * 40
	var fall_tween = create_tween()
	fall_tween.set_trans(Tween.TRANS_QUAD)
	fall_tween.set_ease(Tween.EASE_IN)
	fall_tween.tween_property(self, "global_position", final_position, .5)
	
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(anim, "modulate:a", 0, 0.5)
	reset.start()

func _on_reset_timeout() -> void:
	is_broken = false
	anim.play("default")
	print(collision_layer)
	global_position = start_position
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(anim, "modulate:a", 1, .5)
	collision_body.disabled = false
	collision_area.disabled = false
	print(collision_layer)
