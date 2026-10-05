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
	root.gui_embed_subwindows = true
	var game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_run("Fantasmas")
	game._enter_stage()
	game.enemy_intent_damage = 8
	game.enemy_intent_hits = 2
	game.player_block = 3
	game._refresh_battle()
	await process_frame
	await process_frame
	game.intent_details_button.grab_focus()
	var before := JSON.stringify([game.player_hp, game.enemy_hp, game.player_block, game.hand, game.energy, game.turn])
	game.intent_details_button.pressed.emit()
	await process_frame
	var dialog = game.get_node("IntentDetails")
	check(dialog.visible and dialog.exclusive, "Consulta modal")
	check("Daño sin cubrir: 13" in dialog.get_node("IntentDescription").text, "Previsión actual")
	game._show_intent_details()
	check(game.find_children("IntentDetails", "Window", false, false).size() == 1, "No duplica ventanas")
	game._end_turn()
	game._play_card(game.hand[0])
	game._request_menu()
	check(before == JSON.stringify([game.player_hp, game.enemy_hp, game.player_block, game.hand, game.energy, game.turn]) and game.screen == "battle", "Consulta no modifica combate")
	if "--capture" in OS.get_cmdline_user_args():
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/intent-details-preview.png")
	dialog.confirmed.emit()
	await process_frame
	check(not game.has_node("IntentDetails") and root.gui_get_focus_owner() == game.intent_details_button, "Cerrar restaura foco")
	game.player_block = 10
	game._show_intent_details()
	check("Daño sin cubrir: 6" in game.get_node("IntentDetails").get_node("IntentDescription").text, "Reabrir recalcula defensa")
	var escape := InputEventAction.new()
	escape.action = "ui_cancel"
	escape.pressed = true
	game._unhandled_key_input(escape)
	await process_frame
	check(not game.has_node("IntentDetails") and game.screen == "battle", "Esc vuelve al combate")
	game.choosing_card = true
	game._show_intent_details()
	check(not game.has_node("IntentDetails"), "Respeta selección pendiente")
	game.choosing_card = false
	game._finish_battle(false)
	game._show_intent_details()
	check(game.intent_details_button.disabled and not game.has_node("IntentDetails"), "No consulta intención tras finalizar")
	game.queue_free()
	await process_frame
	print("DETALLE DE INTENCIÓN: %d fallos" % failures)
	quit(0 if failures == 0 else 1)
