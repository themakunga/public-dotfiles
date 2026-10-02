# Sofle RGB EVA-01 — fuentes QMK

Keymap completo: QWERTY US, Ctrl en lugar de Caps Lock, tres capas,
encoders por capa, controles multimedia, RGB Matrix y OLED con Bongo Cat.
Entrega únicamente de código fuente. VIA está desactivado.

## Destino de hardware

- QMK: `sofle/rev1`, nombre usado también para Sofle v2 y RGB estándar.
- Controlador supuesto: Pro Micro ATmega32U4, 5 V / 16 MHz, bootloader Caterina.
- USB conectado a la mitad izquierda (`MASTER_LEFT`).
- Matriz estándar de 58 teclas más dos pulsadores de encoder.
- RGB estándar: 72 LED en total, 36 por mitad, pin D3.
- OLED SSD1306 de 128×32, presentación horizontal.

Las fotos y la identificación aportada se tomaron como referencia del Sofle RGB
estándar. El color púrpura no identifica eléctricamente la PCB. Este código no
es para Sofle Keyhive, Sofle Choc ni Pro Micro RP2040. Contrastar las inscripciones
reales antes de flashear. Si el teclado proviene de un fabricante con firmware
propio, comparar su mapa de pines con `keyboards/sofle/rev1/keyboard.json`.

QMK consultado: `0.34.5`, commit
`b1aea2556040c28d58d611c8aef0082b5780bb6d`.
Referencia oficial: https://github.com/qmk/qmk_firmware/blob/b1aea2556040c28d58d611c8aef0082b5780bb6d/keyboards/sofle/readme.md

## Compilar

Copiar esta carpeta completa, conservando el nombre `nicolas`, dentro de:

```text
qmk_firmware/keyboards/sofle/keymaps/nicolas/
```

Desde un entorno QMK ya instalado:

```sh
qmk compile -kb sofle/rev1 -km nicolas
```

El firmware compilado se utiliza en ambas mitades. No se incluyen archivos
`.hex`, `.bin`, `.uf2` ni archivos de configuración VIA.

## Capas y encoders

Las etiquetas del diseño L2 y L3 corresponden a QMK `MO(1)` y `MO(2)`.
Mantenerlas activa la capa; soltarlas regresa a la base. No hay tap-hold.
Configurar distribución US en el sistema operativo.

| Capa | Giro izquierdo antihorario / horario | Pulsación izquierda | Giro derecho antihorario / horario | Pulsación derecha |
|---|---|---|---|---|
| Base, QMK 0 | Mouse izquierda / derecha | Clic izquierdo | Mouse arriba / abajo | Clic derecho |
| Segunda, QMK 1 | Volumen bajar / subir | Mute/unmute | Page Up / Page Down | Home |
| Tercera, QMK 2 | Efecto RGB anterior / siguiente | LED encendido/apagado | Brillo bajar / subir | LED encendido/apagado |

Los pulsadores envían press/release normales: mantener el clic permite
arrastrar mientras se gira el otro encoder. Ambos toggles LED afectan a la
iluminación sincronizada del teclado, no solamente a su mitad.

Se conservan Shift, Ctrl, Super/GUI y Alt/Option. La fila numérica ofrece sus
símbolos US con Shift o L2; L3 contiene F1–F10 sobre los números, F11 en Esc y
F12 en Backspace. Las teclas de multimedia y LED del dibujo siguen disponibles.

## Pantallas

- Izquierda: nombre del keymap y recordatorio de capas.
- Derecha: icono y número de capa, SUP/CTRL/OPT/SHFT resaltados, Bongo Cat al
  centro y las tres últimas pulsaciones a la derecha.
- La lista LAST indica pulsaciones recientes, no todas las teclas mantenidas.
- El gato alterna las patas al pulsar y vuelve al reposo tras 220 ms.
- Los datos se sincronizan mediante RPC de QMK; el gato no depende de WPM.

El Bongo Cat viene de `dancarroll/qmk-bongo`; ver `bongo/UPSTREAM.md` y su
licencia. Sus cuatro fotogramas se conservan sin cambios. El renderizador
sustituye únicamente los márgenes de fondo/mesa por texto.

La pantalla emplea una versión reducida de la fuente QMK 6×8 (ASCII imprimible),
no Hack Nerd Font. La tipografía y colores de las keycaps de las imágenes no
se aplican a un OLED monocromo. La orientación real debe comprobarse en el
montaje: para invertir horizontalmente ambos OLED, usar `OLED_ROTATION_180`
en `oled_init_user`. Un montaje vertical requiere recomponer el contenido;
no basta girar esta composición de 128×32.

## Ajustes útiles

En `config.h`:

- `MOUSEKEY_MOVE_DELTA`: paso inicial del mouse; valor 4 para empezar.
- `ENCODER_MAP_KEY_DELAY`: duración de eventos del encoder, 10 ms.
- `RGB_MATRIX_MAXIMUM_BRIGHTNESS`: límite de brillo, 100/255.
- `RGB_MATRIX_DEFAULT_VAL`: brillo inicial, 64/255.
- `RGB_MATRIX_DEFAULT_HUE`: tono inicial violeta, 191/255.
- `OLED_TIMEOUT`: espera de apagado del OLED, 60000 ms.

Efectos compilados: color sólido, respiración, ciclo de color y ciclo lateral.
Los valores iniciales RGB se usan al inicializar EEPROM; una configuración
previa puede prevalecer. Si el giro de un encoder resulta invertido, cambiar
el orden de sus dos argumentos `ENCODER_CCW_CW` en `keymap.c`.

Para ahorrar memoria se desactivan VIA, NKRO, consola, comandos, Magic,
Grave Escape, Space Cadet, tap-hold y oneshot. El layout no utiliza esas
funciones. Se conservan modificadores normales, capas momentáneas, mouse,
multimedia, RGB y pantallas. LTO está habilitado.

## Verificación realizada

```sh
python3 check_oled.py
```

La prueba comprueba las asignaciones de teclas/encoders y compila el módulo
OLED con stubs locales: nombres, historial, modificadores, capas, RPC,
reintentos y preservación de los píxeles del gato. Requiere Python 3 y un
compilador C local (`cc`). No depende de paquetes Python externos.

La variante anterior con VIA llegó a compilar antes de cambiar el alcance.
La entrega final sin VIA no se ha vuelto a compilar como firmware, siguiendo
la solicitud de entregar sólo fuentes. Las pruebas locales no verifican los
pines, el sentido físico de los encoders, el brillo real, el bus OLED ni el
espacio final disponible: eso se comprueba al compilar y probar en el teclado.
