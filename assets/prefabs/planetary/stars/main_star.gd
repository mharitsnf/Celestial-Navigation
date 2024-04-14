class_name MainStar extends Area3D

@export_group("References")
@export var sprite : Sprite3D

var _pulsating : bool = false
var _pulsating_speed : float = -1.
var _alpha_range : Vector2 = Vector2(0, 1)
var _color : Color = Color(1,1,1)

var sun: MainLight

func _ready() -> void:
	_init_sun()

func _process(_delta: float) -> void:
	_init_sun()
	sprite.modulate.a = lerp(0., 1., sun.get_star_visibility_weight())

func _init_sun() -> void:
	if !sun:
		sun = STUtil.get_only_node_in_group("sun")

func is_pulsating() -> bool:
	return _pulsating

func set_pulsating(value : bool) -> void:
	_pulsating = value

	if value:
		_pulsating_speed = 1.
	else:
		_pulsating_speed = -1.
		sprite.modulate.a = 1

func get_alpha_range() -> Vector2:
	return _alpha_range

func set_alpha_range(new_range : Vector2) -> void:
	_alpha_range = new_range

func get_pulsating_speed() -> float:
	return _pulsating_speed

func set_pulsating_speed(value : float) -> void:
	_pulsating_speed = value

func get_color() -> Color:
	return _color

func set_color(new_color : Color) -> void:
	_color = new_color
	sprite.modulate = new_color

func load_data(data : Dictionary) -> void:
	global_position = Vector3(
		data.np_x, data.np_y, data.np_z,
	) * data.distance_from_center
	set_pulsating(data.is_pulsating)
	set_pulsating_speed(data.pulsating_speed)
	set_alpha_range(Vector2(data.alpha_min, data.alpha_max))
	set_color(Color(data.color_r, data.color_g, data.color_b, 1))
