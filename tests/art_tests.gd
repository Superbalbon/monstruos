extends SceneTree

var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
func run() -> void:
	var game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	var registry: Dictionary = preload("res://src/card_art.gd").PATHS
	check(registry.size() == 40, "Cuarenta ilustraciones")
	for id in game.cards_by_id:
		var card: Dictionary = game.cards_by_id[id]
		var path: String = game._card_art_path(card)
		check(not path.is_empty() and path == registry.get(id, ""), "Asociación " + id)
		var texture = load(path)
		check(texture is Texture2D, "Textura importada " + id)
		if texture is Texture2D:
			check(texture.get_width() * 4 == texture.get_height() * 3, "Formato vertical 3:4 " + id)
		var upgraded: Dictionary = game.CardUpgrades.resolve(game.cards_by_id, id + "+")
		check(game._card_art_path(upgraded) == path, "Mejora conserva ilustración " + id)
		var view = game.CardViewScene.new()
		view.setup(card, game.FACTION_COLORS[card.faccion], path)
		root.add_child(view)
		var image = view.find_child("CardIllustration", true, false)
		check(image != null and image.texture == texture, "Carta muestra textura " + id)
		if image != null:
			check(image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Sin recorte ni deformación " + id)
		view.queue_free()
		await process_frame
	check(game._card_art_path({"id": "ENEMY_ACTION", "faccion": "Humanos"}).is_empty(), "Acción temporal sin arte incorrecto")
	game.queue_free()
	await process_frame
	print("ILUSTRACIONES: %d fallos" % failures)
	quit(0 if failures == 0 else 1)
