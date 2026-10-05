# Ilustraciones de cartas

Las 40 cartas del prototipo tienen ilustración, incluidas sus mejoras.
Las copias se nombran con identificador y nombre sin tildes, por ejemplo:
`assets/cards/humanos/H001_balas_de_plata.png`.

`src/card_art.gd` asocia cada identificador a su archivo. No renombrar las
copias sin actualizar ese registro. Sigue siendo compatible con archivos
nombrados solo por ID (`H001.webp`, `.png`, `.jpg`, `.jpeg`) como alternativa.

Los originales de `assets/art_originals/` se conservan intactos. Sus subcarpetas
no se incluyen en Git y `.gdignore` evita importarlos o exportarlos por duplicado.
Las copias de `assets/cards/` sí deben acompañar al código al sincronizar.
Mantén una copia de seguridad separada de los originales.

Los PNG se copian sin recomprimir, redimensionar ni recortar (unos 97 MB).
Todas las imágenes son 3:4; 38 miden 1086 × 1448 y dos 864 × 1152.
El marco, nombre, coste y reglas los dibuja Godot. La ilustración se muestra
completa y centrada, conservando su proporción.
En la mano, el área de ilustración mide 180 píxeles de alto. El coste actual
aparece en la esquina superior izquierda; el daño o Bloqueo base (incluidas
las mejoras), en la derecha. Las cartas sin esos valores muestran «EFECTO».
Debajo aparecen el nombre y las reglas; los textos largos se consultan con VER.
El texto inferior omite frases iniciales de daño o Bloqueo simple cuando la
cifra ya está en el indicador. Conserva condiciones, ataques múltiples y
efectos compuestos; la ayuda y VER mantienen siempre la descripción completa.
El botón **VER** o el clic derecho abre una ventana de consulta con la imagen
ampliada y las reglas completas. Cerrar o Esc no modifica la partida.

`tools/install_card_art.ps1` comprueba que exista exactamente un PNG por ID,
crea las copias y verifica sus hashes. No sobrescribe destinos distintos.
Para sustituir una ilustración existente, revisar primero ambas versiones.

Pruebas: `godot --headless --path . --script res://tests/art_tests.gd`.
