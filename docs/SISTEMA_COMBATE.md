# Sistema de combate

## Reglas base del prototipo

- El jugador comienza la expedición con **50 de Salud** máxima y conserva la Salud entre encuentros.
- Al inicio de cada turno obtiene **3 de Ímpetu** y roba hasta tener **5 cartas**.
- Las cartas jugadas van al descarte, salvo **Agotar**, poderes y aliados. Estos últimos permanecen activos hasta acabar el combate.
- Cuando el mazo se vacía, el descarte se baraja y forma un mazo nuevo.
- El **Bloqueo** absorbe daño y desaparece al comenzar el turno del jugador, salvo con Barricada activa.
- Cada enemigo muestra su siguiente intención: ataque, defensa, estado o acción especial.
- Las 40 cartas base y sus 40 mejoras están implementadas. En el descanso final puedes mejorar una copia de tu mazo en vez de curarte o retirarla. La copia añade «+» a su nombre; algunas mejoras reducen su coste. Solo se realiza una mejora por expedición en el prototipo. La vista previa indica el resultado exacto antes de elegir.

Estos valores son un punto de partida para pruebas, no cifras definitivas.

## Estados comunes

| Estado | Regla inicial |
|---|---|
| Vulnerable | Recibe un 50 % más de daño de ataques durante sus cargas. Cada turno pierde una carga. |
| Débil | Inflige un 25 % menos de daño de ataques durante sus cargas. Cada turno pierde una carga. |
| Sangrado | Al terminar su turno recibe daño igual a las cargas y después pierde una carga. |
| Consagración | Cada carga añade 3 al siguiente golpe de ataque y se consume. |
| Etéreo | Evita el siguiente golpe recibido sin consumir Bloqueo y después se elimina; no evita todos los golpes de un ataque múltiple. Antorcha lo elimina antes de golpear. |
| Marcado | Activa efectos de Caza. Solo puede haber un objetivo marcado por el jugador. |

Los porcentajes se redondean hacia abajo, con un mínimo de 1 cuando el ataque original causaría daño.

## Recursos de facción

### Humanos — Preparación

Los Humanos no tienen un medidor adicional. Sus cartas generan **Consagración**, aliados y Bloqueo persistente. Son la facción de referencia para medir el balance de las demás.

### Hombres Lobo — Furia

- Empiezan cada combate con 0 y pueden acumular hasta 10.
- Obtienen 1 de Furia al perder Salud por un ataque enemigo y mediante cartas.
- Algunas cartas consumen Furia para mejorar su efecto.
- Al llegar a 10, entran en **Descontrol**: ganan 2 de Fuerza ese turno, pierden 3 de Salud y la Furia vuelve a 5.
- La Fuerza añade 2 al daño de cada ataque y caduca al terminar el turno del jugador. Si Descontrol ocurre durante el ataque enemigo, beneficia al siguiente turno del jugador. El coste de Salud ignora Bloqueo y puede causar derrota.

### Vampiros — Sed

- Empiezan con 0 y pueden acumular hasta 10.
- Las técnicas vampíricas más potentes aumentan la Sed.
- El Drenaje y ciertas cartas de sangre reducen la Sed.
- Al terminar el turno con 8 o más, pierden 2 de Salud. Con 10, además obtienen 1 de Débil.

### Fantasmas — Ectoplasma

- Empiezan con 0 y pueden acumular hasta 8.
- No desaparece entre turnos durante el combate.
- Se obtiene mediante cartas de espíritu y se consume para activar Ecos, Posesiones y efectos Etéreos.

## Tipos de carta

- **Ataque:** causa daño directamente.
- **Habilidad:** defensa, control, robo o manipulación de recursos.
- **Poder:** efecto pasivo para el resto del combate; se retira del mazo tras jugarlo.
- **Aliado:** permanece en juego; el momento de su efecto depende de la carta. Milicia actúa al terminar tu turno, Héroe responde una vez por turno a pérdida de Salud por ataque enemigo y Espía solo selecciona cartas al entrar. Se admiten copias y cuentan para Milicia y Lobo Solitario.

## Mazos iniciales

Cada personaje empieza con 10 cartas, usando repeticiones para que el mazo sea comprensible:

- **Humanos:** 4 Balas de Plata, 4 Aldeano Valiente, 1 Cruz Sagrada y 1 Antorcha Ardiente.
- **Hombres Lobo:** 4 Garra Salvaje, 4 Piel Gruesa, 1 Aullido y 1 Pista de Presa.
- **Vampiros:** 4 Mordisco Vampírico, 4 Velo de Sombras, 1 Sangre Pura y 1 Murciélago Espía.
- **Fantasmas:** 3 Toque Gélido, 1 Ectoplasma Frío, 4 Velo Fantasmal, 1 Susurro Espectral y 1 Eco del Pasado. Ectoplasma Frío permite generar recurso repetidamente y activar Eco desde el primer combate.

## Referencia de balance

Una carta común de coste 1 debería aportar aproximadamente uno de estos valores:

- 6 de daño.
- 5 de Bloqueo.
- 4 de daño y un beneficio menor.
- 3 de Bloqueo y un beneficio menor.

Las sinergias pueden superar esa referencia si requieren preparación, consumen un recurso limitado o introducen un riesgo real.
