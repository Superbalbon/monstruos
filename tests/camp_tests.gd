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
	for instance in [game, other]:
		instance.persistence_enabled = false
		root.add_child(instance)
	var path := "res://.godot/camp-test-%d.json" % Time.get_ticks_usec()
	game.save_store.path = path
	other.save_store.path = path
	game.persistence_enabled = true
	other.persistence_enabled = true
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	for faction in game.STARTER_DECKS:
		game.start_run(faction)
		game._show_deck("", true)
		check(not game.has_node("DeckOverlay"), "No retirar fuera del descanso")
		game.stage = 3
		game.player_hp = 22
		game.show_route()
		await process_frame
		await process_frame
		var refine = game.find_child("RefineDeckButton", true, false)
		check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(refine.get_global_rect()), "Alternativa visible")
		refine.pressed.emit()
		game._unhandled_key_input(cancel)
		await process_frame
		check(game.stage == 3 and game.run_deck.size() == 10 and game.player_hp == 22, "Cancelar no cambia nada")
		other._resume_run()
		check(other.stage == 3 and other.run_deck.size() == 10, "Guardado previo sin retirar")
		game._show_deck("", true)
		game._remove_card_at_camp(-1)
		game._remove_card_at_camp(100)
		check(game.run_deck.size() == 10, "Índices inválidos rechazados")
		var id: String = game.run_deck[0]
		var copies: int = game.run_deck.count(id)
		var views = game.get_node("DeckOverlay").find_children("*", "Button", true, false)
		views[0].pressed.emit()
		var dialog = game.get_node("RemovalConfirmation")
		var saved_before := FileAccess.get_file_as_string(path)
		check(game.run_deck.size() == 10 and game.stage == 3, "Seleccionar aún no retira")
		check(game.cards_by_id[id].nombre in dialog.dialog_text and "10 a 9" in dialog.dialog_text, "Confirma carta y tamaño final")
		check(dialog.get_cancel_button().has_focus(), "Conservar carta por defecto")
		game._request_card_removal(1)
		check(game.get_node("RemovalConfirmation") == dialog, "No duplica confirmación")
		game._unhandled_key_input(cancel)
		await process_frame
		check(not game.has_node("RemovalConfirmation") and game.has_node("DeckOverlay"), "Escape vuelve al selector sin cerrarlo")
		check(FileAccess.get_file_as_string(path) == saved_before and game.run_deck.size() == 10, "Cancelar conserva archivo y mazo")
		views[0].pressed.emit()
		game.get_node("RemovalConfirmation").canceled.emit()
		await process_frame
		check(game.stage == 3 and game.player_hp == 22, "Botón conservar no consume descanso")
		views[0].pressed.emit()
		game.get_node("RemovalConfirmation").confirmed.emit()
		check(game.run_deck.size() == 9 and game.run_deck.count(id) == copies - 1, "Retira solo una copia")
		check(game.stage == 4 and game.player_hp == 22, "Retirar no cura y avanza")
		game._remove_card_at_camp(0)
		game._rest(15)
		check(game.run_deck.size() == 9 and game.player_hp == 22, "Decisión no repetible")
		other._resume_run()
		check(other.stage == 4 and other.run_deck == game.run_deck and other.player_hp == 22, "Carga conserva retirada")
		other._enter_stage()
		check(other.hand.size() + other.draw_pile.size() == 9, "Combate con mazo reducido")
		var saved: Dictionary = game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS)
		saved.stage = 2
		check(not game.save_store.valid(saved, game.cards_by_id, game.STARTER_DECKS, game.REWARDS), "No acepta nueve cartas antes del descanso")
	game.start_run("Humanos")
	game._request_card_removal(0)
	check(not game.has_node("RemovalConfirmation"), "No confirma retirada fuera del descanso")
	game.stage = 3
	game.player_hp = 22
	game.show_route()
	game._enter_stage()
	check(game.player_hp == 37 and game.run_deck.size() == 10 and game.stage == 4, "Curación sigue disponible")
	game.start_run("Humanos")
	game.stage = 3
	game._show_deck("", true)
	game._request_card_removal(0)
	game.run_deck.reverse()
	var changed_deck = game.run_deck.duplicate()
	game.get_node("RemovalConfirmation").confirmed.emit()
	await process_frame
	check(game.run_deck == changed_deck and game.stage == 3, "Confirmación obsoleta no retira otra copia")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	game.queue_free()
	other.queue_free()
	await process_frame
	print("DESCANSO: %d fallos" % failures)
	quit(1 if failures else 0)
