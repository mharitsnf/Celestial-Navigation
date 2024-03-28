extends Interactable

func handle_track_finished() -> void:
    match current_track:
        "Start", "Second":
            set_current_track("Second")
        _:
            set_current_track("Fallback")