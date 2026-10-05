extends RefCounted

# Base values; conditional bonuses, statuses and enemy defenses are in the rules.
const DAMAGE := {"H001": 6, "H007": 7, "L001": 6, "L004": 5, "L005": 4, "L006": 4, "L008": 8, "V001": 6, "V005": 10, "V006": 8, "F004": 4, "F005": 7, "F009": 6}
const BLOCK := {"H002": 4, "H003": 5, "H009": 8, "L029": 5, "V007": 5, "F003": 5}

static func badge(card: Dictionary) -> String:
	var id: String = card.id
	var parts: Array[String] = []
	var damage := int(card.get("attack_damage", DAMAGE.get(id, card.get("damage", 0))))
	if id == "H004":
		damage = int(card.get("direct_damage", 3))
	var hits := 3 if id == "L005" else int(card.get("hits", 1))
	if damage > 0:
		parts.append("%d%s DAÑO" % [damage, "×%d" % hits if hits > 1 else ""])
	var block := int(card.get("block_amount", BLOCK.get(id, card.get("block", 0))))
	if block > 0:
		parts.append("%d BLOQ." % block)
	return "\n".join(parts) if not parts.is_empty() else "EFECTO"

static func rules(card: Dictionary) -> String:
	# Only remove an exact, unconditional sentence already represented by a badge.
	# Leave conditional damage, repeated attacks and compound sentences untouched.
	var full := str(card.efecto)
	var id := str(card.id)
	var damage := int(card.get("attack_damage", DAMAGE.get(id, 0)))
	var block := int(card.get("block_amount", BLOCK.get(id, 0)))
	var prefixes: Array[String] = []
	if damage > 0 and id != "L005":
		prefixes.append("Inflige %d de daño." % damage)
	if block > 0:
		prefixes.append("Obtén %d de Bloqueo." % block)
	for prefix in prefixes:
		if full == prefix:
			return "Daño indicado arriba." if prefix.begins_with("Inflige") else "Bloqueo indicado arriba."
		if full.begins_with(prefix + " "):
			return full.trim_prefix(prefix + " ")
	return full
