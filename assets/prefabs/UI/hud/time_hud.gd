class_name TimeHUD extends HBoxContainer

@export var meridian_label: Label
@export var local_label: Label

func set_meridian_label_text(value: String) -> void:
    if !meridian_label: return
    meridian_label.text = value

func set_local_label_text(value: String) -> void:
    if !local_label: return
    local_label.text = value