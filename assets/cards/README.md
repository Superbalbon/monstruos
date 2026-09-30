# Ilustraciones de cartas

Godot busca automáticamente una ilustración cuyo nombre coincida con el identificador de la carta.

## Estructura

```text
assets/cards/
├── humanos/H001.webp
├── hombres_lobo/L001.webp
├── vampiros/V001.webp
└── fantasmas/F001.webp
```

También se aceptan temporalmente `.png`, `.jpg` y `.jpeg`. Para la versión del juego se recomienda WebP optimizado.

## Preparación

- Proporción vertical 3:4.
- Resolución maestra recomendada: 1728 × 2304 px.
- No incorporar nombre, coste, marco ni reglas en la imagen.
- Mantener el sujeto principal dentro del 80 % central para permitir recortes.
- Conservar los originales de alta resolución fuera del repositorio.

El marco, el coste, el nombre, el tipo, la rareza y el texto los genera Godot.

