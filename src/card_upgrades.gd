extends RefCounted

# Only these base effects are implemented as upgrades in this milestone.
const VALUES := {
	"H001": {"attack_damage": 8}, "H003": {"block_amount": 8},
	"L001": {"attack_damage": 9}, "L029": {"block_amount": 8},
	"V001": {"attack_damage": 9}, "V007": {"block_amount": 8},
	"F009": {"attack_damage": 9}, "F003": {"block_amount": 8}
}

static func can_upgrade(id: String) -> bool:
	return VALUES.has(id)

static func resolve(cards: Dictionary, deck_id: String) -> Dictionary:
	var upgraded := deck_id.ends_with("+")
	var id := deck_id.trim_suffix("+") if upgraded else deck_id
	if not cards.has(id) or (upgraded and not can_upgrade(id)):
		return {}
	var card: Dictionary = cards[id].duplicate(true)
	if upgraded:
		card.upgraded = true
		card.nombre = str(card.nombre) + " +"
		card.efecto = card.mejora
		card.merge(VALUES[id], true)
	return card
