class_name SaveSystem extends Node

class LoadedNode extends RefCounted:
	var node: Node
	var data: Dictionary
	func _init(_node: Node, _data: Dictionary) -> void:
		node = _node
		data = _data
	func preprocess(arr: Array[LoadedNode]) -> void:
		if !data.has("on_init"): return
		
        # Loop over the on_init dictionary, replace it with nodes
		for key: String in data["on_init"].keys():
			if !key.begins_with("i_"): continue
			data["on_init"][key] = arr[data["on_init"][key]].node
		
        # Send the on_init dictionary to the on_preprocess function of the node
		node.on_preprocess(data["on_init"])

@export var should_load_game: bool
var transition_screen: TransitionScreen

func _ready() -> void:
	transition_screen = STUtil.get_only_node_in_group("transition_screen")
	if should_load_game:
		await load_game()
		# var atmosphere: Node3D = STUtil.get_only_node_in_group("atmosphere")
		# if atmosphere: await atmosphere.ready
		print('ok')
	await get_tree().create_timer(1).timeout # Wait for physics to settle
	transition_screen.hide_screen()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("test_save"):
		save_game()

func load_game() -> void:
	if not FileAccess.file_exists("user://example_save_file.save"):
		return
	
	var save_nodes: Array[Node] = STUtil.get_nodes_in_group("persist")
	for i: Node in save_nodes:
		i.queue_free()

	await get_tree().process_frame

	# Reference to new nodes
	var new_nodes: Array[LoadedNode] = []

	var save_file: FileAccess = FileAccess.open("user://example_save_file.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string: String = save_file.get_line()
		var json: JSON = JSON.new()
		var parse_res: int = json.parse(json_string)
		if parse_res != OK:
			push_warning("JSON parse error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var dict_data: Dictionary = json.data

		var new_object: Node = load(dict_data["metadata"]["filename"]).instantiate()
		if !new_object.has_method("on_preprocess"):
			push_warning("Persistent node ", new_object.name, " is is missing a on_preprocess() function, skipped")
			continue
		if !new_object.has_method("on_load_ready"):
			push_warning("Persistent node ", new_object.name, " is is missing a on_load_ready() function, skipped")
			continue
		
		new_nodes.append(LoadedNode.new(new_object, dict_data))

	for n: LoadedNode in new_nodes:
		n.preprocess(new_nodes)
		get_node(n.data["metadata"]["parent"]).add_child(n.node)
		n.node.on_load_ready(n.data["on_ready"])

func save_game() -> void:
	var save_file: FileAccess = FileAccess.open("user://example_save_file.save", FileAccess.WRITE)
	var save_nodes: Array[Node] = STUtil.get_nodes_in_group("persist")
	for node: Node in save_nodes:
		if node.scene_file_path.is_empty():
			push_warning("Persistent node ", node.name, " is not an instanced scene, skipped")
			continue
		
		if !node.has_method("save_state"):
			push_warning("Persistent node ", node.name, " is is missing a save_state() function, skipped")
			continue

		var node_data: Dictionary = node.call("save_state")
		var json_string: String = JSON.stringify(node_data)
		save_file.store_line(json_string)
	print("Game saved!")
	print(save_nodes)
