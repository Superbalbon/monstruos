extends RefCounted

const CURRENCIES := {"Humanos": "Reales", "Hombres Lobo": "Colmillos de caza", "Vampiros": "Sellos de sangre", "Fantasmas": "Ecos"}
const REWARDS := {0: 20, 1: 30, 2: 25, 4: 40}
const ITEMS := {
	"H_CROSS": {"faction": "Humanos", "name": "Cruz del Alba", "price": 35, "effect": "consecration", "amount": 1, "text": "Comienza cada combate con 1 Consagración."},
	"H_RING": {"faction": "Humanos", "name": "Anillo del Guardián", "price": 30, "effect": "block", "amount": 4, "text": "Obtén 4 Bloqueo al comenzar el primer turno de cada combate."},
	"H_MEDAL": {"faction": "Humanos", "name": "Medalla del Socorro", "price": 20, "effect": "heal", "amount": 3, "text": "Recupera 3 Salud después de vencer, sin superar tu máximo."},
	"L_TOTEM": {"faction": "Hombres Lobo", "name": "Tótem de la Sierra", "price": 35, "effect": "fury", "amount": 2, "text": "Comienza cada combate con 2 Furia."},
	"L_BONE": {"faction": "Hombres Lobo", "name": "Amuleto de Hueso", "price": 30, "effect": "block", "amount": 4, "text": "Obtén 4 Bloqueo al comenzar el primer turno de cada combate."},
	"L_FANG": {"faction": "Hombres Lobo", "name": "Colmillo del Retorno", "price": 20, "effect": "heal", "amount": 3, "text": "Recupera 3 Salud después de vencer, sin superar tu máximo."},
	"V_SIGNET": {"faction": "Vampiros", "name": "Sortija de Montenegro", "price": 35, "effect": "energy", "amount": 1, "text": "Obtén 1 Ímpetu adicional solo en el primer turno de cada combate."},
	"V_CAMEO": {"faction": "Vampiros", "name": "Camafeo del Velo", "price": 30, "effect": "block", "amount": 4, "text": "Obtén 4 Bloqueo al comenzar el primer turno de cada combate."},
	"V_CHALICE": {"faction": "Vampiros", "name": "Cáliz del Regreso", "price": 20, "effect": "heal", "amount": 3, "text": "Recupera 3 Salud después de vencer, sin superar tu máximo."},
	"F_CLOCK": {"faction": "Fantasmas", "name": "Reloj Detenido", "price": 35, "effect": "ectoplasm", "amount": 2, "text": "Comienza cada combate con 2 Ectoplasma."},
	"F_CHAIN": {"faction": "Fantasmas", "name": "Cadena del Umbral", "price": 30, "effect": "block", "amount": 4, "text": "Obtén 4 Bloqueo al comenzar el primer turno de cada combate."},
	"F_MIRROR": {"faction": "Fantasmas", "name": "Espejo del Recuerdo", "price": 20, "effect": "heal", "amount": 3, "text": "Recupera 3 Salud después de vencer, sin superar tu máximo."}
}

static func bonus(owned: Array[String], effect: String) -> int:
	var total := 0
	for id in owned:
		if ITEMS.has(id) and ITEMS[id].effect == effect:
			total += int(ITEMS[id].amount)
	return total
