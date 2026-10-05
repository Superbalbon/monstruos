extends RefCounted

const AREAS := {
	"forest": {"title": "BOSQUE DE LAS ÁNIMAS", "name": "EL MONTERO HUECO", "hp": 44,
		"favored": "Hombres Lobo", "hindered": "Fantasmas", "bonus": "2 Furia inicial",
		"pattern": [{"damage": 5, "hits": 2}, {"block": 6}, {"damage": 13}]},
	"cemetery": {"title": "CEMENTERIO DE SAN TELMO", "name": "LA SEPULTURERA SIN ROSTRO", "hp": 44,
		"favored": "Fantasmas", "hindered": "Humanos", "bonus": "2 Ectoplasma inicial",
		"pattern": [{"damage": 7}, {"block": 8, "weak": 1}, {"damage": 12}]},
	"castle": {"title": "CASTILLO DE MONTENEGRO", "name": "EL MAYORDOMO DE HIERRO", "hp": 44,
		"favored": "Vampiros", "hindered": "Hombres Lobo", "bonus": "1 Ímpetu extra solo en el primer turno",
		"pattern": [{"damage": 8, "block": 3}, {"damage": 4, "hits": 2}, {"damage": 14}]}
}

static func effect_text(id: String, faction: String) -> String:
	var area: Dictionary = AREAS[id]
	if faction == area.favored:
		return "Ventaja: " + str(area.bonus) + "."
	if faction == area.hindered:
		return "Perjuicio: el rival comienza con 4 Bloqueo adicional."
	return "Terreno neutral: sin bonificaciones ni penalizaciones."

static func preview(id: String, faction: String) -> String:
	var area: Dictionary = AREAS[id]
	var actions: Array[String] = []
	for action in area.pattern:
		var parts: Array[String] = []
		if action.has("damage"):
			parts.append("ataque %d × %d" % [action.damage, action.get("hits", 1)])
		if action.has("block"):
			parts.append("%d Bloqueo" % action.block)
		if action.has("weak"):
			parts.append("%d Débil" % action.weak)
		actions.append(" + ".join(parts))
	return "%s · %d Salud · 25 monedas y elección de carta\n%s\nCiclo: %s" % [area.name, area.hp, effect_text(id, faction), " → ".join(actions)]
