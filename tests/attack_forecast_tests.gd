extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)

func run() -> void:
	var forecast = preload("res://src/attack_forecast.gd")
	for damage in [0, 1, 4, 9]:
		for hits in [1, 2, 3]:
			for block in [0, 3, 50]:
				for ethereal in [false, true]:
					var result: Dictionary = forecast.calculate(damage, hits, block, ethereal, 0)
					check(result.total == result.avoided + result.absorbed + result.uncovered, "Daño repartido sin duplicar")
					check(result.uncovered >= 0 and result.absorbed <= block, "Límites de defensa")
					check(result.avoided == (damage if ethereal else 0), "Etéreo evita solo un golpe")
	var game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_run("Fantasmas")
	game._enter_stage()
	game.enemy_intent_damage = 8
	game.enemy_intent_hits = 3
	game.enemy_weak = 1
	game.possession_active = true
	game.player_ethereal = true
	game.player_block = 2
	var before := JSON.stringify([game.player_hp, game.player_block, game.hand, game.energy, game.possession_active, game.player_ethereal])
	var result: Dictionary = game._defense_forecast()
	check(result.per_hit == 3 and result.total == 9 and result.avoided == 3 and result.absorbed == 2 and result.uncovered == 4, "Débil, Posesión, Etéreo y Bloqueo combinados")
	game._refresh_battle()
	check("Daño sin cubrir: 4" in game.intent_label.tooltip_text, "Previsión disponible en interfaz")
	check(before == JSON.stringify([game.player_hp, game.player_block, game.hand, game.energy, game.possession_active, game.player_ethereal]), "Consulta no consume defensas ni recursos")
	game._end_turn()
	check(game.combat_stats.received == 4, "Coincide con golpes reales sin reacciones")
	game.start_run("Humanos")
	game._enter_stage()
	game.enemy_intent_damage = 9
	game.enemy_intent_hits = 2
	game.allies.append(game.cards_by_id.H006.duplicate(true))
	game.allies.append(game.cards_by_id.H006.duplicate(true))
	result = game._defense_forecast()
	check(result.militia == 12 and result.absorbed == 12 and result.uncovered == 6, "Dos Milicias generan Bloqueo por ambos aliados")
	game._end_turn()
	check(game.combat_stats.received == 6, "Previsión de Milicia coincide con combate")
	game.enemy_intent_damage = 0
	game._refresh_battle()
	check("No hay golpes" in game.intent_label.tooltip_text, "No anuncia daño en intención defensiva")
	game._finish_battle(false)
	check("DEFENSA PREVISTA" not in game.intent_label.tooltip_text, "No mantiene previsión tras terminar")
	game.queue_free()
	await process_frame
	print("PREVISIÓN DEFENSIVA: %d fallos" % failures)
	quit(0 if failures == 0 else 1)
