extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)

func focus_and_check(target: Control, context: String) -> void:
	var parent := target.get_parent()
	while parent != null and not parent is ScrollContainer:
		parent = parent.get_parent()
	check(parent != null, "Contenedor desplazable " + context)
	target.grab_focus()
	await process_frame
	await process_frame
	check(root.gui_get_focus_owner() == target, "Foco " + context)
	check(parent.get_global_rect().encloses(target.get_global_rect()), "Control enfocado visible " + context)

func run() -> void:
	root.size = Vector2i(1280, 720)
	var game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game._show_catalog()
	await process_frame
	await process_frame
	var catalog = game.get_node("CatalogOverlay")
	var inspectors = catalog.find_children("InspectCard", "Button", true, false)
	check(inspectors.size() == 10, "Diez cartas de la facción seleccionada")
	await focus_and_check(inspectors.back(), "última carta del catálogo")
	await focus_and_check(inspectors.front(), "primera carta del catálogo")
	check(not root.has_node("CardDetail") and game.screen == "title", "Navegar no abre ni inicia partida")
	game.start_run("Humanos")
	game.screen = "won"
	game.show_rewards()
	await process_frame
	await process_frame
	var before := JSON.stringify(game.run_deck)
	var reward = game.find_child("RewardCard_" + str(game.REWARDS.Humanos.back()), true, false)
	await focus_and_check(reward, "última recompensa")
	check(game.screen == "reward" and before == JSON.stringify(game.run_deck), "Foco no elige recompensa")
	game.start_run("Humanos")
	game._enter_stage()
	game.hand.clear()
	for i in range(10):
		game.hand.append(game.cards_by_id.H001.duplicate(true))
	game._refresh_battle()
	await process_frame
	await process_frame
	await focus_and_check(game.hand_box.get_child(9), "mano larga")
	check(game.hand.size() == 10 and game.energy == 3, "Foco no juega carta")
	game._show_deck()
	await process_frame
	await process_frame
	var deck = game.get_node("DeckOverlay")
	await focus_and_check(deck.find_children("InspectCard", "Button", true, false).back(), "consulta de mazo")
	game.queue_free()
	await process_frame
	print("TECLADO Y DESPLAZAMIENTO: %d fallos" % failures)
	quit(0 if failures == 0 else 1)
