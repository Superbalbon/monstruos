extends Control

const CARD_DATA_PATH := "res://data/cartas_prototipo.json"
const CardViewScene = preload("res://src/card_view.gd")
const RouteEvents = preload("res://src/route_events.gd")
var save_store = preload("res://src/run_save.gd").new()
var persistence_enabled := true
var save_failed := false
const MAX_HP := 50
const MAX_ENERGY := 3
const HAND_TARGET := 5

const FACTION_COLORS := {
	"Humanos": Color("d5b66f"),
	"Hombres Lobo": Color("c98258"),
	"Vampiros": Color("c94f6d"),
	"Fantasmas": Color("73c6c8")
}

const FACTION_SUBTITLES := {
	"Humanos": "Preparación, fe y comunidad",
	"Hombres Lobo": "Furia, caza y manada",
	"Vampiros": "Sed, sangre y control",
	"Fantasmas": "Ectoplasma, ecos y posesión"
}

const STARTER_DECKS := {
	"Humanos": ["H001", "H001", "H001", "H001", "H003", "H003", "H003", "H003", "H002", "H007"],
	"Hombres Lobo": ["L001", "L001", "L001", "L001", "L029", "L029", "L029", "L029", "L002", "L018"],
	"Vampiros": ["V001", "V001", "V001", "V001", "V007", "V007", "V007", "V007", "V014", "V004"],
	"Fantasmas": ["F009", "F009", "F009", "F004", "F003", "F003", "F003", "F003", "F001", "F015"]
}

var cards_by_id: Dictionary = {}
var selected_faction := ""
var run_deck: Array[String] = []
var stage := 0
var screen := "title"
var encounter_name := "EL DESVELADO"
const ENEMY_PATTERNS := {
	0: [{"damage": 7}, {"damage": 10}, {"block": 7}, {"damage": 13}],
	1: [{"damage": 4, "hits": 2}, {"block": 4}, {"damage": 12}],
	2: [{"damage": 8, "block": 4}, {"block": 10}, {"damage": 14}],
	4: [{"damage": 9}, {"block": 8, "weak": 1, "ethereal": true}, {"damage": 6, "hits": 2}, {"damage": 16}]
}
const REWARDS := {
	"Humanos": ["H004", "H005", "H007", "H010", "H008", "H006", "H009"],
	"Hombres Lobo": ["L006", "L008", "L002", "L004", "L007", "L005", "L003"],
	"Vampiros": ["V005", "V006", "V014", "V009", "V002", "V003", "V008"],
	"Fantasmas": ["F004", "F006", "F001", "F005", "F002", "F008", "F007"]
}
var draw_pile: Array[Dictionary] = []
var discard_pile: Array[Dictionary] = []
var exhaust_pile: Array[Dictionary] = []
var hand: Array[Dictionary] = []

var player_hp := MAX_HP
var player_block := 0
var energy := MAX_ENERGY
var faction_resource := 0
var consecrated := 0
var last_attack_damage := 0
var last_attack_card: Dictionary = {}
var temporary_strength := 0
var player_weak := 0
var possession_active := false
var player_ethereal := false
var barricade_active := false
var active_powers: Array[String] = []
var hunter_triggered := false
var mist_triggered := false
var thirst_triggered := false
var pack_played := false
var allies: Array[Dictionary] = []
var hero_triggered := false
var last_enemy_card: Dictionary = {}
var enemy_ethereal := false

var enemy_hp := 48
var enemy_max_hp := 48
var enemy_block := 0
var enemy_weak := 0
var enemy_bleed := 0
var enemy_vulnerable := 0
var enemy_marked := false
var enemy_intent_damage := 0
var enemy_intent_hits := 1
var enemy_intent_block := 0
var enemy_intent_weak := 0
var enemy_intent_ethereal := false
var enemy_pattern := 0
var turn := 0
var battle_over := false
var choosing_card := false
const COMBAT_LOG_LIMIT := 200
var combat_log: Array[String] = []
var combat_stats: Dictionary = {}

var player_status: Label
var enemy_status: Label
var intent_label: Label
var message_label: Label
var pile_buttons: Dictionary = {}
var hand_box: HBoxContainer
var end_turn_button: Button
var battle_root: VBoxContainer

func _ready() -> void:
	if not _load_cards():
		_show_data_error()
		return
	show_title_screen()

func _load_cards() -> bool:
	if not FileAccess.file_exists(CARD_DATA_PATH):
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CARD_DATA_PATH))
	if not parsed is Dictionary or not parsed.has("cartas"):
		return false
	for card_variant in parsed["cartas"]:
		if card_variant is Dictionary and card_variant.has("id"):
			cards_by_id[card_variant["id"]] = card_variant
	for faction in STARTER_DECKS:
		for card_id in STARTER_DECKS[faction]:
			if not cards_by_id.has(card_id):
				return false
	return true

func _clear_screen() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

func _show_data_error() -> void:
	_clear_screen()
	var label := _make_label("No se pudo cargar data/cartas_prototipo.json", 26, Color("ff6b6b"))
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(label)

func _make_label(text_value: String, font_size: int, color := Color.WHITE) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _make_panel(color: Color, radius := 14) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _make_button(text_value: String, font_size := 18) -> Button:
	var button := Button.new()
	button.text = text_value
	button.add_theme_font_size_override("font_size", font_size)
	button.focus_mode = Control.FOCUS_ALL
	return button

