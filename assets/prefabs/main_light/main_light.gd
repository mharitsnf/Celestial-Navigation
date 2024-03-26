class_name MainLight extends DirectionalLight3D

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

func _ready() -> void:
	pcm = STUtil.get_only_node_in_group("player_controller_manager")

func _process(_delta: float) -> void:
	_look_at_center()
	_adjust_energy_level()

func _look_at_center() -> void:
	look_at(Vector3.ZERO)

const SUNSET_ANGLE: float = -.25
const MAX_ENERGY_ANGLE: float = .8
func _adjust_energy_level() -> void:
	if !pcm: return
	var player_entity: BaseEntity = pcm.get_player_entity()
	if player_entity:
		var player_normal: Vector3 = player_entity.basis.y
		var dir_to_light: Vector3 = (global_position - player_entity.global_position).normalized()
		var ndotl: float = player_normal.dot(dir_to_light)
		ndotl = max(SUNSET_ANGLE, min(ndotl, MAX_ENERGY_ANGLE))
		ndotl = remap(ndotl, SUNSET_ANGLE, MAX_ENERGY_ANGLE, 0., 1.)

		light_energy = lerp(0., max_energy, ndotl)
		print(name, " ", light_energy)