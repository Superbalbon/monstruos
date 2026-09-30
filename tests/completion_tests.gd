extends SceneTree

var failures := 0
var game

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func battle(faction: String, at_stage := 0) -> void:
	game.start_run(faction)
	game.stage = at_stage
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
	var save_path := "res://.godot/completion-save-%d.json" % Time.get_ticks_usec()
	game.save_store.path = save_path
	check(game.cards_by_id.size() == 40, "Catálogo exacto de cuarenta cartas")
	for id in game.cards_by_id:
		var card: Dictionary = game.cards_by_id[id]
		var faction: String = card.faccion
		check(id in game.STARTER_DECKS[faction] or id in game.REWARDS[faction], "Accesible en juego " + id)
		var deck: Array = game.STARTER_DECKS[faction].duplicate()
		deck.append(id)
		check(game.save_store.write({"version": 1, "state": "route", "faction": faction, "stage": 1, "hp": 30, "deck": deck}), "Escritura " + id)
		var saved: Dictionary = game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS)
		check(not saved.is_empty() and saved.deck == deck, "Carga " + id)
		battle(faction)
		game.faction_resource = 4
		game.player_hp = 30
		game.last_enemy_card = game._enemy_action_card()
		if id == "F015":
			play("F004")
		game.energy = 3
		var cost: int = game._card_cost(card)
		check(game._can_play(card), "Precondiciones " + id)
		play(id)
		check(game.energy == 3 - cost, "Pago " + id)
		if game.choosing_card:
			game.get_node("ScoutOverlay").find_children("*", "Button", true, false)[0].pressed.emit()
		if card.tipo == "Aliado":
			check(game._ally_count(id) == 1, "Aliado persistente " + id)
		elif card.tipo == "Poder":
			check(id in game._active_power_ids(), "Poder persistente " + id)
		elif id in ["L018", "V008", "V014", "F001", "F008", "F015"]:
			check(game.exhaust_pile.back().id == id, "Agotamiento " + id)
		else:
			check(game.discard_pile.back().id == id, "Descarte " + id)
		await process_frame
	battle("Humanos")
	play("H006")
	game.energy = 3
	play("H009")
	check(game.allies.size() == 2 and game.player_block == 8, "Entrada de aliados")
	game.player_block = 0
	game.enemy_intent_damage = 5
	game._end_turn()
	check(game.player_hp == 50 and game.enemy_hp == 100, "Milicia genera seis Bloqueo para dos aliados")
	game.player_block = 0
	game.enemy_intent_damage = 8
	game.enemy_intent_hits = 2
	game._end_turn()
	check(game.player_hp == 40 and game.enemy_hp == 96, "Héroe contraataca una vez por turno")
	game.player_block = 0
	game.enemy_intent_damage = 8
	game.enemy_intent_hits = 1
	game._end_turn()
	check(game.enemy_hp == 92, "Héroe se renueva")
	game.enemy_hp = 3
	game.enemy_block = 0
	game.enemy_intent_block = 0
	game.enemy_intent_damage = 8
	game.enemy_intent_hits = 2
	var hp: int = game.player_hp
	game._end_turn()
	check(game.screen == "won" and game.player_hp == hp - 2, "Contraataque letal detiene segundo golpe")
	battle("Humanos")
	play("H006")
	game.energy = 3
	play("H006")
	game.enemy_intent_damage = 10
	game._end_turn()
	check(game.player_hp == 50, "Dos milicias generan doce Bloqueo")
	game.start_battle("Humanos")
	check(game.allies.is_empty(), "Aliados reinician")
	battle("Hombres Lobo")
	play("L003")
	check(game._card_cost(game.cards_by_id["L002"]) == 1, "Alfa cuenta como primera Manada al activarse")
	game.enemy_intent_damage = 0
	game._end_turn()
	check(game._card_cost(game.cards_by_id["L002"]) == 0 and game._card_cost(game.cards_by_id["L005"]) == 1, "Alfa reduce primera Manada")
	play("L002")
	check(game.energy == 3 and game._card_cost(game.cards_by_id["L002"]) == 1, "Descuento se consume")
	check(game._card_cost(game.cards_by_id["L005"]) == 1, "Manada conserva descuento propio")
	game.allies.append(game.cards_by_id["H006"].duplicate(true))
	play("L008")
	check(game.enemy_hp == 96, "Solitario penalizado por aliado")
	battle("Vampiros", 2)
	check(not game._can_play(game.cards_by_id["V008"]), "Conversión requiere acción previa")
	game._end_turn()
	play("V008")
	var copy: Dictionary = game.hand.back()
	check(copy.id == "ENEMY_ACTION" and copy.temporal and copy.coste == 1, "Copia temporal rebajada")
	check(copy.damage == 8 and copy.block == 4, "Copia acción ejecutada y no próxima defensa")
	game.enemy_block = 0
	game._play_card(copy)
	check(game.enemy_hp == 92 and game.player_block == 4, "Copia ejecuta ataque y bloqueo")
	check(game.run_deck.size() == 10, "Temporal no entra en mazo persistente")
	var invalid_deck: Array = game.run_deck.duplicate()
	invalid_deck.append("ENEMY_ACTION")
	check(not game.save_store.valid({"version": 1, "state": "route", "faction": "Vampiros", "stage": 2, "hp": 30, "deck": invalid_deck}, game.cards_by_id, game.STARTER_DECKS, game.REWARDS), "Guardado rechaza temporales")
	game.start_battle("Vampiros")
	check(game.last_enemy_card.is_empty() and game.hand.size() + game.draw_pile.size() == 10, "Temporal desaparece entre combates")
	battle("Vampiros", 4)
	game.enemy_pattern = 1
	game._set_enemy_intent()
	game._end_turn()
	play("V008")
	copy = game.hand.back()
	game._play_card(copy)
	check(copy.tipo == "Habilidad" and game.player_block == 8 and game.player_ethereal and game.enemy_weak == 1, "Conversión reproduce defensa y estados sin ataque")
	check(game.last_attack_card.is_empty(), "Una copia defensiva no cuenta como ataque")
	battle("Humanos", 4)
	game.enemy_pattern = 1
	game._set_enemy_intent()
	game._end_turn()
	check(game.enemy_ethereal, "Custodio obtiene Etéreo anunciado")
	game.enemy_block = 0
	game.player_weak = 0
	play("H001")
	check(game.enemy_hp == 100 and not game.enemy_ethereal, "Etéreo evita ataque normal")
	game.enemy_ethereal = true
	play("H007")
	check(game.enemy_hp == 93 and not game.enemy_ethereal, "Antorcha elimina Etéreo antes del daño")
	battle("Humanos")
	game.enemy_ethereal = true
	game.enemy_vulnerable = 2
	play("H004")
	check(game.enemy_hp == 97 and game.enemy_ethereal, "Daño de Trampa no consume Etéreo ni recibe Vulnerable")
	game.hand.clear()
	var before_energy: int = game.energy
	game._play_card(game.cards_by_id["H001"])
	check(game.energy == before_energy and game.enemy_hp == 97, "No se juega una carta ajena a la mano")
	battle("Fantasmas")
	game.faction_resource = 7
	play("F007")
	check(game.faction_resource == 8 and game.enemy_weak == 2, "Lamento aplica estados y respeta límite")
	battle("Fantasmas")
	play("F004")
	game.faction_resource = 4
	play("F015")
	check(game.enemy_hp == 94 and game.faction_resource == 3, "Eco repite generación de Ectoplasma")
	game.energy = 3
	play("F005")
	check(game.enemy_vulnerable == 1, "Aparición aplica Vulnerable")
	play("F015")
	check(game.enemy_vulnerable == 1, "Eco reevalúa condición tras pagar Ectoplasma")
	battle("Fantasmas")
	game.faction_resource = 4
	play("L005")
	play("F015")
	check(game.enemy_hp == 82, "Eco repite tres golpes a mitad de potencia")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	game.queue_free()
	await process_frame
	print("CATÁLOGO COMPLETO: %d fallos" % failures)
	quit(1 if failures else 0)