func show_title_screen() -> void:
	screen = "title"
	_clear_screen()
	var background := ColorRect.new()
	background.color = Color("080b13")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(760, 0)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 18)
	center.add_child(content)

	var year := _make_label("ESPAÑA · 1897", 18, Color("a69d8a"))
	year.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(year)
	var title := _make_label("MONSTRUOS", 64, Color("d8bd79"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)
	var subtitle := _make_label("Las campanas de Valdegrís han tocado trece veces.", 23, Color("d7d9df"))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(subtitle)
	var description := _make_label("Elige quién responderá a la Desvelada.", 18, Color("9ea8b8"))
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(description)

	var start_button := _make_button("ELEGIR PROTAGONISTA", 21)
	start_button.custom_minimum_size = Vector2(0, 58)
	start_button.pressed.connect(show_faction_selection)
	content.add_child(start_button)
	var catalog_button := _make_button("CATÁLOGO DE CARTAS", 21)
	catalog_button.pressed.connect(_show_catalog)
	content.add_child(catalog_button)
	var guide_button := _make_button("GUÍA DE REGLAS", 21)
	guide_button.pressed.connect(_show_rules)
	content.add_child(guide_button)
	var saved: Dictionary = save_store.read(cards_by_id, STARTER_DECKS, REWARDS) if persistence_enabled else {}
	if not saved.is_empty() and saved.state != "finished":
		start_button.text = "NUEVA EXPEDICIÓN"
		var resume := _make_button("CONTINUAR · %s · Etapa %d" % [saved.faction, int(saved.stage) + 1], 21)
		resume.custom_minimum_size.y = 58
		resume.pressed.connect(_resume_run)
		content.add_child(resume)
		content.add_child(_make_label("Una nueva expedición sustituye el guardado al elegir estirpe.", 16))
	if not save_store.last_error.is_empty():
		content.add_child(_make_label(save_store.last_error, 16, Color("ee6b7a")))
	if save_failed:
		content.add_child(_make_label("El último guardado falló; continuar recuperará el anterior.", 16, Color("ee6b7a")))

func _checkpoint(state: String) -> void:
	if not persistence_enabled:
		return
	save_failed = not save_store.write({"version": 1, "state": state, "faction": selected_faction,
		"stage": stage, "hp": maxi(0, player_hp), "deck": run_deck})
	if save_failed:
		var warning := _make_label("No se pudo guardar. " + save_store.last_error, 16, Color("ee6b7a"))
		warning.position = Vector2(12, 2)
		add_child(warning)

func _resume_run() -> void:
	var saved: Dictionary = save_store.read(cards_by_id, STARTER_DECKS, REWARDS)
	if saved.is_empty() or saved.state == "finished":
		show_title_screen()
		return
	selected_faction = saved.faction
	run_deck.assign(saved.deck)
	player_hp = int(saved.hp)
	stage = int(saved.stage)
	if saved.state == "reward":
		screen = "won"
		show_rewards()
	else:
		show_route()

func _show_deck(pile_name := "", remove_at_camp := false) -> void:
	if has_node("RulesOverlay") or has_node("DeckOverlay") or choosing_card:
		return
	if remove_at_camp and (screen != "route" or stage != 3 or run_deck.size() <= 9):
		return
	var display_cards: Array[Dictionary] = []
	var heading := "TU MAZO"
	var description := "Composición de la expedición; incluye todas las copias."
	if pile_name.is_empty():
		for id in run_deck:
			display_cards.append(cards_by_id[id])
		if remove_at_camp:
			heading = "RETIRAR UNA CARTA"
			description = "Selecciona una copia para retirarla de esta expedición. Avanzarás al jefe SIN recuperar Salud."
	else:
		if screen not in ["battle", "won", "lost"]:
			return
		heading = pile_name.to_upper()
		match pile_name:
			"Robo":
				display_cards.assign(draw_pile)
				description = "Cartas pendientes de robar, ordenadas por nombre. No revela el orden de robo."
			"Descarte":
				display_cards.assign(discard_pile)
				description = "Se barajan para formar la pila de robo cuando esta se queda vacía."
			"Agotadas":
				display_cards.assign(exhaust_pile)
				description = "Fuera de circulación hasta el siguiente combate."
			"Poderes":
				for id in _active_power_ids():
					display_cards.append(cards_by_id[id])
				description = "Efectos persistentes activos durante este combate. No vuelven a las pilas."
			"Aliados":
				display_cards.assign(allies)
				description = "Cada copia permanece hasta terminar el combate. Sus efectos se acumulan."
			_: return
		display_cards.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.nombre) < str(b.nombre))
	var overlay := PanelContainer.new()
	overlay.name = "DeckOverlay"
	overlay.set_meta("camp_removal", remove_at_camp)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	overlay.add_child(box)
	box.add_child(_make_label("%s · %d cartas" % [heading, display_cards.size()], 28, Color("d8bd79")))
	var explanation := _make_label(description, 18)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(explanation)
	if display_cards.is_empty():
		box.add_child(_make_label("No hay cartas en esta pila.", 20))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(grid)
	for index in display_cards.size():
		var card: Dictionary = display_cards[index]
		var view := CardViewScene.new()
		view.setup(card, FACTION_COLORS[selected_faction], _card_art_path(card))
		view.focus_mode = Control.FOCUS_NONE
		if remove_at_camp:
			view.focus_mode = Control.FOCUS_ALL
			view.pressed.connect(_remove_card_at_camp.bind(index))
		grid.add_child(view)
	var close := _make_button("CERRAR MAZO" if pile_name.is_empty() else "VOLVER AL COMBATE")
	if remove_at_camp:
		close.text = "CANCELAR · VOLVER AL DESCANSO"
	close.custom_minimum_size.y = 48
	close.pressed.connect(overlay.queue_free)
	box.add_child(close)
	close.grab_focus()

func _remove_card_at_camp(index: int) -> void:
	if screen != "route" or stage != 3 or run_deck.size() <= 9 or index < 0 or index >= run_deck.size():
		return
	if not has_node("DeckOverlay") or not get_node("DeckOverlay").get_meta("camp_removal", false):
		return
	run_deck.remove_at(index)
	stage = 4
	show_route()

func _log_combat(entry: String) -> void:
	combat_log.append("[Turno %d] %s" % [turn, entry])
	if combat_log.size() > COMBAT_LOG_LIMIT:
		combat_log.pop_front()

func _show_history() -> void:
	if screen not in ["battle", "won", "lost"] or choosing_card or has_node("DeckOverlay") or has_node("RulesOverlay"):
		return
	var overlay := PanelContainer.new()
	overlay.name = "DeckOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var margin := MarginContainer.new()
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 24)
	overlay.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)
	box.add_child(_make_label("HISTORIAL · " + encounter_name, 28, Color("d8bd79")))
	box.add_child(_make_label("Últimos %d eventos del combate actual. No se guardan al salir." % COMBAT_LOG_LIMIT, 17))
	var entries := RichTextLabel.new()
	entries.name = "HistoryEntries"
	entries.size_flags_vertical = Control.SIZE_EXPAND_FILL
	entries.bbcode_enabled = false
	entries.selection_enabled = true
	entries.scroll_following = true
	entries.add_theme_font_size_override("normal_font_size", 18)
	box.add_child(entries)
	entries.text = "\n\n".join(combat_log)
	var close := _make_button("CERRAR HISTORIAL")
	close.custom_minimum_size.y = 48
	close.pressed.connect(overlay.queue_free)
	box.add_child(close)
	close.grab_focus()

func _show_catalog() -> void:
	if has_node("RulesOverlay") or has_node("CatalogOverlay") or choosing_card:
		return
	var overlay := PanelContainer.new()
	overlay.name = "CatalogOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var margin := MarginContainer.new()
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 20)
	overlay.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)
	box.add_child(_make_label("CATÁLOGO · CARTAS JUGABLES", 28, Color("d8bd79")))
	var explanation := _make_label("Consulta las cartas disponibles. No modifica tu mazo. Las recompensas se eligen tras vencer.", 17)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(explanation)
	var filter := OptionButton.new()
	filter.name = "FactionFilter"
	for faction in STARTER_DECKS:
		filter.add_item(faction)
	box.add_child(filter)
	var count := _make_label("", 16)
	count.name = "CardCount"
	box.add_child(count)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var grid := GridContainer.new()
	grid.name = "CatalogGrid"
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(grid)
	filter.item_selected.connect(func(index: int):
		_fill_catalog(grid, count, filter.get_item_text(index))
		scroll.scroll_vertical = 0
	)
	var factions: Array = STARTER_DECKS.keys()
	var initial := maxi(0, factions.find(selected_faction))
	filter.select(initial)
	_fill_catalog(grid, count, filter.get_item_text(initial))
	var close := _make_button("CERRAR CATÁLOGO")
	close.custom_minimum_size.y = 48
	close.pressed.connect(overlay.queue_free)
	box.add_child(close)
	close.grab_focus()

func _fill_catalog(grid: GridContainer, count: Label, faction: String) -> void:
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	var ids: Array[String] = []
	for id in STARTER_DECKS[faction] + REWARDS[faction]:
		if id not in ids:
			ids.append(id)
	ids.sort()
	count.text = "%s · %d cartas distintas · mejoras todavía no disponibles" % [faction, ids.size()]
	for id in ids:
		var entry := VBoxContainer.new()
		grid.add_child(entry)
		var view := CardViewScene.new()
		view.setup(cards_by_id[id], FACTION_COLORS[faction], _card_art_path(cards_by_id[id]))
		view.focus_mode = Control.FOCUS_NONE
		entry.add_child(view)
		var starter: bool = id in STARTER_DECKS[faction]
		var reward: bool = id in REWARDS[faction]
		var source := "Inicial + recompensa" if starter and reward else ("Mazo inicial" if starter else "Solo recompensa")
		var label := _make_label(source, 15, FACTION_COLORS[faction])
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		entry.add_child(label)

