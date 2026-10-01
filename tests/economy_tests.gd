extends SceneTree

const Relics = preload("res://src/relics.gd")
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func close_overlay(game) -> void:
	game.get_node("DeckOverlay").queue_free()
	await process_frame

func run() -> void:
	root.size = Vector2i(1280, 720)
	var game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	var path := "res://.godot/economy-%d.json" % Time.get_ticks_usec()
	game.save_store.path = path
	game.persistence_enabled = true
	for faction in game.STARTER_DECKS:
		game.start_run(faction)
		check(game.coins == 0 and game.relics.is_empty(), "Nueva expedición limpia")
		game._enter_stage()
		game.enemy_hp = 0
		game._finish_battle(true)
		check(game.coins == 20, "Botín aldea " + faction)
		game._finish_battle(true)
		check(game.coins == 20, "Victoria no duplica botín")
		game._resume_run()
		check(game.screen == "reward" and game.coins == 20, "Carga recompensa conserva botín sin repetirlo")
		game._take_reward("")
		await process_frame
		await process_frame
		for action in game.find_children("*", "Button", true, false):
			check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(action.get_global_rect()), "Ruta visible " + faction + ": " + action.text)
		game._show_relics()
		await process_frame
		await process_frame
		var count := 0
		var heal_id := ""
		var block_id := ""
		var special_id := ""
		for id in Relics.ITEMS:
			if Relics.ITEMS[id].faction != faction:
				continue
			count += 1
			var button = game.get_node("DeckOverlay").find_child("Buy_" + id, true, false)
			check(button != null, "Reliquia de estirpe visible " + id)
			check(button.disabled == (Relics.ITEMS[id].price > 20), "Deshabilita saldo insuficiente")
			match Relics.ITEMS[id].effect:
				"heal": heal_id = id
				"block": block_id = id
				_: special_id = id
		check(count == 3, "Tres reliquias por estirpe")
		check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(game.get_node("DeckOverlay").find_child("CloseRelics", true, false).get_global_rect()), "Cierre del mercader visible")
		game._buy_relic(special_id)
		game._buy_relic("INVALID")
		var foreign := "H_CROSS" if faction != "Humanos" else "F_CLOCK"
		game._buy_relic(foreign)
		check(game.coins == 20 and game.relics.is_empty(), "Rechaza compras inválidas")
		game._buy_relic(heal_id)
		check(game.coins == 0 and heal_id in game.relics and game.stage == 1 and game.player_hp == 50, "Compra cobra sin consumir ruta")
		game._buy_relic(heal_id)
		check(game.relics.size() == 1 and game.coins == 0, "Sin duplicados")
		await close_overlay(game)
		game._resume_run()
		check(game.relics == [heal_id] and game.coins == 0, "Compra persiste")
		game.player_hp = 40
		game._enter_stage()
		game.enemy_hp = 0
		game._finish_battle(true)
		check(game.coins == 30 and game.player_hp == 43, "Acechador paga más y cura tres")
		game.show_rewards()
		game._take_reward("")
		game._enter_stage()
		game.player_hp = 49
		game.enemy_hp = 0
		game._finish_battle(true)
		check(game.coins == 55 and game.player_hp == 50, "Estación paga y curación respeta máximo")
		game.show_rewards()
		game._take_reward("")
		game._show_relics()
		game._buy_relic(special_id)
		check(game.coins == 20 and special_id in game.relics and game.stage == 3, "Mercader antes del jefe")
		await close_overlay(game)
		# Buy the remaining defensive item with an explicit test balance.
		game.coins = 30
		game.show_route()
		game._show_relics()
		game._buy_relic(block_id)
		check(game.coins == 0 and game.relics.size() == 3, "Tres compras únicas")
		await close_overlay(game)
		game._resume_run()
		check(game.relics.size() == 3, "Carga colección completa")
		game._rest(15)
		game._enter_stage()
		check(game.player_block == 4, "Bloqueo inicial " + faction)
		await process_frame
		await process_frame
		for action in game.find_children("*", "Button", true, false):
			if action.text == "RELIQUIAS":
				check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(action.get_global_rect()), "Consulta visible en combate " + faction)
		check(game.energy == (4 if faction == "Vampiros" else 3), "Ímpetu inicial")
		check(game.consecrated == (1 if faction == "Humanos" else 0), "Consagración inicial")
		check(game.faction_resource == (2 if faction in ["Fantasmas", "Hombres Lobo"] else 0), "Recurso inicial")
		game._begin_player_turn()
		check(game.player_block == 0 and game.energy == 3, "Bonificación inicial no se repite por turno")
		game.start_battle(faction)
		check(game.player_block == 4 and game.energy == (4 if faction == "Vampiros" else 3), "Bonificación vuelve en otro combate")
		game._show_relics()
		game._buy_relic(heal_id)
		check(game.coins == 0 and game.relics.size() == 3, "Combate solo permite consulta")
		await close_overlay(game)
		game.enemy_hp = 0
		game._finish_battle(true)
		check(game.coins == 40, "Botín del jefe")
	game.start_run("Humanos")
	game.stage = 1
	game.coins = 50
	game.show_route()
	var saved_before := FileAccess.get_file_as_string(path)
	game.save_store.path = "res://.godot/nonexistent-economy-parent/save.json"
	game._show_relics()
	game._buy_relic("H_RING")
	check(game.coins == 50 and game.relics.is_empty() and game.save_failed, "Fallo de escritura revierte compra")
	check(FileAccess.get_file_as_string(path) == saved_before, "Fallo no cambia guardado previo")
	game.save_store.path = path
	game._buy_relic("H_RING")
	check(game.coins == 20 and game.relics == ["H_RING"] and not game.save_failed, "Reintento de compra")
	await close_overlay(game)
	var valid = game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS)
	check(valid.version == 3, "Economía usa formato 3")
	game.stage = 3
	game.show_route()
	game._show_deck("", false, true)
	game._upgrade_card_at_camp(0)
	game._resume_run()
	check(game.stage == 4 and game.run_deck[0].ends_with("+") and game.relics == ["H_RING"] and game.coins == 20, "Guardado combina economía y mejora de carta")
	for change in [{"coins": -1}, {"coins": 0.5}, {"coins": "20"}, {"relics": ["H_RING", "H_RING"]}, {"relics": ["F_CLOCK"]}, {"relics": ["invalid"]}, {"relics": "H_RING"}]:
		var invalid: Dictionary = valid.duplicate(true)
		invalid.merge(change, true)
		check(not game.save_store.valid(invalid, game.cards_by_id, game.STARTER_DECKS, game.REWARDS), "Rechaza economía dañada " + str(change))
	var old: Dictionary = valid.duplicate(true)
	old.version = 1
	old.erase("coins")
	old.erase("relics")
	game.save_store.write(old)
	game._resume_run()
	check(game.coins == 0 and game.relics.is_empty(), "Guardado antiguo carga sin moneda ni reliquias")
	game._rest(12)
	check(game.coins == 0, "Refugio no concede moneda")
	game._enter_stage()
	game.player_hp = 0
	game._finish_battle(false)
	check(game.coins == 0 and game.player_hp == 0, "Derrota no paga ni cura")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	game.queue_free()
	await process_frame
	print("ECONOMÍA Y RELIQUIAS: %d fallos" % failures)
	quit(1 if failures else 0)
