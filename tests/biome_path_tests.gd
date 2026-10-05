extends SceneTree

var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
func run() -> void:
	root.size = Vector2i(1280, 720)
	var game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	var path := "res://.godot/paths-%d.json" % Time.get_ticks_usec()
	game.save_store.path = path
	game.persistence_enabled = true
	for id in game.Biomes.AREAS:
		for choice in ["combat", "refuge", "merchant"]:
			game.start_run("Humanos")
			game.stage = 2
			game.player_hp = 30
			game.coins = 40
			game.show_route()
			game._show_biomes()
			game.find_child("ChooseBiome_" + id, true, false).pressed.emit()
			check(game.screen == "biome" and game.biome_path == "pending", "Entrada no combate")
			game._request_menu()
			game._resume_run()
			check(game.screen == "biome" and game.biome == id, "Elección pendiente persiste")
			await process_frame
			await process_frame
			for button in game.find_children("*", "Button", true, false):
				check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(button.get_global_rect()), "Botón visible: " + button.text)
			game.save_store.path = "res://.godot/missing-path-parent/save.json"
			game._choose_biome_path(choice)
			check(game.biome_path == "pending" and game.player_hp == 30 and game.stage == 2, "Fallo revierte decisión")
			game.save_store.path = path
			game._choose_biome_path(choice)
			game._resume_run()
			check(game.biome_path == choice, "Camino persiste")
			game._choose_biome_path("refuge")
			if choice == "combat":
				check(game.screen == "route" and game.player_hp == 30, "Combate no permite curación")
				game._enter_stage()
				game.enemy_hp = 0
				game._finish_battle(true)
				game._resume_run()
				check(game.screen == "reward" and game.coins == 65, "Botín del combate")
				game._take_reward("")
			elif choice == "merchant":
				check(game.screen == "biome" and game.player_hp == 30, "Mercader no cura")
				game._show_relics()
				game._buy_relic("H_RING")
				game.get_node("DeckOverlay").queue_free()
				await process_frame
				game._resume_run()
				check(game.coins == 10 and "H_RING" in game.relics, "Compra persiste sin descuento urbano")
				game._leave_biome_shop()
			else:
				check(game.player_hp == 42 and game.coins == 40 and game.run_deck.size() == 10, "Refugio sin botín ni carta")
			check(game.stage == 3, "Todos avanzan al descanso")
			game._resume_run()
			check(game.stage == 3, "No se repite el camino al cargar")
			var valid: Dictionary = game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS)
			check(valid.version == 7, "Formato 7 válido")
			valid.biome_path = "pending"
			check(not game.save_store.valid(valid, game.cards_by_id, game.STARTER_DECKS, game.REWARDS), "No acepta pendiente tras escenario")
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("CAMINOS INTERNOS: %d fallos" % failures)
	quit(0 if failures == 0 else 1)
