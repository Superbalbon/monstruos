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
	"F006": {"weak_amount": 3},
	"H006": {"coste": 1}, "H008": {"innate": true}, "H009": {"block_amount": 12},
	"H010": {"coste": 2}, "L003": {"coste": 1}, "L007": {"on_play_fury": 2},
	"L018": {"exhausts": false}, "V002": {"mist_block": 5},
	"V003": {"first_thirst_energy": 1}, "V004": {"scout_count": 3},
	"V008": {"copy_discount": 2}, "F002": {"resource_cost": 1},
	"F007": {"coste": 1}, "F008": {"resource_cost": 2}, "F015": {"echo_scale": 0.75}
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
		# Some upgrade descriptions specify only a delta, not the full effect.
		if id in ["H006", "H008", "H009", "H010", "L003", "L007", "L018", "V002", "V003", "V004", "V008", "F002", "F007", "F008", "F015"]:
			var effects := {
				"H006": "Permanece en juego. Al final de tu turno, obtén 3 de Bloqueo por cada Aliado (incluye esta Milicia).",
				"H008": "Empieza cada combate en tu mano. La primera vez que aplicas Vulnerable cada turno, roba 1 carta.",
				"H009": "Permanece en juego. Obtén 12 de Bloqueo. La primera vez que un ataque te quite Salud cada turno, causa 4 de daño al atacante.",
				"H010": "Tu Bloqueo ya no desaparece al comenzar tu turno.",
				"L003": "La primera carta de Manada de cada turno cuesta 1 menos (mínimo 0). Este Alfa cuenta como Manada al jugarlo.",
				"L007": "Al jugarla, gana 2 Furia. Al inicio de tu turno, gana 1 Furia y 1 Fuerza durante ese turno.",
				"L018": "Aplica Marcado. Roba 1 carta. No se agota.",
				"V002": "La primera vez que juegues una carta de Niebla cada turno, obtén 5 de Bloqueo.",
				"V003": "Cuando aumente tu Sed, roba 1 carta una vez por turno. La primera activación del combate también otorga 1 Ímpetu.",
				"V004": "Al jugarlo, mira las tres próximas cartas. Roba una y devuelve las demás arriba, en su orden. Permanece como Aliado sin repetir el efecto.",
				"V008": "Copia en tu mano la última carta no vampírica ejecutada por el enemigo. La copia cuesta 2 menos (mínimo 0) y dura este combate. Agota.",
				"F002": "Consume 1 Ectoplasma. Reduce a la mitad cada golpe de la intención actual (mínimo 1). Requiere un ataque anunciado. No se acumula.",
				"F007": "Aplica 2 Débil a todos los enemigos. Obtén 2 Ectoplasma.",
				"F008": "Consume 2 Ectoplasma. Etéreo evita el siguiente golpe sin gastar Bloqueo. No se acumula. Agota.",
				"F015": "Consume 2 Ectoplasma. Repite el último Ataque de este turno al 75 % (redondea abajo, mínimo 1 por efecto positivo). Agota."
			}
			card.efecto = effects[id]
	return card
