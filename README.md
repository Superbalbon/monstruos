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

El prototipo de Godot permite elegir una de las cuatro facciones y completar una expedición con combates, recompensas, descanso, jefe y puntos de guardado. Las 40 cartas base del prototipo están implementadas y disponibles en el catálogo: 10 por facción. Las 40 tienen una mejora disponible en el descanso. Ampliar al resto del catálogo nominal de 200 queda pendiente; el balance es provisional.

## Ejecutar el prototipo

1. Instala Godot 4.3 o posterior.
2. Importa esta carpeta seleccionando `project.godot`.
3. Ejecuta el proyecto con **F6** o **F5**.

No requiere complementos ni recursos externos.

## Controles

- **Guía de reglas**, en el menú y la ruta, o **Reglas**, durante el combate,
  explica turnos, estados, las cuatro facciones y guardado. Elige un tema en
  el desplegable y desplaza el texto si es necesario. **Volver** o **Esc** cierra
  la guía sin modificar la partida. Las reglas describen el prototipo actual,
  incluidas las mecánicas aún sin uso como Marcado.
- Selecciona una carta para jugarla.
- En la selección de estirpe, **Ver mazo inicial** muestra sus diez cartas,
  incluidas las copias repetidas, un consejo de juego y el resumen de costes.
  No inicia una expedición ni modifica la partida guardada. **Esc** o
  **Volver a las estirpes** cierra la consulta; **Jugar** sigue siendo la acción
  que inicia la partida (con confirmación si hay un guardado pendiente).
- Pasa el cursor sobre una carta para leer su efecto completo. La ayuda distingue las mejoras disponibles de las que siguen pendientes.
- Si una carta de la mano está desactivada, su ayuda explica todas las condiciones
  pendientes: Ímpetu, Ectoplasma, ataque previo, intención o estado incompatible.
  Los costes mostrados incluyen los descuentos de Manada y Alfa.
- **Terminar turno** indica cuando no quedan cartas jugables. Es informativo:
  nunca termina el turno automáticamente ni impide terminarlo antes.
- Pulsa **Terminar turno** para resolver la intención enemiga.
- El Murciélago Espía abre una selección de las siguientes cartas del mazo.

## Ruta del prototipo

### Moneda, mercader y reliquias

Cada victoria concede moneda temática: **Reales** para Humanos, **Colmillos de
caza** para Hombres Lobo, **Sellos de sangre** para Vampiros y **Ecos** para
Fantasmas. Tienen el mismo valor: aldea 20, Acechador 30, estación 25 y Custodio
40. El refugio, la ermita y el descanso no dan moneda. El botín se guarda antes
de elegir carta; cargar una recompensa pendiente no vuelve a concederlo.

El **Mercader** vende en el cruce posterior a la aldea y en el descanso antes
del jefe. Comprar no consume la elección de ruta ni la del descanso. Cada
estirpe tiene tres reliquias únicas; sus efectos son pasivos, no cartas:

| Estirpe | Especial — 35 | Defensa — 30 | Recuperación — 20 |
|---|---|---|---|
| Humanos | Cruz del Alba: 1 Consagración inicial | Anillo del Guardián | Medalla del Socorro |
| Hombres Lobo | Tótem de la Sierra: 2 Furia inicial | Amuleto de Hueso | Colmillo del Retorno |
| Vampiros | Sortija de Montenegro: +1 Ímpetu en el primer turno | Camafeo del Velo | Cáliz del Regreso |
| Fantasmas | Reloj Detenido: 2 Ectoplasma inicial | Cadena del Umbral | Espejo del Recuerdo |

Todas las defensivas dan 4 Bloqueo solo en el primer turno de cada combate;
las de recuperación curan 3 Salud después de vencer, sin superar 50. Los
efectos iniciales se reaplican en cada nuevo combate, no en cada turno. No hay
duplicados. **Reliquias** permite consultar la colección y sus efectos desde
la ruta o el combate; fuera del mercader no permite comprar.

Las compras son definitivas durante la expedición y se guardan inmediatamente.
Si falla la escritura se revierte la compra y se muestra un aviso. Moneda y
reliquias se reinician al comenzar otra expedición; no son progreso permanente.
El guardado con economía usa la versión 3: conserva mejoras de cartas, y carga
guardados antiguos sin moneda ni reliquias, sin botín retroactivo. No cargues
estos nuevos guardados en versiones antiguas del juego. Precios y balance
son provisionales; ningún enemigo exige comprar una reliquia para acceder.

