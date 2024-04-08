class_name FPCSextant extends FPCType

var raycast: RayCast3D

func _ready() -> void:
    raycast = STUtil.get_only_node_in_group("first_person_raycast")

func process(_delta: float) -> void:
    _handle_calculate_latitude()

func _handle_calculate_latitude() -> void:
    if Input.is_action_just_pressed("calculate_latitude"):
        if !raycast:
            push_warning("Raycast is not found")
            return
        
        if !raycast.is_colliding(): return
        
        var pos: Vector3 = parent.get_follow_target().global_position
        var xz_pos: Vector3 = Vector3(pos.x, 0., pos.z)
        pos = pos.normalized()
        xz_pos = xz_pos.normalized()
        var dot_latitude: float = abs(xz_pos.dot(pos))
        var latitude: float = remap(dot_latitude, 0., 1., 90., 0.)
        latitude = latitude if pos.y >=0 else -latitude

        var collision_pos: Vector3 = raycast.get_collision_point()
        var xz_collision_pos: Vector3 = Vector3(collision_pos.x, 0., collision_pos.z)
        xz_collision_pos = xz_collision_pos.normalized()
        var dot_err: float = xz_pos.dot(xz_collision_pos)
        var err: float = remap(dot_err, -1, 1, 180., 0)
        print(latitude - err)