extends AnimatableBody2D
@onready var target: Sprite2D = $Target

@export var speed_platform = 3

func _ready() -> void:
	
	target.visible = false
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", target.global_position, speed_platform)
	tween.tween_property(self, "global_position", global_position, speed_platform)
	tween.set_loops()
