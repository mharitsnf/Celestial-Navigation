class_name TimeHUD extends HBoxContainer

@export var meridian_label: Label
@export var slide_offset: Vector2 = Vector2(0., -64.)

var transitioning: bool = false
var initial_pos: Vector2 = Vector2(869., 963.)

func _ready() -> void:
    position = initial_pos
    modulate.a = 0
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
    await get_tree().create_timer(.55).timeout
    var tween: Tween = create_tween()
    tween.set_parallel()
    tween.tween_property(self, "position", initial_pos + slide_offset, .2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(self, "modulate", Color(1.,1.,1.,1.), .2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    await tween.finished
    set_transitioning(false)

func hide_hud() -> void:
    if is_transitioning(): return
    set_transitioning(true)
    await get_tree().create_timer(.55).timeout
    var tween: Tween = create_tween()
    tween.set_parallel()
    tween.tween_property(self, "position", initial_pos, .2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(self, "modulate", Color(1.,1.,1.,0.), .2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    await tween.finished
    visible = false
    set_transitioning(false)