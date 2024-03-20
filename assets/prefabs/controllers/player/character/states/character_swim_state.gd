class_name CharacterSwimState extends CharacterState

func process(_delta: float) -> void:
	var _move_dir: Vector2 = _get_move_direction()
	character.move(_move_dir)
