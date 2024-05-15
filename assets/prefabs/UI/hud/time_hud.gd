class_name TimeHUD extends Control

@export_group("References")
@export var meridian_label: Label

func set_meridian_label_text(value: String) -> void:
    if !meridian_label: return
    meridian_label.text = value