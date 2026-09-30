extends SceneTree

var failures := 0
var game

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func battle(faction: String) -> void:
	game.start_run(faction)
	game._enter_stage()
	game.enemy_hp = 100

func play(id: String) -> void:
	var card: Dictionary = game.cards_by_id[id].duplicate(true)
	game.hand.append(card)
	game._play_card(card)

func run() -> void:
	game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	battle("Hombres Lobo")
	game.faction_resource = 8
	game.player_block = 20
	play("L002")
	check(game.faction_resource == 5 and game.player_hp == 47 and game.player_block == 20, "Descontrol ignora Bloqueo")
	check(game.temporary_strength == 2, "Fuerza de Descontrol")
	play("L001")
	check(game.enemy_hp == 92, "Ataque con Fuerza")
	game.enemy_intent_damage = 0
	game._end_turn()
	check(game.temporary_strength == 0, "Fuerza caduca al terminar turno")
	battle("Hombres Lobo")
	game.faction_resource = 9
	game.enemy_intent_damage = 7
	game._end_turn()
	check(game.player_hp == 40 and game.faction_resource == 5, "Descontrol provocado por ataque enemigo")
	check(game.temporary_strength == 2, "Fuerza disponible el próximo turno")
	play("L001")
	check(game.enemy_hp == 92, "Fuerza aplica el próximo turno")
	game.enemy_intent_damage = 0
	game._end_turn()
	check(game.temporary_strength == 0, "Fuerza no persiste dos turnos")
	battle("Hombres Lobo")
	game.faction_resource = 9
	game.player_block = 20
	game._end_turn()
	check(game.faction_resource == 9, "Ataque bloqueado no genera Furia")
	game.player_hp = 3
	play("L002")
	check(game.screen == "lost", "Descontrol puede causar derrota")
	for thirst in [7, 8, 10]:
		battle("Vampiros")
		game.faction_resource = thirst
		game.player_block = 20
		game.enemy_intent_damage = 0
		game._end_turn()
		check(game.player_hp == (50 if thirst == 7 else 48), "Daño Sed %d" % thirst)
		check(game.player_weak == (1 if thirst == 10 else 0), "Débil Sed %d" % thirst)
	game.enemy_block = 0
	play("V001")
	check(game.enemy_hp == 96, "Débil reduce ataque de 6 a 4")
	play("V014")
	check(game.faction_resource == 8 and game.player_weak == 1, "Reducir Sed no borra Débil del turno")
	game.enemy_intent_damage = 0
	game._end_turn()
	check(game.player_weak == 0, "Débil caduca sin Sed máxima")
	battle("Vampiros")
	check(game.player_weak == 0 and game.temporary_strength == 0, "Estados reiniciados por combate")
	game.player_hp = 2
	game.faction_resource = 8
	game.enemy_intent_damage = 0
	game._end_turn()
	check(game.screen == "lost", "Sed puede causar derrota")
	battle("Fantasmas")
	check(game.run_deck.size() == 10 and "F004" in game.run_deck, "Generador de Ectoplasma inicial")
	check(not game._can_play(game.cards_by_id["F015"]), "Eco requiere recurso y ataque")
	play("F001")
	play("F004")
	check(game.faction_resource == 2 and game._can_play(game.cards_by_id["F015"]), "Eco disponible con cartas iniciales")
	play("F015")
	check(game.enemy_hp == 94 and game.faction_resource == 1, "Eco repite daño y generación de Ectoplasma")
	check(game.exhaust_pile.size() == 2, "Susurro y Eco se agotan")
	game.queue_free()
	await process_frame
	print("FACCIONES: %d fallos" % failures)
	quit(1 if failures else 0)
