extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)

func run() -> void:
	root.size = Vector2i(1280, 720)
	var game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	var path := "res://.godot/biomes-%d.json" % Time.get_ticks_usec()
	game.save_store.path = path
	game.persistence_enabled = true
	for faction in game.STARTER_DECKS:
		for id in game.Biomes.AREAS:
			var area: Dictionary = game.Biomes.AREAS[id]
			game.start_run(faction)
			game.stage = 2
			game.show_route()
			var before := FileAccess.get_file_as_string(path)
			game._show_biomes()
			await process_frame
			await process_frame
			var close = game.find_child("CloseBiomes", true, false)
			check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(close.get_global_rect()), "Cierre accesible")
			check(FileAccess.get_file_as_string(path) == before, "Consulta no guarda")
			game._choose_biome(id)
			check(game.screen == "battle" and game.encounter_name == area.name and game.enemy_max_hp == 44, "Rival " + id)
			check(game.enemy_block == (4 if faction == area.hindered else 0), "Perjuicio visible " + faction + id)
			check(game.energy == (4 if faction == "Vampiros" and id == "castle" else 3), "Ímpetu de terreno")
			check(game.faction_resource == (2 if faction == area.favored and id != "castle" else 0), "Recurso de terreno")
			game._end_turn()
			check(game.energy == 3, "Ventaja de Ímpetu no se repite")
			game._resume_run()
			check(game.screen == "route" and game.biome == id and game.player_hp == 50, "Reanuda desvío y Salud previa")
			check(game.find_child("BiomesButton", true, false) == null and game.find_child("EliteChallengeButton", true, false) == null, "No cambia elección")
			game._show_encounter_briefing(true)
			check(not game.has_node("DeckOverlay"), "No elige élite tras terreno")
			check(area.name in game._encounter_briefing_text(2), "Ficha refleja terreno guardado")
			game._enter_stage()
			game.enemy_hp = 0
			game._finish_battle(true)
			game._resume_run()
			check(game.screen == "reward" and game.coins == 25 and game.biome == id, "Recompensa persistida")
			game._take_reward("")
			game._rest(15)
			game._enter_stage()
			check(game.encounter_name == "EL CUSTODIO" and game.energy == 3 and game.faction_resource == 0 and game.enemy_block == 0, "No afecta jefe")
	game.start_run("Humanos")
	game.stage = 1
	game.show_route()
	game._show_city()
	game._choose_city_path("refuge")
	game._show_biomes()
	game.save_store.path = "res://.godot/no-biome-parent/save.json"
	game._choose_biome("cemetery")
	check(game.biome.is_empty() and game.screen == "route", "Fallo de escritura revierte elección")
	game.save_store.path = path
	game._choose_biome("cemetery")
	var valid: Dictionary = game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS)
	check(not valid.is_empty() and valid.version == 6 and valid.city_path == "refuge", "Ciudad y terreno compatibles")
	for changes in [{"biome": "unknown"}, {"biome": 1}, {"elite": true}, {"stage": 1}, {"arena": {"wave": 1, "entry_hp": 50}}, {"city_path": "bad"}]:
		var invalid := valid.duplicate(true)
		invalid.merge(changes, true)
		check(not game.save_store.valid(invalid, game.cards_by_id, game.STARTER_DECKS, game.REWARDS), "Rechaza guardado incompatible")
	game.relics.assign(["H_RING"])
	game._checkpoint("route")
	game._resume_run()
	game._enter_stage()
	check(game.player_block == 4 and game.enemy_block == 4, "Reliquia y perjuicio se suman sin anularse")
	game.start_run("Vampiros")
	check(game.biome.is_empty(), "Nueva expedición limpia terreno")
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("ESCENARIOS: %d fallos" % failures)
	quit(0 if failures == 0 else 1)
