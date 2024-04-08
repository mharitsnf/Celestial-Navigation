extends Node3D

@export var time_speed: float = 1.
var time_elapsed: float = 0.
var current_day: int = 0

const SECONDS_PER_DAY: float = 86400.

func _process(delta: float) -> void:
    _calculate_time_elapsed(delta)
    _rotate_per_time()
    _calculate_meridian_time()

func _calculate_time_elapsed(delta: float) -> void:
    if time_elapsed < delta * time_speed: print("day changed")

    var half_day_mark: float = fmod(time_elapsed, SECONDS_PER_DAY / 2.)
    if half_day_mark < delta * time_speed: print("half day mark")

    time_elapsed += delta * time_speed
    time_elapsed = fmod(time_elapsed, SECONDS_PER_DAY)

func _rotate_per_time() -> void:
    rotation_degrees.y = remap(time_elapsed, 0., SECONDS_PER_DAY, 360, 0)

func _calculate_meridian_time() -> void:
    var seconds: int = floori(fmod(time_elapsed, 60.))
    var minutes: int = floori(fmod(time_elapsed / 60., 60.))
    var hours: int = floori(fmod(time_elapsed / 3600., 60.))

    var str_seconds: String = "0"+str(seconds) if seconds < 10 else str(seconds)
    var str_minutes: String = "0"+str(minutes) if minutes < 10 else str(minutes)
    var str_hours: String = "0"+str(hours) if hours < 10 else str(hours)
    var str_time: String = str_hours + ":" + str_minutes + ":" + str_seconds
    print(str_time)

# ========== Save and load state functions ==========
func save_state() -> Dictionary:
    return {
        "metadata": {
            "filename": scene_file_path,
            "parent": get_parent().get_path(),
        },
        "on_init": {
            "time_elapsed": time_elapsed,
            "time_speed": time_speed,
        },
        "on_ready": {}
    }

func on_load_init(data: Dictionary) -> void:
    time_elapsed = data["time_elapsed"]
    time_speed = data["time_speed"]

func on_load_ready(_data: Dictionary) -> void:
    pass
# ========== ========== ========== ==========