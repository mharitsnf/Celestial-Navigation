class_name MainLight extends DirectionalLight3D

@export var default_max_shadow_distance: float = 100.
@export var sundial_max_shadow_distance: float = 5.
@export var max_energy: float = 1.
@export var sprite_modulation: Color = Color.WHITE:
	set(value):
		sprite_modulation = value
		if sprite: sprite.modulate = value
@export var sprite_scale: float = 50.:
	set(value):
		sprite_scale = value
		if sprite: sprite.scale = Vector3(value, value, value)
@export_group("References")
@export var sprite: Sprite3D

var pcm: PlayerControllerManager
var main_camera: MainCamera

func _ready() -> void:
	pcm = STUtil.get_only_node_in_group("player_controller_manager")
	main_camera = STUtil.get_only_node_in_group("main_camera")

	# Connect signal
	if main_camera and !main_camera.follow_target_changed.is_connected(_on_main_camera_follow_target_changed):
		main_camera.follow_target_changed.connect(_on_main_camera_follow_target_changed)

func _process(_delta: float) -> void:
	_refetch_main_camera()
	_refetch_player_controller_manager()

	_look_at_center()
	_adjust_energy_level()

func _look_at_center() -> void:
	look_at(Vector3.ZERO)

func _refetch_main_camera() -> void:
	if !main_camera:
		push_warning("main_camera is missing. Searching again...")
		main_camera = STUtil.get_only_node_in_group("main_camera")
		if main_camera and !main_camera.follow_target_changed.is_connected(_on_main_camera_follow_target_changed):
			main_camera.follow_target_changed.connect(_on_main_camera_follow_target_changed)

		var current_target: VirtualCamera = main_camera.get_follow_target()
		if STUtil.is_node_in_group(current_target, "sundial_vc") and directional_shadow_max_distance != sundial_max_shadow_distance:
			directional_shadow_max_distance = sundial_max_shadow_distance

func _refetch_player_controller_manager() -> void:
	if !pcm:
		push_warning("player_controller_manager not found. Searching again...")
		pcm = STUtil.get_only_node_in_group("player_controller_manager")
		return

const SUNSET_ANGLE: float = -.25
const MAX_ENERGY_ANGLE: float = .8
func _adjust_energy_level() -> void:
	if !pcm: return
	var player_entity: Node3D = pcm.get_player_entity()
	if player_entity:
		var player_normal: Vector3 = player_entity.basis.y
		var dir_to_light: Vector3 = (global_position - player_entity.global_position).normalized()
		var ndotl: float = player_normal.dot(dir_to_light)
		ndotl = max(SUNSET_ANGLE, min(ndotl, MAX_ENERGY_ANGLE))
		ndotl = remap(ndotl, SUNSET_ANGLE, MAX_ENERGY_ANGLE, 0., 1.)

		light_energy = lerp(0., max_energy, ndotl)

func _on_main_camera_follow_target_changed(target: VirtualCamera) -> void:
	if STUtil.is_node_in_group(target, "sundial_vc") and directional_shadow_max_distance != sundial_max_shadow_distance:
		var tween: Tween = create_tween()
		tween.tween_property(self, "directional_shadow_max_distance", sundial_max_shadow_distance, .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	elif !STUtil.is_node_in_group(target, "sundial_vc") and directional_shadow_max_distance != default_max_shadow_distance:
		var tween: Tween = create_tween()
		tween.tween_property(self, "directional_shadow_max_distance", default_max_shadow_distance, .75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)