func _show_rules() -> void:
	if choosing_card or has_node("RulesOverlay") or has_node("MenuConfirmation") or has_node("DeckOverlay") or has_node("CatalogOverlay"):
		return
	add_child(preload("res://src/rules_guide.gd").new())

func _request_menu() -> void:
	if has_node("RulesOverlay") or choosing_card or has_node("MenuConfirmation") or has_node("DeckOverlay") or has_node("CatalogOverlay"):
		return
	if screen in ["route", "reward"]:
		_checkpoint(screen)
		if not save_failed:
			show_title_screen()
		return
	if screen != "battle":
		show_title_screen()
		return
	var saved: Dictionary = save_store.read(cards_by_id, STARTER_DECKS, REWARDS)
	var can_resume := not save_failed and not saved.is_empty()
	if can_resume:
		can_resume = saved.state == "route" and saved.faction == selected_faction and int(saved.stage) == stage and saved.deck == run_deck
	var dialog := ConfirmationDialog.new()
	dialog.name = "MenuConfirmation"
	dialog.title = "Salir del combate"
	dialog.dialog_text = "La expedición está guardada antes de este combate.\nAl continuar se reiniciará el encuentro con la Salud de entonces.\nLos turnos de este combate no se conservarán."
	dialog.ok_button_text = "Salir al menú"
	dialog.cancel_button_text = "Seguir jugando"
	if not can_resume:
		dialog.dialog_text = "No hay un guardado válido de este encuentro.\nLa salida se ha cancelado para conservar la partida abierta."
		dialog.get_ok_button().disabled = true
	dialog.confirmed.connect(show_title_screen)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered(Vector2i(620, 210))

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		if has_node("RulesOverlay"):
			get_node("RulesOverlay").close()
		elif has_node("CatalogOverlay"):
			get_node("CatalogOverlay").queue_free()
		elif has_node("DeckOverlay"):
			get_node("DeckOverlay").queue_free()
		elif screen == "event":
			show_route()
		elif screen in ["battle", "route", "reward"]:
			_request_menu()
		get_viewport().set_input_as_handled()

func _add_save_status(box: VBoxContainer) -> void:
	var status := "Guardado automático realizado · puedes continuar desde el menú."
	if save_failed:
		status = "Guardado pendiente: no se ha podido escribir. Volver al menú reintentará el guardado."
	var label := _make_label(status, 15, Color("ee6b7a") if save_failed else Color("79d98c"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(label)

func show_faction_selection() -> void:
	_clear_screen()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 64)
	margin.add_theme_constant_override("margin_right", 64)
	margin.add_theme_constant_override("margin_top", 42)
	margin.add_theme_constant_override("margin_bottom", 42)
	add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 22)
	margin.add_child(root)

	var heading := _make_label("ELIGE UNA ESTIRPE", 36, Color("d8bd79"))
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(heading)
	var cards := GridContainer.new()
	cards.columns = 2
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards.add_theme_constant_override("h_separation", 20)
	cards.add_theme_constant_override("v_separation", 20)
	root.add_child(cards)

	for faction in STARTER_DECKS:
		var panel := _make_panel(Color(FACTION_COLORS[faction], 0.16))
		panel.custom_minimum_size = Vector2(540, 220)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		cards.add_child(panel)
		var box := VBoxContainer.new()
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		box.add_theme_constant_override("separation", 10)
		panel.add_child(box)
		var name_label := _make_label(faction.to_upper(), 28, FACTION_COLORS[faction])
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(name_label)
		var role := _make_label(FACTION_SUBTITLES[faction], 17, Color("c8ccd5"))
		role.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(role)
		var choose := _make_button("JUGAR", 18)
		choose.custom_minimum_size = Vector2(0, 48)
		choose.pressed.connect(start_run.bind(faction))
		box.add_child(choose)

	var back := _make_button("Volver", 16)
	back.pressed.connect(show_title_screen)
	root.add_child(back)

func start_run(faction: String) -> void:
	selected_faction = faction
	run_deck.assign(STARTER_DECKS[faction])
	player_hp = MAX_HP
	stage = 0
	show_route()

func _journey_panel(title: String, description: String) -> VBoxContainer:
	_clear_screen()
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(900, 0)
	box.add_theme_constant_override("separation", 18)
	center.add_child(box)
	box.add_child(_make_label(title, 32, Color("d8bd79")))
	box.add_child(_make_label(description, 18))
	box.add_child(_make_label("%s · Salud %d/%d · Mazo %d cartas" % [selected_faction, player_hp, MAX_HP, run_deck.size()], 18))
	return box

func show_route() -> void:
	screen = "route"
	var box := _journey_panel("EL CAMINO A SANTA VIGILIA", "Aldea → Sendero, refugio o ermita → Estación → Descanso → Monasterio")
	var labels := ["Aldea: enfrentarse al Desvelado", "Sendero: combatir al Acechador", "Estación: combatir al Guardagujas", "Descansar junto al fuego (+15 Salud)", "Monasterio: enfrentarse al Custodio"]
	for index in labels.size():
		var button := _make_button(("✓ " if index < stage else "") + str(labels[index]))
		button.disabled = index != stage
		button.custom_minimum_size.y = 48
		button.pressed.connect(_enter_stage)
		box.add_child(button)
	if stage == 1:
		var alternatives := HBoxContainer.new()
		box.add_child(alternatives)
		var rest := _make_button("Refugio: +12 Salud, sin combate ni carta")
		rest.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rest.pressed.connect(_rest.bind(12))
		alternatives.add_child(rest)
		var event_button := _make_button("Investigar la ermita")
		event_button.name = "HermitageButton"
		event_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		event_button.pressed.connect(_show_hermitage)
		alternatives.add_child(event_button)
	if stage == 3:
		var refine := _make_button("Alternativa: retirar una carta del mazo SIN recuperar Salud")
		refine.name = "RefineDeckButton"
		refine.disabled = run_deck.size() <= 9
		refine.pressed.connect(_show_deck.bind("", true))
		box.add_child(refine)
	var deck_button := _make_button("VER MAZO")
	deck_button.pressed.connect(_show_deck)
	var collection_buttons := HBoxContainer.new()
	box.add_child(collection_buttons)
	deck_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	collection_buttons.add_child(deck_button)
	var catalog_button := _make_button("CATÁLOGO DE CARTAS")
	catalog_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	catalog_button.pressed.connect(_show_catalog)
	collection_buttons.add_child(catalog_button)
	var guide := _make_button("GUÍA DE REGLAS")
	guide.pressed.connect(_show_rules)
	collection_buttons.add_child(guide)
	var menu := _make_button("GUARDAR Y VOLVER AL MENÚ")
	menu.pressed.connect(_request_menu)
	box.add_child(menu)
	_checkpoint("route")
	_add_save_status(box)

