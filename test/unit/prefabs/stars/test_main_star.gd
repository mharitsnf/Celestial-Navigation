extends GutTest


var main_star : PackedScene = preload("res://assets/prefabs/stars/main_star.tscn")
var main_star_inst : MainStar


func before_each() -> void:
	main_star_inst = main_star.instantiate()
	add_child_autoqfree(main_star_inst)

func test_has_sprite() -> void:
	assert_ne(main_star_inst.sprite, null, "Sprite should not be null")

func test_color() -> void:
	assert_accessors(main_star_inst, "color", Color(1.,1.,1.), Color(.5,.5,.5))
	assert_eq(main_star_inst.sprite.modulate, main_star_inst.get_color(), "Color property and sprite modulate should be the same")

func test_pulsating() -> void:
	assert_accessors(main_star_inst, "pulsating", false, true)

func test_pulsating_speed() -> void:
	assert_accessors(main_star_inst, "pulsating_speed", -1., 1.)

func test_alpha_range() -> void:
	assert_accessors(main_star_inst, "alpha_range", Vector2(0., 1.), Vector2(.25, .75))

func test_load_data() -> void:
	# Assume data has passed validation
	var data : Dictionary = {
		"distance_from_center": 2000.,
		"np_x": 1.,
		"np_y": 0.,
		"np_z": 0.,
		"is_pulsating": true,
		"pulsating_speed": 1.,
		"alpha_min": 0.,
		"alpha_max": 1.,
		"color_r": 1.,
		"color_g": 1.,
		"color_b": 1.,
	}
	main_star_inst.load_data(data)
	assert_eq(main_star_inst.global_position, Vector3(data.np_x, data.np_y, data.np_z) * data.distance_from_center, "Global position should be the same as the one provided")