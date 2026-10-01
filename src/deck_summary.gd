extends RefCounted

# Uses resolved expedition cards, never combat discounts or upgrade previews.
static func summarize(cards: Array[Dictionary]) -> Dictionary:
	var result := {"total": cards.size(), "upgraded": 0, "types": {}, "costs": [0, 0, 0, 0], "average": 0.0}
	var cost_total := 0
	for card in cards:
		var type := str(card.get("tipo", "Otro"))
		result.types[type] = int(result.types.get(type, 0)) + 1
		var cost := maxi(0, int(card.get("coste", 0)))
		result.costs[mini(cost, 3)] += 1
		cost_total += cost
		if card.get("upgraded", false):
			result.upgraded += 1
	if not cards.is_empty():
		result.average = float(cost_total) / cards.size()
	return result

static func describe(cards: Array[Dictionary]) -> String:
	var summary := summarize(cards)
	var types: Array[String] = []
	var names: Array = summary.types.keys()
	names.sort()
	for name in names:
		types.append("%s: %d" % [name, summary.types[name]])
	return "%s · Mejoradas: %d/%d\nCostes de Ímpetu · 0: %d | 1: %d | 2: %d | 3+: %d · Media: %.1f\nCostes impresos actuales, incluidas mejoras; sin descuentos de combate." % [
		" · ".join(types) if not types.is_empty() else "Mazo vacío",
		summary.upgraded, summary.total, summary.costs[0], summary.costs[1],
		summary.costs[2], summary.costs[3], summary.average]
