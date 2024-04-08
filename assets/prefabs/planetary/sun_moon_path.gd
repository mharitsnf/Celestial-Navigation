class_name SunMoonPath extends Node3D

@export var rotation_per_frame: float = 5.
@export var mesh_instance: MeshInstance3D
var shader_mat: ShaderMaterial

func _enter_tree() -> void:
    shader_mat = mesh_instance.get_active_material(0)

func _ready() -> void:
    shader_mat.set_shader_parameter("cutoff", 0.)

func _process(delta: float) -> void:
    mesh_instance.rotate_y(delta * deg_to_rad(rotation_per_frame))

func _set_cutoff(value: float) -> void:
    shader_mat.set_shader_parameter("cutoff", value)

func show_path() -> void:
    var tween: Tween = create_tween()
    var from: float = shader_mat.get_shader_parameter("cutoff")
    tween.tween_method(_set_cutoff, from, 1., .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    await tween.finished

func hide_path() -> void:
    var tween: Tween = create_tween()
    var from: float = shader_mat.get_shader_parameter("cutoff")
    tween.tween_method(_set_cutoff, from, 0., .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    await tween.finished