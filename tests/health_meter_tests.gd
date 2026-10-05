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
	for faction in game.STARTER_DECKS:
		game.start_run(faction)
		game._enter_stage()
		for health in [50, 25, 12, 0, 38]:
			game.player_hp = health
			game.enemy_max_hp = 80
			game.enemy_hp = 40
			game.player_block = 17
			game._refresh_battle()
			await process_frame
			await process_frame
			check(game.player_health.value == health and game.player_health.max_value == 50, "Salud de " + faction)
			check(game.enemy_health.value == 40 and game.enemy_health.max_value == 80, "Escala propia del enemigo")
			check(game.player_hp == health and game.player_block == 17, "Solo presentación, no altera combate")
			check(("%d/50" % health) in game.player_status.text, "Cifra exacta conservada")
			check(Rect2(0, 0, 1280, 720).encloses(game.end_turn_button.get_global_rect()), "Fin de turno visible")
			check(game.player_health.get_global_rect().end.y <= game.player_status.global_position.y, "Barra sin solapar texto")
	game.player_health.set_health(-3, 50)
	check(game.player_health.value == 0, "No muestra Salud negativa")
	game.player_health.set_health(60, 50)
	check(game.player_health.value == 50, "No desborda máximo")
	game.player_health.set_health(12, 50)
	check(game.player_health.get_theme_stylebox("fill").bg_color == Color("df6878"), "Salud crítica")
	check(game.enemy_health.get_theme_stylebox("fill").bg_color == Color("e4bb70"), "Estilos independientes")
	game.player_health.set_health(0, 0)
	check(game.player_health.max_value == 1 and game.player_health.value == 0, "Máximo inválido seguro")
	game.queue_free()
	await process_frame
	print("BARRAS DE SALUD: %d fallos" % failures)
	quit(0 if failures == 0 else 1)
