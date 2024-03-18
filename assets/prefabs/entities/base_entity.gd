class_name BaseEntity extends RigidBody3D

@export var visual_node : Node3D

func _calculate_gerstner(wave_data : Vector4, vertex : Vector3) -> Array[Vector3]:
    var steepness : float = wave_data.x
    var wavelength : float = wave_data.y
    var direction : Vector2 = Vector2(wave_data.z, wave_data.w)

    var k : float = 2. * PI / wavelength;
    var c : float = sqrt(9.8 / k);
    var d : Vector2 = direction.normalized();
    # var f : float = k * (d.dot(Vector2(vertex.x, vertex.z)) - (ocean_plane.elapsed_time * c * ocean_plane.speed))
    var f : float = k * (d.dot(Vector2(vertex.x, vertex.z)) - (c))
    var a : float = steepness / k

    var d_tangent : Vector3 = Vector3(
        - d.x * d.x * (steepness * sin(f)),
        d.x * (steepness * cos(f)), 
        - d.x * d.y * (steepness * sin(f))
    )

    var d_binormal : Vector3 = Vector3(
        - d.x * d.y * (steepness * sin(f)),
        d.y * (steepness * cos(f)),
        - d.y * d.y * (steepness * sin(f))
    )

    var d_vert : Vector3 = Vector3(
        d.x * (a * cos(f)),
        a * sin(f),
        d.y * (a * cos(f))
    )

    return [d_vert, d_tangent, d_binormal]