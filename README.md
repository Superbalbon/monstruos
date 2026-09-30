# Monstruos

Videojuego *deck-builder roguelike* ambientado en una España gótica de finales del siglo XIX.

En 1897, una herida sobrenatural se abre bajo la comarca de Valdegrís. Humanos, hombres lobo, vampiros y fantasmas deben decidir si combaten entre sí o impiden que una presencia más antigua borre la frontera entre los vivos y los muertos.

## Identidad del juego

- **Género:** construcción de mazos, combates por turnos y rutas ramificadas.
- **Ambientación:** España, 1897; revolución industrial tardía, tradición rural, espiritismo y terror gótico.
- **Facciones jugables:** Humanos, Hombres Lobo, Vampiros y Fantasmas.
- **Tono:** misterio, tragedia y alianzas incómodas; ninguna especie es inherentemente buena o malvada.
- **Nombre provisional:** **Monstruos**.

## Documentación

- [Historia y mundo](docs/HISTORIA_Y_MUNDO.md)
- [Diseño de las facciones](docs/FACCIONES.md)
- [Sistema de combate](docs/SISTEMA_COMBATE.md)
- [Catálogo de 200 cartas](data/cartas.csv)
- [Primeras 40 cartas jugables](data/cartas_prototipo.json)
- [Evoluciones especiales](data/evoluciones.csv)
- [Prompts de arte del prototipo](docs/PROMPTS_ARTE_PROTOTIPO.md)
- [Convención para ilustraciones](assets/cards/README.md)

## Estado

La preproducción narrativa, el catálogo nominal y las reglas base de combate están definidos. El prototipo de Godot permite elegir una de las cuatro facciones y disputar un combate completo con su mazo inicial cargado desde los datos del juego.

## Ejecutar el prototipo

1. Instala Godot 4.3 o posterior.
2. Importa esta carpeta seleccionando `project.godot`.
3. Ejecuta el proyecto con **F6** o **F5**.

No requiere complementos ni recursos externos.

## Controles

- Selecciona una carta para jugarla.
- Pasa el cursor sobre una carta para ver su mejora.
- Pulsa **Terminar turno** para resolver la intención enemiga.
- El Murciélago Espía abre una selección de las siguientes cartas del mazo.

## Ruta del prototipo

La selección de estirpe inicia una expedición: aldea, sendero o refugio,
estación, descanso y jefe de Santa Vigilia. La Salud y las cartas adquiridas
se conservan entre encuentros. Tras vencer puedes elegir una de cinco cartas
(seis en Fantasmas, accesibles con la barra horizontal)
o continuar sin ampliar el mazo. El refugio recupera 12 de Salud y el descanso
15, sin superar 50. El guardado automático permite continuar desde el menú.

En el descanso anterior al Custodio puedes elegir entre recuperar 15 Salud o
**retirar una carta sin curarte**. La alternativa abre tu mazo: selecciona la
copia que quieras retirar de esta expedición, o cancela con Esc. Retirar avanza
al monasterio y se guarda automáticamente; no puedes retirar y curarte en el
mismo descanso. El mazo puede quedar en 9 cartas. Los guardados anteriores
siguen funcionando en esta versión; no uses una versión antigua para cargar
una expedición cuyo mazo haya quedado reducido a 9 cartas.

Las recompensas son una selección fija por facción de efectos implementados.
Hay ocho efectos nuevos: Trampa para Lobos, Campana de la Iglesia,
Colmillo Venenoso, Lobo Solitario, Drenaje Vital, Colmillo Noble,
Ectoplasma Frío y Cadena Etérea. El catálogo de 40 cartas sigue siendo un
documento de diseño: todavía no están implementadas todas las cartas,
las mejoras ni los aliados persistentes. Descontrol y las penalizaciones de Sed
ya funcionan; los estados del jugador se muestran junto a su recurso.
El balance de la ruta es provisional.

Cada facción dispone también de una cuarta recompensa:

- **Barricada:** cuesta 3 y conserva el Bloqueo restante entre turnos. Es un poder
  activo hasta terminar el combate; no se descarta ni se vuelve a robar. Otra
  copia no puede jugarse mientras esté activo. En el siguiente combate vuelve
  al mazo y hay que activarlo de nuevo.
