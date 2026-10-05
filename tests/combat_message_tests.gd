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
	game.start_run("Vampiros")
	game._enter_stage()
	game.enemy_intent_damage = 1
	game.enemy_intent_hits = 3
	game.enemy_intent_block = 12
	game.enemy_intent_weak = 2
	game.enemy_intent_ethereal = true
	game.faction_resource = 10
	game._end_turn()
	await process_frame
	await process_frame
	check("Sed máxima" in game.message_label.text and "Obtiene Etéreo" in game.message_label.text, "Mensaje real largo generado")
	for control in [game.message_label, game.enemy_status, game.end_turn_button]:
		check(Rect2(0, 0, 1280, 720).encloses(control.get_global_rect()), "Mensaje no desplaza controles")
	check(game.message_label.get_tooltip() == game.message_label.text, "Ayuda conserva texto completo actual")
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/combat-message-preview.png")
	var tooltip = game.message_label._make_custom_tooltip(game.message_label.get_tooltip())
	root.add_child(tooltip)
	await process_frame
	check(tooltip.text == game.message_label.text and tooltip.size.x <= 540, "Ayuda con ancho limitado y texto completo")
	tooltip.queue_free()
	game.message_label.text = "Nuevo turno."
	check(game.message_label.get_tooltip() == "Nuevo turno.", "Ayuda no conserva mensaje antiguo")
	game._finish_battle(false)
	check("DERROTA" in game.message_label.get_tooltip(), "Ayuda actualizada al finalizar")
	game.queue_free()
	await process_frame
	print("MENSAJES DE COMBATE: %d fallos" % failures)
	quit(0 if failures == 0 else 1)
