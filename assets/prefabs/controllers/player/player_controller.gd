class_name PlayerController extends Node

@export var third_person_camera: ThirdPersonCamera
@export var interaction_scanner: Area3D
var interactions: Array
var current_interactable: Interactable
var current_track: InteractionTrack
var interacting: bool

var ui_manager: UIManager
var manager: PlayerControllerManager
var parent: BaseEntity

func _enter_tree() -> void:
	parent = get_parent()
	manager = get_parent().get_parent()
	manager.add_controller(self)

	if !interaction_scanner.area_entered.is_connected(_on_interactable_entered):
		interaction_scanner.area_entered.connect(_on_interactable_entered)
	if !interaction_scanner.area_exited.is_connected(_on_interactable_exited):
		interaction_scanner.area_exited.connect(_on_interactable_exited)

func _ready() -> void:
	ui_manager = STUtil.get_only_node_in_group("ui_manager")

func _exit_tree() -> void:
	manager.remove_controller(self)

func process(_delta: float) -> bool:
	_get_start_interact_input()
	return !(is_interacting() or ui_manager.has_current_ui()) # If interacting or has an active ui from other means (like opening menu), do not proceed

func physics_process(_delta: float) -> bool:
	return true

func is_active() -> bool:
	return manager.get_current_controller() == self

# ========== Interaction functions ==========
func is_interacting() -> bool:
	return interacting

func set_interacting(value: bool) -> void:
	interacting = value

func _get_start_interact_input() -> void:
	if is_interacting() or interactions.is_empty() or ui_manager.has_current_ui(): return
	if Input.is_action_just_pressed("interact"):		
		if !_setup_interaction(): return
		_interact()

func _setup_interaction() -> bool:
	var top_node: Area3D = interactions.back()
	if top_node is Interactable:
		if !top_node.interaction: return false
		current_interactable = top_node
		current_track = top_node.get_track()
		if !current_track:
			_finish_interaction()
			return false
	return true

func _start_interaction() -> void:
	set_interacting(true)

func _finish_interaction() -> void:
	set_interacting(false)
	current_interactable = null
	current_track = null

func _interact() -> void:
	_start_interaction()
	for c: InteractionCommand in current_track.commands:
		await c.action(get_tree())
		if !c.auto_next: await STUtil.interact_pressed
	current_interactable.handle_track_finished()
	_finish_interaction()

func _on_interactable_entered(area: Area3D) -> void:
	interactions.append(area)

func _on_interactable_exited(area: Area3D) -> void:
	interactions.erase(area)
# ========== ========== ========== ==========
