extends ColorRect

const SECTIONS := {
	"La ermita": "ENCUENTRO NARRATIVO\n\nTras vencer en la aldea puedes investigar la ermita en lugar de combatir al Acechador o tomar el refugio. La aparición cuenta una historia distinta a cada facción.\n\nAyudar cuesta 8 Salud y añade la carta mostrada al mazo: Milicia Organizada para Humanos, Alfa Dominante para Hombres Lobo, Conversión para Vampiros y Lamento Nocturno para Fantasmas. Necesitas al menos 9 Salud.\n\nEscuchar recupera 12 Salud, hasta el máximo de 50, sin añadir carta. Ambas decisiones avanzan a la estación y se guardan juntas con el mazo. No puedes repetir el evento.\n\nVolver o Esc cancela sin coste. Si cierras el juego antes de elegir, continuar recupera el cruce previo.",
	"Combate": "TURNO Y CARTAS\n\nComienzas cada turno con 3 Ímpetu y robas hasta tener 5 cartas. Jugar una carta paga su coste actual. Al terminar turno descartas la mano y el enemigo ejecuta la intención anunciada. Si falta mazo, se baraja el descarte.\n\nAgotar retira la carta durante este combate. Los poderes y aliados permanecen en juego; vuelven al mazo en el siguiente combate. No puedes activar dos copias del mismo poder, pero sí varios aliados iguales.\n\nLas cartas desactivadas explican el motivo al pasar el cursor. El aviso de que no quedan cartas jugables nunca termina el turno automáticamente.\n\nHay 40 cartas base y 25 mejoras disponibles. La ayuda de cada carta distingue las mejoras implementadas de las pendientes.",
	"Mejoras": "DESCANSO FINAL\n\nAntes del Custodio puedes mejorar una copia de tu mazo en vez de curarte o retirar una carta. El selector muestra la versión mejorada; su ayuda compara antes y después. Esc cancela. Confirmar avanza al monasterio sin curar.\n\nHay 25 mejoras disponibles, incluidos los ataques y defensas básicos y cartas de estados y recursos. Ejemplos: Cruz Sagrada da 6 Bloqueo; Manada Feroz hace tres golpes de 5; Drenaje Vital causa 13 daño y cura 4; Ectoplasma Frío causa 7 daño. Consulta la ayuda de cada carta para ver su mejora exacta.\n\nSolo cambia la copia seleccionada, marcada con +. Las mejoras persisten en el mazo y el guardado, y Eco las tiene en cuenta. Los costes, descuentos, límites y efectos no modificados se conservan. Las otras 15 mejoras aún no están implementadas.\n\nSolo puedes realizar una mejora por expedición en este prototipo. No abras una partida con mejoras en una versión antigua del juego.",
	"Estados": "BLOQUEO\nAbsorbe daño antes de perder Salud. Tu Bloqueo restante desaparece al comenzar tu turno, salvo con Barricada activa.\n\nVULNERABLE Y DÉBIL\nVulnerable aumenta un 50 % el daño de ataques recibido. Débil reduce un 25 % el daño de ataques causado. Se redondea hacia abajo; un ataque positivo bajo Débil hace al menos 1 antes del Bloqueo. Cada golpe de un ataque múltiple se calcula por separado. El daño de Trampa y del contraataque del Héroe no es un ataque.\n\nSANGRADO\nAl acabar el turno enemigo pierde tanta Salud como Sangrado tenga, ignorando Bloqueo; después pierde una carga.\n\nETÉREO\nEvita un solo golpe sin gastar Bloqueo y se consume. Permanece si nadie ataca. Antorcha lo elimina antes de golpear.\n\nPOSESIÓN\nReduce a la mitad cada golpe de la intención actual, después de Débil, mínimo 1. Requiere un ataque anunciado y no se acumula.\n\nMARCADO\nPista de Presa lo aplica. En las 40 cartas actuales aún no hay un efecto que aproveche esta marca.",
	"Humanos": "CONSAGRACIÓN\nCada carga añade 3 al siguiente golpe de ataque y se consume. En un ataque múltiple, las cargas se consumen golpe a golpe.\n\nCOMUNIDAD\nCada Milicia genera 3 Bloqueo por aliado al terminar tu turno, incluyéndose a sí misma. Varias Milicias acumulan sus efectos.\n\nHéroe Local otorga 8 Bloqueo al entrar. La primera vez cada turno que un ataque enemigo te quite Salud, contraataca por 4 por cada Héroe. Si mata al enemigo, cancela sus golpes restantes.\n\nCazador Experto roba una carta la primera vez que apliques Vulnerable cada turno. Barricada conserva el Bloqueo entre turnos, pero no entre combates.",
	"Hombres Lobo": "FURIA\nEmpieza en 0. Ganas Furia mediante cartas y 1 por cada golpe enemigo que te quite Salud. Al alcanzar 10, Descontrol reduce la Furia a 5, cuesta 3 Salud y añade 2 Fuerza temporal. Este coste ignora Bloqueo y puede causar derrota.\n\nSi Descontrol ocurre durante el ataque enemigo, su Fuerza dura tu siguiente turno. Cada punto de Fuerza añade 1 al daño de cada golpe de ataque. Luna Llena genera 1 Furia y 1 Fuerza desde el siguiente turno tras activarla.\n\nMANADA\nAlfa reduce en 1 el coste de la primera carta Manada del turno, mínimo 0. Su propia activación cuenta como Manada. Manada Feroz cuesta 1 menos si ya jugaste una Manada ese turno: no acumula ambos descuentos a la vez.\n\nLobo Solitario hace 4 menos de daño si tienes algún aliado en juego.",
	"Vampiros": "SED\nEmpieza en 0 y tiene máximo 10. Después de la acción enemiga, con Sed 8 o más pierdes 2 Salud; con 10 recibes además 1 Débil para tu siguiente turno.\n\nSed Insaciable roba una carta la primera vez que aumente realmente la Sed cada turno. Intentar aumentarla estando ya en 10 no activa el poder. Su primera activación no concede Ímpetu en la versión base.\n\nNiebla Eterna concede 3 Bloqueo con la primera carta Niebla del turno; su propia activación cuenta.\n\nCONVERSIÓN Y ESPÍA\nConversión copia la última acción ejecutada por un enemigo no vampiro, no su siguiente intención. La copia cuesta 1 y solo dura este combate; no se guarda en el mazo de la expedición.\n\nEl Espía permite elegir una de las dos próximas cartas y devuelve la otra arriba del mazo. Permanece como aliado, pero no repite la selección cada turno.",
	"Fantasmas": "ECTOPLASMA\nEmpieza en 0, llega hasta 8 y se conserva entre turnos. Posesión consume 2; Paso a Través consume 3 y concede Etéreo. Ambos requieren además el Ímpetu indicado en la carta.\n\nECO DEL PASADO\nRequiere 2 Ectoplasma y haber jugado un Ataque este turno. Repite el último al 50 %, con todos sus golpes y efectos secundarios. Los valores positivos se redondean hacia abajo con mínimo 1. No vuelve a pagar su Ímpetu, pero los costes secundarios de recurso no se reducen.\n\nLas condiciones se comprueban de nuevo después de pagar el Ectoplasma de Eco: Aparición puede dejar de aplicar Vulnerable si ya no tienes 3. Eco se agota.\n\nEjemplo: Ectoplasma Frío hace 4 daño y genera 1 Ectoplasma; su Eco hace 2 y genera 1, antes de otros modificadores.",
	"Expedición y guardado": "RUTA\nConservas Salud y mazo entre encuentros. Tras vencer eliges una de siete recompensas de tu facción o ninguna. Usa la barra horizontal para verlas todas. El catálogo permite consultar las 10 cartas de cada facción sin añadirlas al mazo.\n\nEl refugio recupera 12 Salud y evita un combate y su recompensa. En el descanso final eliges curar 15 o retirar una copia del mazo sin curarte. No se supera el máximo de 50 Salud.\n\nGUARDADO\nSe guarda en los puntos de control de la ruta y las recompensas. Salir durante un combate reinicia ese encuentro al continuar: no conserva el turno exacto. Una nueva expedición sustituye la anterior.\n\nEl guardado es local al ordenador. GitHub sincroniza el proyecto, no tu partida. Victoria final o derrota cierran la expedición. Consultar esta guía no guarda, consume turnos ni modifica la partida."
}

