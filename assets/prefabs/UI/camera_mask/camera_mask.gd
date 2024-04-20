class_name CameraMask extends ColorRect

@export var anim: AnimationPlayer
var shader_mat: ShaderMaterial

var hidden_scale: Vector2 = Vector2(1.5, 1.5)

func _enter_tree() -> void:
    shader_mat = material

func _ready() -> void:
    visible = false
    shader_mat.set_shader_parameter("cutoff", 1)
    pivot_offset = size / 2
    scale = hidden_scale

func to_camera_mask() -> STUtil.Promise:
    var this_tween: Tween = create_tween()
    var from: float = shader_mat.get_shader_parameter("cutoff")
    this_tween.tween_method(_set_cutoff_mask, from, 1., .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    await this_tween.finished
    return STUtil.Promise.new()

func to_sextant_mask() -> STUtil.Promise:
    var this_tween: Tween = create_tween()
    var from: float = shader_mat.get_shader_parameter("cutoff")
    this_tween.tween_method(_set_cutoff_mask, from, 0., .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    await this_tween.finished
    return STUtil.Promise.new()

func _set_cutoff_mask(value: float) -> void:
    shader_mat.set_shader_parameter("cutoff", value)

func show_mask() -> void:
    visible = true
    var tween: Tween = create_tween().set_parallel(true)
    tween.tween_property(self, "scale", Vector2.ONE, .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func hide_mask() -> void:
    var tween: Tween = create_tween().set_parallel(true)
    tween.tween_property(self, "scale", hidden_scale, .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    await tween.finished
    visible = false