- **Mordida Rabiosa:** 5 de daño, 2 de Sangrado y 1 de Furia, en ese orden.
- **Hipnosis Mental:** 2 de Débil y 1 de Sed; puede alcanzar el umbral peligroso.
- **Aparición Súbita:** 7 de daño y, con al menos 3 de Ectoplasma, aplica
  1 de Vulnerable después del golpe, sin consumir Ectoplasma.

Estas recompensas son compatibles con el formato de guardado existente.

Fantasmas dispone además de dos defensas como recompensa, también visibles en
el catálogo (no se añaden automáticamente al mazo inicial):

- **Posesión Leve:** 1 Ímpetu y 2 Ectoplasma. Reduce a la mitad cada golpe de la
  intención actual, después de Débil, redondeando hacia abajo con mínimo 1.
  Requiere que el enemigo anuncie un ataque y no se acumula consigo misma.
- **Paso a Través:** 1 Ímpetu y 3 Ectoplasma. Otorga Etéreo y se agota. Evita el
  siguiente golpe sin consumir Bloqueo, pero no los demás de un ataque múltiple.
  Se conserva si el enemigo solo se defiende; no se acumula consigo mismo.

Ambos efectos se reinician al comenzar otro combate. La intención refleja la
reducción por Posesión e indica cuándo Etéreo evitará el primer golpe.

Hay tres poderes adicionales como quinta recompensa de sus facciones:

- **Cazador Experto (Humanos):** roba una carta la primera vez que aplicas
  Vulnerable cada turno mientras está activo. Combina con Trampa para Lobos.
- **Luna Llena (Hombres Lobo):** desde el siguiente turno, genera 1 Furia y
  1 Fuerza temporal al empezar cada turno. Puede provocar Descontrol, incluso
  una derrota si no queda suficiente Salud para pagar su coste.
- **Niebla Eterna (Vampiros):** la primera carta de Niebla jugada cada turno
  mientras está activo otorga 3 Bloqueo. Su propia activación cuenta como Niebla;
  a partir del siguiente turno puede activarse con Velo de Sombras.

Estos poderes salen de las pilas al jugarse, aparecen en **Poderes** y en el
historial, y no admiten otra copia activa simultáneamente. Sus cartas vuelven
al mazo en el siguiente combate, pero hay que activarlas de nuevo.

## Intenciones enemigas

Cada encuentro tiene su propio ciclo, que se repite en este orden:

| Enemigo | Ciclo de acciones |
|---|---|
| Desvelado | Ataque 7 → ataque 10 → Bloqueo 7 → ataque 13 |
| Acechador | Dos golpes de 4 → Bloqueo 4 → ataque 12 |
| Guardagujas | Ataque 8 y Bloqueo 4 → Bloqueo 10 → ataque 14 |
| Custodio | Ataque 9 → Bloqueo 8 y 1 Débil → dos golpes de 6 → ataque 16 |

La intención muestra todos los efectos antes de resolverlos. Débil reduce cada
golpe un 25 % (redondeado hacia abajo), y el Bloqueo disponible se consume entre
golpes. Un hombre lobo obtiene Furia por cada golpe que le quite Salud. El Débil
del Custodio afecta al siguiente turno del jugador. Los ataques cesan al morir.
El balance de estos patrones es provisional; las pruebas verifican sus reglas,
no garantizan una dificultad equilibrada para todas las facciones.

## Pruebas de regresión

Con Godot accesible en consola:

```powershell
godot --headless --path . --script res://tests/run_tests.gd
```

Comprueba las cuatro facciones, persistencia de Salud y mazo, recompensa única,
rechazo de recompensa, descanso, jefe, derrota, reinicio y duplicados del Espía.
Las victorias de las pruebas de ruta se fuerzan para comprobar transiciones;
esto no constituye una prueba de equilibrio de dificultad.

## Guardado y consulta del mazo

