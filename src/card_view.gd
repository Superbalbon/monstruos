class_name CardView
extends Button

var card_data: Dictionary
var illustration_path := ""
var rules_tooltip := ""

func setup(card: Dictionary, faction_color: Color, art_path: String, current_cost := -1) -> void:
	card_data = card
	illustration_path = art_path
	text = ""
	custom_minimum_size = Vector2(218, 300)
	tooltip_text = str(card["nombre"]) + "\n" + str(card["efecto"])
	if card.get("upgraded", false):
		tooltip_text += "\nMejora aplicada a esta copia. No puede mejorarse otra vez."
	elif preload("res://src/card_upgrades.gd").can_upgrade(str(card.id)):
		tooltip_text += "\nMejora disponible en el descanso: " + str(card["mejora"])
	else:
		tooltip_text += "\nMejora prevista (aún no disponible): " + str(card["mejora"])
	if card.get("temporal", false):
		tooltip_text += "\nTemporal: desaparece al terminar el combate; no se añade a tu mazo."
	if current_cost >= 0 and current_cost != int(card["coste"]):
		tooltip_text = "Coste actual: %d (base: %d).\n" % [current_cost, int(card["coste"])] + tooltip_text
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
	content.add_theme_constant_override("separation", 3)
	margin.add_child(content)

	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var name_label := Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.text = str(card["nombre"]).to_upper()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", faction_color.lightened(0.25))
	var cost_label := Label.new()
	cost_label.name = "CostLabel"
	cost_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var base_cost := int(card["coste"])
	var effective_cost := current_cost if current_cost >= 0 else base_cost
	cost_label.text = "%d⚡" % effective_cost
	if effective_cost != base_cost:
		cost_label.text = "%d→%d⚡" % [base_cost, effective_cost]
	cost_label.add_theme_font_size_override("font_size", 15)
	var cost_color := Color("ffd166")
	if effective_cost < base_cost:
		cost_color = Color("8de0ae")
	elif effective_cost > base_cost:
		cost_color = Color("ffb4a9")
	cost_label.add_theme_color_override("font_color", cost_color)
	header.add_child(cost_label)
	var spacer := Control.new()
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	var stats := Label.new()
	stats.name = "StatLabel"
	stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stats.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	stats.text = preload("res://src/card_metrics.gd").badge(card)
	stats.add_theme_font_size_override("font_size", 14)
	header.add_child(stats)
	for badge in [cost_label, stats]:
		var badge_style := StyleBoxFlat.new()
		badge_style.bg_color = Color("10141eed")
		badge_style.set_corner_radius_all(6)
		badge_style.content_margin_left = 6
		badge_style.content_margin_right = 6
		badge_style.content_margin_top = 4
		badge_style.content_margin_bottom = 4
		badge.add_theme_stylebox_override("normal", badge_style)

	var art_panel := PanelContainer.new()
	art_panel.name = "ArtPanel"
	art_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_panel.custom_minimum_size = Vector2(0, 180)
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
		image.name = "CardIllustration"
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		image.texture = load(art_path) as Texture2D
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
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

	art_panel.add_child(header)
	content.add_child(name_label)
	var effect_label := Label.new()
	effect_label.name = "CardRules"
	effect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect_label.text = preload("res://src/card_metrics.gd").rules(card)
	effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect_label.max_lines_visible = 3
	effect_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	effect_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	effect_label.add_theme_font_size_override("font_size", 12)
	effect_label.add_theme_color_override("font_color", Color("d9dce3"))
	content.add_child(effect_label)

	var footer := Label.new()
	footer.name = "CardFooter"
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.text = "%s · %s" % [card["tipo"], card["rareza"]]
	if card.get("temporal", false):
		footer.text += " · Temporal"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 10)
	footer.add_theme_color_override("font_color", Color("929bad"))
	var footer_row := HBoxContainer.new()
	footer_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(footer_row)
	footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	footer_row.add_child(footer)

	# Separate action: inspecting must never emit this card's pressed signal.
	var inspect := Button.new()
	inspect.name = "InspectCard"
	inspect.text = "VER"
	inspect.add_theme_font_size_override("font_size", 11)
	inspect.tooltip_text = "Ampliar ilustración y leer la carta. También: clic derecho."
	inspect.mouse_filter = Control.MOUSE_FILTER_STOP
	inspect.pressed.connect(_open_details)
	footer_row.add_child(inspect)
	tooltip_text += "\nDaño y Bloqueo superiores: valores base, incluidas las mejoras. Las condiciones y estados pueden modificarlos. El coste muestra el valor actual."
	rules_tooltip = tooltip_text

func set_play_availability(reason: String) -> void:
	# Only the combat hand uses this label. Catalogs and rewards keep type/rarity.
	disabled = not reason.is_empty()
	var footer := find_child("CardFooter", true, false) as Label
	footer.text = "NO DISPONIBLE" if disabled else "JUGABLE"
	if card_data.get("temporal", false):
		footer.text += " · Temporal"
	footer.add_theme_color_override("font_color", Color("ffb4a9") if disabled else Color("8de0ae"))
	tooltip_text = ("NO DISPONIBLE\n" + reason + "\n\n" if disabled else "") + rules_tooltip
	tooltip_text += "\n%s · %s" % [card_data.tipo, card_data.rareza]

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		accept_event()
		_open_details()

func _open_details() -> void:
	if not is_inside_tree() or get_tree().root.has_node("CardDetail"):
		return
	var detail := preload("res://src/card_detail.gd").new()
	get_tree().root.add_child(detail)
	var detail_ref: WeakRef = weakref(detail)
	tree_exiting.connect(func():
		var open_detail = detail_ref.get_ref()
		if open_detail != null:
			open_detail.queue_free()
	, CONNECT_ONE_SHOT)
	detail.show_card(card_data.duplicate(true), illustration_path, tooltip_text)

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

	# The focus ring is drawn over the card, without obscuring its illustration.
	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.border_color = Color("fff2c6")
	focus.set_border_width_all(3)
	focus.set_corner_radius_all(12)
	add_theme_stylebox_override("focus", focus)

	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("0b0d12")
	disabled.border_color = Color(faction_color, 0.22)
	add_theme_stylebox_override("disabled", disabled)
