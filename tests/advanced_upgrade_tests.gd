extends SceneTree

var failures := 0
var game

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func play(id: String) -> void:
	var card: Dictionary = game.CardUpgrades.resolve(game.cards_by_id, id)
	game.hand.append(card)
	game._play_card(card)

func run() -> void:
	game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	var path := "res://.godot/advanced-upgrade-%d.json" % Time.get_ticks_usec()
	game.save_store.path = path
	var expectations := {
		"H002": {"player_block": 6, "consecrated": 1},
		"H004": {"enemy_hp": 95, "enemy_vulnerable": 2},
		"H005": {"enemy_weak": 2}, "H007": {"enemy_hp": 90},
		"L002": {"faction_resource": 7, "enemy_weak": 1},
		"L004": {"enemy_hp": 93, "enemy_bleed": 3, "faction_resource": 5},
		"L005": {"enemy_hp": 85},
		"L006": {"enemy_hp": 94, "enemy_weak": 2, "enemy_bleed": 2, "faction_resource": 2},
		"L008": {"enemy_hp": 89},
		"V005": {"enemy_hp": 87, "player_hp": 34, "faction_resource": 2},
		"V006": {"enemy_hp": 89, "faction_resource": 5},
		"V009": {"enemy_weak": 3, "faction_resource": 5},
		"V014": {"faction_resource": 1}, "F001": {"faction_resource": 6},
		"F004": {"enemy_hp": 93, "faction_resource": 5},
		"F005": {"enemy_hp": 90, "enemy_vulnerable": 1},
		"F006": {"enemy_weak": 3, "faction_resource": 5}
	}
	check(game.CardUpgrades.VALUES.size() == 25, "Veinticinco mejoras disponibles")
	for id in expectations:
		var original: Dictionary = game.cards_by_id[id].duplicate(true)
		game.start_run(original.faccion)
		game.stage = 3
		if id not in game.run_deck:
			game.run_deck.append(id)
		game.show_route()
		game._show_deck("", false, true)
		game._upgrade_card_at_camp(game.run_deck.find(id))
		check(id + "+" in game.run_deck and game.stage == 4, "Adquirible en descanso " + id)
		game.persistence_enabled = true
		game._checkpoint("route")
		var saved: Dictionary = game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS)
		check(not saved.is_empty() and saved.deck == game.run_deck, "Guardado y carga " + id)
		game.persistence_enabled = false
		game._enter_stage()
		game.hand.clear()
		game.enemy_hp = 100
		game.player_hp = 30
		game.faction_resource = 4
		play(id + "+")
		for property in expectations[id]:
			check(game.get(property) == expectations[id][property], id + ": " + property)
		check(game.energy == 3 - original.coste, "Conserva coste " + id)
		if id in ["F001", "V014"]:
			check(game.exhaust_pile.back().upgraded, "Conserva agotamiento " + id)
		else:
			check(game.discard_pile.back().upgraded, "Conserva mejora en descarte " + id)
		if id in ["H005", "V014", "F001"]:
			check(game.hand.size() == 1, "Conserva robo " + id)
		check(game.cards_by_id[id] == original, "No modifica definición base " + id)
	game.start_run("Fantasmas")
	game._enter_stage()
	game.enemy_hp = 100
	game.faction_resource = 4
	play("L004+")
	play("F015")
	check(game.enemy_hp == 90 and game.enemy_bleed == 4, "Eco repite daño y Sangrado mejorados con redondeo")
	game.start_run("Hombres Lobo")
	game._enter_stage()
	game.enemy_hp = 100
	game.pack_played = true
	play("L005+")
	check(game.energy == 2 and game.enemy_hp == 85, "Manada mejorada conserva descuento y tres golpes")
	game.energy = 3
	game.allies.append(game.cards_by_id["H006"])
	play("L008+")
	check(game.enemy_hp == 78, "Solitario mejorado conserva penalización de aliado")
	game.start_run("Fantasmas")
	game._enter_stage()
	game.faction_resource = 7
	play("F001+")
	check(game.faction_resource == 8, "Ectoplasma mejorado no supera límite")
	game.start_run("Vampiros")
	game._enter_stage()
	game.faction_resource = 1
	play("V014+")
	check(game.faction_resource == 0, "Reducción de Sed no baja de cero")
	game.player_hp = 49
	play("V005+")
	check(game.player_hp == 50, "Curación mejorada respeta máximo")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	game.queue_free()
	await process_frame
	print("MEJORAS AVANZADAS: %d fallos" % failures)
	quit(1 if failures else 0)
