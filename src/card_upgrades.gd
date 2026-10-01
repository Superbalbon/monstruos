extends RefCounted

# Only these base effects are implemented as upgrades in this milestone.
const VALUES := {
	"H001": {"attack_damage": 8}, "H003": {"block_amount": 8},
	"L001": {"attack_damage": 9}, "L029": {"block_amount": 8},
	"V001": {"attack_damage": 9}, "V007": {"block_amount": 8},
	"F009": {"attack_damage": 9}, "F003": {"block_amount": 8},
	"H002": {"block_amount": 6}, "H004": {"direct_damage": 5},
	"H005": {"weak_amount": 2}, "H007": {"attack_damage": 10},
	"L002": {"fury_amount": 3}, "L004": {"attack_damage": 7, "bleed_amount": 3},
	"L005": {"attack_damage": 5},
	"L006": {"attack_damage": 6, "efecto": "Inflige 6 de daño y aplica 2 de Débil. Consume 2 de Furia; si lo hace, aplica 2 de Sangrado."},
	"L008": {"attack_damage": 11},
	"V005": {"attack_damage": 13, "heal_amount": 4}, "V006": {"attack_damage": 11},
	"V009": {"weak_amount": 3}, "V014": {"thirst_reduction": 3},
	"F001": {"ectoplasm_amount": 2}, "F004": {"attack_damage": 7},
	"F005": {"attack_damage": 10, "efecto": "Inflige 10 de daño. Si tienes 3 o más de Ectoplasma, aplica 1 de Vulnerable."},
	"F006": {"weak_amount": 3}
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
