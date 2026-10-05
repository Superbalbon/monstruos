extends SceneTree

var failures := 0
var game

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func battle(faction: String, hp := 50) -> void:
	game.start_run(faction)
	game.player_hp = hp
	game._enter_stage()

func play(id: String) -> void:
	var card: Dictionary = game.cards_by_id[id].duplicate(true)
	game.hand.append(card)
	game._play_card(card)

func run() -> void:
	root.size = Vector2i(1280, 720)
	game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	battle("Humanos")
	game.enemy_hp = 3
	play("H001")
	check(game.combat_stats.damage == 3 and game.combat_stats.cards == 1 and game.combat_stats.energy == 1, "Golpe letal cuenta daño efectivo y carta pagada")
	await process_frame
	await process_frame
	var summary = game.hand_box.get_node("CombatSummary")
	check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(summary.get_global_rect()), "Resumen dentro de pantalla")
	check(summary.text == game._combat_summary_text() and "RESUMEN DEL COMBATE" in game.combat_log.back(), "Resumen visible y copiable en historial")
	check("atacar" not in game.intent_label.tooltip_text and "Combate terminado" in game.intent_label.tooltip_text, "Ayuda no anuncia ataques tras victoria")
	var count: int = game.combat_log.size()
	game._finish_battle(true)
	check(game.combat_log.size() == count, "Finalización no duplica resumen")
	battle("Humanos", 4)
	game.player_block = 2
	game.enemy_intent_damage = 10
	game.enemy_intent_hits = 2
	game._end_turn()
	check(game.combat_stats.blocked == 2 and game.combat_stats.received == 4 and game.player_hp == 0, "Derrota limita pérdida a Salud restante y detiene segundo golpe")
	check(game.screen == "lost" and game.hand_box.has_node("CombatSummary"), "Resumen también tras derrota")
	check("Combate terminado" in game.intent_label.tooltip_text, "Ayuda actualizada tras derrota")
	battle("Fantasmas")
	game.faction_resource = 8
	game.enemy_intent_damage = 8
	game.enemy_intent_hits = 2
	game.enemy_weak = 1
	play("F002")
	play("F008")
	game.player_block = 2
	game._end_turn()
	check(game.combat_stats.avoided == 3 and game.combat_stats.blocked == 2 and game.combat_stats.received == 1, "Etéreo tras Débil y Posesión no cuenta como Bloqueo")
	battle("Vampiros", 49)
	play("V005")
	check(game.combat_stats.healed == 1 and game.player_hp == 50, "Curación no cuenta exceso")
	game.faction_resource = 8
	game.enemy_intent_damage = 0
	game._end_turn()
	check(game.combat_stats.self_damage == 2 and game.combat_stats.received == 0, "Sed separada de ataques")
	check(game.combat_stats.starting_hp + game.combat_stats.healed - game.combat_stats.received - game.combat_stats.self_damage == game.player_hp, "Balance de Salud cuadra")
	battle("Hombres Lobo", 2)
	game.faction_resource = 9
	play("L002")
	check(game.combat_stats.self_damage == 2 and game.screen == "lost", "Descontrol letal registra solo Salud restante")
	battle("Hombres Lobo")
	game.enemy_hp = 2
	game.enemy_bleed = 5
	game.enemy_intent_damage = 0
	game._end_turn()
	check(game.combat_stats.bleed == 2 and game.combat_stats.damage == 0, "Sangrado separado y limitado al daño efectivo")
	battle("Humanos")
	game.enemy_ethereal = true
	play("H001")
	check(game.combat_stats.damage == 0, "Etéreo enemigo evita contabilizar daño")
	game.enemy_block = 5
	play("H001")
	check(game.combat_stats.damage == 1, "Daño excluye Bloqueo enemigo")
	game.energy = 0
	play("H001")
	check(game.combat_stats.cards == 2, "Carta rechazada no cuenta")
	battle("Hombres Lobo")
	game.active_powers.append("L003")
	play("L002")
	check(game.combat_stats.cards == 1 and game.combat_stats.energy == 0, "Ímpetu cuenta coste descontado")
	battle("Humanos")
	check(game.combat_stats.cards == 0 and game.combat_stats.damage == 0 and game.combat_stats.starting_hp == 50, "Estadísticas reinician entre combates")
	game.queue_free()
	await process_frame
	print("RESUMEN: %d fallos" % failures)
	quit(1 if failures else 0)
