extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func run() -> void:
	root.size = Vector2i(1280, 720)
	var scene = load("res://main.tscn")
	var game = scene.instantiate()
	var other = scene.instantiate()
	var path := "res://.godot/event-test-%d.json" % Time.get_ticks_usec()
	for instance in [game, other]:
		instance.persistence_enabled = false
		root.add_child(instance)
		instance.save_store.path = path
		instance.persistence_enabled = true
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	for faction in game.STARTER_DECKS:
		game.start_run(faction)
		game._show_hermitage()
		check(game.screen == "route", "Evento no accesible antes de aldea")
		game.stage = 1
		game.player_hp = 20
		game.show_route()
		await process_frame
		await process_frame
		var open = game.find_child("HermitageButton", true, false)
		check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(open.get_global_rect()), "Entrada visible en ruta")
		open.pressed.emit()
		await process_frame
		await process_frame
		check(game.screen == "event", "Abre evento " + faction)
		var help = game.find_child("HelpApparitionButton", true, false)
		var listen = game.find_child("ListenApparitionButton", true, false)
		for control in [help, listen, game.find_child("EventStory", true, false)]:
			check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(control.get_global_rect()), "Evento cabe en pantalla " + faction)
		other._resume_run()
		check(other.stage == 1 and other.player_hp == 20 and other.screen == "route", "Cerrar antes de elegir conserva cruce")
		game._unhandled_key_input(cancel)
		check(game.screen == "route" and game.player_hp == 20 and game.run_deck.size() == 10, "Cancelar sin coste")
		game._show_hermitage()
		game._resolve_hermitage("invalid")
		check(game.screen == "event" and game.player_hp == 20, "Rechaza opción desconocida")
		game._resolve_hermitage("help")
		var reward: String = game.RouteEvents.HERMITAGE[faction].card
		check(game.stage == 2 and game.player_hp == 12 and game.run_deck.back() == reward, "Ayuda paga y entrega carta " + faction)
		game._resolve_hermitage("help")
		game._resolve_hermitage("listen")
		game._show_hermitage()
		check(game.run_deck.size() == 11 and game.player_hp == 12 and game.screen == "route", "No se puede repetir ni curar después")
		other._resume_run()
		check(other.stage == 2 and other.player_hp == 12 and other.run_deck == game.run_deck, "Guardado conserva toda la elección")
		other._enter_stage()
		check(other.encounter_name == "EL GUARDAGUJAS" and other.hand.size() + other.draw_pile.size() == 11, "Continúa estación con carta nueva")
	game.start_run("Humanos")
	game.stage = 1
	game.player_hp = 8
	game.show_route()
	game._show_hermitage()
	check(game.find_child("HelpApparitionButton", true, false).disabled, "Impide sacrificio letal")
	game._resolve_hermitage("help")
	check(game.player_hp == 8 and game.stage == 1, "Validación también rechaza coste letal")
	game._resolve_hermitage("listen")
	check(game.player_hp == 20 and game.stage == 2 and game.run_deck.size() == 10, "Escuchar cura sin carta")
	game.start_run("Fantasmas")
	game.stage = 1
	game.player_hp = 49
	game.show_route()
	game._show_hermitage()
	game._resolve_hermitage("listen")
	check(game.player_hp == 50, "Curación limitada al máximo")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	game.queue_free()
	other.queue_free()
	await process_frame
	print("ERMITA: %d fallos" % failures)
	quit(1 if failures else 0)