- **Catálogo de cartas**, en el menú principal y en la ruta, muestra todas las
  cartas implementadas, sin duplicados y filtradas por facción. Cada carta indica
  si pertenece al mazo inicial, si se obtiene como recompensa o ambas cosas.
  Consultarlo no añade cartas ni modifica el guardado. Se cierra con su botón
  o con **Esc**; las cartas aún pendientes de implementar no aparecen.
- En combate, **Salir al menú** (o **Esc**) abre una confirmación que explica
  que se reiniciará el encuentro. **Seguir jugando** cancela sin alterar el turno.
- En la ruta, **Guardar y volver al menú** confirma el guardado antes de salir.
- En recompensas, **Guardar y elegir la recompensa más tarde** permite aplazar
  la elección. La ruta y las recompensas muestran el estado del guardado.

- Se guarda al llegar a la ruta, tras vencer (recompensa pendiente), al elegir
  recompensa y después del descanso. Victoria final y derrota cierran la expedición.
- Cerrar durante un combate permite reintentarlo desde el punto de control previo,
  con la Salud previa y un nuevo barajado; no se recupera el turno exacto.
- `Continuar` restaura facción, Salud, etapa y mazo. Elegir estirpe para una nueva
  expedición sustituye la anterior, tal como indica el menú.
- `Ver mazo` muestra todas las copias de la expedición desde la ruta y el combate.
- En combate, pulsa **Robo**, **Descarte**, **Agotadas** o **Poderes** para consultar
  las cartas de esa pila, incluidas las copias repetidas. Robo se ordena por nombre
  y no revela el orden real ni altera el barajado. Poderes muestra Barricada cuando
  está activa. Los visores son de solo consulta y se cierran con **Esc** o su botón.
- **Historial**, junto a las pilas, muestra los últimos 200 eventos del combate:
  cartas, estados tras jugarlas, intenciones, golpes, absorción por Bloqueo,
  Descontrol, Sed, Sangrado y resultado. Permite seleccionar y copiar el texto.
  También puede abrirse tras victoria o derrota, antes de abandonar esa pantalla.
  Es temporal: se reinicia en cada combate y no forma parte del guardado.
- El archivo `user://expedicion.json` es local al ordenador, no se sincroniza
  mediante GitHub. En Windows normalmente se encuentra en
  `%APPDATA%/Godot/app_userdata/Monstruos/expedicion.json`.
- Guardados dañados o de otra versión se rechazan con aviso. Una escritura
  temporal precede al reemplazo del archivo; un fallo se muestra en pantalla.

Pruebas adicionales: `godot --headless --path . --script res://tests/save_tests.gd`.
Las pruebas usan archivos exclusivos en `.godot/` y no modifican la partida real.

El mazo inicial de Fantasmas incorpora Ectoplasma Frío para poder activar Eco
del Pasado. Este cambio afecta a nuevas expediciones; los guardados existentes
conservan su mazo. Puedes consultar las reglas de cada recurso dejando el cursor
sobre el estado del personaje. Pruebas de estas reglas:
`godot --headless --path . --script res://tests/faction_tests.gd`.

Pruebas de las nuevas cartas y del ciclo de vida de Barricada:
`godot --headless --path . --script res://tests/reward_tests.gd`.

Pruebas del catálogo, sus filtros, procedencia de cartas y consulta sin cambios:
`godot --headless --path . --script res://tests/catalog_tests.gd`.

Pruebas de patrones, intenciones y ataques múltiples:
`godot --headless --path . --script res://tests/enemy_tests.gd`.

Pruebas de consulta de pilas sin alterar el combate ni el orden de robo:
`godot --headless --path . --script res://tests/pile_tests.gd`.

Pruebas del historial, consulta sin cambios y límite de eventos:
`godot --headless --path . --script res://tests/history_tests.gd`.

Pruebas de la decisión del descanso, cancelación, copia individual y carga:
`godot --headless --path . --script res://tests/camp_tests.gd`.

Pruebas de Posesión, Etéreo, costes y acceso a recompensas desplazables:
`godot --headless --path . --script res://tests/ghost_defense_tests.gd`.

Pruebas de poderes persistentes, activación una vez por turno y reinicio:
`godot --headless --path . --script res://tests/power_tests.gd`.
