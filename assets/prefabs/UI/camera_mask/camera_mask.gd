class_name CameraMask extends ColorRect

@export var anim: AnimationPlayer

func _ready() -> void:
    size = Vector2(2688, 1512)
    position = Vector2(-376, -216)

func show_mask() -> void:
    var tween: Tween = create_tween().set_parallel(true)
    tween.tween_property(self, "size", Vector2(1920, 1080), .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(self, "position", Vector2(0, 0), .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func hide_mask() -> void:
    var tween: Tween = create_tween().set_parallel(true)
    tween.tween_property(self, "size", Vector2(2688, 1512), .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(self, "position", Vector2(-376, -216), .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)