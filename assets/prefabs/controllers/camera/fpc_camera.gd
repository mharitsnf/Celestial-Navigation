class_name FPCCamera extends FPCFunction

# ========== Built in functions ==========
func process(_delta: float) -> void:
    _handle_capture_image()
# ========== ========== ========== ==========

# ========== Capture image ==========
const STANDALONE_PICTURES_DIR_PATH: String = "pictures/"
const EDITOR_PICTURES_DIR_PATH: String = "assets/resources/pictures/"
func _handle_capture_image() -> void:
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