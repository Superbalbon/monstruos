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
	var path := "res://.godot/elite-%d.json" % Time.get_ticks_usec()
	game.save_store.path = path
	game.persistence_enabled = true
	for faction in game.STARTER_DECKS:
		game.start_run(faction)
		game._show_encounter_briefing(true)
		check(not game.has_node("DeckOverlay"), "Desafío no disponible antes de estación")
		game.stage = 2
		game.coins = 20
		game.show_route()
		await process_frame
		await process_frame
		var challenge = game.find_child("EliteChallengeButton", true, false)
		check(challenge != null and Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(challenge.get_global_rect()), "Desafío visible " + faction)
		var saved_before := FileAccess.get_file_as_string(path)
		challenge.pressed.emit()
		var overlay = game.get_node("DeckOverlay")
		var info: String = overlay.find_child("EncounterBriefing", true, false).text
		check("56 Salud" in info and "+45" in info and "6 × 2" in info and "1 Débil" in info, "Previsualización completa")
		await process_frame
		await process_frame
		check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(overlay.find_child("AcceptEliteButton", true, false).get_global_rect()), "Aceptación visible")
		var cancel := InputEventAction.new()
		cancel.action = "ui_cancel"
		cancel.pressed = true
		game._unhandled_key_input(cancel)
		await process_frame
		check(not game.elite_encounter and FileAccess.get_file_as_string(path) == saved_before, "Cancelar conserva ruta y guardado")
		game._accept_elite()
		check(not game.elite_encounter, "No acepta sin previsualización")
		game._show_encounter_briefing(true)
		game.get_node("DeckOverlay").find_child("AcceptEliteButton", true, false).pressed.emit()
		check(game.screen == "battle" and game.elite_encounter and game.enemy_max_hp == 56 and game.encounter_name == "EL REVISOR DE CENIZA", "Entra al rival elegido")
		var saved = game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS)
		check(saved.version == 4 and saved.elite and saved.state == "route", "Elección guardada antes del combate")
		game._end_turn()
		check(game.player_hp == 38, "Primer ataque: dos golpes de seis")
		check(game.last_enemy_card.damage == 6 and game.last_enemy_card.hits == 2, "Conversión registra acción real")
		game._resume_run()
		check(game.screen == "route" and game.elite_encounter and game.player_hp == 50 and game.coins == 20, "Reanuda punto previo y elección")
		check(game.find_child("EliteChallengeButton", true, false) == null, "No ofrece cambiar rival tras aceptar")
		check("REVISOR" in game._encounter_briefing_text(2), "Ficha del encuentro restaurado")
		game._enter_stage()
		game._end_turn()
		game._end_turn()
		check(game.enemy_block == 8 and game.player_weak == 1 and game.enemy_intent_damage == 16, "Defensa y Débil antes de ataque fuerte")
		game._end_turn()
		check(game.player_hp == 22 and game.enemy_intent_damage == 6 and game.enemy_intent_hits == 2, "Golpe fuerte y repetición del ciclo")
		game.enemy_hp = 0
		game._finish_battle(true)
		game._finish_battle(true)
		check(game.coins == 65 and game.stage == 2, "Botín 45 una sola vez")
		game._resume_run()
		check(game.screen == "reward" and game.coins == 65 and game.elite_encounter, "Recompensa pendiente de élite persistida")
		game._take_reward(str(game.REWARDS[faction][0]))
		check(game.stage == 3 and not game.elite_encounter and game.run_deck.size() == 11, "Una recompensa y avance al descanso")
		game._resume_run()
		check(game.stage == 3 and game.coins == 65 and not game.elite_encounter, "Progreso tras élite persistido")
		game._rest(15)
		game._enter_stage()
		check(game.encounter_name == "EL CUSTODIO" and game.enemy_max_hp == 58 and game.enemy_intent_damage == 9, "Jefe no hereda patrón de élite")
	game.start_run("Humanos")
	game.stage = 2
	game.show_route()
	var before := FileAccess.get_file_as_string(path)
	game._show_encounter_briefing(true)
	game.save_store.path = "res://.godot/nonexistent-elite-parent/save.json"
	game._accept_elite()
	check(game.screen == "route" and not game.elite_encounter and game.has_node("DeckOverlay"), "Error de guardado impide empezar")
	check(FileAccess.get_file_as_string(path) == before, "Error conserva archivo anterior")
	game.save_store.path = path
	game._accept_elite()
	var valid = game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS)
	for changes in [{"elite": "yes"}, {"elite": 1}, {"stage": 1}, {"stage": 4}]:
		var invalid: Dictionary = valid.duplicate(true)
		invalid.merge(changes, true)
		check(not game.save_store.valid(invalid, game.cards_by_id, game.STARTER_DECKS, game.REWARDS), "Rechaza elección inválida " + str(changes))
	valid.relics = ["H_RING"]
	valid.coins = 15
	game.save_store.write(valid)
	game._resume_run()
	check(game.elite_encounter and game.relics == ["H_RING"] and game.coins == 15, "Elección restaura moneda y reliquias")
	game._enter_stage()
	check(game.player_block == 4, "Reliquia se aplica al desafío restaurado")
	game.player_hp = 0
	game._finish_battle(false)
	check(game.coins == 15, "Derrota élite sin botín")
	game._resume_run()
	check(game.screen == "title", "Derrota élite finaliza expedición")
	game.start_run("Humanos")
	game.stage = 2
	game._enter_stage()
	check(not game.elite_encounter and game.enemy_max_hp == 44 and game.enemy_intent_damage == 8, "Nueva partida conserva alternativa normal")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	game.queue_free()
	await process_frame
	print("DESAFÍO DE ÉLITE: %d fallos" % failures)
	quit(1 if failures else 0)