### Encuentros y decisiones

**Ver rival**, junto al combate disponible, permite consultar su Salud y la
secuencia de acciones base antes de entrar. La secuencia se repite; el daño
indicado es por golpe, antes de estados y Bloqueo. Durante la lucha, la intención
actual refleja los modificadores. **Esc** o **Volver a la ruta** cierra la
consulta sin iniciar el encuentro, gastar Salud ni cambiar el guardado.

Después de la aldea, **Investigar la ermita** abre el primer encuentro narrativo,
«La ermita de los nombres», con una perspectiva distinta para cada estirpe.
Puedes entregar 8 Salud (necesitas al menos 9) para obtener Milicia Organizada,
Alfa Dominante, Conversión o Lamento Nocturno según tu facción; o escuchar y
recuperar 12 Salud sin carta. Ambas decisiones sustituyen al combate del Acechador
y avanzan a la estación, guardando Salud y mazo. La carta se muestra antes de
elegir. **Esc** vuelve al cruce sin decidir; cerrar el juego antes de elegir
conserva el punto de control del cruce. No se puede repetir el evento.
El equilibrio entre estas alternativas y combatir es todavía provisional.

La selección de estirpe inicia una expedición: aldea, sendero o refugio,
estación, descanso y jefe de Santa Vigilia. La Salud y las cartas adquiridas
se conservan entre encuentros. Tras vencer puedes elegir una de siete cartas
por facción (accesibles con la barra horizontal)
o continuar sin ampliar el mazo. El refugio recupera 12 de Salud y el descanso
15, sin superar 50. El guardado automático permite continuar desde el menú.

En recompensas, **Ver mazo · Consultar antes de elegir** abre tu mazo y su
resumen de costes sin aceptar ninguna carta. Ciérralo con Esc para seguir
eligiendo. Bajo cada recompensa se muestra cuántas copias tienes, incluyendo
las mejoradas, y cuántas de ellas están mejoradas. Elegir añade una copia base;
consultar no cambia el guardado ni la recompensa pendiente.

En el descanso anterior al Custodio puedes elegir entre recuperar 15 Salud,
mejorar una carta o **retirar una carta sin curarte**. Para retirar, selecciona la
copia que quieras retirar de esta expedición, o cancela con Esc. Retirar avanza
al monasterio y se guarda automáticamente; no puedes retirar y curarte en el
mismo descanso. El mazo puede quedar en 9 cartas. Los guardados anteriores
siguen funcionando en esta versión; no uses una versión antigua para cargar
una expedición cuyo mazo haya quedado reducido a 9 cartas.

Al pulsar una carta para retirarla se abre una confirmación con su nombre,
efecto, coste y tamaño final del mazo. **Conservar carta** (opción enfocada por
defecto) o **Esc** vuelve al selector sin gastar el descanso ni cambiar el
guardado. Solo **Retirar y continuar** elimina la copia y avanza sin curarte.

Las recompensas son una selección fija por facción de efectos implementados.
Hay ocho efectos nuevos: Trampa para Lobos, Campana de la Iglesia,
Colmillo Venenoso, Lobo Solitario, Drenaje Vital, Colmillo Noble,
Ectoplasma Frío y Cadena Etérea. Las 40 cartas base y los aliados persistentes
ya están implementados, junto con las 40 mejoras descritas en la sección siguiente.
Descontrol y las penalizaciones de Sed
ya funcionan; los estados del jugador se muestran junto a su recurso.
El balance de la ruta es provisional.

Tras vencer al Custodio aparece **Leer desenlace**, junto al resumen del combate.
Cada protagonista tiene un epílogo propio para cerrar esta ruta del prototipo.
**Volver al resultado** o **Esc** permite consultar de nuevo el resumen y el
historial. Puedes releerlo mientras permanezcas en el resultado final; no se
guarda una galería de finales ni se conceden desbloqueos permanentes. Los
finales de la campaña completa descritos en el documento de mundo siguen siendo
diseño futuro.

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

**Manada Feroz** es la sexta recompensa de Hombres Lobo: inflige 4 de daño tres
veces. Cuesta 2 Ímpetu, o 1 si ya jugaste una carta con etiqueta Manada ese turno
(por ejemplo, Aullido u otra Manada Feroz). La mano muestra el coste real sin
alterar los datos base; el descuento se reinicia cada turno. Fuerza, Débil y
Vulnerable se calculan por golpe, el Bloqueo se consume entre golpes y el ataque
se detiene si el enemigo muere. No se añade automáticamente al mazo inicial.

