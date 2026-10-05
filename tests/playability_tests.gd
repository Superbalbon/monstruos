extends SceneTree

var failures := 0
var game

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func reason(id: String) -> String:
	return game._play_block_reason(game.cards_by_id[id])

func run() -> void:
	game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_run("Fantasmas")
	game._enter_stage()
	game.energy = 0
	check("Ímpetu" in reason("F015") and "Ectoplasma" in reason("F015") and "Ataque" in reason("F015"), "Eco enumera todas las condiciones pendientes")
	game.energy = 3
	game.faction_resource = 3
	game.last_attack_card = game.cards_by_id["F009"].duplicate(true)
	check(reason("F015").is_empty(), "Eco disponible al cumplir condiciones")
	game.enemy_intent_damage = 0
	check("anunciar un ataque" in reason("F002"), "Posesión explica intención defensiva")
	game.possession_active = true
	check("ya está activa" in reason("F002"), "Posesión duplicada")
	game.player_ethereal = true
	check("Ya tienes Etéreo" in reason("F008"), "Etéreo duplicado")
	check("todavía no" in reason("V008"), "Conversión sin acción previa")
	game.last_enemy_card = {"faccion": "Vampiros"}
	check("vampírica" in reason("V008"), "Conversión no válida")
	game.active_powers.append("V003")
	check("poder ya" in reason("V003"), "Poder duplicado")
	game.choosing_card = true
	check("Espía" in reason("F009"), "Selección pendiente tiene prioridad")
	game.choosing_card = false
	game.battle_over = true
	check("terminado" in reason("F009"), "Combate terminado tiene prioridad")
	game.battle_over = false
	game.hand.clear()
	game.hand.append(game.cards_by_id["F008"].duplicate(true))
	game._refresh_battle()
	await process_frame
	await process_frame
	var view = game.hand_box.get_child(0)
	check(view.disabled and "NO DISPONIBLE" in view.tooltip_text and "Ya tienes Etéreo" in view.tooltip_text, "Carta muestra motivo en tooltip")
	check(view.find_child("CardFooter", true, false).text == "NO DISPONIBLE", "Bloqueo visible sin depender del color")
	check(not view.find_child("InspectCard", true, false).disabled, "Consulta disponible aunque no se pueda jugar")
	check("SIN CARTAS JUGABLES" in game.end_turn_button.text, "Fin de turno indica bloqueo")
	var hp: int = game.player_hp
	game._play_card(game.hand[0])
	check("Ya tienes Etéreo" in game.message_label.text and game.energy == 3 and game.player_hp == hp and game.hand.size() == 1, "Intento inválido explica sin consumir recursos")
	game.player_ethereal = false
	game._refresh_battle()
	await process_frame
	await process_frame
	check(not game.hand_box.get_child(0).disabled and "NO DISPONIBLE" not in game.hand_box.get_child(0).tooltip_text, "Motivo desaparece al desbloquear")
	check(game.hand_box.get_child(0).find_child("CardFooter", true, false).text == "JUGABLE", "Indicador actualizado al desbloquear")
	var reusable = game.hand_box.get_child(0)
	reusable.set_play_availability("Prueba de bloqueo")
	reusable.set_play_availability("Prueba de bloqueo")
	check(reusable.tooltip_text.count("Prueba de bloqueo") == 1, "No duplica motivos al actualizar")
	reusable.set_play_availability("")
	check("Prueba de bloqueo" not in reusable.tooltip_text, "Limpia motivo antiguo")
	check(game.end_turn_button.text == "TERMINAR TURNO", "Botón se restaura")
	game.active_powers.append("L003")
	game.pack_played = false
	game.energy = 0
	check(reason("L002").is_empty(), "Ayuda usa coste dinámico cero de Alfa")
	game.pack_played = true
	check("Necesitas 1 Ímpetu" in reason("L002"), "Ayuda actualiza coste después de Manada")
	for card in game.cards_by_id.values():
		check(game._can_play(card) == game._play_block_reason(card).is_empty(), "Reglas y ayuda coinciden " + str(card.id))
	game.queue_free()
	await process_frame
	print("JUGABILIDAD: %d fallos" % failures)
	quit(1 if failures else 0)
