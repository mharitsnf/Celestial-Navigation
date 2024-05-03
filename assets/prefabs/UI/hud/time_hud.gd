class_name TimeHUD extends Control

@export var slide_offset: Vector2 = Vector2(0., -64.)
@export var initial_pos: Vector2 = Vector2(854., 1004.)
@export_group("References")
@export var meridian_label: Label
@export var label_container: Control
@export var hbox: HBoxContainer

var transitioning: bool = false

const SHOWN_LABEL_SIZE: Vector2 = Vector2(100., 0.)
const HIDDEN_LABEL_SIZE: Vector2 = Vector2(0., 0.)
const SHOWN_SEPARATION: int = 24
const HIDDEN_SEPARATION: int = 0

func _ready() -> void:
    position = initial_pos
    modulate.a = 0
    label_container.custom_minimum_size = HIDDEN_LABEL_SIZE
    hbox.add_theme_constant_override("separation", HIDDEN_SEPARATION)
    visible = false

func set_meridian_label_text(value: String) -> void:
    if !meridian_label: return
    meridian_label.text = value

func is_transitioning() -> bool:
    return transitioning

func set_transitioning(value: bool) -> void:
    transitioning = value

func show_hud() -> void:
    if is_transitioning(): return
    set_transitioning(true)
    visible = true

    # Wait camera transition
    # await get_tree().create_timer(.55).timeout
    
    var tween: Tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "position", initial_pos + slide_offset, .25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(self, "modulate", Color(1.,1.,1.,1.), .25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    await tween.finished
    tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(label_container, "custom_minimum_size", SHOWN_LABEL_SIZE, .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(hbox, "theme_override_constants/separation", SHOWN_SEPARATION, .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    await tween.finished
    
    set_transitioning(false)

func hide_hud() -> void:
    if is_transitioning(): return
    set_transitioning(true)

    var tween: Tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(label_container, "custom_minimum_size", HIDDEN_LABEL_SIZE, .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(hbox, "theme_override_constants/separation", HIDDEN_SEPARATION, .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    await tween.finished
    tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "modulate", Color(1.,1.,1.,0.), .25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(self, "position", initial_pos, .25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    await tween.finished
   
    visible = false
    set_transitioning(false)