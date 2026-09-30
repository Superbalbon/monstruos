extends RefCounted

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
	if value.get("version") != 1 or value.get("state") not in ["route", "reward", "finished"]:
		return false
	var faction: Variant = value.get("faction")
	if not faction is String or not starters.has(faction):
		return false
	for key in ["stage", "hp"]:
		var number: Variant = value.get(key)
		if not (number is int or number is float) or not is_finite(float(number)) or float(number) != floor(float(number)):
			return false
	if value.stage < 0 or value.stage > 4 or value.hp < 0 or value.hp > 50:
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
	for id in value.deck:
		if not id is String or not cards.has(id):
			return false
		if id not in starters[faction] and id not in rewards[faction]:
			return false
	return true
