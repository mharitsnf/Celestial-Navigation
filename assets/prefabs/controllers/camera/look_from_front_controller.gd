class_name LookFromFrontVCC extends VirtualCameraController

@export var offset: Vector3
@export var reference_node: Node3D

func enter_camera() -> void:
    (parent as ThirdPersonCamera).spring_arm.position = offset
    (parent as ThirdPersonCamera).y_gimbal.rotation.y = reference_node.rotation.y + PI