**Sed Insaciable** es la sexta recompensa de Vampiros. Cuesta 1 Ímpetu y queda
como poder activo: la primera vez que aumente realmente la Sed en cada turno,
roba 1 carta. Combina con Colmillo Noble e Hipnosis Mental. Con Sed 10 no se
activa ni consume la oportunidad; reducir Sed y volver a aumentarla sí puede
activarlo. Si no quedan cartas para robar, la activación se consume igualmente.
No roba al jugarse ni por aumentos anteriores; no admite dos copias activas.

## Mejorar cartas en el descanso

Antes del Custodio puedes **curarte**, **retirar una carta** o **mejorar una carta**.
Son alternativas excluyentes: mejorar avanza al monasterio sin recuperar Salud.
La selección muestra el resultado y su ayuda compara el efecto actual con el
mejorado. Elige una copia concreta; Esc cancela sin consumir el descanso.

Las ocho mejoras básicas:

| Facción | Ataque | Defensa |
|---|---|---|
| Humanos | Balas de Plata: 6 → 8 daño, conserva el +3 contra Vulnerable | Aldeano Valiente: 5 → 8 Bloqueo |
| Hombres Lobo | Garra Salvaje: 6 → 9 daño | Piel Gruesa: 5 → 8 Bloqueo |
| Vampiros | Mordisco Vampírico: 6 → 9 daño | Velo de Sombras: 5 → 8 Bloqueo |
| Fantasmas | Toque Gélido: 6 → 9 daño | Velo Fantasmal: 5 → 8 Bloqueo |

Otras 17 mejoras implementadas (conservan los efectos y costes no mencionados):

- Humanos: Cruz Sagrada da 6 Bloqueo; Trampa para Lobos causa 5 daño;
  Campana aplica 2 Débil; Antorcha causa 10 daño.
- Hombres Lobo: Aullido genera 3 Furia; Mordida Rabiosa causa 7 daño y 3 Sangrado;
  Manada Feroz hace tres golpes de 5; Colmillo Venenoso causa 6 daño;
  Lobo Solitario causa 11 daño (7 con aliados).
- Vampiros: Drenaje Vital causa 13 daño y cura 4; Colmillo Noble causa 11 daño;
  Hipnosis aplica 3 Débil; Sangre Pura reduce la Sed en 3.
- Fantasmas: Susurro genera 2 Ectoplasma; Ectoplasma Frío causa 7 daño;
  Aparición causa 10 daño; Cadena Etérea aplica 3 Débil.

Los descuentos de Manada, el agotamiento, los límites de recursos y los efectos
condicionales se conservan. Eco repite los valores mejorados y los redondea con
las mismas reglas que los de las cartas base.

Las 15 mejoras especiales completan el catálogo:

- Milicia Organizada y Alfa Dominante cuestan 1; Barricada cuesta 2;
  Lamento Nocturno cuesta 1.
- Cazador Experto empieza en la mano inicial, ocupando uno de sus cinco huecos;
  no se activa automáticamente. Héroe Local otorga 12 Bloqueo al jugarse.
- Luna Llena genera 2 Furia al entrar (puede provocar Descontrol) y mantiene
  su efecto recurrente. Pista de Presa deja de agotarse.
- Niebla Eterna otorga 5 Bloqueo en su primera activación de cada turno.
  Sed Insaciable añade 1 Ímpetu solo en su primera activación del combate;
  conserva el robo una vez por turno y exige que la Sed aumente realmente.
- Murciélago Espía mira tres cartas, roba una y devuelve las restantes arriba
  en su orden original. Si quedan menos, ofrece las disponibles.
- Conversión rebaja en 2 el coste de la copia (mínimo 0); sigue siendo temporal.
- Posesión Leve consume 1 Ectoplasma; Paso a Través consume 2.
  Eco del Pasado repite al 75 %, redondeando abajo con mínimo 1 por efecto positivo.

Las pilas de Poderes y Aliados muestran la versión que se jugó, incluido su «+».
Los efectos activos se reinician entre combates, pero las mejoras del mazo no.

El nombre lleva **+** y la mejora se conserva al robar, descartar y cargar la
expedición. Eco repite también el daño mejorado. Se reutiliza la ilustración base;
no necesitas producir otra imagen. Las otras copias del mazo no cambian.

