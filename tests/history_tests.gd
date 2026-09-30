extends SceneTree

var failures := 0
var game

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func has_entry(fragment: String) -> bool:
	return fragment in "\n".join(game.combat_log)

func run() -> void:
	game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_run("Hombres Lobo")
	game.stage = 1
	game._enter_stage()
	check(game.combat_log.size() == 2 and has_entry("4 × 2"), "Inicio e intención")
	game.faction_resource = 9
	game.player_block = 2
	game._end_turn()
	check(has_entry("Golpe 1/2: 4 de daño, 2 absorbido") and has_entry("Golpe 2/2"), "Registro por golpe")
	check(has_entry("Descontrol"), "Descontrol visible")
	var card: Dictionary = game.cards_by_id["L001"].duplicate(true)
	game.hand.append(card)
	game._play_card(card)
	check(has_entry("Juegas Garra Salvaje (coste 1)") and has_entry("Estado: Salud"), "Carta y estado")
	var before = game.combat_log.duplicate()
	var hp: int = game.player_hp
	game._show_history()
	await process_frame
	check(game.get_node("DeckOverlay").find_child("HistoryEntries", true, false).text == "\n\n".join(before), "Visor contiene eventos exactos")
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	game._unhandled_key_input(cancel)
	await process_frame
	check(game.combat_log == before and game.player_hp == hp and game.screen == "battle", "Consulta sin cambios")
	game._finish_battle(false)
	check(has_entry("DERROTA"), "Resultado registrado")
	game._show_history()
	check(game.has_node("DeckOverlay"), "Historial accesible tras derrota")
	game.start_run("Vampiros")
	game._enter_stage()
	check(not has_entry("Descontrol") and game.combat_log.size() == 2, "Reinicio por combate")
	game.faction_resource = 10
	game._end_turn()
	check(has_entry("La Sed te causa 2") and has_entry("Sed máxima te aplica 1 Débil"), "Penalizaciones de Sed")
	game.enemy_bleed = 2
	game.enemy_hp = 1
	game._end_turn()
	check(has_entry("Sangrado: el enemigo pierde 1 Salud") and has_entry("VICTORIA"), "Sangrado letal y victoria")
	for index in 210:
		game._log_combat("Evento %d" % index)
	check(game.combat_log.size() == 200 and game.combat_log[0].ends_with("Evento 10") and game.combat_log[-1].ends_with("Evento 209"), "Límite conserva últimos eventos")
	game.queue_free()
	await process_frame
	print("HISTORIAL: %d fallos" % failures)
	quit(1 if failures else 0)
