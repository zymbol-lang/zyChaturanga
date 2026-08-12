# चतुरङ्गम् (Chaturanga)

> **Escrito para Zymbol v0.0.9**

El antepasado del ajedrez, para la terminal, escrito íntegramente en Zymbol —en
sánscrito—, con un rival de búsqueda alfa-beta, las reglas históricas y una
interfaz en cinco idiomas y tres escrituras de cifras.

चतुरङ्गम् es el cuarto juego TUI real escrito en Zymbol, después de
[Serpiente](https://github.com/zymbol-lang/zySerpiente),
[Hov veS](https://github.com/zymbol-lang/zyKlingonGalaxy) y
[囲碁](https://github.com/zymbol-lang/zy-GO). Existe para validar una clase de
capacidad distinta de la del motor de go: **identificadores en devanagari** con
conjuntos y visarga, **búsqueda alfa-beta recursiva** pasando el tablero por
parámetros de salida, y **cifras que cambian de escritura con el idioma**.

> **English:** [README.md](README.md) · **संस्कृतम्:** [README_SA.md](README_SA.md)
> · **हिन्दी:** [README_HI.md](README_HI.md)
> · **Especificación técnica:** [DESIGN.md](DESIGN.md)
> · **Hallazgos de lenguaje:** [HALLAZGOS_ES.md](HALLAZGOS_ES.md)

---

## ¿Por qué sánscrito?

El juego es indio. Se describe por primera vez en sánscrito, y su propio nombre
es un compuesto sánscrito: **चतुर्-अङ्ग**, *cuatro miembros* — las cuatro
divisiones de un ejército. Las piezas son esas divisiones:

| Sánscrito | División | Llegó a ser |
|-----------|----------|-------------|
| पत्तिः | infantería | peón |
| अश्वः | caballería | caballo |
| रथः | carros | torre |
| गजः | elefantes | alfil |
| मन्त्री | el consejero | dama |
| राजा | el rey | rey |

Así que el código está escrito en sánscrito. Cada identificador, nombre de módulo
y nombre de fichero usa devanagari, y el vocabulario del código fuente es aquel
con el que el juego fue descrito. Esto además llena un hueco del proyecto Zymbol:
japonés (囲碁), coreano, chino (ZyAudit), klingon (Hov veS), español y griego ya
estaban cubiertos — una escritura índica no.

La **interfaz** está en cinco idiomas: sánscrito (संस्कृतम्), hindi (हिन्दी),
persa (فارسی), inglés y español — el idioma en que nació, el que se juega hoy, el
que lo trajo hacia occidente, y los dos en que este proyecto se documenta.

---

## Cómo jugar

Necesita el [intérprete Zymbol](https://github.com/zymbol-lang/interpreter)
v0.0.9 o posterior:

```bash
zymbol run चतुरङ्गम्.zy          # sánscrito
zymbol run --vm चतुरङ्गम्.zy     # el mismo juego, ~38× más rápido
```

Cuatro puntos de entrada, un solo juego. Solo se diferencian en el idioma que
preseleccionan, y desde la pantalla de configuración se puede cambiar:

| Fichero | Interfaz | Cifras |
|---------|----------|--------|
| `चतुरङ्गम्.zy` | संस्कृतम् | devanagari `०१२३` |
| `चतुरंग.zy` | हिन्दी | devanagari `०१२३` |
| `شطرنج.zy` | فارسی | persa `۰۱۲۳` |
| `chaturanga.zy` | English | latinas `0123` |

> **Sobre `--vm`.** La VM de registros está medida en ~38× el tree-walker con
> esta carga — muy por encima del ~4× que documenta el intérprete. El juego se
> juega bien en los dos; el nivel más alto solo es cómodo en la VM. Ver
> [HALLAZGOS_ES.md](HALLAZGOS_ES.md) HLZ-CHA-004.

### Tamaño de terminal

El juego lee el tamaño real con `>>?` al arrancar y se niega a dibujar un tablero
roto. Cada casilla ocupa exactamente **dos columnas**, así que el bloque del
tablero mide 21 columnas por 10 filas.

| Disposición | Terminal mínima |
|-------------|-----------------|
| Panel al lado del tablero | 49 × 13 |
| Panel debajo del tablero | 23 × 15 |
| Por debajo | se niega, y dice qué le faltaba |

---

## Controles

| Tecla | Acción |
|-------|--------|
| `↑` `↓` `←` `→` | Mover el cursor |
| `↵` | Coger una pieza · jugar |
| `u` | Deshacer tu jugada y la respuesta de la máquina |
| `t` | Cambiar el juego de piezas |
| `?` | Ayuda |
| `q` | Abandonar · salir |

Pulsar `↵` sobre otra pieza tuya mueve la selección allí en vez de fallar, así
que nunca hay que cancelar primero.

> **Sobre las flechas.** `<<|` devuelve los propios glifos de flecha — `'↑'`,
> `'↓'`, `'←'`, `'→'` — no las letras `'U'` `'D'` `'L'` `'R'` que documenta
> GUIDE.md §3b. La guía se equivoca; Serpiente compara con los glifos desde
> v0.0.5.

---

## Pantallas

### El tablero — 80 × 24, en sánscrito

```
    a b c d e f g h     ╭────────────────────────╮
  ८ ♜ ♞ ♝ ♛ ♚   ♞ ♜  ८  │ हस्तः       श्वेतः        │
  ७ ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟  ७  │ चालाः      २           │
  ६       ♝          ६  │ गृहीतानि    ० · ०       │
  ५                  ५  ├────────────────────────┤
  ४                  ४  │ स्तरः       मध्यमः       │
  ३         ♙        ३  │ अन्तिमः     f८–d६       │
  २ ♙ ♙ ♙ ♙   ♙ ♙ ♙  २  │ सामग्री     —           │
  १ ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖  १  ╰────────────────────────╯
    a b c d e f g h
```

La segunda jugada de las negras es el गजः de f8 a d6 —dos casillas en diagonal,
saltando por encima de lo que haya en medio—. Ese es el elefante, y es la señal
más clara de que esto no es ajedrez.

### La misma partida en persa, con las piezas de dibujo

```
    a b c d e f g h     ╭────────────────────────╮
  ۸ 🛞 🐎 🐘 🧙 👑 🐘 🐎 🛞  ۸  │ نوبت       سفید        │
  ۷ 🚶 🚶 🚶 🚶 🚶 🚶 🚶 🚶  ۷  │ حرکت‌ها     ۰           │
  ۶                  ۶  │ گرفته      ۰ · ۰       │
  ۵                  ۵  ├────────────────────────┤
  ۴                  ۴  │ سطح        متوسط       │
  ۳                  ۳  │ آخرین      —           │
  ۲ 🚶 🚶 🚶 🚶 🚶 🚶 🚶 🚶  ۲  │ برتری      —           │
  ۱ 🛞 🐎 🐘 🧙 👑 🐘 🐎 🛞  ۱  ╰────────────────────────╯
    a b c d e f g h
```

Los números de fila son `۸ ۷ ۶`, no `8 7 6`. Nada del código de dibujo lo sabe
— ver [Las cifras también se traducen](#las-cifras-también-se-traducen).

---

## Juegos de piezas

Cuatro, cambiables en partida con `t`. En los cuatro cada casilla mide
exactamente dos columnas, así que la disposición nunca se mueve:

| Juego | Blancas | Negras | El bando lo indica |
|-------|---------|--------|--------------------|
| शतरञ्जम् | ♔ ♕ ♖ ♗ ♘ ♙ | ♚ ♛ ♜ ♝ ♞ ♟ | el glifo — se lee sin color alguno |
| चित्रम् | 👑 🧙 🛞 🐘 🐎 🚶 | los mismos | el fondo de la casilla |
| अक्षरम् | रा म र ग अ प | los mismos | el fondo de la casilla |
| लातिनम् | K Q R B N P | k q r b n p | el glifo |

Dos de los cuatro llevan el bando en el color y no en la forma, y la razón se
dice en vez de esconderse: un emoji no tiene variante clara y oscura, y el
devanagari no tiene mayúsculas. En esos dos el patrón del tablero se aparta para
que el fondo pueda decir de quién es la pieza. `लातिनम्` es el recurso portátil,
para terminales que miden mal los emoji o ligan estrecho los conjuntos.

## Tableros

| Estilo | Qué es |
|--------|--------|
| अष्टापदम् | El tablero histórico: de un solo color, con las dieciséis casillas marcadas del *ashtapada* (columnas a, d, e, h × filas 1, 4, 5, 8) |
| चित्रितम् | Escaqueado claro y oscuro — un invento europeo, siglos posterior a este juego, y el que todo el mundo reconoce |

---

## Reglas implementadas

Son los movimientos del chaturanga histórico, no los del ajedrez moderno. Tres
piezas difieren, y esas tres son toda la diferencia entre los dos juegos.

| Pieza | Se mueve | No |
|-------|----------|-----|
| राजा | una casilla en cualquier dirección | sin enroque — eso es Europa del siglo XV |
| मन्त्री | **una casilla en diagonal** | no es una dama: la pieza más débil tras el peón |
| रथः | cualquier distancia en línea recta | como la torre de siempre |
| अश्वः | el salto del caballo | sin cambios en dos mil años |
| गजः | **salta exactamente dos casillas en diagonal**, por encima de lo que haya | no es un alfil: alcanza 8 casillas de las 64 y nunca sale de ellas |
| पत्तिः | un paso adelante, captura en diagonal | **sin salto doble**, sin al paso, sin elección al coronar |

| Regla | Comportamiento |
|-------|----------------|
| Coronación | Un पत्तिः que llega a la última fila se convierte en मन्त्री — y en nada más |
| Jaque | Una jugada que deja a tu propio rey atacado no es legal |
| Mate — मातः | Derrota |
| **Ahogado — गतिरोधः** | **Derrota para el ahogado**, la regla antigua del shatranj |
| Rey desnudo — निर्वस्त्रः | Reducido al rey solo: derrota, salvo que ambos lo estén, que son tablas |

**Por qué la posición inicial tiene 16 jugadas y el ajedrez 20.** Ocho peones dan
un paso cada uno, los caballos tienen dos jugadas cada uno y los elefantes dos
cada uno; torres, consejero y rey están encerrados. Las cuatro que faltan son los
saltos dobles de peón que este juego no tiene. `परीक्षा/गतिपरीक्षा.zy` lo afirma.

**Por qué el ahogado es victoria aquí.** El consejero y el elefante son débiles y
el final de partida deja el tablero casi vacío. Con la regla moderna, casi toda
partida entre iguales acabaría en tablas. Esta es la decisión que tomó la
tradición del shatranj y es lo que hace afilado el final: el motor te encerrará
tan a gusto como te dará mate, y eso cuenta.

---

## El rival — मतिः

Búsqueda alfa-beta en forma negamax. Esta es la diferencia más profunda con el
motor de go: **el go ofrece trescientas jugadas por posición y buscar es
inútil; el chaturanga ofrece unas veinte y buscar es el instrumento correcto.**
El go premia conocer formas; el chaturanga premia contar.

| Nivel | Profundidad | Tolerancia | Comportamiento |
|-------|-------------|------------|----------------|
| आरम्भकः | 1 | 200 | Ve lo que se puede capturar ahora. Te regalará una pieza. |
| मध्यमः | 2 | 60 | Ve la respuesta. Deja de regalar piezas. |
| निपुणः | 3 | 20 | Ve la contrarrespuesta. Pone trampas sencillas. |

El nivel no es «jugar mal a propósito». Es una **tolerancia**: cuánto por debajo
de la mejor puede puntuar una jugada y aun así ser elegida al azar entre las
supervivientes. Un principiante no es un programa que juega mal; es uno que no
distingue una buena jugada de una casi buena, y 200 puntos es exactamente el
precio de una pieza.

La evaluación es material más tablas de casilla. Los valores son de este juego,
no del ajedrez — y el orden es lo interesante:

```
पत्तिः  100     गजः  150     मन्त्री  200     अश्वः  300     रथः  500
```

El carro vale más que el consejero, y el caballo más que el elefante y el
consejero juntos. En un juego donde la dama es una pieza de un paso y el alfil un
saltador de ocho casillas, la torre es el rey del tablero.

**Estimación honesta de fuerza:** un principiante flojo de club. Captura lo que
cuelgues, no cuelga lo suyo, encuentra un mate o un ahogado en uno, y no ve tres
jugadas de táctica. Ese es el objetivo — el motor existe para demostrar que el
lenguaje puede expresar una búsqueda de verdad, no para ganarte.

Medido: **1 646 nodos** para una jugada de profundidad 3 en la apertura, frente a
**4 448** para el mismo árbol sin podar. Alfa-beta hace su trabajo, y los dos
intérpretes visitan exactamente los mismos nodos.

---

## Las cifras también se traducen

Esto es lo que चतुरङ्गम् añade a la arquitectura de i18n que estableció 囲碁. El
motor de go tiene dos mecanismos — cadenas de interfaz en ejecución y traducción
de identificadores por reexportación. Este tiene un tercero:

**elegir idioma elige escritura de cifras.**

```zymbol
निर्धारणम्(संकेतः) {
    वर्तमानाभाषा = संकेतः
    ?? संकेतः {
        "fa" => { #۰۹# }      // arábigo-índico extendido, U+06F0
        "en" => { #09# }      // latino
        "es" => { #09# }
        _    => { #०९# }      // devanagari, U+0966
    }
    <~ ०
}
```

Ningún código de dibujo sabe qué escritura está activa. La única línea que compone
el nombre de una casilla produce `e४`, `e۴` o `e4`; el contador de jugadas, las
capturas y las etiquetas de fila la siguen todas.
`परीक्षा/भाषापरीक्षा.zy` afirma las tres escrituras.

El persa recibe cifras arábigo-índicas **extendidas** (`۰۹`, U+06F0) y no las
árabes (`٠٩`, U+0660). Son escrituras distintas y usar el juego equivocado es un
error que un lector nota de inmediato.

Los otros dos mecanismos también están:

**Cadenas de interfaz** (`भाषा/`) — 60 claves, cinco idiomas, un despachador que
guarda la elección como estado de módulo, de modo que ninguna función de dibujo
lleva un parámetro de idioma. Las claves son sánscritas con prefijo de dominio
(`खण्ड.गृहीतानि`, nunca `गृहीतानि` a secas), que es lo que hace la completitud
*decidible*: una clave nunca puede ser igual a su propia traducción, así que una
que falte vuelve como sí misma y el gate la ve.

Cada idioma compone además tres frases, porque una tabla no declina:

| | संस्कृतम् | हिन्दी | فارسی | English | Español |
|---|---|---|---|---|---|
| `जयवाक्यम्(1, 1)` | श्वेतः मातेन जयति | सफ़ेद मात से जीता | سفید با مات برد | White wins by checkmate | ganan las blancas por jaque mate |
| `ग्रहणवाक्यम्(3)` | गजः गृहीतः | हाथी पिट गया | فیل گرفته شد | took an elephant | capturó el elefante |

El sánscrito pone la causa en instrumental (मातेन, *por medio de* mate), el hindi
la construye con से, el persa con با, el inglés flexiona el artículo (*an*
elephant) y el español hace los colores femeninos plurales (*las blancas ganan*).
Nada de eso sobrevive a una tabla de consulta.

**Traducción de identificadores** (`api/`) — capas de reexportación puras que
exponen todo el motor con nombres ingleses y españoles, sin lógica y sin coste.
Las constantes se reexportan con `.` y las funciones con `::`:

```zymbol
<# ./api/espanol => es
tablero = es::tablero_nuevo()
es::posicion_inicial(tablero)
jugadas = es::jugadas_legales(tablero, es.BLANCAS)
```

Los nombres de las piezas son los del chaturanga: `es.ELEFANTE`, no `ALFIL`.
Nombrar una pieza por su descendiente sería describir otro juego.

---

## Pruebas

El gate es [ZyQuality](https://github.com/zymbol-lang/zyquality), que ejecuta cada
suite contra su golden en todos los motores que puedan:

```bash
cd ../zyquality && bash project/run.sh --only chaturanga
```

```
── chaturanga
  goldens   6 goldens via `run`: 6 match, 0 stale, 0 unchecked
  engines   7 files: 6 agree, 0 diverge, 1 with too few engines
```

En local, y además barriendo `zymbol check` sobre todas las fuentes:

```bash
bash परीक्षा/सर्वपरीक्षा.sh
```

Las posiciones de prueba se escriben como diagramas para poder comprobarlas a
ojo:

```zymbol
गजबाधा = आ::पठनम्([
    "........",
    "........",
    "........",
    "....P...",     // el elefante salta por encima de esto
    "...B....",
    "........",
    "........",
    "........"
])
निवेदनम्("elephant leaps over a piece", अस्ति(गजबाधा, "d4", "f6"), #1, दोषाः)
```

Las letras son las internacionales —R N B Q K P— por una razón: el devanagari no
tiene mayúsculas, así que un solo carácter no puede distinguir blancas de negras.
Y esas letras descienden de estas mismas piezas. Tomarlas prestadas es una vuelta
a casa, no un préstamo.

---

## Limitaciones

1. **Aún no hay tablas por repetición ni por cincuenta jugadas.** La huella de
   posición existe (`नियमाः::स्थितिसंकेतः`) y el controlador todavía no guarda su
   historial. Una partida puede repetirse indefinidamente.
2. **Motor de fuerza principiante.** Profundidad 3, sin búsqueda de quietud, así
   que entrará en una secuencia de capturas que se resuelva en la cuarta jugada.
3. **El renderizado del devanagari depende de tu terminal y tu fuente.** La
   aritmética de columnas es correcta respecto a `std/term`; una terminal que
   ligue `ङ्ग` más estrecho de lo que suman sus puntos de código se verá corrida
   igualmente. Cambia al juego `लातिनम्`.
4. **El bidireccional es cosa de la terminal.** El idioma persa guarda sus
   cadenas en orden lógico y las mide bien; cómo se dibujan es del emulador.
5. **El nivel alto quiere `--vm`.** Dos segundos por jugada con el tree-walker
   frente a una veinteava parte de segundo con la VM.

---

## Estado

| Fase | Contenido | Estado |
|------|-----------|--------|
| 1 | Tablero, codificación de piezas, jugada como entero | **hecho** |
| 2 | Movimientos históricos, detección de ataque | **hecho** |
| 3 | Legalidad, jaque, mate, ahogado, rey desnudo, coronación | **hecho** |
| 4 | Evaluación y alfa-beta con tres niveles | **hecho** |
| 5 | Cinco idiomas, despachador, tres escrituras de cifras, gate de completitud | **hecho** |
| 6 | Ancho de columna, cuatro juegos de piezas, dos tableros | **hecho** |
| 7 | Controlador, TUI, deshacer, cuatro entradas | **hecho** |
| 8 | Seis suites con goldens, registradas en ZyQuality | **hecho** |
| 9 | api/english y api/espanol | **hecho** |
| 10 | Tablas por repetición y cincuenta jugadas; registro de partidas | pendiente |
| 11 | Arnés motor contra motor, como el 棋戦 de 囲碁 | pendiente |

---

## Hallazgos de lenguaje

Bugs, carencias e ideas encontrados escribiendo esto están en
[HALLAZGOS_ES.md](HALLAZGOS_ES.md). El más afilado: `@ <identificador>` es un
bucle *mientras* en el tree-walker y un bucle *veces* en la VM cuando el
identificador contiene un `Bool` — la VM aborta, `zymbol check` no dice nada, y
ningún fichero del corpus de paridad escribe esa forma.

Los tres hallazgos que registró el esqueleto inicial del proyecto también se
discuten allí: dos no lo eran, y decirlo importa — un registro de hallazgos que
acepta cualquier cosa deja de serlo.

---

## Créditos

Creado por [**OscarEEspinozaB**](https://github.com/OscarEEspinozaB), en
colaboración con **Claude Code**.

Forma parte del proyecto [Zymbol](https://github.com/zymbol-lang), cuyo método
para validar un lenguaje escribiendo programas reales en él se describe en
[LDV.md](https://github.com/zymbol-lang/interpreter/blob/main/LDV.md).
