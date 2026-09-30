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
se conservan entre encuentros. Tras vencer puedes elegir una de tres cartas
o continuar sin ampliar el mazo. El refugio recupera 12 de Salud y el descanso
15, sin superar 50. La ruta se mantiene en memoria; cerrar el juego la reinicia.

Las recompensas son una selección fija por facción de efectos implementados.
Hay ocho efectos nuevos: Trampa para Lobos, Campana de la Iglesia,
Colmillo Venenoso, Lobo Solitario, Drenaje Vital, Colmillo Noble,
Ectoplasma Frío y Cadena Etérea. El catálogo de 40 cartas sigue siendo un
documento de diseño: todavía no están implementadas todas las cartas,
las mejoras, los aliados persistentes ni todas las reglas de Furia/Sed.
El balance de la ruta es provisional.

## Pruebas de regresión

Con Godot accesible en consola:

```powershell
godot --headless --path . --script res://tests/run_tests.gd
```

Comprueba las cuatro facciones, persistencia de Salud y mazo, recompensa única,
rechazo de recompensa, descanso, jefe, derrota, reinicio y duplicados del Espía.
Las victorias de las pruebas de ruta se fuerzan para comprobar transiciones;
esto no constituye una prueba de equilibrio de dificultad.
