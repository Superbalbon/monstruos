extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func run() -> void:
	root.size = Vector2i(1280, 720)
	var game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	var path := "res://.godot/briefing-%d.json" % Time.get_ticks_usec()
	game.save_store.path = path
	game.persistence_enabled = true
	game.start_run("Humanos")
	for encounter_stage in [0, 1, 2, 4]:
		game.stage = encounter_stage
		game.show_route()
		await process_frame
		await process_frame
		for button in game.find_children("*", "Button", true, false):
			check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(button.get_global_rect()), "Acción visible: " + button.text)
		var saved := FileAccess.get_file_as_string(path)
		var deck = game.run_deck.duplicate()
		game.find_child("InspectEncounter_" + str(encounter_stage), true, false).pressed.emit()
		var overlay = game.get_node("DeckOverlay")
		var info: String = overlay.find_child("EncounterBriefing", true, false).text
		var encounter = game.ENCOUNTERS[encounter_stage]
		check(encounter.name in info and ("%d Salud" % encounter.hp) in info, "Nombre y Salud reales")
		for action in game.ENEMY_PATTERNS[encounter_stage]:
			if action.has("damage"):
				check(("%d × %d" % [action.damage, action.get("hits", 1)]) in info, "Daño por golpe")
			if action.has("block"):
				check(("%d Bloqueo" % action.block) in info, "Bloqueo real")
		check(("te aplica 1 Débil" in info) == (encounter_stage == 4), "Estados del Custodio")
		game._show_encounter_briefing()
		check(game.get_node("DeckOverlay") == overlay, "No duplica ficha")
		game._enter_stage()
		game._rest(12)
		game._show_hermitage()
		check(game.screen == "route" and game.stage == encounter_stage, "Consulta bloquea acciones subyacentes")
		var cancel := InputEventAction.new()
		cancel.action = "ui_cancel"
		cancel.pressed = true
		game._unhandled_key_input(cancel)
		await process_frame
		check(not game.has_node("DeckOverlay") and game.run_deck == deck and game.player_hp == 50, "Escape conserva expedición")
		check(FileAccess.get_file_as_string(path) == saved, "No reescribe guardado")
		game._enter_stage()
		check(game.screen == "battle" and game.enemy_max_hp == encounter.hp and game.encounter_name == encounter.name, "Encuentro coincide con ficha")
		game._show_encounter_briefing()
		check(not game.has_node("DeckOverlay"), "No abre ficha de ruta en combate")
	game.stage = 3
	game.show_route()
	game._show_encounter_briefing()
	check(not game.has_node("DeckOverlay") and game._encounter_briefing_text(3).is_empty(), "Descanso no es combate")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	game.queue_free()
	await process_frame
	print("FICHAS DE ENCUENTROS: %d fallos" % failures)
	quit(1 if failures else 0)