Los guardados anteriores siguen cargándose. Una expedición con una mejora usa
el formato 2: no la abras con una versión antigua del juego. El prototipo solo
permite una mejora por expedición, en el descanso final, y nunca dos sobre la misma copia.

## Catálogo base completo

Las últimas incorporaciones completan las 40 cartas; se obtienen como recompensas,
no se añaden automáticamente a los mazos iniciales:

- **Milicia Organizada:** permanece como aliado. Al terminar tu turno, cada
  Milicia genera 3 Bloqueo por aliado en juego, incluida ella misma.
- **Héroe Local:** permanece como aliado y otorga 8 Bloqueo al entrar. La primera
  vez cada turno que un ataque enemigo te quite Salud, causa 4 daño por Héroe.
  Un contraataque letal detiene los golpes restantes del enemigo.
- **Alfa Dominante:** poder que reduce en 1 el coste de la primera carta Manada
  de cada turno, mínimo 0. Su activación cuenta como Manada ese turno.
- **Conversión:** copia la última acción realmente ejecutada por un enemigo no
  vampiro, no la próxima intención. Las acciones enemigas tienen coste base 2;
  la copia cuesta 1 y reproduce daño, golpes, Bloqueo, Débil y Etéreo indicados.
  Conversión se agota; la copia puede descartarse y robarse durante ese combate,
  pero nunca se añade al mazo de la expedición ni al guardado.
- **Lamento Nocturno:** aplica 2 Débil y genera 2 Ectoplasma, hasta el máximo de 8.

Murciélago Espía también permanece como aliado, aunque su selección de cartas
solo ocurre al jugarlo. Lobo Solitario inflige 4 en vez de 8 si tienes aliados.
Los aliados admiten varias copias y se reinician en cada combate.

**Eco del Pasado** repite el último ataque jugado este turno, incluidos sus
efectos secundarios y su número de golpes, al 50 % de potencia. Los valores
positivos se redondean hacia abajo con mínimo 1; los costes de recurso no se
reducen. Las condiciones se vuelven a evaluar después de pagar los 2 Ectoplasma.
No paga de nuevo el Ímpetu del ataque. **Antorcha Ardiente** elimina Etéreo antes
de golpear, por lo que su daño no queda anulado por ese estado.

## Intenciones enemigas

Cada encuentro tiene su propio ciclo, que se repite en este orden:

| Enemigo | Ciclo de acciones |
|---|---|
| Desvelado | Ataque 7 → ataque 10 → Bloqueo 7 → ataque 13 |
| Acechador | Dos golpes de 4 → Bloqueo 4 → ataque 12 |
| Guardagujas | Ataque 8 y Bloqueo 4 → Bloqueo 10 → ataque 14 |
| Custodio | Ataque 9 → Bloqueo 8, 1 Débil y Etéreo → dos golpes de 6 → ataque 16 |

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

- Al ganar o perder aparece un **resumen del combate** con turnos, cartas,
  Ímpetu gastado, daño directo, Sangrado, Salud perdida, Bloqueo aprovechado,
  daño evitado por Etéreo y curación efectiva. No cuenta exceso de daño o
  curación; separa Sed/Descontrol de los ataques enemigos. También se añade al
  historial para copiarlo. Solo describe ese combate y no se guarda entre sesiones.
- **Catálogo de cartas**, en el menú principal y en la ruta, muestra todas las
  cartas implementadas, sin duplicados y filtradas por facción. Cada carta indica
  si pertenece al mazo inicial, si se obtiene como recompensa o ambas cosas.
  El selector **Cartas base / Cartas mejoradas (+)** permite consultar las 40
  mejoras; su tooltip compara el efecto y coste con la versión base. El buscador
  filtra por nombre, tipo, rareza, etiqueta o efecto, sin distinguir mayúsculas
  ni tildes. Los filtros se combinan y el contador muestra las coincidencias.
  Las versiones mejoradas son previsualizaciones: se consiguen en el descanso.
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
  expedición pide confirmar antes de sustituir una partida pendiente. El diálogo
  muestra facción, etapa, Salud, tamaño del mazo y si queda una recompensa por
  elegir. **Conservar partida** o **Esc** cancela sin escribir el guardado.
  También se confirma antes de sobrescribir un guardado dañado o incompatible.
  Sin guardado o con una expedición finalizada, el inicio es directo. Esc en la
  selección de estirpe vuelve al menú.
