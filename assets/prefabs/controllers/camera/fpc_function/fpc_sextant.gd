class_name FPCSextant extends FPCFunction

@export var error_range: float = 3.
var raycast: RayCast3D

func _ready() -> void:
    raycast = STUtil.get_only_node_in_group("first_person_raycast")

func process(_delta: float) -> void:
    _handle_calculate_latitude()

func _handle_calculate_latitude() -> void:
    if Input.is_action_pressed("calculate_latitude"):
        if !raycast:
            push_warning("Raycast is not found")
            return
        
        if !raycast.is_colliding(): return
        
        # Calculate true latitude
        var latitude: float = STUtil.get_lat_long(parent.get_follow_target().global_position).latitude

        # Calculate angle error
        var pos: Vector3 = parent.get_follow_target().global_position
        var xz_pos: Vector3 = Vector3(pos.x, 0., pos.z)
        pos = pos.normalized()
        xz_pos = xz_pos.normalized()
        var collision_pos: Vector3 = raycast.get_collision_point()
        var xz_collision_pos: Vector3 = Vector3(collision_pos.x, 0., collision_pos.z)
        xz_collision_pos = xz_collision_pos.normalized()
        var dot_err: float = xz_pos.dot(xz_collision_pos)
        var err: float = remap(dot_err, -1, 1, 180., 0)
        
        # Find final latitude
        var adjusted_lat: float = latitude - err
        var final_error: float = randf_range(-error_range, error_range)
        var final_lat: float = snappedf(adjusted_lat + final_error, .01)
        print(final_lat)