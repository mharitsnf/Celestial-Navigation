extends EditorInspectorPlugin

var convert_btn = preload("res://addons/bumptonormal/convert_button.tscn")

func _can_handle(object):
	return object is Image or object is Texture2D or object is CompressedTexture2D

func _parse_begin(object):
	var custom_control = convert_btn.instantiate()
	custom_control.image = object
	add_custom_control(custom_control)
