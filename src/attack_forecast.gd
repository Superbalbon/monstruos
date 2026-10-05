extends RefCounted

# Compare the announced hits with defenses, without simulating retaliation,
# death, thirst or fury. This is deliberately not a prediction of final health.
static func calculate(hit_damage: int, hits: int, block: int, ethereal: bool, militia_block: int) -> Dictionary:
	var damage := maxi(0, hit_damage)
	var count := maxi(0, hits) if damage > 0 else 0
	var total := damage * count
	var avoided := damage if ethereal and count > 0 else 0
	var available := maxi(0, block) + maxi(0, militia_block)
	var absorbed := mini(available, total - avoided)
	return {"per_hit": damage, "hits": count, "total": total, "avoided": avoided,
		"militia": maxi(0, militia_block), "absorbed": absorbed,
		"uncovered": total - avoided - absorbed}

static func describe(result: Dictionary) -> String:
	if result.hits == 0:
		return "DEFENSA PREVISTA\nNo hay golpes anunciados. Los demás efectos de la intención siguen aplicándose."
	return ("DEFENSA PREVISTA SI TERMINAS AHORA\n"
		+ "Golpes: %d × %d = %d de daño (Débil y Posesión ya aplicados).\n" % [result.per_hit, result.hits, result.total]
		+ "Etéreo evita: %d. Milicia añade: %d Bloqueo.\n" % [result.avoided, result.militia]
		+ "Absorbido por Bloqueo: %d. Daño sin cubrir: %d.\n\n" % [result.absorbed, result.uncovered]
		+ "Compara todos los golpes con tus defensas actuales.\n"
		+ "No predice la Salud final: no incluye interrupciones por muerte\n"
		+ "o contraataques, ni pérdida de Salud por Sed o Descontrol.")
