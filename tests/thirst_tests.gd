extends SceneTree

var failures := 0
var game

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func battle() -> void:
	game.start_run("Vampiros")
	game._enter_stage()
	game.enemy_hp = 100

func play(id: String) -> void:
	var card: Dictionary = game.cards_by_id[id].duplicate(true)
	game.hand.append(card)
	game._play_card(card)

func run() -> void:
	game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	battle()
	var before: int = game.hand.size()
	play("V006")
	check(game.hand.size() == before and not game.thirst_triggered, "Sin poder no roba")
	play("V003")
	check(game.hand.size() == before and "V003" in game.active_powers, "Activar no roba retroactivamente")
	play("V009")
	check(game.hand.size() == before + 1 and game.thirst_triggered and game.faction_resource == 2, "Hipnosis activa robo")
	game.energy = 3
	play("V006")
	check(game.hand.size() == before + 1, "Solo una activación por turno")
	check(not game._can_play(game.cards_by_id["V003"]), "Poder no se duplica")
	game.enemy_intent_damage = 0
	game._end_turn()
	check(not game.thirst_triggered, "Activación se renueva")
	before = game.hand.size()
	play("V006")
	check(game.hand.size() == before + 1, "Colmillo activa en nuevo turno")
	battle()
	play("V003")
	game.faction_resource = 10
	before = game.hand.size()
	play("V009")
	check(game.hand.size() == before and not game.thirst_triggered, "Sed al máximo no activa ni gasta oportunidad")
	play("V014")
	check(not game.thirst_triggered, "Reducir Sed no activa poder")
	before = game.hand.size()
	play("V006")
	check(game.hand.size() == before + 1 and game.thirst_triggered, "Reducir y luego aumentar sí activa")
	battle()
	play("V003")
	game.hand.clear()
	game.draw_pile.clear()
	game.discard_pile.clear()
	play("V009")
	check(game.hand.is_empty() and game.thirst_triggered, "Sin cartas no se roba la carta en resolución")
	check("robas 0 carta" in "\n".join(game.combat_log), "Historial refleja falta de cartas")
	battle()
	play("V003")
	game.hand.clear()
	game.draw_pile.clear()
	game.discard_pile.assign([game.cards_by_id["V007"].duplicate(true)])
	play("V006")
	check(game.hand.size() == 1 and game.hand[0].id == "V007", "Roba del descarte al barajar")
	game.run_deck.append("V003")
	game.start_battle("Vampiros")
	check(game.active_powers.is_empty() and not game.thirst_triggered, "Poder reinicia entre combates")
	check(game.hand.size() + game.draw_pile.size() == 11, "Poder vuelve al mazo")
	game._finish_battle(true)
	game.show_rewards()
	game._take_reward("V003")
	check(game.run_deck.count("V003") == 2, "Disponible como recompensa")
	game.queue_free()
	await process_frame
	print("SED INSACIABLE: %d fallos" % failures)
	quit(1 if failures else 0)
