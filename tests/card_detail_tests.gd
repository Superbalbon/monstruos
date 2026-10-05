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
	game.start_run("Humanos")
	game._enter_stage()
	var before := JSON.stringify([game.player_hp, game.energy, game.hand, game.run_deck, game.turn, game.coins])
	var card: Dictionary = game.CardUpgrades.resolve(game.cards_by_id, "H001+")
	var view = game.CardViewScene.new()
	view.setup(card, game.FACTION_COLORS.Humanos, game._card_art_path(card), 0)
	view.disabled = true
	game.add_child(view)
	var presses := [0]
	view.pressed.connect(func(): presses[0] += 1)
	view.find_child("InspectCard", true, false).pressed.emit()
	await process_frame
	await process_frame
	var detail = root.get_node("CardDetail")
	check(detail.visible and detail.exclusive, "Ventana modal visible")
	check(detail.title == "H001 · Balas de Plata +", "Identidad mejorada")
	var body: String = detail.find_child("DetailDescription", true, false).text
	check("Coste actual: 0" in body and str(card.efecto) in body and "Mejora aplicada" in body, "Reglas completas y coste dinámico")
	check(detail.find_child("DetailIllustration", true, false).texture != null, "Ilustración cargada")
	check(detail.get_ok_button().get_rect().size.y > 0, "Cierre disponible")
	view._open_details()
	check(root.find_children("CardDetail", "Window", false, false).size() == 1, "No duplica ventana")
	detail.canceled.emit()
	await process_frame
	check(not root.has_node("CardDetail"), "Cancelar cierra")
	check(presses[0] == 0 and before == JSON.stringify([game.player_hp, game.energy, game.hand, game.run_deck, game.turn, game.coins]), "Consulta no juega ni muta la partida")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_RIGHT
	click.pressed = true
	view._gui_input(click)
	check(root.has_node("CardDetail"), "Clic derecho en carta deshabilitada")
	root.get_node("CardDetail").confirmed.emit()
	await process_frame
	view._open_details()
	view.queue_free()
	await process_frame
	await process_frame
	check(not root.has_node("CardDetail"), "Cerrar escena elimina detalle")
	var restricted_view := CardView.new()
	restricted_view.setup(card, Color.WHITE, "")
	restricted_view.tooltip_text = "Esta copia ya está mejorada."
	game.add_child(restricted_view)
	restricted_view._open_details()
	check(str(card.efecto) in root.get_node("CardDetail").find_child("DetailDescription", true, false).text, "Aviso de mejora no oculta reglas completas")
	root.get_node("CardDetail").confirmed.emit()
	restricted_view.queue_free()
	await process_frame
	game.enemy_hp = 0
	game._finish_battle(true)
	game.show_rewards()
	var reward = game.find_child("RewardCard_H004", true, false)
	reward.find_child("InspectCard", true, false).pressed.emit()
	check(game.screen == "reward" and game.run_deck.size() == 10, "Ampliar recompensa no la elige")
	root.get_node("CardDetail").confirmed.emit()
	await process_frame
	game.queue_free()
	await process_frame
	print("VISTA AMPLIADA: %d fallos" % failures)
	quit(0 if failures == 0 else 1)