- `Ver mazo` muestra todas las copias de la expedición desde la ruta y el combate.
  Incluye un resumen por tipo, número de copias mejoradas, distribución de costes
  (0, 1, 2 y 3 o más) y coste medio. Cuenta los costes impresos de las versiones
  actuales, sin descuentos temporales de combate. También aparece al mejorar o
  retirar en el descanso: describe el mazo actual, no las mejoras previsualizadas.
  No cambia el orden de robo ni aparece en los visores de pilas individuales.
- En combate, pulsa **Robo**, **Descarte**, **Agotadas**, **Poderes** o **Aliados** para consultar
  las cartas de esa pila, incluidas las copias repetidas. Robo se ordena por nombre
  y no revela el orden real ni altera el barajado. Poderes muestra los poderes
  activos y Aliados las copias en juego. Los visores se cierran con **Esc** o su botón.
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
Confirmación de sustitución y cancelación sin cambios:
`godot --headless --path . --script res://tests/new_run_tests.gd`.
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

Pruebas de las 40 previsualizaciones mejoradas y búsqueda combinada:
`godot --headless --path . --script res://tests/catalog_upgrade_tests.gd`.

Pruebas de patrones, intenciones y ataques múltiples:
`godot --headless --path . --script res://tests/enemy_tests.gd`.

Pruebas de consulta de pilas sin alterar el combate ni el orden de robo:
`godot --headless --path . --script res://tests/pile_tests.gd`.

Pruebas del resumen de composición y costes del mazo:
`godot --headless --path . --script res://tests/deck_summary_tests.gd`.

Pruebas de consulta de los cuatro mazos iniciales sin modificar la expedición:
`godot --headless --path . --script res://tests/starter_preview_tests.gd`.

Pruebas de los cuatro epílogos, acceso tras victoria final y consulta sin cambios:
`godot --headless --path . --script res://tests/epilogue_tests.gd`.

Pruebas de información previa de rivales y conservación de la ruta:
`godot --headless --path . --script res://tests/briefing_tests.gd`.

Pruebas de moneda, doce reliquias, efectos pasivos, compras y migración de guardados:
`godot --headless --path . --script res://tests/economy_tests.gd`.

Pruebas de consulta del mazo y copias disponibles en recompensas:
`godot --headless --path . --script res://tests/reward_consultation_tests.gd`.

Pruebas del historial, consulta sin cambios y límite de eventos:
`godot --headless --path . --script res://tests/history_tests.gd`.

Pruebas de la decisión del descanso, cancelación, copia individual y carga:
`godot --headless --path . --script res://tests/camp_tests.gd`.

Pruebas de Posesión, Etéreo, costes y acceso a recompensas desplazables:
`godot --headless --path . --script res://tests/ghost_defense_tests.gd`.

Pruebas de poderes persistentes, activación una vez por turno y reinicio:
`godot --headless --path . --script res://tests/power_tests.gd`.

Pruebas de Manada Feroz, coste dinámico visible y ataques múltiples del jugador:
`godot --headless --path . --script res://tests/pack_tests.gd`.

Pruebas de Sed Insaciable, límite de Sed, robo y barajado:
`godot --headless --path . --script res://tests/thirst_tests.gd`.

Pruebas de acceso, pago, destino y guardado de las 40 cartas, aliados, Alfa,
Conversión, Etéreo enemigo, Lamento y efectos secundarios de Eco:
`godot --headless --path . --script res://tests/completion_tests.gd`.

Pruebas de motivos de bloqueo, costes dinámicos, ayudas y aviso de fin de turno:
`godot --headless --path . --script res://tests/playability_tests.gd`.

Pruebas de la guía, navegación por temas, foco, cierre y conservación del combate:
`godot --headless --path . --script res://tests/guide_tests.gd`.

Pruebas del resumen, daño efectivo, Bloqueo, Etéreo, curación, costes y reinicio:
`godot --headless --path . --script res://tests/summary_tests.gd`.

Pruebas del encuentro narrativo, cuatro facciones, costes, cancelación y guardado:
`godot --headless --path . --script res://tests/event_tests.gd`.

Pruebas de las ocho mejoras, copia individual, cancelación, efectos, Eco y guardado:
`godot --headless --path . --script res://tests/upgrade_tests.gd`.

Pruebas de las otras 17 mejoras, estados, recursos, límites, descuentos y guardado:
`godot --headless --path . --script res://tests/advanced_upgrade_tests.gd`.

Pruebas de las 15 mejoras especiales y acceso/guardado de las 40 mejoras:
`godot --headless --path . --script res://tests/special_upgrade_tests.gd`.
