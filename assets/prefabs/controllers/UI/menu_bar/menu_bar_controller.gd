class_name MenuBarController extends UIController

@export var appear_to_focus_delay: float = .1
@export var texture_rect: TextureRect
@export var button_container: VBoxContainer

var active_button: MainMenuButton = null

# ==============================
# region Lifecycle Functions

func _ready() -> void:
    for c: Node in button_container.get_children():
        (c as MainMenuButton).focus_entered.connect(_on_main_menu_button_focus_entered.bind(c as MainMenuButton))

func _enter_tree() -> void:
    # During first initialization, wait for the above _ready function to run first.
    if !parent.is_node_ready():
        await parent.ready
    
    # Reset animation
    _reset_animation()

    # Emulate pressing menu button
    show_ui()
    await animation_finished
    
    # Delay to focus
    # await get_tree().create_timer(appear_to_focus_delay).timeout
    
    # Grab focus
    (button_container.get_children()[0] as MainMenuButton).grab_focus()

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

func _on_main_menu_button_focus_entered(button: MainMenuButton) -> void:
    active_button = button

# ==============================
# region Animation

func _reset_animation() -> void:
    texture_rect.position = Vector2.ZERO + Vector2(-32., 0.)
    texture_rect.modulate = Color(1.,1.,1.,0.)

func show_ui() -> void:
    animating = true
    var tween: Tween = create_tween()
    tween.set_parallel()
    tween.tween_property(texture_rect, "position", Vector2.ZERO, animation_speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(texture_rect, "modulate", Color(1.,1.,1.,1.), animation_speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    await tween.finished
    animation_finished.emit()
    animating = false

func hide_ui() -> void:
    animating = true
    var tween: Tween = create_tween()
    tween.set_parallel()
    tween.tween_property(texture_rect, "position", Vector2.ZERO + Vector2(-32., 0.), animation_speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(texture_rect, "modulate", Color(1.,1.,1.,0.), animation_speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    await tween.finished
    animation_finished.emit()
    animating = false