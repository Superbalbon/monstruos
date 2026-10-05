extends AcceptDialog

var previous_focus: Control

func show_details(description: String) -> void:
	title = "Intención enemiga y defensa prevista"
	exclusive = true
	transient = true
	ok_button_text = "VOLVER AL COMBATE"
	previous_focus = get_tree().root.gui_get_focus_owner()
	var body := RichTextLabel.new()
	body.name = "IntentDescription"
	body.bbcode_enabled = false
	body.selection_enabled = true
	body.add_theme_font_size_override("normal_font_size", 20)
	body.text = description + "\n\nSolo consulta: cerrar no termina el turno ni consume recursos."
	add_child(body)
	confirmed.connect(close)
	canceled.connect(close)
	popup_centered(Vector2i(760, 470))
	get_ok_button().grab_focus()

func close() -> void:
	hide()
	if is_instance_valid(previous_focus) and previous_focus.is_inside_tree():
		previous_focus.grab_focus()
	queue_free()
