class_name CharacterEntity extends BaseEntity

@export var rotation_speed : float = 1
@export var speed_limit : float = 20
@export var move_force : float = 1

func move(direction: Vector2) -> void:
    var move_dir: Vector3 = visual_container.basis.z * direction.y + visual_container.basis.x * direction.x
    move_dir.normalized()
    apply_force(move_dir * move_force)