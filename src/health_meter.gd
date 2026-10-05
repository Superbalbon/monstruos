extends ProgressBar

func _init() -> void:
	custom_minimum_size = Vector2(0, 8)
	show_percentage = false
	mouse_filter = Control.MOUSE_FILTER_PASS
	focus_mode = Control.FOCUS_NONE
	var background := StyleBoxFlat.new()
	background.bg_color = Color("090d15")
	background.set_corner_radius_all(4)
	add_theme_stylebox_override("background", background)
	var fill := StyleBoxFlat.new()
	fill.set_corner_radius_all(4)
	add_theme_stylebox_override("fill", fill)

func set_health(current: int, maximum: int) -> void:
	max_value = maxi(1, maximum)
	value = clampi(current, 0, maxi(1, maximum))
	var ratio := value / max_value
	var fill := get_theme_stylebox("fill") as StyleBoxFlat
	fill.bg_color = Color("df6878") if ratio <= 0.25 else Color("e4bb70") if ratio <= 0.5 else Color("79cfa2")
	tooltip_text = "Salud: %d/%d. El Bloqueo se muestra por separado." % [int(value), int(max_value)]
