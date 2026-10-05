extends AcceptDialog

var previous_focus: Control

func show_card(card: Dictionary, art_path: String, description: String) -> void:
	name = "CardDetail"
	title = "%s · %s" % [card.id, card.nombre]
	transient = true
	exclusive = true
	ok_button_text = "CERRAR · VOLVER"
	previous_focus = get_tree().root.gui_get_focus_owner()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	add_child(row)
	var image := TextureRect.new()
	image.name = "DetailIllustration"
	image.custom_minimum_size = Vector2(260, 360)
	image.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if not art_path.is_empty() and ResourceLoader.exists(art_path):
		image.texture = load(art_path) as Texture2D
	row.add_child(image)
	var text := RichTextLabel.new()
	text.name = "DetailDescription"
	text.custom_minimum_size.x = 280
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.bbcode_enabled = false
	text.selection_enabled = true
	text.add_theme_font_size_override("normal_font_size", 20)
	var full_description := description
	if str(card.efecto) not in full_description:
		full_description = str(card.efecto) + "\n\n" + full_description
	text.text = "%s · %s · %s\nCoste base: %d Ímpetu\n\n%s\n\nSolo consulta: cerrar no juega, compra ni selecciona la carta." % [card.faccion, card.tipo, card.rareza, int(card.coste), full_description]
	if image.texture == null:
		text.text += "\n\nIlustración pendiente para esta carta."
	row.add_child(text)
	confirmed.connect(_close_details)
	canceled.connect(_close_details)
	popup_centered(Vector2i(860, 620))
	get_ok_button().grab_focus()

func _close_details() -> void:
	hide()
	if is_instance_valid(previous_focus) and previous_focus.is_inside_tree() and previous_focus.is_visible_in_tree():
		previous_focus.grab_focus()
	queue_free()