var previous_focus: Control

func _ready() -> void:
	name = "RulesOverlay"
	color = Color(0.02, 0.03, 0.05, 0.98)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	previous_focus = get_viewport().gui_get_focus_owner()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 40)
	add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)
	var heading := Label.new()
	heading.text = "GUÍA DE REGLAS · MONSTRUOS"
	heading.add_theme_font_size_override("font_size", 26)
	box.add_child(heading)
	var topics := OptionButton.new()
	topics.name = "GuideTopics"
	for topic in SECTIONS:
		topics.add_item(topic)
	box.add_child(topics)
	var body := RichTextLabel.new()
	body.name = "GuideBody"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.selection_enabled = true
	body.add_theme_font_size_override("normal_font_size", 20)
	box.add_child(body)
	topics.item_selected.connect(func(index: int):
		body.text = SECTIONS[topics.get_item_text(index)]
		body.scroll_to_line(0))
	topics.select(SECTIONS.keys().find("Combate"))
	body.text = SECTIONS["Combate"]
	var close_button := Button.new()
	close_button.name = "CloseGuide"
	close_button.text = "VOLVER · ESC"
	close_button.custom_minimum_size.y = 44
	close_button.pressed.connect(close)
	box.add_child(close_button)
	# Keep keyboard navigation inside the guide, away from battle controls.
	var controls: Array[Control] = [topics, body, close_button]
	for index in controls.size():
		var control := controls[index]
		control.focus_mode = Control.FOCUS_ALL
		var next := control.get_path_to(controls[(index + 1) % controls.size()])
		var previous := control.get_path_to(controls[(index + controls.size() - 1) % controls.size()])
		control.focus_next = next
		control.focus_previous = previous
		control.focus_neighbor_bottom = next
		control.focus_neighbor_top = previous
		control.focus_neighbor_left = previous
		control.focus_neighbor_right = next
	close_button.grab_focus()

func close() -> void:
	if is_instance_valid(previous_focus) and previous_focus.is_visible_in_tree():
		previous_focus.grab_focus()
	queue_free()