func _show_hermitage() -> void:
	if screen != "route" or stage != 1:
		return
	screen = "event"
	var event: Dictionary = RouteEvents.HERMITAGE[selected_faction]
	var card: Dictionary = cards_by_id[event.card]
	var box := _journey_panel("LA ERMITA DE LOS NOMBRES", "Una campana sin badajo suena al borde del camino.")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	var story := _make_label(str(event.story) + "\n\nAyudar cuesta 8 Salud y añade la carta mostrada a tu mazo. Escuchar recupera 12 Salud sin añadir cartas. Ambas opciones sustituyen al Acechador y avanzan a la estación.", 20)
	story.name = "EventStory"
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(story)
	var preview := CardViewScene.new()
	preview.setup(card, FACTION_COLORS[selected_faction], _card_art_path(card))
	preview.disabled = true
	row.add_child(preview)
	var help_button := _make_button("Ayudar: −8 Salud · obtener " + str(card.nombre))
	help_button.name = "HelpApparitionButton"
	help_button.disabled = player_hp <= RouteEvents.HERMITAGE_COST
	help_button.tooltip_text = "Necesitas al menos 9 Salud: esta decisión no puede matarte."
	help_button.pressed.connect(_resolve_hermitage.bind("help"))
	box.add_child(help_button)
	var listen := _make_button("Escuchar su historia: +12 Salud · sin carta")
	listen.name = "ListenApparitionButton"
	listen.pressed.connect(_resolve_hermitage.bind("listen"))
	box.add_child(listen)
	var back := _make_button("Volver al cruce sin decidir · Esc")
	back.pressed.connect(show_route)
	box.add_child(back)
	back.grab_focus()

func _resolve_hermitage(choice: String) -> void:
	if screen != "event" or stage != 1:
		return
	if choice == "help":
		if player_hp <= RouteEvents.HERMITAGE_COST:
			return
		player_hp -= RouteEvents.HERMITAGE_COST
		run_deck.append(str(RouteEvents.HERMITAGE[selected_faction].card))
	elif choice == "listen":
		player_hp = mini(MAX_HP, player_hp + RouteEvents.HERMITAGE_HEAL)
	else:
		return
	stage += 1
	show_route() # Same checkpoint format: health, card and advanced stage together.

func _enter_stage() -> void:
	if screen != "route":
		return
	if stage == 3:
		_rest(15)
		return
	encounter_name = str({0: "EL DESVELADO", 1: "EL ACECHADOR", 2: "EL GUARDAGUJAS", 4: "EL CUSTODIO"}.get(stage, "EL DESVELADO"))
	enemy_max_hp = int({0: 36, 1: 40, 2: 44, 4: 58}.get(stage, 36))
	start_battle(selected_faction)

func _rest(amount: int) -> void:
	if screen != "route" or stage not in [1, 3]:
		return
	player_hp = mini(MAX_HP, player_hp + amount)
	stage += 1
	show_route()

func show_rewards() -> void:
	if screen != "won":
		return
	screen = "reward"
	var box := _journey_panel("ELIGE UNA RECOMPENSA", "Añade una carta a tu mazo para los siguientes encuentros.")
	box.custom_minimum_size.x = 960
	if REWARDS[selected_faction].size() > 4:
		box.add_child(_make_label("Desplaza la barra horizontal para ver todas las recompensas.", 16))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.y = 280
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	scroll.add_child(row)
	for id in REWARDS[selected_faction]:
		var card: Dictionary = cards_by_id[id]
		var view := CardViewScene.new()
		view.setup(card, FACTION_COLORS[selected_faction], _card_art_path(card))
		view.pressed.connect(_take_reward.bind(str(id)))
		row.add_child(view)
	var skip := _make_button("Continuar sin añadir carta")
	skip.pressed.connect(_take_reward.bind(""))
	box.add_child(skip)
	_checkpoint("reward")
	var menu := _make_button("GUARDAR Y ELEGIR LA RECOMPENSA MÁS TARDE")
	menu.pressed.connect(_request_menu)
	box.add_child(menu)
	_add_save_status(box)

func _take_reward(id: String) -> void:
	if screen != "reward":
		return
	if not id.is_empty():
		if id not in REWARDS[selected_faction]:
			return
		run_deck.append(id)
	stage += 1
	show_route()

func start_battle(faction: String) -> void:
	combat_stats = {"cards": 0, "energy": 0, "damage": 0, "bleed": 0,
		"received": 0, "self_damage": 0, "blocked": 0, "avoided": 0,
		"healed": 0, "starting_hp": player_hp}
	selected_faction = faction
	screen = "battle"
	draw_pile.clear()
	discard_pile.clear()
	exhaust_pile.clear()
	hand.clear()
	for card_id in run_deck:
		draw_pile.append(cards_by_id[card_id].duplicate(true))
	draw_pile.shuffle()
	player_block = 0
	energy = MAX_ENERGY
	faction_resource = 0
	consecrated = 0
	last_attack_damage = 0
	last_attack_card.clear()
	temporary_strength = 0
	player_weak = 0
	possession_active = false
	player_ethereal = false
	barricade_active = false
	active_powers.clear()
	allies.clear()
	hero_triggered = false
	last_enemy_card.clear()
	enemy_ethereal = false
	hunter_triggered = false
	mist_triggered = false
	thirst_triggered = false
	enemy_hp = enemy_max_hp
	enemy_block = 0
	enemy_weak = 0
	enemy_bleed = 0
	enemy_vulnerable = 0
	enemy_marked = false
	enemy_pattern = 0
	turn = 0
	combat_log.clear()
	_log_combat("Comienza el combate contra %s. Salud: %d/%d." % [encounter_name, player_hp, MAX_HP])
	battle_over = false
	choosing_card = false
	_build_battle_screen()
	_begin_player_turn()

