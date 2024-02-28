extends GutTest


var star_loader : PackedScene = preload("res://assets/prefabs/star loader/star_loader.tscn")
var star_loader_inst : StarLoader


func before_each() -> void:
	star_loader_inst = star_loader.instantiate()
	add_child_autoqfree(star_loader_inst)

func test_packed_scenes() -> void:
	assert_ne(star_loader_inst.main_star_scene, null, "main_star_scene should not be null")
	assert_ne(star_loader_inst.background_star_scene, null, "background_star_scene should not be null")

func test_variables() -> void:
	assert_ne(star_loader_inst.main_star_container, null, "main_star_container should not be null")
	assert_ne(star_loader_inst.background_star_container, null, "background_star_container should not be null")

	assert_ne(star_loader_inst.starmap_filename, null, "starmap_filename should not be null")
	assert_ne(star_loader_inst.starmap_filename, "", "starmap_filename should not be an empty string")
	assert_file_exists(star_loader_inst.FOLDER_PATH + star_loader_inst.starmap_filename + star_loader_inst.FILE_EXTENSION)

	assert_gt(star_loader_inst.distance_from_center, 800., "distance_from_center should be more than planet radius")

func test_load_main_stars() -> void:
	await wait_for_signal(star_loader_inst.star_loading_finished, .25, "Waiting for loading to be finished")
	assert_gt(star_loader_inst.main_star_container.get_child_count(), 0, "Should have more than 1 child")

func test_load_background_stars() -> void:
	await wait_for_signal(star_loader_inst.star_loading_finished, .25, "Waiting for loading to be finished")
	assert_gt(star_loader_inst.background_star_container.get_child_count(), 0, "Should have more than 1 child")