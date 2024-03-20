class_name CharacterState extends State

var character: CharacterEntity

func _enter_tree() -> void:
    super()
    character = get_parent().get_parent()

func _get_move_direction() -> Vector2:
    return Input.get_vector("character_left", "character_right", "character_forward", "character_backward")