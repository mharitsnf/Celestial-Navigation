extends HUDController

func reset_animation() -> void:
    parent.modulate = Color(1.,1.,1.,0.)

func show_hud() -> void:
    animating = true

    var tween: Tween = create_tween()
    tween.tween_property(parent, "modulate", Color(1.,1.,1.,1.), .5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    await tween.finished
    
    animating = false
    shown = true
    animation_finished.emit()

func hide_hud() -> void:
    animating = true

    var tween: Tween = create_tween()
    tween.tween_property(parent, "modulate", Color(1.,1.,1.,0.), .5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    await tween.finished

    animating = false
    shown = false
    animation_finished.emit()