class_name MenuBarController extends UIController

@export var appear_to_focus_delay: float = .1
@export var texture_rect: TextureRect
@export var button_container: VBoxContainer
var main_menu_buttons: Array[Node]

func _enter_tree() -> void:
    # Wait for parent to be ready
    if !parent.is_node_ready():
        await parent.ready
    
    # Emulate pressing menu button
    await get_tree().create_timer(1.).timeout
    show_ui()
    await animation_finished
    
    # Populate button
    if main_menu_buttons.is_empty():
        main_menu_buttons = button_container.get_children()
    if main_menu_buttons.is_empty():
        push_error("No menu button available.")
        return
    
    # Delay to focus
    await get_tree().create_timer(appear_to_focus_delay).timeout
    
    # Grab focus
    (main_menu_buttons[0] as MainMenuButton).grab_focus()

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