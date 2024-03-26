extends Node3D

@export var time_speed: float = 1.
var time_elapsed: float = 0.

const SECONDS_PER_DAY: float = 86400.

func _process(delta: float) -> void:
    _calculate_time_elapsed(delta)
    _rotate_per_time()

func _calculate_time_elapsed(delta: float) -> void:
    time_elapsed += delta * time_speed
    time_elapsed = fmod(time_elapsed, SECONDS_PER_DAY)

func _rotate_per_time() -> void:
    rotation_degrees.y = remap(time_elapsed, 0., SECONDS_PER_DAY, 0., 360)