class_name SaveSystem extends Node

class LoadedNode extends RefCounted:
    var node: Node
    var data: Dictionary
    func _init(_node: Node, _data: Dictionary) -> void:
        node = _node
        data = _data
    func preprocess_on_init(arr: Array[LoadedNode]) -> void:
        if !data.has("on_init"): return
        for key: String in data["on_init"].keys():
            if key.begins_with("i_"):
                var real_target: Node = arr[data["on_init"][key]].node
                if real_target.has_node("Controller"):
                    if node is MainCamera: real_target = real_target.get_node("Controller").third_person_camera
                    elif node is PlayerControllerManager: real_target = real_target.get_node("Controller")
                data["on_init"][key] = real_target

func _ready() -> void:
    load_game()

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
        if !new_object.has_method("on_load_init"):
            push_warning("Persistent node ", new_object.name, " is is missing a on_load_init() function, skipped")
            continue
        if !new_object.has_method("on_load_ready"):
            push_warning("Persistent node ", new_object.name, " is is missing a on_load_ready() function, skipped")
            continue
        
        new_nodes.append(LoadedNode.new(new_object, dict_data))

    for n: LoadedNode in new_nodes:
        n.preprocess_on_init(new_nodes)
        n.node.on_load_init(n.data["on_init"])
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