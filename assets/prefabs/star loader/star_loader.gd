class_name StarLoader extends Node


const FOLDER_PATH : String = "res://assets/starmaps/"
const FILE_EXTENSION : String = ".smap"

@export var starmap_filename : String
@export var distance_from_center : float
@export_group("Main star settings")
@export var main_star_scene : PackedScene
@export var main_star_container : Node3D
@export_group("Background star settings")
@export var background_star_scene : PackedScene
@export var use_background_star : bool = true
@export var background_star_amount : int = 1000
@export var background_star_container : Node3D

signal star_loading_finished


func _ready() -> void:
	await _load_main_stars()
	if use_background_star:
		await _load_background_stars()
	star_loading_finished.emit()


func _load_main_stars() -> void:
	var starmap_file : FileAccess = FileAccess.open(FOLDER_PATH + starmap_filename + FILE_EXTENSION, FileAccess.READ)
	while starmap_file.get_position() < starmap_file.get_length():
		var json_string : String = starmap_file.get_line()
		var json : JSON = JSON.new()

		var parse_result : int = json.parse(json_string)
		if parse_result != OK:
			printerr("JSON parse error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		var data : Dictionary = json.get_data()
		data['distance_from_center'] = distance_from_center
        
		var main_star_inst : MainStar = main_star_scene.instantiate()
		main_star_container.add_child.call_deferred(main_star_inst)
		await main_star_inst.ready
		main_star_inst.load_data(data)


func _load_background_stars() -> void:
	for i : int in range(background_star_amount):
		var dir : Vector3 = Vector3(randf() * 2. - 1, randf() * 2. - 1., randf() * 2. - 1.).normalized()
		var star_inst : Node3D = background_star_scene.instantiate()
		background_star_container.add_child.call_deferred(star_inst)
		await star_inst.ready
		star_inst.global_position = dir * distance_from_center