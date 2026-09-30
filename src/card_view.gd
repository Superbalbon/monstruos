class_name CardView
extends Button

var card_data: Dictionary

func setup(card: Dictionary, faction_color: Color, art_path: String) -> void:
	card_data = card
	text = ""
	custom_minimum_size = Vector2(218, 258)
	tooltip_text = "Mejora: " + str(card["mejora"])
	clip_contents = true
	_build_styles(faction_color)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 9)
	margin.add_theme_constant_override("margin_bottom", 9)
	add_child(margin)

	var content := VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 5)
	margin.add_child(content)

	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(header)
	var name_label := Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.text = str(card["nombre"]).to_upper()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", faction_color.lightened(0.25))
	header.add_child(name_label)
	var cost_label := Label.new()
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cost_label.text = "%d⚡" % int(card["coste"])
	cost_label.add_theme_font_size_override("font_size", 15)
	cost_label.add_theme_color_override("font_color", Color("ffd166"))
	header.add_child(cost_label)

	var art_panel := PanelContainer.new()
	art_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_panel.custom_minimum_size = Vector2(0, 112)
	var art_style := StyleBoxFlat.new()
	art_style.bg_color = faction_color.darkened(0.72)
	art_style.corner_radius_top_left = 7
	art_style.corner_radius_top_right = 7
	art_style.corner_radius_bottom_left = 7
	art_style.corner_radius_bottom_right = 7
	art_panel.add_theme_stylebox_override("panel", art_style)
	content.add_child(art_panel)

	if not art_path.is_empty() and ResourceLoader.exists(art_path):
		var image := TextureRect.new()
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		image.texture = load(art_path) as Texture2D
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		art_panel.add_child(image)
	else:
		var placeholder := Label.new()
		placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		placeholder.text = str(card["id"]) + "\nILUSTRACIÓN PENDIENTE"
		placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		placeholder.add_theme_font_size_override("font_size", 12)
		placeholder.add_theme_color_override("font_color", Color(faction_color, 0.72))
		art_panel.add_child(placeholder)

	var effect_label := Label.new()
	effect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect_label.text = str(card["efecto"])
	effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	effect_label.add_theme_font_size_override("font_size", 12)
	effect_label.add_theme_color_override("font_color", Color("d9dce3"))
	content.add_child(effect_label)

	var footer := Label.new()
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.text = "%s · %s" % [card["tipo"], card["rareza"]]
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 10)
	footer.add_theme_color_override("font_color", Color("929bad"))
	content.add_child(footer)

func _build_styles(faction_color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("11151f")
	normal.border_color = Color(faction_color, 0.7)
	normal.set_border_width_all(2)
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = faction_color.darkened(0.73)
	hover.border_color = faction_color.lightened(0.2)
	hover.set_border_width_all(3)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", hover)

	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("0b0d12")
	disabled.border_color = Color(faction_color, 0.22)
	add_theme_stylebox_override("disabled", disabled)

