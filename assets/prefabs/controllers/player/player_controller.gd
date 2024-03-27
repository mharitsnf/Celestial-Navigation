class_name PlayerController extends Node

@export var interaction_scanner: Area3D
var interactions: Array
var current_interaction: Interaction
var current_track: InteractionTrack
var interacting: bool
var command_running: bool

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
	_get_next_interact_input()
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

func is_command_running() -> bool:
	return command_running

func set_command_running(value: bool) -> void:
	command_running = value

func _get_next_interact_input() -> void:
	if !is_interacting(): return
	if Input.is_action_just_pressed("interact") and !is_command_running():
		_interact()

func _get_start_interact_input() -> void:
	if is_interacting() or is_command_running() or ui_manager.has_current_ui(): return
	if Input.is_action_just_pressed("interact") and !interactions.is_empty():		
		var top_node: Area3D = interactions.back()
		if top_node is Interactable:
			current_interaction = top_node.interaction
			if !current_interaction:
				_reset_interaction()
				return

			current_track = top_node.interaction.get_current_track_resource().duplicate()
			if !current_track:
				_reset_interaction()
				return

			set_interacting(true)
			_interact()

func _reset_interaction() -> void:
	current_interaction = null
	current_track = null

func _interact() -> void:
	var command: InteractionCommand = current_track.commands.pop_front()
	if !command:
		current_interaction.handle_track_finished()
		set_interacting(false)
		_reset_interaction()
		return

	set_command_running(true)
	await command.action(get_tree())
	set_command_running(false)

	if command.auto_next:
		_interact()

func _on_interactable_entered(area: Area3D) -> void:
	interactions.append(area)

func _on_interactable_exited(area: Area3D) -> void:
	interactions.erase(area)
# ========== ========== ========== ==========
