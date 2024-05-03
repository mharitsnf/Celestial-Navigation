class_name ChatBoxController extends UIController

@export var initial_position: Vector2 = Vector2(304, 512)
@export var slide_offset: Vector2 = Vector2(0.,-8.)
@export var display_speed: float
@export_group("References")
@export var npr: NinePatchRect
@export var text_container: MarginContainer
@export var speaker_label: Label
@export var chat_label: Label
@export var timer: Timer

var shader: ShaderMaterial
var current_cutoff: float = 0.

var speaker_text: String
var chat_text: String
signal show_text_finished

func _enter_tree() -> void:
    if !timer.timeout.is_connected(_on_timer_timeout):
        timer.timeout.connect(_on_timer_timeout)

    set_speaker_text("")
    set_chat_text("")

    parent.anchors_preset = Control.PRESET_CENTER_BOTTOM
    parent.position = initial_position
    text_container.modulate.a = 0

    timer.wait_time = display_speed

func _ready() -> void:
    shader = npr.material

# ========== Setters and getters ==========
func set_display_speed(value: float) -> void:
    display_speed = value
    timer.wait_time = value

func _set_cutoff_value(value: float) -> void:
    current_cutoff = value
    if shader:
        shader.set_shader_parameter("cutoff", value)

func set_speaker_text(value: String) -> void:
    speaker_text = value
    speaker_label.text = value

func set_chat_text(value: String) -> void:
    chat_text = value
    chat_label.text = value
    chat_label.visible_ratio = 0.
# ========== ========== ========== ==========

# ========== From parent ==========
func show_ui() -> void:
    var tween: Tween = create_tween()
    tween.set_parallel()
    tween.tween_property(parent, "position", initial_position + slide_offset, animation_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(text_container, "modulate", Color(1.,1.,1.,1.), animation_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_method(_set_cutoff_value, current_cutoff, 1., animation_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    await tween.finished
    animation_finished.emit()

func hide_ui() -> void:
    var tween: Tween = create_tween()
    tween.set_parallel()
    tween.tween_property(parent, "position", initial_position, animation_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(text_container, "modulate", Color(1.,1.,1.,0.), animation_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_method(_set_cutoff_value, current_cutoff, 0., animation_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
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