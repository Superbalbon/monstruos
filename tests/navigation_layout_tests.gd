extends SceneTree

var failures := 0
var game

func _initialize() -> void:
	call_deferred("run")

func inspect_screen(label: String) -> void:
	await process_frame
	await process_frame
	var viewport := Rect2(0, 0, 1280, 720)
	for control in game.find_children("*", "Control", true, false):
		if not (control is Button or control is ScrollContainer) or not control.is_visible_in_tree():
			continue
		var parent = control.get_parent()
		var in_scroll := false
		while parent != game and parent != null:
			if parent is ScrollContainer:
				in_scroll = true
			parent = parent.get_parent()
		if in_scroll:
			continue # Items are reachable by scrolling; check the viewport itself.
		if not viewport.encloses(control.get_global_rect()):
			failures += 1
			printerr("FAIL: %s / %s / %s" % [label, control.text if control is Button else control.name, control.get_global_rect()])

func run() -> void:
	root.size = Vector2i(1280, 720)
	game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	await inspect_screen("Menú")
	game.show_faction_selection()
	await inspect_screen("Estirpes")
	for faction in game.STARTER_DECKS:
		game.start_run(faction)
		for stage in range(5):
			game.stage = stage
			game.show_route()
			await inspect_screen(faction + " Ruta " + str(stage))
		game.stage = 1
		game.show_route()
		game._show_hermitage()
		await inspect_screen(faction + " Ermita")
		game.show_route()
		game._show_city()
		await inspect_screen(faction + " Ciudad")
		game.stage = 3
		game.show_route()
		game._show_relics()
		await inspect_screen(faction + " Mercader")
		game.show_route()
		game.stage = 2
		game.show_route()
		game._show_biomes()
		await inspect_screen(faction + " Escenarios")
		game.show_route()
		game.stage = 0
		game.show_route()
		game._enter_stage()
		game.enemy_hp = 0
		game._finish_battle(true)
		await inspect_screen(faction + " Victoria")
		game.show_rewards()
		await inspect_screen(faction + " Recompensa")
	game.queue_free()
	await process_frame
	print("NAVEGACIÓN VISIBLE: %d fallos" % failures)
	quit(0 if failures == 0 else 1)
