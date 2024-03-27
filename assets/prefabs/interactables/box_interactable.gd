extends Interactable

func handle_track_finished() -> void:
    match current_track:
        "Start", "Second":
            current_track = "Second"
        _:
            current_track = "Fallback"