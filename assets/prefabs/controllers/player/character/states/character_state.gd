class_name CharacterState extends State

var tpc: ThirdPersonCamera
var fpc: FirstPersonCamera
var main_camera: MainCamera
var character: CharacterEntity

func _enter_tree() -> void:
    super()
    character = get_parent().get_parent()

func _ready() -> void:
    tpc = STUtil.get_node_in_group_by_name(String(character.get_path()) + "/VCs", "TPC")
    fpc = STUtil.get_node_in_group_by_name(String(character.get_path()) + "/VCs", "FPC")
    main_camera = STUtil.get_only_node_in_group("main_camera")

func _get_move_direction() -> Vector2:
    return Input.get_vector("character_left", "character_right", "character_forward", "character_backward")