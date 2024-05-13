class_name HardLookVCC extends VirtualCameraController

@export var offset: Vector3
@export_range(0., 360., .1) var y_rotation_offset: float
@export var reference_node: Node3D

func process(_delta: float) -> void:
    _set_rotation()

func _set_rotation() -> void:
    (parent as ThirdPersonCamera).spring_arm.position = offset
    (parent as ThirdPersonCamera).y_gimbal.rotation.y = reference_node.rotation.y + deg_to_rad(y_rotation_offset)