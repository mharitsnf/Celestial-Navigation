class_name MainCameraController extends Node

var available_virtual_cameras: Array
var parent: MainCamera
var current_controller: VirtualCameraController

# ========== Built-in functions ==========
func _enter_tree() -> void:
	parent = get_parent()

func _ready() -> void:
	await get_tree().process_frame
	available_virtual_cameras = STUtil.get_nodes_in_group(parent.get_follow_target().get_parent().name + "VCs")

func _process(_delta: float) -> void:
	if current_controller:
		current_controller.rotate_joypad()
		if current_controller is FPCController:
			current_controller.zoom_joypad()
	
	_switch_camera()
	_handle_capture_image()

func _unhandled_input(event: InputEvent) -> void:
	if current_controller:
		if event is InputEventMouseMotion:
			current_controller.rotate_mouse(event)
		if current_controller is FPCController and event is InputEventMouseButton:
			current_controller.zoom_mouse(event)
# ========== ========== ========== ==========

# ========== Follow target changed ==========
const STANDALONE_PICTURES_DIR_PATH: String = "pictures/"
const EDITOR_PICTURES_DIR_PATH: String = "assets/resources/pictures/"
func _handle_capture_image() -> void:
	if !current_controller is FPCController: return
	
	if Input.is_action_just_pressed("capture_image"):
		var final_viewport: SubViewport = STUtil.get_only_node_in_group("final_viewport")
		if !final_viewport:
			push_warning("Final viewport not found, capture image not processed")
			return
		
		var img: Image = final_viewport.get_texture().get_image()
		var tex: ImageTexture = ImageTexture.create_from_image(img)
		var final_path: String = "user://" + STANDALONE_PICTURES_DIR_PATH if OS.has_feature("standalone") else "res://" + EDITOR_PICTURES_DIR_PATH

		if !DirAccess.dir_exists_absolute(final_path):
			var res: int = DirAccess.make_dir_absolute(final_path)
			if res != Error.OK:
				push_error("Folder could not be created, exiting create picture")
				return
		
		var pic: Picture = Picture.new()
		pic.resource_path = final_path + str(floor(Time.get_unix_time_from_system())) + ".tres"
		pic.image_tex = tex
		var save_state: int = ResourceSaver.save(pic)
		if save_state != Error.OK:
			push_error("Picture could not be saved")
# ========== ========== ========== ==========

# ========== Available VCs ==========
func set_available_virtual_cameras(value: Array) -> void:
	available_virtual_cameras = value

func get_available_virtual_cameras() -> Array:
	return available_virtual_cameras
# ========== ========== ========== ==========

# ========== Switching ==========
func _get_next_virtual_camera() -> VirtualCamera:
	if parent.is_transitioning(): return parent.get_follow_target()
	for vc: Node in available_virtual_cameras:
		if vc is VirtualCamera:
			if vc == parent.get_follow_target(): continue
			return vc
	return parent.get_follow_target()

func _switch_camera() -> void:
	if Input.is_action_just_pressed("switch_camera"):
		var next_camera: VirtualCamera = _get_next_virtual_camera()
		next_camera.copy_rotation(parent.get_follow_target().get_x_rotation(), parent.get_follow_target().get_y_rotation())
		parent.set_follow_target(next_camera)
# ========== ========== ========== ==========

# ========== Follow target changed ==========
func _on_follow_target_changed(target: VirtualCamera) -> void:
	if !target.has_node("Controller"):
		push_warning("The new virtual camera ", target, " has no controller!")
		current_controller = null
		return
	current_controller = target.get_node("Controller")
# ========== ========== ========== ==========
