class_name CameraMask extends ColorRect

@export var anim: AnimationPlayer
var shader_mat: ShaderMaterial

func _enter_tree() -> void:
    shader_mat = material

func _ready() -> void:
    shader_mat.set_shader_parameter("cutoff", 1)
    size = Vector2(2688, 1512)
    position = Vector2(-376, -216)

func to_camera_mask() -> void:
    var tween: Tween = create_tween()
    tween.tween_method(_set_cutoff_mask, 0., 1., .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func to_sextant_mask() -> void:
    var tween: Tween = create_tween()
    tween.tween_method(_set_cutoff_mask, 1., 0., .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func _set_cutoff_mask(value: float) -> void:
    shader_mat.set_shader_parameter("cutoff", value)

func show_mask() -> void:
    var tween: Tween = create_tween().set_parallel(true)
    tween.tween_property(self, "size", Vector2(1920, 1080), .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(self, "position", Vector2(0, 0), .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func hide_mask() -> void:
    var tween: Tween = create_tween().set_parallel(true)
    tween.tween_property(self, "size", Vector2(2688, 1512), .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(self, "position", Vector2(-376, -216), .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)