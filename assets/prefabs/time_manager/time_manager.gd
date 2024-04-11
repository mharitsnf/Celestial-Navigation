extends Node3D

@export var time_speed: float = 1.
var time_elapsed: float = 0.
var current_day: int = 0

var time_hud: TimeHUD
var player_controller_manager: PlayerControllerManager

const SECONDS_PER_DAY: float = 86400.
const SECONDS_PER_LONG_ANGLE: float = 240.

func _ready() -> void:
	time_hud = STUtil.get_only_node_in_group("time_hud")
	player_controller_manager = STUtil.get_only_node_in_group("player_controller_manager")

func _process(delta: float) -> void:
	_calculate_time_elapsed(delta)
	_rotate_per_time()

	if time_hud:
		var meridian_time: Array = get_time()
		time_hud.set_meridian_label_text(meridian_time[0] + ":" + meridian_time[1])
		
		var latlng: STUtil.LatLong = STUtil.get_lat_long(player_controller_manager.get_current_controller().parent.global_position)
		var time_elapsed_offset: float = SECONDS_PER_LONG_ANGLE * latlng.longitude
		var local_time_elapsed: float = time_elapsed - time_elapsed_offset
		local_time_elapsed = SECONDS_PER_DAY + local_time_elapsed if local_time_elapsed < 0 else local_time_elapsed
		local_time_elapsed = fmod(local_time_elapsed, SECONDS_PER_DAY)

		var local_time: Array = get_time(local_time_elapsed)
		time_hud.set_local_label_text(local_time[0] + ":" + local_time[1])

func _calculate_time_elapsed(delta: float) -> void:
	if time_elapsed < delta * time_speed: print("day changed")

	var half_day_mark: float = fmod(time_elapsed, SECONDS_PER_DAY / 2.)
	if half_day_mark < delta * time_speed: print("half day mark")

	time_elapsed += delta * time_speed
	time_elapsed = fmod(time_elapsed, SECONDS_PER_DAY)

func _rotate_per_time() -> void:
	rotation_degrees.y = remap(time_elapsed, 0., SECONDS_PER_DAY, 360, 0)

func get_local_time() -> Array:
	return []

func _snap_to_five(value: int) -> int:
	return floor(value / 5.) * 5

func get_time(time: float = time_elapsed) -> Array:
	var seconds: int = _snap_to_five(floori(fmod(time, 60.)))
	var minutes: int = _snap_to_five(floori(fmod(time / 60., 60.)))
	var hours: int = floori(fmod(time / 3600., 60.))

	var str_seconds: String = "0"+str(seconds) if seconds < 10 else str(seconds)
	var str_minutes: String = "0"+str(minutes) if minutes < 10 else str(minutes)
	var str_hours: String = "0"+str(hours) if hours < 10 else str(hours)
	return [
		str_hours, str_minutes, str_seconds, hours, minutes, seconds
	]

# ========== Save and load state functions ==========
func save_state() -> Dictionary:
	return {
		"metadata": {
			"filename": scene_file_path,
			"path": get_path(),
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
