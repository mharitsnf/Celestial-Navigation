class_name BoatWave extends Node3D

@export var boat: BoatEntity

func _process(_delta: float) -> void:
	_adjust_scale()

func _adjust_scale() -> void:
	var max_speed: float = boat.speed_limit
	var current_speed: float = boat.linear_velocity.length()
	var new_scale: float = remap(current_speed, 0., max_speed, 0., 1.)
	scale = Vector3(new_scale,new_scale,new_scale)
