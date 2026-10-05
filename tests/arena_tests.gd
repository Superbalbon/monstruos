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
	var path := "res://.godot/arena-%d.json" % Time.get_ticks_usec()
	game.save_store.path = path
	game.persistence_enabled = true
	for faction in game.STARTER_DECKS:
		game.start_run(faction)
		game.stage = 1
		game.player_hp = 31
		game.coins = 20
		game.show_route()
		game._show_city()
		await process_frame
		await process_frame
		for action in game.find_children("*", "Button", true, false):
			check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(action.get_global_rect()), "Ciudad visible: " + action.text)
		game._choose_city_path("arena")
		check(game.screen == "arena" and game.arena.entry_hp == 31, "Entrada de " + faction)
		await process_frame
		await process_frame
		for action in game.find_children("*", "Button", true, false):
			check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(action.get_global_rect()), "Arena visible: " + action.text)
		var saved = game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS)
		check(not saved.is_empty() and saved.version == 5, "Guardado válido de arena")
		game._choose_city_path("refuge")
		game._rest(12)
		game._enter_stage()
		check(game.screen == "arena" and game.player_hp == 31, "No cambia camino ni cura")
		for wave in range(1, 4):
			game._start_arena_wave()
			check(game.screen == "battle" and game.enemy_max_hp == game.ARENA_WAVES[wave - 1].hp, "Rival de oleada")
			game._resume_run()
			check(game.screen == "arena" and int(game.arena.wave) == wave, "Reinicio solo oleada actual")
			game._start_arena_wave()
			game._end_turn()
			check(game.player_hp > 0, "Ataque real no mata en prueba")
			game.player_hp = 25
			game.enemy_hp = 0
			game._finish_battle(true)
			var earned: int = game.coins
			game._finish_battle(true)
			check(game.coins == earned, "Premio no duplicado")
			game._resume_run()
			if wave < 3:
				check(game.player_hp == 25 and int(game.arena.wave) == wave + 1, "Salud y próxima oleada persistidas")
		check(game.stage == 2 and game.player_hp == 31 and game.coins == 70 and game.arena.is_empty(), "Tres premios y Salud restaurada")
		game._show_city()
		check(game.screen == "route", "No repite arena")
		game._enter_stage()
		check(game.encounter_name == "EL GUARDAGUJAS" and game.enemy_intent_damage == 8, "No filtra patrón a estación")
	# Actual defeat, not just invoking the result handler.
	game.start_run("Humanos")
	game.stage = 1
	game.player_hp = 2
	game.show_route()
	game._show_city()
	game._choose_city_path("arena")
	game._start_arena_wave()
	game._end_turn()
	check(game.screen == "route" and game.stage == 2 and game.player_hp == 2 and game.coins == 0, "Caer no termina expedición ni paga premio")
	game._resume_run()
	check(game.stage == 2 and game.player_hp == 2, "Derrota de arena guardada como ruta")
	game.start_run("Humanos")
	game.stage = 1
	game.show_route()
	game._show_city()
	game._choose_city_path("arena")
	game._start_arena_wave()
	game.enemy_hp = 1
	game.hand.assign([game.cards_by_id["H001"].duplicate(true)])
	game._play_card(game.hand[0])
	check(game.screen == "arena" and game.coins == 10, "Carta real termina oleada")
	game._request_menu()
	game._resume_run()
	check(game.screen == "arena" and game.arena.wave == 2 and game.coins == 10, "Menú conserva premio y siguiente oleada")
	game.save_store.path = "res://.godot/missing-arena-directory/save.json"
	game._start_arena_wave()
	check(game.screen == "arena", "Fallo de guardado bloquea siguiente combate")
	game.save_store.path = path
	game._start_arena_wave()
	game.player_hp = 1
	game._end_turn()
	game._resume_run()
	check(game.stage == 2 and game.player_hp == 50 and game.coins == 10, "Caer después de premio lo conserva y restaura Salud original")
	game.start_run("Humanos")
	game.stage = 1
	game.player_hp = 17
	game.show_route()
	game._show_city()
	var before := FileAccess.get_file_as_string(path)
	game.save_store.path = "res://.godot/missing-arena-directory/save.json"
	game._choose_city_path("arena")
	check(game.city_path.is_empty() and game.arena.is_empty() and game.player_hp == 17 and FileAccess.get_file_as_string(path) == before, "Fallo no compromete camino")
	game.save_store.path = path
	game._choose_city_path("arena")
	var valid = game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS)
	for changes in [{"wave": 0}, {"wave": 4}, {"wave": 1.5}, {"entry_hp": 0}, {"entry_hp": 51}, {"entry_hp": "50"}]:
		var invalid: Dictionary = valid.duplicate(true)
		invalid.arena.merge(changes, true)
		check(not game.save_store.valid(invalid, game.cards_by_id, game.STARTER_DECKS, game.REWARDS), "Rechaza arena malformada")
	game._leave_arena()
	check(game.stage == 2 and game.player_hp == 17, "Retirada sin combatir")
	game.start_run("Humanos")
	game.stage = 1
	game.player_hp = 20
	game.coins = 30
	game.show_route()
	game._show_city()
	game._choose_city_path("merchant")
	game._resume_run()
	check(game.screen == "city" and game.city_path == "merchant", "Mercado comprometido persiste")
	game._show_relics()
	game._buy_relic("H_CROSS")
	check(game.coins == 0 and "H_CROSS" in game.relics, "Descuento humano de cinco")
	game.get_node("DeckOverlay").queue_free()
	await process_frame
	game._choose_city_path("refuge")
	check(game.player_hp == 20, "Mercado excluye refugio")
	game._leave_city()
	check(game.stage == 2 and game.player_hp == 20, "Mercado no cura")
	game.start_run("Fantasmas")
	game.stage = 1
	game.player_hp = 45
	game.show_route()
	game._show_city()
	game._choose_city_path("refuge")
	game._resume_run()
	check(game.stage == 2 and game.player_hp == 50 and game.city_path == "refuge", "Refugio capado y persistido")
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("CIUDAD Y ARENA: %d fallos" % failures)
	quit(0 if failures == 0 else 1)
