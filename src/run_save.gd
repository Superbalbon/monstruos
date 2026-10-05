extends RefCounted

const CardUpgrades = preload("res://src/card_upgrades.gd")
const Relics = preload("res://src/relics.gd")
const Biomes = preload("res://src/biomes.gd")

var path := "user://expedicion.json"
var last_error := ""

func write(data: Dictionary) -> bool:
	last_error = ""
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		last_error = "No se pudo abrir el archivo de guardado."
		return false
	file.store_string(JSON.stringify(data))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		last_error = "No se pudo escribir el guardado."
		return false
	error = DirAccess.rename_absolute(ProjectSettings.globalize_path(path + ".tmp"), ProjectSettings.globalize_path(path))
	if error != OK:
		last_error = "No se pudo reemplazar el guardado anterior."
		return false
	return true

func read(cards: Dictionary, starters: Dictionary, rewards: Dictionary) -> Dictionary:
	last_error = ""
	if not FileAccess.file_exists(path):
		return {}
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		last_error = "La partida guardada está dañada."
		return {}
	var value: Variant = parser.data
	if not valid(value, cards, starters, rewards):
		last_error = "La partida guardada no es compatible o está dañada."
		return {}
	return value

func valid(value: Variant, cards: Dictionary, starters: Dictionary, rewards: Dictionary) -> bool:
	if not value is Dictionary:
		return false
	var version: Variant = value.get("version")
	if not (version is int or version is float) or not is_finite(float(version)) or float(version) != floor(float(version)):
		return false
	if int(version) not in [1, 2, 3, 4, 5, 6, 7] or value.get("state") not in ["route", "reward", "finished"]:
		return false
	var faction: Variant = value.get("faction")
	if not faction is String or not starters.has(faction):
		return false
	if value.version >= 3:
		var coins: Variant = value.get("coins")
		if not (coins is int or coins is float) or not is_finite(float(coins)) or float(coins) != floor(float(coins)) or coins < 0 or coins > 10000:
			return false
		var relics: Variant = value.get("relics")
		if not relics is Array or relics.size() > 3:
			return false
		var seen: Array[String] = []
		for id in relics:
			if not id is String or not Relics.ITEMS.has(id) or id in seen:
				return false
			if Relics.ITEMS[id].faction != faction:
				return false
			seen.append(id)
	for key in ["stage", "hp"]:
		var number: Variant = value.get(key)
		if not (number is int or number is float) or not is_finite(float(number)) or float(number) != floor(float(number)):
			return false
	if value.stage < 0 or value.stage > 4 or value.hp < 0 or value.hp > 50:
		return false
	if value.version >= 4:
		if not value.get("elite") is bool:
			return false
		if value.elite and int(value.stage) != 2:
			return false
	if value.version >= 6:
		if not value.get("biome") is String or not Biomes.AREAS.has(value.biome) or value.stage < 2 or value.elite:
			return false
		if not value.get("city_path") is String or not value.get("arena") is Dictionary or not value.arena.is_empty():
			return false
	if value.version == 7:
		if value.get("biome_path") not in ["pending", "combat", "refuge", "merchant"]:
			return false
		if value.biome_path == "pending" and (int(value.stage) != 2 or value.state != "route"):
			return false
		if value.biome_path == "refuge" and value.stage < 3:
			return false
		if value.biome_path == "merchant" and int(value.stage) == 2 and value.state != "route":
			return false
	if value.version == 5 or (value.version >= 6 and not value.city_path.is_empty()):
		if value.get("city_path") not in ["merchant", "refuge", "arena"] or not value.get("arena") is Dictionary or value.stage < 1:
			return false
		if not value.arena.is_empty():
			if value.city_path != "arena" or int(value.stage) != 1 or value.state != "route" or value.elite:
				return false
			for key in ["entry_hp", "wave"]:
				var number: Variant = value.arena.get(key)
				if not (number is int or number is float) or not is_finite(float(number)) or float(number) != floor(float(number)):
					return false
			if value.arena.entry_hp < 1 or value.arena.entry_hp > 50 or value.arena.wave < 1 or value.arena.wave > 3:
				return false
		elif int(value.stage) == 1 and value.city_path != "merchant":
			return false
		if int(value.stage) == 1 and value.state != "route":
			return false
	if value.state != "finished" and value.hp == 0:
		return false
	if value.state == "reward" and int(value.stage) not in [0, 1, 2]:
		return false
	if not value.get("deck") is Array or value.deck.size() < 9 or value.deck.size() > 13:
		return false
	# Only the final rest can remove a card; earlier checkpoints need ten.
	if value.deck.size() == 9 and int(value.stage) != 4:
		return false
	var upgrades := 0
	for deck_id in value.deck:
		if not deck_id is String:
			return false
		var id: String = deck_id
		if id.ends_with("+"):
			id = id.trim_suffix("+")
			upgrades += 1
			if int(value.version) not in [2, 3, 4, 5, 6, 7] or int(value.stage) != 4 or value.deck.size() == 9 or upgrades > 1 or not CardUpgrades.can_upgrade(id):
				return false
		if not cards.has(id):
			return false
		if id not in starters[faction] and id not in rewards[faction]:
			return false
	return true
