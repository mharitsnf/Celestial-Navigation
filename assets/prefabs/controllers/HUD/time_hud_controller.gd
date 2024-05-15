extends HUDController

@export_group("References")
@export var label_container: Control
@export var hbox: HBoxContainer

const SLIDE_TO_SHOW_OFFSET: Vector2 = Vector2(16., 0)
const INIT_POSITION: Vector2 = Vector2(-16., 626.)
const SHOWN_LABEL_SIZE: Vector2 = Vector2(100., 0.)
const HIDDEN_LABEL_SIZE: Vector2 = Vector2(0., 0.)
const SHOWN_SEPARATION: int = 24
const HIDDEN_SEPARATION: int = 0

func reset_animation() -> void:
    parent.position = INIT_POSITION
    parent.modulate = Color(1.,1.,1.,0.)
    label_container.custom_minimum_size = HIDDEN_LABEL_SIZE
    hbox.add_theme_constant_override("separation", HIDDEN_SEPARATION)
    parent.visible = false

func show_hud() -> void:
    if is_animating(): return
    reset_animation()
    parent.visible = true
    animating = true

    var tween: Tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(parent, "position", INIT_POSITION + SLIDE_TO_SHOW_OFFSET, .25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(parent, "modulate", Color(1.,1.,1.,1.), .25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    await tween.finished
    tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(label_container, "custom_minimum_size", SHOWN_LABEL_SIZE, .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(hbox, "theme_override_constants/separation", SHOWN_SEPARATION, .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    await tween.finished
    
    animating = false
    shown = true

func hide_hud() -> void:
    if is_animating(): return
    animating = true

    var tween: Tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(label_container, "custom_minimum_size", HIDDEN_LABEL_SIZE, .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(hbox, "theme_override_constants/separation", HIDDEN_SEPARATION, .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    await tween.finished
    tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(parent, "modulate", Color(1.,1.,1.,0.), .25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(parent, "position", INIT_POSITION, .25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    await tween.finished

    parent.visible = false
    animating = false
    shown = false