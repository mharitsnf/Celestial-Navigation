class_name ThirdPersonCamera extends VirtualCamera

@export_group("Positioning")
@export var lerp_weight : float = 10
@export var _spring_length : float = 5
@export var _offset : Vector3 = Vector3.ZERO
@export_group("References")
@export var offset_node : Node3D
@export var gimbal : Node3D
@export var spring_arm : SpringArm3D

func _process(delta: float) -> void:
	super(delta)
	_lerp_spring_length(delta)
	_lerp_height_offset(delta)

func _lerp_spring_length(delta: float) -> void:
	spring_arm.spring_length = lerp(spring_arm.spring_length, _spring_length, lerp_weight * delta)

func _lerp_height_offset(delta: float) -> void:
	offset_node.position = lerp(offset_node.position, _offset, lerp_weight * delta)

func rotate_camera(direction : Vector2) -> void:
	gimbal.rotate_object_local(Vector3.UP, direction.x * rotation_speed)
	spring_arm.rotate_object_local(Vector3.RIGHT, direction.y * rotation_speed)
	var min_angle: float = default_angle.x if !is_submerged() else submerged_angle.x
	var max_angle: float = default_angle.y if !is_submerged() else submerged_angle.y
	spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, min_angle, max_angle)

func get_x_rotation() -> float:
	return gimbal.rotation.y

func get_y_rotation() -> float:
	return spring_arm.rotation.x

func copy_rotation(x_rotation: float, y_rotation: float) -> void:
	gimbal.rotation.y = x_rotation
	spring_arm.rotation.x = y_rotation
	var min_angle: float = default_angle.x if !is_submerged() else submerged_angle.x
	var max_angle: float = default_angle.y if !is_submerged() else submerged_angle.y
	spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, min_angle, max_angle)