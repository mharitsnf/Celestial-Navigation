class_name FirstPersonCamera extends VirtualCamera

@export_group("Positioning")
@export var lerp_weight : float = 10
@export var _offset : Vector3
@export_group("References")
@export var offset_node : Node3D # Offset placement node
@export var gimbal : Node3D # For rotation in local Y
@export var inner_gimbal : Node3D # For rotation in local X

func _ready() -> void:
    super()

func _process(delta: float) -> void:
    super(delta)
    _lerp_gimbal_position(delta)

func _lerp_gimbal_position(delta: float) -> void:
    offset_node.position = lerp(offset_node.position, _offset, lerp_weight * delta)

func rotate_camera(direction : Vector2, min_angle: float = min_x_angle) -> void:
    direction *= -1.
    gimbal.rotate_object_local(Vector3.UP, direction.x * rotation_speed)
    inner_gimbal.rotate_object_local(Vector3.RIGHT, direction.y * rotation_speed)
    inner_gimbal.rotation_degrees.x = clamp(
        inner_gimbal.rotation_degrees.x,
        min_angle,
        max_x_angle
    )