func _build_battle_screen() -> void:
	_clear_screen()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)
	battle_root = VBoxContainer.new()
	battle_root.add_theme_constant_override("separation", 12)
	margin.add_child(battle_root)

	var header := HBoxContainer.new()
	battle_root.add_child(header)
	var title := _make_label("MONSTRUOS", 25, Color("d8bd79"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var faction_label := _make_label(selected_faction.to_upper(), 20, FACTION_COLORS[selected_faction])
	header.add_child(faction_label)
	var deck_button := _make_button("VER MAZO", 16)
	deck_button.pressed.connect(_show_deck)
	header.add_child(deck_button)
	var guide_button := _make_button("REGLAS", 16)
	guide_button.pressed.connect(_show_rules)
	header.add_child(guide_button)
	var menu_button := _make_button("SALIR AL MENÚ", 16)
	menu_button.tooltip_text = "Al continuar se reiniciará este combate desde el último guardado."
	menu_button.pressed.connect(_request_menu)
	header.add_child(menu_button)

	var battlefield := HBoxContainer.new()
	battlefield.size_flags_vertical = Control.SIZE_EXPAND_FILL
	battlefield.add_theme_constant_override("separation", 22)
	battle_root.add_child(battlefield)

	var player_panel := _make_panel(Color("141c2b"))
	player_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	battlefield.add_child(player_panel)
	var player_box := VBoxContainer.new()
	player_box.alignment = BoxContainer.ALIGNMENT_CENTER
	player_box.add_theme_constant_override("separation", 12)
	player_panel.add_child(player_box)
	var protagonist := _make_label(_protagonist_name(), 29, FACTION_COLORS[selected_faction])
	protagonist.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_box.add_child(protagonist)
	player_status = _make_label("", 19)
	player_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_box.add_child(player_status)

	var enemy_panel := _make_panel(Color("301823"))
	enemy_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	battlefield.add_child(enemy_panel)
	var enemy_box := VBoxContainer.new()
	enemy_box.alignment = BoxContainer.ALIGNMENT_CENTER
	enemy_box.add_theme_constant_override("separation", 12)
	enemy_panel.add_child(enemy_box)
	var enemy_name := _make_label(encounter_name, 29, Color("e3677e"))
	enemy_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_box.add_child(enemy_name)
	enemy_status = _make_label("", 19)
	enemy_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_box.add_child(enemy_status)
	intent_label = _make_label("", 18, Color("f0c36a"))
	intent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intent_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	enemy_box.add_child(intent_label)

	message_label = _make_label("", 17, Color("cbd2df"))
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battle_root.add_child(message_label)
	var piles_row := HBoxContainer.new()
	piles_row.add_theme_constant_override("separation", 10)
	battle_root.add_child(piles_row)
	pile_buttons.clear()
	for pile_name in ["Robo", "Descarte", "Agotadas", "Poderes", "Aliados"]:
		var button := _make_button("", 14)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.tooltip_text = "Consultar cartas: " + pile_name
		button.pressed.connect(_show_deck.bind(pile_name))
		piles_row.add_child(button)
		pile_buttons[pile_name] = button
	var history_button := _make_button("HISTORIAL", 14)
	history_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	history_button.pressed.connect(_show_history)
	piles_row.add_child(history_button)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 276)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	battle_root.add_child(scroll)
	hand_box = HBoxContainer.new()
	hand_box.alignment = BoxContainer.ALIGNMENT_CENTER
	hand_box.add_theme_constant_override("separation", 10)
	scroll.add_child(hand_box)

	end_turn_button = _make_button("TERMINAR TURNO", 18)
	end_turn_button.custom_minimum_size = Vector2(0, 48)
	end_turn_button.pressed.connect(_end_turn)
	battle_root.add_child(end_turn_button)

func _protagonist_name() -> String:
	match selected_faction:
		"Humanos": return "INÉS VALCÁRCEL"
		"Hombres Lobo": return "TOMÁS DE ARCE"
		"Vampiros": return "LEONOR DE MONTENEGRO"
		_: return "CLARA"

func _begin_player_turn() -> void:
	turn += 1
	hero_triggered = false
	pack_played = false
	hunter_triggered = false
	mist_triggered = false
	thirst_triggered = false
	if not barricade_active:
		player_block = 0
	energy = MAX_ENERGY
	last_attack_damage = 0
	last_attack_card.clear()
	_set_enemy_intent()
	if "L007" in active_powers:
		temporary_strength += 1
		_log_combat("Luna Llena: +1 Fuerza durante este turno y +1 Furia.")
		_gain_fury(1)
		if player_hp <= 0:
			_finish_battle(false)
			return
	_draw_to_hand(HAND_TARGET)
	message_label.text = "Turno %d. La criatura revela su intención." % turn
	_log_combat("Inicio de turno. " + _enemy_intent_text())
	_refresh_battle()

func _set_enemy_intent() -> void:
	var pattern: Array = ENEMY_PATTERNS.get(stage, ENEMY_PATTERNS[0])
	var action: Dictionary = pattern[enemy_pattern % pattern.size()]
	enemy_intent_damage = int(action.get("damage", 0))
	enemy_intent_hits = int(action.get("hits", 1))
	enemy_intent_block = int(action.get("block", 0))
	enemy_intent_weak = int(action.get("weak", 0))
	enemy_intent_ethereal = bool(action.get("ethereal", false))

func _enemy_hit_damage() -> int:
	if enemy_intent_damage <= 0:
		return 0
	var damage := maxi(1, floori(enemy_intent_damage * 0.75)) if enemy_weak > 0 else enemy_intent_damage
	return maxi(1, floori(damage * 0.5)) if possession_active else damage

func _enemy_intent_text() -> String:
	var parts: Array[String] = []
	if enemy_intent_damage > 0:
		var attack := "atacar por %d" % _enemy_hit_damage()
		if enemy_intent_hits > 1:
			attack += " × %d" % enemy_intent_hits
		parts.append(attack)
		if player_ethereal:
			parts.append("Etéreo evitará el primer golpe")
	if enemy_intent_block > 0:
		parts.append("ganar %d Bloqueo" % enemy_intent_block)
	if enemy_intent_weak > 0:
		parts.append("aplicar %d Débil" % enemy_intent_weak)
	if enemy_intent_ethereal:
		parts.append("obtener Etéreo")
	return "Intención: " + " · ".join(parts)

func _draw_to_hand(target_size: int) -> void:
	while hand.size() < target_size:
		if not _ensure_draw_card():
			break
		hand.append(draw_pile.pop_back())

func _draw_cards(amount: int) -> void:
	for index in amount:
		if not _ensure_draw_card():
			return
		hand.append(draw_pile.pop_back())

func _ensure_draw_card() -> bool:
	if draw_pile.is_empty():
		if discard_pile.is_empty():
			return false
		draw_pile.assign(discard_pile)
		discard_pile.clear()
		draw_pile.shuffle()
	return true

func _card_cost(card: Dictionary) -> int:
	var cost := int(card["coste"])
	if card["id"] == "L005" and pack_played:
		cost -= 1
	if "L003" in active_powers and not pack_played and "Manada" in card.get("etiquetas", []):
		cost -= 1
	return maxi(0, cost)

func _can_play(card: Dictionary) -> bool:
	return _play_block_reason(card).is_empty()

func _play_block_reason(card: Dictionary) -> String:
	if battle_over:
		return "El combate ha terminado."
	if choosing_card:
		return "Termina primero la elección del Murciélago Espía."
	if card["id"] in _active_power_ids():
		return "Este poder ya está activo durante el combate."
	var reasons: Array[String] = []
	var cost := _card_cost(card)
	if energy < cost:
		reasons.append("Necesitas %d Ímpetu; tienes %d." % [cost, energy])
	match str(card.id):
		"V008":
			if last_enemy_card.is_empty():
				reasons.append("El enemigo todavía no ha ejecutado ninguna carta que puedas copiar.")
			elif last_enemy_card.get("faccion") == "Vampiros":
				reasons.append("La última carta enemiga es vampírica y no puede copiarse.")
		"F002", "F008", "F015":
			var needed := 3 if card.id == "F008" else 2
			if faction_resource < needed:
				reasons.append("Necesitas %d Ectoplasma; tienes %d." % [needed, faction_resource])
			if card.id == "F002":
				if possession_active:
					reasons.append("Posesión ya está activa; no se acumula.")
				if enemy_intent_damage <= 0:
					reasons.append("El enemigo debe anunciar un ataque para usar Posesión.")
			if card.id == "F008" and player_ethereal:
				reasons.append("Ya tienes Etéreo; no se acumula.")
			if card.id == "F015" and last_attack_card.is_empty():
				reasons.append("Juega primero un Ataque en este turno para repetirlo.")
	return "\n".join(reasons)

func _play_card(card: Dictionary) -> void:
	if not hand.has(card):
		message_label.text = "Esa carta ya no está en tu mano."
		return
	var blocked := _play_block_reason(card)
	if not blocked.is_empty():
		message_label.text = blocked.replace("\n", " ")
		return
	var paid_cost := _card_cost(card)
	energy -= paid_cost
	combat_stats.cards += 1
	combat_stats.energy += paid_cost
	var card_id: String = card["id"]
	var exhausts := card_id in ["L018", "V008", "V014", "F001", "F008", "F015"]
	var action_message: String = str(card["nombre"]) + ": "
	_log_combat("Juegas %s (coste %d)." % [card["nombre"], paid_cost])
	# Remove before drawing so this exact instance cannot be selected twice.
	hand.erase(card)
	if "Manada" in card.get("etiquetas", []):
		pack_played = true

	match card_id:
		"H001", "H007", "L001", "L004", "L005", "L006", "L008", "V001", "V005", "V006", "F004", "F005", "F009", "ENEMY_ACTION":
			action_message += _resolve_attack_card(card)
		"H006":
			action_message += "la Milicia permanece junto a tus aliados."
		"H009":
			action_message += _gain_block(8) + " Héroe Local permanece en juego."
		"F007":
			enemy_weak += 2
			faction_resource = mini(8, faction_resource + 2)
			action_message += "2 de Débil y 2 de Ectoplasma."
		"V008":
			var copy := last_enemy_card.duplicate(true)
			copy.coste = maxi(0, int(copy.coste) - 1)
			copy.temporal = true
			hand.append(copy)
			action_message += "creas " + str(copy.nombre) + " temporal (coste %d)." % int(copy.coste)
		"H008", "L003", "L007", "V002", "V003":
			active_powers.append(card_id)
			action_message += "poder activo durante este combate."
		"F002":
			faction_resource -= 2
			possession_active = true
			action_message += "reduces a la mitad cada golpe de la intención actual."
		"F008":
			faction_resource -= 3
			player_ethereal = true
			action_message += "Etéreo: evitarás el siguiente golpe. Agota."
		"H010":
			barricade_active = true
			action_message += "conservas el Bloqueo entre turnos durante este combate."
		"V009":
			enemy_weak += 2
			_gain_thirst(1)
			action_message += "2 de Débil y 1 de Sed."
		"H004":
			action_message += _deal_damage(3)
			_apply_vulnerable(2)
		"H005":
			enemy_weak += 1
			_draw_cards(1)
			action_message += "Débil y robo de una carta."
		"F006":
			enemy_weak += 2
			faction_resource = mini(8, faction_resource + 1)
			action_message += "2 de Débil y 1 de Ectoplasma."
		"H002":
			player_block += 4
			consecrated += 1
			action_message += "4 de Bloqueo y Consagración."
		"H003": action_message += _gain_block(5)
		"L002":
			_gain_fury(2)
			enemy_weak += 1
			action_message += "2 de Furia y 1 de Débil."
		"L018":
			enemy_marked = true
			_draw_cards(1)
			action_message += "el enemigo queda Marcado. Robas 1 carta."
		"L029": action_message += _gain_block(5)
		"V004":
			action_message += "examina las próximas cartas."
			_start_scout()
		"V007": action_message += _gain_block(5)
		"V014":
			faction_resource = maxi(0, faction_resource - 2)
			_draw_cards(1)
			action_message += "reduces la Sed y robas 1 carta."
		"F001":
			faction_resource = mini(8, faction_resource + 1)
			_draw_cards(1)
			action_message += "1 de Ectoplasma y robas 1 carta."
		"F003": action_message += _gain_block(5)
		"F015":
			faction_resource -= 2
			action_message += _resolve_attack_card(last_attack_card, 0.5) + " mediante Eco."
	if str(card.tipo) == "Ataque":
		last_attack_card = card.duplicate(true)

	if "V002" in active_powers and not mist_triggered and "Niebla" in card.get("etiquetas", []):
		mist_triggered = true
		player_block += 3
		_log_combat("Niebla Eterna: +3 Bloqueo por la primera carta de Niebla del turno.")
	if str(card.tipo) == "Aliado":
		allies.append(card)
	elif card_id in _active_power_ids():
		pass # Persistent power: leaves the piles until the next combat.
	elif exhausts:
		exhaust_pile.append(card)
	else:
		discard_pile.append(card)
	message_label.text = action_message
	_log_combat(action_message)
	_log_combat("Estado: Salud %d, Bloqueo %d, Ímpetu %d, %s. Enemigo: Salud %d, Bloqueo %d, Débil %d, Vulnerable %d, Sangrado %d." % [maxi(0, player_hp), player_block, energy, _resource_text(), enemy_hp, enemy_block, enemy_weak, enemy_vulnerable, enemy_bleed])
	if player_hp <= 0:
		_finish_battle(false)
	elif enemy_hp <= 0:
		_finish_battle(true)
	else:
		_refresh_battle()

func _active_power_ids() -> Array[String]:
	var ids: Array[String] = active_powers.duplicate()
	if barricade_active:
		ids.append("H010")
	return ids

func _apply_vulnerable(amount: int) -> void:
	enemy_vulnerable += amount
	if "H008" in active_powers and not hunter_triggered:
		hunter_triggered = true
		_draw_cards(1)
		_log_combat("Cazador Experto: robas 1 carta por aplicar Vulnerable.")

func _potency(amount: int, scale: float) -> int:
	return maxi(1, floori(amount * scale)) if amount > 0 else 0

func _resolve_attack_card(card: Dictionary, scale := 1.0) -> String:
	var id: String = card.id
	var damage: int = {"H001": 6, "H007": 7, "L001": 6, "L004": 5, "L005": 4, "L006": 4, "L008": 8, "V001": 6, "V005": 10, "V006": 8, "F004": 4, "F005": 7, "F009": 6}.get(id, int(card.get("damage", 0)))
	var hits: int = 3 if id == "L005" else int(card.get("hits", 1))
	if id == "L008" and not allies.is_empty():
		damage -= 4
	if id == "H007":
		enemy_ethereal = false
	var results: Array[String] = []
	for hit in hits:
		if enemy_hp <= 0 or damage <= 0:
			break
		var bonus := 3 if id == "H001" and enemy_vulnerable > 0 else 0
		var result := _attack(damage, bonus, scale)
		results.append(result)
		if hits > 1:
			_log_combat("%s · golpe %d: %s" % [card.nombre, hit + 1, result])
	match id:
		"L004":
			enemy_bleed += _potency(2, scale)
			_gain_fury(_potency(1, scale))
		"L006":
			enemy_weak += _potency(2, scale)
			if faction_resource >= 2:
				faction_resource -= 2
				enemy_bleed += _potency(2, scale)
		"V005":
			_heal_health(_potency(3, scale))
			faction_resource = maxi(0, faction_resource - _potency(2, scale))
		"V006": _gain_thirst(_potency(1, scale))
		"F004": faction_resource = mini(8, faction_resource + _potency(1, scale))
		"F005":
			if faction_resource >= 3:
				_apply_vulnerable(_potency(1, scale))
		"ENEMY_ACTION":
			player_block += _potency(int(card.block), scale)
			enemy_weak += _potency(int(card.weak), scale)
			if card.get("ethereal", false):
				player_ethereal = true
	return " / ".join(results) if not results.is_empty() else "efectos aplicados."

func _attack(base_damage: int, bonus_damage := 0, scale := 1.0) -> String:
	var damage := base_damage + bonus_damage + temporary_strength
	if consecrated > 0:
		damage += 3
		consecrated -= 1
	if player_weak > 0:
		damage = maxi(1, floori(damage * 0.75))
	damage = _potency(damage, scale)
	var dealt := _deal_damage(damage, true)
	last_attack_damage = damage
	return dealt

func _gain_thirst(amount: int) -> void:
	var previous := faction_resource
	faction_resource = clampi(faction_resource + amount, 0, 10)
	if faction_resource > previous and "V003" in active_powers and not thirst_triggered:
		thirst_triggered = true
		var previous_hand := hand.size()
		_draw_cards(1)
		_log_combat("Sed Insaciable: robas %d carta al aumentar la Sed." % (hand.size() - previous_hand))

func _gain_fury(amount: int) -> void:
	faction_resource = mini(10, faction_resource + amount)
	if faction_resource == 10:
		faction_resource = 5
		_lose_health(3, "self_damage")
		temporary_strength += 2
		_log_combat("Descontrol: coste de 3 Salud, Furia vuelve a 5 y Fuerza +2.")

func _deal_damage(amount: int, is_attack := false) -> String:
	var modified := amount
	if is_attack and enemy_vulnerable > 0:
		modified = floori(modified * 1.5)
	if is_attack and enemy_ethereal and modified > 0:
		enemy_ethereal = false
		return "0 de daño (Etéreo)."
	var absorbed := mini(enemy_block, modified)
	enemy_block -= absorbed
	var health_damage := mini(enemy_hp, modified - absorbed)
	enemy_hp = maxi(0, enemy_hp - health_damage)
	combat_stats.damage += health_damage
	return "%d de daño." % health_damage

func _lose_health(amount: int, source: String) -> int:
	var lost := mini(maxi(0, player_hp), maxi(0, amount))
	player_hp -= lost
	combat_stats[source] += lost
	return lost

func _heal_health(amount: int) -> void:
	var healed := mini(MAX_HP - player_hp, maxi(0, amount))
	player_hp += healed
	combat_stats.healed += healed

func _gain_block(amount: int) -> String:
	player_block += amount
	return "%d de Bloqueo." % amount

func _start_scout() -> void:
	var choices: Array[Dictionary] = []
	for index in 2:
		if _ensure_draw_card():
			choices.append(draw_pile.pop_back())
	if choices.is_empty():
		return
	if choices.size() == 1:
		hand.append(choices[0])
		return
	choosing_card = true
	var overlay := ColorRect.new()
	overlay.name = "ScoutOverlay"
	overlay.color = Color(0.01, 0.01, 0.02, 0.9)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(520, 0)
	box.add_theme_constant_override("separation", 14)
	center.add_child(box)
	var title := _make_label("MURCIÉLAGO ESPÍA · ELIGE UNA CARTA", 22, Color("d8bd79"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	for index in choices.size():
		var choice: Dictionary = choices[index]
		var button := _make_button("%s  [%d]\n%s" % [choice["nombre"], choice["coste"], choice["efecto"]], 16)
		button.custom_minimum_size = Vector2(0, 82)
		button.pressed.connect(_resolve_scout.bind(index, choices, overlay))
		box.add_child(button)

func _resolve_scout(index: int, choices: Array[Dictionary], overlay: ColorRect) -> void:
	if not choosing_card:
		return
	var chosen: Dictionary = choices[index]
	hand.append(chosen)
	for other in choices.size():
		if other != index:
			draw_pile.append(choices[other])
	choosing_card = false
	overlay.queue_free()
	message_label.text = "El Murciélago Espía trae %s a tu mano." % chosen["nombre"]
	_log_combat(message_label.text)
	_refresh_battle()

func _ally_count(id: String) -> int:
	var count := 0
	for ally in allies:
		if ally.id == id:
			count += 1
	return count

func _enemy_action_card() -> Dictionary:
	# Enemy turns are explicit cards, so Conversion copies the action actually
	# played, not a future intention or an unrelated player card.
	var faction: String = {0: "Fantasmas", 1: "Hombres Lobo", 2: "Humanos", 4: "Fantasmas"}.get(stage, "Fantasmas")
	return {"id": "ENEMY_ACTION", "nombre": "%s · acción %d" % [encounter_name.capitalize(), enemy_pattern % ENEMY_PATTERNS.get(stage, ENEMY_PATTERNS[0]).size() + 1],
		"faccion": faction, "tipo": "Ataque" if enemy_intent_damage > 0 else "Habilidad", "rareza": "Enemiga", "coste": 2,
		"damage": enemy_intent_damage, "hits": enemy_intent_hits, "block": enemy_intent_block, "weak": enemy_intent_weak, "ethereal": enemy_intent_ethereal,
		"efecto": ("%d daño × %d. Obtén %d Bloqueo y aplica %d Débil." % [enemy_intent_damage, enemy_intent_hits, enemy_intent_block, enemy_intent_weak]) + (" Obtén Etéreo." if enemy_intent_ethereal else ""),
		"mejora": "Sin mejora: carta enemiga.", "etiquetas": []}

func _end_turn() -> void:
	if battle_over or choosing_card:
		return
	discard_pile.append_array(hand)
	hand.clear()
	# Expire player-turn effects before resolving the enemy. Descontrol caused
	# by the enemy therefore remains available for the next player turn.
	temporary_strength = 0
	player_weak = maxi(0, player_weak - 1)
	var militia_count := _ally_count("H006")
	if militia_count > 0:
		var militia_block := 3 * allies.size() * militia_count
		player_block += militia_block
		_log_combat("Milicia Organizada: +%d Bloqueo por %d aliados." % [militia_block, allies.size()])
	last_enemy_card = _enemy_action_card()
	_log_combat("El enemigo juega " + str(last_enemy_card.nombre) + ".")
	_log_combat("Fin del turno del jugador. " + _enemy_intent_text())
	var total_damage := 0
	var incoming := _enemy_hit_damage()
	for hit in enemy_intent_hits:
		if incoming == 0 or player_hp <= 0 or enemy_hp <= 0:
			break
		if player_ethereal:
			player_ethereal = false
			combat_stats.avoided += incoming
			_log_combat("Etéreo evita el golpe %d/%d sin consumir Bloqueo." % [hit + 1, enemy_intent_hits])
			continue
		var absorbed := mini(player_block, incoming)
		player_block -= absorbed
		combat_stats.blocked += absorbed
		var health_damage := _lose_health(incoming - absorbed, "received")
		total_damage += health_damage
		_log_combat("Golpe %d/%d: %d de daño, %d absorbido por Bloqueo, pierdes %d Salud." % [hit + 1, enemy_intent_hits, incoming, absorbed, health_damage])
		if selected_faction == "Hombres Lobo" and health_damage > 0:
			_gain_fury(1)
		if health_damage > 0 and not hero_triggered and _ally_count("H009") > 0:
			hero_triggered = true
			_log_combat("Héroe Local contraataca: " + _deal_damage(4 * _ally_count("H009")))
	possession_active = false
	message_label.text = "%s: recibes %d de daño de ataques." % [encounter_name, total_damage]
	if player_hp > 0 and enemy_hp > 0:
		enemy_block += enemy_intent_block
		player_weak += enemy_intent_weak
		if enemy_intent_ethereal:
			enemy_ethereal = true
			message_label.text += " Obtiene Etéreo."
		if enemy_intent_block > 0:
			message_label.text += " Gana %d Bloqueo." % enemy_intent_block
		if enemy_intent_weak > 0:
			message_label.text += " Te aplica %d Débil." % enemy_intent_weak
	if enemy_weak > 0:
		enemy_weak -= 1
	if enemy_vulnerable > 0:
		enemy_vulnerable -= 1
	if selected_faction == "Vampiros" and faction_resource >= 8:
		_lose_health(2, "self_damage")
		message_label.text += " La Sed te causa 2 de daño."
		if faction_resource == 10:
			player_weak += 1
			message_label.text += " La Sed máxima te aplica 1 Débil."
	enemy_pattern += 1
	if enemy_bleed > 0:
		_log_combat("Sangrado: el enemigo pierde %d Salud." % mini(enemy_hp, enemy_bleed))
	combat_stats.bleed += mini(enemy_hp, enemy_bleed)
	enemy_hp = maxi(0, enemy_hp - enemy_bleed)
	enemy_bleed = maxi(0, enemy_bleed - 1)
	_log_combat(message_label.text)
	if player_hp <= 0:
		_finish_battle(false)
	elif enemy_hp <= 0:
		_finish_battle(true)
	else:
		var enemy_report := message_label.text
		_begin_player_turn()
		if not battle_over:
			message_label.text = enemy_report + " Turno %d." % turn

func _resource_text() -> String:
	match selected_faction:
		"Hombres Lobo": return "Furia %d/10" % faction_resource
		"Vampiros": return "Sed %d/10" % faction_resource
		"Fantasmas": return "Ectoplasma %d/8" % faction_resource
		_: return "Consagración %d" % consecrated

func _card_art_path(card: Dictionary) -> String:
	var faction_folder: String = str({
		"Humanos": "humanos",
		"Hombres Lobo": "hombres_lobo",
		"Vampiros": "vampiros",
		"Fantasmas": "fantasmas"
	}.get(str(card["faccion"]), ""))
	if faction_folder.is_empty():
		return ""
	var base_path := "res://assets/cards/%s/%s" % [faction_folder, card["id"]]
	for extension in [".webp", ".png", ".jpg", ".jpeg"]:
		var candidate: String = base_path + extension
		if ResourceLoader.exists(candidate):
			return candidate
	return ""

func _refresh_battle() -> void:
	player_status.text = "♥ %d/%d     ◆ %d     ⚡ %d/%d\n%s" % [maxi(0, player_hp), MAX_HP, player_block, energy, MAX_ENERGY, _resource_text()]
	if temporary_strength > 0:
		player_status.text += " · Fuerza +%d" % temporary_strength
	if player_weak > 0:
		player_status.text += " · Débil %d" % player_weak
	if possession_active:
		player_status.text += " · Posesión"
	if player_ethereal:
		player_status.text += " · Etéreo"
	if barricade_active:
		player_status.text += " · Barricada"
	for id in active_powers:
		player_status.text += " · " + str(cards_by_id[id].nombre)
	player_status.tooltip_text = "Consagración: +3 al siguiente ataque; consume una carga."
	match selected_faction:
		"Hombres Lobo": player_status.tooltip_text = "Furia 10: pierde 3 Salud, vuelve a 5 y gana +2 daño de ataque este turno. Si ocurre al recibir un ataque, dura tu próximo turno."
		"Vampiros": player_status.tooltip_text = "Sed 8–10: pierde 2 Salud al terminar turno. Con 10, el siguiente turno tus ataques causan un 25 % menos de daño."
		"Fantasmas": player_status.tooltip_text = "Ectoplasma se conserva entre turnos. Eco necesita 2 y un ataque previo este turno."
	var enemy_states: Array[String] = []
	if enemy_weak > 0:
		enemy_states.append("Débil %d" % enemy_weak)
	if enemy_vulnerable > 0:
		enemy_states.append("Vulnerable %d" % enemy_vulnerable)
	if enemy_marked:
		enemy_states.append("Marcado")
	if enemy_ethereal:
		enemy_states.append("Etéreo")
	if enemy_bleed > 0:
		enemy_states.append("Sangrado %d" % enemy_bleed)
	var state_text := " · ".join(enemy_states) if not enemy_states.is_empty() else "Sin estados"
	enemy_status.text = "♥ %d/%d     ◆ %d\n%s" % [enemy_hp, enemy_max_hp, enemy_block, state_text]
	intent_label.text = _enemy_intent_text()
	var pile_counts := {"Robo": draw_pile.size(), "Descarte": discard_pile.size(), "Agotadas": exhaust_pile.size(), "Poderes": _active_power_ids().size(), "Aliados": allies.size()}
	for pile_name in pile_counts:
		pile_buttons[pile_name].text = "%s · %d" % [pile_name.to_upper(), pile_counts[pile_name]]
		pile_buttons[pile_name].disabled = choosing_card

	for child in hand_box.get_children():
		child.queue_free()
	var playable_count := 0
	for card in hand:
		var button := CardViewScene.new() as CardView
		button.setup(card, FACTION_COLORS[selected_faction], _card_art_path(card), _card_cost(card))
		var blocked := _play_block_reason(card)
		button.disabled = not blocked.is_empty()
		if button.disabled:
			button.tooltip_text = "NO DISPONIBLE\n" + blocked + "\n\n" + button.tooltip_text
		else:
			playable_count += 1
		button.pressed.connect(_play_card.bind(card))
		hand_box.add_child(button)
	end_turn_button.disabled = battle_over or choosing_card
	end_turn_button.text = "TERMINAR TURNO" if playable_count > 0 else "TERMINAR TURNO · SIN CARTAS JUGABLES"
	end_turn_button.tooltip_text = "Descarta tu mano y resuelve la intención enemiga."
	if playable_count > 0:
		end_turn_button.tooltip_text += "\nTodavía puedes jugar %d cartas de tu mano (no necesariamente todas con el Ímpetu disponible)." % playable_count

func _combat_summary_text() -> String:
	return ("RESUMEN DEL COMBATE · %d turnos\n" % turn
		+ "Cartas jugadas: %d · Ímpetu gastado: %d\n" % [combat_stats.cards, combat_stats.energy]
		+ "Daño a Salud enemiga: %d · Sangrado: %d\n" % [combat_stats.damage, combat_stats.bleed]
		+ "Salud perdida por ataques: %d · Por Sed/Descontrol: %d\n" % [combat_stats.received, combat_stats.self_damage]
		+ "Daño absorbido por Bloqueo: %d · Evitado por Etéreo: %d\n" % [combat_stats.blocked, combat_stats.avoided]
		+ "Curación efectiva: %d · Salud: %d → %d" % [combat_stats.healed, combat_stats.starting_hp, maxi(0, player_hp)])

func _finish_battle(victory: bool) -> void:
	if battle_over:
		return
	screen = "won" if victory else "lost"
	battle_over = true
	hand.clear()
	_refresh_battle()
	message_label.text = "VICTORIA · La niebla retrocede ante Valdegrís." if victory else "DERROTA · La Desvelada reclama otro recuerdo."
	message_label.add_theme_color_override("font_color", Color("79d98c") if victory else Color("ee6b7a"))
	end_turn_button.disabled = false
	end_turn_button.text = "VOLVER A ELEGIR ESTIRPE"
	for connection in end_turn_button.pressed.get_connections():
		end_turn_button.pressed.disconnect(connection["callable"])
	intent_label.text = "Combate terminado"
	if victory and stage < 4:
		_checkpoint("reward")
		end_turn_button.text = "ELEGIR RECOMPENSA"
		end_turn_button.pressed.connect(show_rewards)
	else:
		_checkpoint("finished")
		if victory:
			message_label.text = "VICTORIA · Has llegado a Santa Vigilia y vencido al Custodio."
		end_turn_button.pressed.connect(show_faction_selection)
	_log_combat(message_label.text)
	var summary := _make_label(_combat_summary_text(), 20, Color("d7d9df"))
	summary.name = "CombatSummary"
	summary.tooltip_text = "Solo este combate. Daño y curación efectivos, sin exceso sobre la Salud disponible. Sangrado se muestra aparte del daño directo. Etéreo cuenta el golpe ya reducido por Débil y Posesión."
	hand_box.add_child(summary)
	_log_combat(_combat_summary_text())
