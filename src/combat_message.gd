extends Label

func _init() -> void:
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	clip_text = true

func _get_tooltip(_at_position: Vector2) -> String:
	# Message text can change several times during one action. Read it on demand.
	return text

func _make_custom_tooltip(for_text: String) -> Object:
	var description := Label.new()
	description.custom_minimum_size.x = 520
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", 17)
	description.text = for_text
	return description
