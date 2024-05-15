class_name MainLightManager extends Node3D

var time_manager: TimeManager

const SECONDS_PER_DAY: float = 86400.
const SECONDS_PER_LONG_ANGLE: float = 240.

func _ready() -> void:
	time_manager = STUtil.get_only_node_in_group("time_manager")

func _process(delta: float) -> void:
	_rotate_per_time(delta)

func _rotate_per_time(_delta: float) -> void:
	rotation_degrees.y = remap(time_manager.get_time_elapsed(), 0., SECONDS_PER_DAY, 360, 0)