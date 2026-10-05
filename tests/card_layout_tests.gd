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
	var metrics = preload("res://src/card_metrics.gd")
	for scenario in [["L005", -1, "2⚡"], ["L005", 1, "2→1⚡"], ["L002", 0, "1→0⚡"], ["H006+", 1, "1⚡"], ["H001", 2, "1→2⚡"]]:
		var data: Dictionary = game.CardUpgrades.resolve(game.cards_by_id, scenario[0])
		var original := JSON.stringify(data)
		var view := CardView.new()
		view.setup(data, Color.WHITE, "", scenario[1])
		root.add_child(view)
		await process_frame
		await process_frame
		var cost = view.find_child("CostLabel", true, false)
		var stats = view.find_child("StatLabel", true, false)
		check(cost.text == scenario[2], "Coste visible " + scenario[2])
		check(cost.get_global_rect().end.x <= stats.global_position.x, "Indicadores sin solapamiento " + scenario[2])
		check(JSON.stringify(data) == original, "Indicador no altera coste real")
		view.grab_focus()
		check(root.gui_get_focus_owner() == view, "Carta recibe foco de teclado")
		var focus = view.get_theme_stylebox("focus")
		check(focus is StyleBoxFlat and not focus.draw_center and focus.border_width_left == 3, "Foco visible sin tapar imagen")
		view.queue_free()
		await process_frame
	for id in game.cards_by_id:
		for suffix in ["", "+"]:
			var data: Dictionary = game.CardUpgrades.resolve(game.cards_by_id, id + suffix)
			var before := JSON.stringify(data)
			var view := CardView.new()
			view.setup(data, Color.WHITE, "")
			root.add_child(view)
			await process_frame
			await process_frame
			var rules = view.find_child("CardRules", true, false)
			check(not rules.text.is_empty(), "Texto disponible " + id + suffix)
			check(str(data.efecto) in view.tooltip_text, "Texto íntegro conservado " + id + suffix)
			check(view.get_global_rect().encloses(rules.get_global_rect()), "Reglas dentro de carta " + id + suffix)
			check(before == JSON.stringify(data), "Sin alterar datos " + id + suffix)
			view.queue_free()
			await process_frame
	check(metrics.rules(game.cards_by_id.H001) == "Si el objetivo tiene Vulnerable, inflige 3 de daño adicional.", "Conserva daño condicional")
	check(metrics.rules(game.cards_by_id.H003) == "Bloqueo indicado arriba.", "Defensa simple sin repetir cifra")
	check(metrics.rules(game.cards_by_id.L005) == str(game.cards_by_id.L005.efecto), "Mantiene ataques múltiples")
	check(metrics.rules(game.cards_by_id.H006) == str(game.cards_by_id.H006.efecto), "Mantiene Bloqueo condicional de Aliados")
	for pair in [["H001", "6 DAÑO"], ["H001+", "8 DAÑO"], ["H002", "4 BLOQ."], ["H009+", "12 BLOQ."], ["L005", "4×3 DAÑO"], ["L005+", "5×3 DAÑO"], ["H004+", "5 DAÑO"], ["F015", "EFECTO"]]:
		check(metrics.badge(game.CardUpgrades.resolve(game.cards_by_id, pair[0])) == pair[1], "Indicador " + pair[0])
	for faction in game.STARTER_DECKS:
		game.start_run(faction)
		game._enter_stage()
		await process_frame
		await process_frame
		check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(game.end_turn_button.get_global_rect()), "Fin de turno visible " + faction + " " + str(game.end_turn_button.get_global_rect()))
		for card in game.hand_box.get_children():
			if card.is_queued_for_deletion():
				continue
			var art = card.find_child("ArtPanel", true, false)
			var cost = card.find_child("CostLabel", true, false)
			var stat = card.find_child("StatLabel", true, false)
			var rules = card.find_child("CardRules", true, false)
			check(art.size.y >= 180, "Imagen más grande")
			check(cost.global_position.x < stat.global_position.x and abs(cost.global_position.y - stat.global_position.y) < 1, "Esquinas superiores")
			check(rules.global_position.y >= art.get_global_rect().end.y, "Reglas debajo de imagen")
			check(card.get_global_rect().encloses(card.find_child("InspectCard", true, false).get_global_rect()), "VER dentro de carta")
	if "--capture" in OS.get_cmdline_user_args():
		game.start_run("Hombres Lobo")
		game._enter_stage()
		game.pack_played = true
		game.player_hp = 12
		game.enemy_hp = 18
		game.hand.clear()
		game.hand.append(game.CardUpgrades.resolve(game.cards_by_id, "L005"))
		game.hand.append(game.CardUpgrades.resolve(game.cards_by_id, "L005+"))
		game.hand.append(game.CardUpgrades.resolve(game.cards_by_id, "L029"))
		game._refresh_battle()
		await process_frame
		await process_frame
		game.hand_box.get_child(0).grab_focus()
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/card-layout-preview.png")
	game.queue_free()
	await process_frame
	print("DISEÑO DE CARTAS: %d fallos" % failures)
	quit(0 if failures == 0 else 1)
