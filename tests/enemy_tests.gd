extends SceneTree

var failures := 0
var game

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func battle(at_stage: int, faction := "Humanos") -> void:
	game.start_run(faction)
	game.stage = at_stage
	game._enter_stage()

func run() -> void:
	game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for at_stage in [0, 1, 2, 4]:
		battle(at_stage)
		var pattern: Array = game.ENEMY_PATTERNS[at_stage]
		for index in pattern.size() * 2:
			var action: Dictionary = pattern[index % pattern.size()]
			game.player_hp = 50
			game.player_block = 0
			game.enemy_block = 0
			check(game.enemy_intent_damage == int(action.get("damage", 0)), "Daño anunciado")
			check(game.enemy_intent_hits == int(action.get("hits", 1)), "Golpes anunciados")
			check(game.enemy_intent_block == int(action.get("block", 0)), "Bloqueo anunciado")
			check(game.enemy_intent_weak == int(action.get("weak", 0)), "Débil anunciado")
			check(game.intent_label.text == game._enemy_intent_text(), "Interfaz usa intención actual")
			game._end_turn()
			check(game.player_hp == 50 - int(action.get("damage", 0)) * int(action.get("hits", 1)), "Daño ejecutado coincide")
			check(game.enemy_block == int(action.get("block", 0)), "Bloqueo ejecutado coincide")
			check(game.player_weak == int(action.get("weak", 0)), "Débil dura siguiente turno")
		await process_frame
	battle(1)
	game.enemy_weak = 1
	game._refresh_battle()
	check("3 × 2" in game.intent_label.text, "Débil modifica cada golpe visible")
	game.player_block = 4
	game._end_turn()
	check(game.player_hp == 48 and game.enemy_weak == 0, "Bloqueo compartido entre golpes, Débil dura acción completa")
	battle(1, "Hombres Lobo")
	game.faction_resource = 9
	game._end_turn()
	check(game.player_hp == 39 and game.faction_resource == 6 and game.temporary_strength == 2, "Furia por cada golpe y Descontrol")
	battle(1, "Hombres Lobo")
	game.player_hp = 1
	game._end_turn()
	check(game.screen == "lost" and game.faction_resource == 1, "Ataques se detienen al morir")
	battle(4)
	game.enemy_pattern = 1
	game._set_enemy_intent()
	game._refresh_battle()
	check("8 Bloqueo" in game.intent_label.text and "1 Débil" in game.intent_label.text, "Custodio anuncia ambos efectos")
	game._end_turn()
	game.enemy_block = 0
	var card: Dictionary = game.cards_by_id["H001"].duplicate(true)
	game.hand.append(card)
	game._play_card(card)
	check(game.enemy_hp == 54, "Maldición reduce ataque jugador de 6 a 4")
	game._end_turn()
	check(game.player_weak == 0, "Maldición caduca al terminar turno del jugador")
	battle(0)
	check(game.enemy_intent_hits == 1 and game.enemy_intent_block == 0 and game.enemy_intent_weak == 0, "Intención limpia al reiniciar")
	game.queue_free()
	await process_frame
	print("ENEMIGOS: %d fallos" % failures)
	quit(1 if failures else 0)
