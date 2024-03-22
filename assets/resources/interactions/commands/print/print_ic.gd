class_name PrintIC extends InteractionCommand

@export_multiline var text_to_print: String

func action() -> void:
    print(text_to_print)