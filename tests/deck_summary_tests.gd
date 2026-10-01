extends SceneTree

const Summary = preload("res://src/deck_summary.gd")
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func close(game) -> void:
	game.get_node("DeckOverlay").queue_free()
	await process_frame

func run() -> void:
	var empty: Array[Dictionary] = []
	check(Summary.summarize(empty).average == 0.0, "Mazo vacío sin división por cero")
	var sample: Array[Dictionary] = [
		{"tipo": "Ataque", "coste": 0}, {"tipo": "Ataque", "coste": 1},
		{"tipo": "Poder", "coste": 2, "upgraded": true},
		{"tipo": "Aliado", "coste": 3}, {"tipo": "Aliado", "coste": 5}]
	var result := Summary.summarize(sample)
	check(result.costs == [1, 1, 1, 2], "Agrupa costes 3 o más")
	check(is_equal_approx(result.average, 2.2), "Media usa coste real, no categoría 3+")
	check(result.types.Ataque == 2 and result.upgraded == 1, "Cuenta copias y mejoras")
	root.size = Vector2i(1280, 720)
	var game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for faction in game.STARTER_DECKS:
		game.start_run(faction)
		var original = game.run_deck.duplicate()
		game._show_deck()
		await process_frame
		await process_frame
		var label = game.get_node("DeckOverlay").find_child("DeckSummary", true, false)
		check("Mejoradas: 0/10" in label.text, "Inicial " + faction)
		check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(label.get_global_rect()), "Resumen visible " + faction)
		check(game.run_deck == original, "No reordena mazo " + faction)
		await close(game)
	game.start_run("Humanos")
	game.run_deck.assign(["H006", "H006+", "H010+"])
	game.stage = 3
	game._show_deck("", false, true)
	var label = game.get_node("DeckOverlay").find_child("DeckSummary", true, false)
	check("Mejoradas: 2/3" in label.text, "Resumen cuenta mejoras actuales, no previsualizaciones")
	check("0: 0 | 1: 1 | 2: 2 | 3+: 0" in label.text, "Costes de las copias mejoradas")
	await close(game)
	game.start_run("Humanos")
	game.stage = 3
	game._show_deck("", true)
	check(game.get_node("DeckOverlay").find_child("DeckSummary", true, false) != null, "Resumen en retirada")
	game._remove_card_at_camp(0)
	game._show_deck()
	check("Mejoradas: 0/9" in game.get_node("DeckOverlay").find_child("DeckSummary", true, false).text, "Actualiza tras retirar una copia")
	await close(game)
	game.start_run("Humanos")
	game.stage = 3
	game._show_deck("", false, true)
	game._upgrade_card_at_camp(0)
	game._show_deck()
	check("Mejoradas: 1/10" in game.get_node("DeckOverlay").find_child("DeckSummary", true, false).text, "Actualiza tras mejorar una copia")
	await close(game)
	# Start an actual encounter, then ensure pile views do not show expedition statistics.
	game.stage = 0
	game._enter_stage()
	var draw_before = game.draw_pile.duplicate(true)
	var hand_before = game.hand.duplicate(true)
	game._show_deck("Robo")
	check(game.get_node("DeckOverlay").find_child("DeckSummary", true, false) == null, "No confunde pilas con mazo completo")
	await close(game)
	game._show_deck()
	check(game.get_node("DeckOverlay").find_child("DeckSummary", true, false) != null, "Resumen en combate")
	check(game.draw_pile == draw_before and game.hand == hand_before and game.energy == 3, "Consulta no altera combate")
	game.queue_free()
	await process_frame
	print("COMPOSICIÓN DEL MAZO: %d fallos" % failures)
	quit(1 if failures else 0)
