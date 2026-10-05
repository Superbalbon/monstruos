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
		game.temporary_strength = 5
		game.player_weak = 3
		game.possession_active = true
		game.player_ethereal = true
		game.barricade_active = true
		# Deliberately overfill the presentation, including several long power names.
		game.active_powers.assign(["H008", "H010", "L007", "V002", "V003"])
		game.enemy_weak = 4
		game.enemy_vulnerable = 3
		game.enemy_marked = true
		game.enemy_ethereal = true
		game.enemy_bleed = 12
		game.enemy_intent_damage = 9
		game.enemy_intent_hits = 3
		game.enemy_intent_block = 12
		game.enemy_intent_weak = 2
		game.enemy_intent_ethereal = true
		game._refresh_battle()
		await process_frame
		await process_frame
		var viewport := Rect2(0, 0, 1280, 720)
		for control in [game.player_status, game.enemy_status, game.intent_label, game.end_turn_button]:
			check(viewport.encloses(control.get_global_rect()), "Control visible " + faction + ": " + str(control.get_global_rect()))
		check(game.player_status.get_global_rect().end.x < game.enemy_status.global_position.x, "Paneles sin solaparse " + faction)
		check(game.player_status.text in game.player_status.tooltip_text, "Todos los estados del personaje consultables")
		check(game.enemy_status.text in game.enemy_status.tooltip_text, "Todos los estados enemigos consultables")
		check(game.intent_label.text in game.intent_label.tooltip_text, "Intención completa consultable")
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/combat-layout-preview.png")
	game.queue_free()
	await process_frame
	print("COMBATE CON ESTADOS: %d fallos" % failures)
	quit(0 if failures == 0 else 1)
