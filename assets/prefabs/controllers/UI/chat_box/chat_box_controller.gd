class_name ChatBoxController extends UIController

@export var slide_offset: Vector2 = Vector2(0.,-80.)
@export var hidden_scale: Vector2 = Vector2(0., .75)
@export var display_speed: float
@export_group("References")
@export var speaker_label: Label
@export var chat_label: Label
@export var timer: Timer

const INITIAL_POSITION: Vector2 = Vector2(576, 736)
var speaker_text: String
var chat_text: String
signal show_text_finished

func _enter_tree() -> void:
    if !timer.timeout.is_connected(_on_timer_timeout):
        timer.timeout.connect(_on_timer_timeout)

    parent.modulate.a = 0
    parent.position = INITIAL_POSITION
    parent.scale = hidden_scale

    timer.wait_time = display_speed

# ========== Setters and getters ==========
func set_display_speed(value: float) -> void:
    display_speed = value
    timer.wait_time = value

func set_speaker_text(value: String) -> void:
    speaker_text = value
    speaker_label.text = value

func set_chat_text(value: String) -> void:
    chat_text = value
    chat_label.text = value
    chat_label.visible_characters = 0
# ========== ========== ========== ==========

# ========== From parent ==========
func exit_ui() -> void:
    set_speaker_text("")
    set_chat_text("")

func show_ui() -> void:
    var tween: Tween = create_tween()
    tween.set_parallel()
    tween.tween_property(parent, "position", INITIAL_POSITION + slide_offset, animation_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(parent, "modulate", Color(1.,1.,1.,1.), animation_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(parent, "scale", Vector2(1.,1.), animation_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    await tween.finished
    animation_finished.emit()

func hide_ui() -> void:
    var tween: Tween = create_tween()
    tween.set_parallel()
    tween.tween_property(parent, "position", INITIAL_POSITION, animation_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(parent, "modulate", Color(1.,1.,1.,0.), animation_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(parent, "scale", hidden_scale, animation_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    await tween.finished
    animation_finished.emit()
# ========== ========== ========== ==========

# ========== Show text ==========
func show_text() -> void:
    timer.start()

func _on_timer_timeout() -> void:
    chat_label.visible_characters += 1
    if chat_label.visible_characters < chat_label.text.length():
        show_text()
    else:
        show_text_finished.emit()
# ========== ========== ========== ==========