class_name ChatBoxController extends UIController

@export var display_speed: float
@export_group("References")
@export var speaker_label: Label
@export var chat_label: Label
@export var timer: Timer
@export var anim: AnimationPlayer

var speaker_text: String
var chat_text: String
signal show_text_finished

func _enter_tree() -> void:
    if !timer.timeout.is_connected(_on_timer_timeout):
        timer.timeout.connect(_on_timer_timeout)

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
func clear() -> void:
    set_speaker_text("")
    set_chat_text("")

func show_ui() -> void:
    anim.play("appear")

func hide_ui() -> void:
    anim.play("disappear")
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