class_name PauseMainMenuController extends UIController

@export var appear_to_focus_delay: float = .1
@export_group("References")
@export var margin_container: MarginContainer
@export var button_container: VBoxContainer

const SLIDE_TO_SHOW_OFFSET: Vector2 = Vector2(32., 0.)
const INIT_POSITION: Vector2 = Vector2(-32, 452.)
var active_button: ListMenuButton = null

# ==============================
# region Lifecycle Functions

func _ready() -> void:
	for c: Node in button_container.get_children():
		# Focus is for clear animation when quitting the menu
		(c as ListMenuButton).focus_entered.connect(_on_list_menu_button_focus_entered.bind(c as ListMenuButton))
		(c as ListMenuButton).pressed.connect(_on_list_menu_button_pressed.bind(c as ListMenuButton))

func _enter_tree() -> void:
	# During first initialization, wait for the above _ready function to run first.
	if !parent.is_node_ready():
		await parent.ready

	# Emulate pressing menu button
	show_ui()
	await animation_finished
	
	# Delay to focus
	# await get_tree().create_timer(appear_to_focus_delay).timeout
	
	# Grab focus
	(button_container.get_children()[0] as ListMenuButton).grab_focus()

func before_exit_tree() -> STUtil.Promise:
	# Stop active button from focusing
	active_button.release_focus()
	await active_button.animation_finished
	active_button = null

	# Hide the UI
	hide_ui()
	await animation_finished
	
	# Return
	return STUtil.Promise.new()

# ==============================
# region Events

func _on_list_menu_button_focus_entered(button: ListMenuButton) -> void:
	active_button = button

func _on_list_menu_button_pressed(button: ListMenuButton) -> void:
	var pressed_command: InteractionCommand = button.get_pressed_command()
	if pressed_command:
		print("Button pressed: ", pressed_command)
		pressed_command.action(get_tree())

# ==============================
# region Animation

func reset_animation() -> void:
	margin_container.position = INIT_POSITION
	margin_container.modulate = Color(1.,1.,1.,0.)

func show_ui() -> void:
	reset_animation()
	animating = true
	var tween: Tween = create_tween()
	tween.set_parallel()
	tween.tween_property(margin_container, "position", INIT_POSITION + SLIDE_TO_SHOW_OFFSET, animation_speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(margin_container, "modulate", Color(1.,1.,1.,1.), animation_speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	animation_finished.emit()
	animating = false

func hide_ui() -> void:
	animating = true
	var tween: Tween = create_tween()
	tween.set_parallel()
	tween.tween_property(margin_container, "position", INIT_POSITION, animation_speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(margin_container, "modulate", Color(1.,1.,1.,0.), animation_speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	animation_finished.emit()
	animating = false
