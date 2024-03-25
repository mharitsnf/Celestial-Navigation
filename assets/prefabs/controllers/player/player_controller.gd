class_name PlayerController extends Node

@export var interaction_scanner: Area3D
var interactions: Array
var current_track: InteractionTrack
var interacting: bool
var command_running: bool

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

func _exit_tree() -> void:
	manager.remove_controller(self)

func process(_delta: float) -> void:
	_get_start_interact_input()
	_get_next_interact_input()

func physics_process(_delta: float) -> void:
	pass

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
	if is_interacting(): return
	if Input.is_action_just_pressed("interact") and !interactions.is_empty():		
		var top_node: Area3D = interactions.back()
		if top_node is Interactable:
			var track: InteractionTrack = top_node.interaction.get_current_track_resource().duplicate()
			if !track: return

			current_track = track
			set_interacting(true)
			_interact()

func _interact() -> void:
	var command: InteractionCommand = current_track.commands.pop_front()
	if !command:
		print("Track finished")
		set_interacting(false)
		return

	set_command_running(true)
	await command.action(get_tree())
	set_command_running(false)

func _on_interactable_entered(area: Area3D) -> void:
	interactions.append(area)

func _on_interactable_exited(area: Area3D) -> void:
	interactions.erase(area)
# ========== ========== ========== ==========