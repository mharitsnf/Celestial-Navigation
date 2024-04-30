@tool
extends HBoxContainer

var image

func _on_button_pressed():
	var orig_path = image.resource_path
	
	# get image from texture
	if image is CompressedTexture2D or image is Texture2D:
		image = image.get_image()
	
	image.bump_map_to_normal_map()
	
	# save file in res://
	var ext = orig_path.get_extension()
	var new_path = orig_path.get_basename() + "_normal." + ext
	var error
	
	if ext == "png": error = image.save_png(new_path)
	elif ext == "jpg": error = image.save_jpg(new_path, 0.95)
	else: error = image.save_webp(new_path)
	
	if error == OK: print("Saved normal map file at %s" % new_path)
	else: print("Error saving normal map: %s" % error)
	
	# reload editor filesystem
	EditorInterface.get_resource_filesystem().scan()
