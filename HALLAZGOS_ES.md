# चतुरङ्गम् — Hallazgos de lenguaje

Bugs, carencias e ideas encontrados escribiendo चतुरङ्गम् en Zymbol v0.0.9,
siguiendo el proceso LDV de [`interpreter/LDV.md`](../interpreter/LDV.md) y la
convención de Serpiente, Hov veS y 囲碁.

Este proyecto valida una clase de capacidad distinta a la del motor de go:
**identificadores en devanagari con conjuntos y visarga**, **cifras en tres
escrituras cambiadas en ejecución**, y **recursión profunda con parámetros de
salida** — que es lo que exige una búsqueda alfa-beta.

| ID | Tipo | Descripción | Estado |
|----|------|-------------|--------|
| HLZ-CHA-001 | Bug | `@ <identificador Bool>` es un bucle *mientras* en el tree-walker y un bucle *veces* en la VM, que aborta | Abierto |
| HLZ-CHA-002 | Carencia | `@ i:2..n` con `n < 2` cuenta hacia atrás en vez de no iterar; no hay forma de rango vacío | Abierto |
| HLZ-CHA-003 | Doc | GUIDE.md dice que el modo numeral persiste «en el mismo fichero»; en realidad es global al proceso | Abierto |
| HLZ-CHA-004 | Medición | La VM resulta ser ~38× más rápida que el tree-walker en esta carga, no ~4× | Informado |
| IDEA-CHA-001 | Idea | El modo numeral condicionado por locale funciona y no está documentado como técnica de i18n | Propuesta |

---

## Hallazgos descartados

El esqueleto inicial de este proyecto, escrito por otro modelo, registraba tres
hallazgos. Dos no lo eran, y decirlo importa: un registro de hallazgos que
acepta cualquier cosa deja de ser un registro.

**BUG-CHA-001 — «`zymbol check` exige `_खेल` donde el fichero se llama `खेल`».**
No es un bug. El fichero estaba en la raíz y declaraba `# .खेल`; el punto inicial
es la convención de *subcarpeta* (`# .carpeta_fichero` → `carpeta/fichero.zy`),
y para una raíz el nombre derivado es `<padre>_<base>` con padre vacío, o sea
`_खेल`. Un módulo de raíz se declara sin punto. 囲碁 hace exactamente eso:
`# 対局` en la raíz, `# .核_盤` dentro de `核/`. Quitado el punto, `zymbol check`
pasa limpio. Ver [`modules.rs:394`](../interpreter/crates/zymbol-semantic/src/modules.rs).

**IDEA-CHA-001 (la original) — «validar un renderizador consciente del ancho de
glifo».** No es un hallazgo del lenguaje. Desde v0.0.8 `std/term::width` responde
la pregunta desde las tablas de unicode-width, y 囲碁 ya tiene el patrón: una capa
fina localizada encima (`表示/文字.zy`). Aquí es `दर्शनम्/अक्षरम्.zy`. Es trabajo
de diseño, no una carencia que reportar.

El tercero sí era real, y resultó ser más grande de lo que decía.

---

## HLZ-CHA-001 — `@ <identificador>` diverge entre motores según el tipo

**Reproducción**

```zymbol
v = #1
c = 0
@ v {
    c++
    ? c >= 3 { v = #0 }
}
>> "c=" c ¶
```

**Observado**

```
$ zymbol run     l.zy   →  c=3
$ zymbol run --vm l.zy   →  Runtime error: cannot compare values with operator 'Ge': Int and Bool
$ zymbol check    l.zy   →  No errors or warnings
```

**Análisis.** GUIDE.md §Loops documenta tres formas que comparten sintaxis: el
bucle infinito `@ { }`, el bucle de *veces* `@ N { }` («cuando el especificador
es un literal entero positivo») y el bucle *mientras* `@ cond { }`. Con una
expresión de comparación (`@ n <= 3`) los dos motores coinciden. Con una variable
`Int` los dos la tratan como *veces* — lo que ya se aparta de la letra de la guía,
que dice *literal*, pero al menos coinciden. Con una variable `Bool`:

| Forma | tree-walker | VM | `check` |
|-------|-------------|-----|---------|
| `@ n <= 3` | mientras | mientras | ok |
| `@ k` con `k` Int | veces | veces | ok |
| `@ v` con `v` Bool | **mientras** | **veces → aborta** | ok |

O sea: el tree-walker decide por el tipo en ejecución y la VM decide por la forma
sintáctica. El analizador no ve nada. Es una divergencia real que el gate de
paridad no cubre porque ningún fichero del corpus escribe `@ <Bool>`.

**Cuál es el correcto** es una decisión de lenguaje, no de este proyecto. Las dos
salidas defendibles: que `@ <Bool>` sea *mientras* en ambos (el tree-walker tiene
razón y la VM tiene un bug), o que sea un error semántico en ambos (`check`
tiene un hueco). Lo que no puede quedarse es que dependa del motor.

**En este proyecto** no aparece: el bucle del juego usa `@ { }` con `@!`, y los
deslizamientos del रथ usan `@ <llamada a función>`, que sí coincide en ambos
motores (comprobado).

---

## HLZ-CHA-002 — un rango ascendente se invierte solo cuando la lista tiene un elemento

**Reproducción**

```zymbol
lista = [42]
n = lista$#
@ i:2..n { >> lista[i] ¶ }    // → array index out of bounds: index 2 for array of length 1
```

**Análisis.** Los rangos de Zymbol infieren su dirección, y eso está documentado
(GUIDE.md, *Reverse Range with Step*: `@ i:10..1:3` cuenta hacia atrás). La
trampa es que la intención habitual «recorre el resto de la lista» se escribe
`@ i:2..n`, y cuando `n` vale 1 eso no es un rango vacío sino `[2, 1]` — un
recorrido hacia atrás que empieza fuera del array.

No hay forma de escribir un rango vacío. `2..1` significa algo, y significa lo
contrario de lo que se quería.

Costó un fallo real: la ordenación de jugadas por selección en
[`मूल/मतिः.zy`](मूल/मतिः.zy) recorría los candidatos con `@ क:२..संख्या` y
reventaba en cuanto quedaba una sola captura por ordenar. El arreglo es una
guarda explícita `? संख्या >= २ { … }`, que es correcta y es ruido.

**Propuesta.** Que `a..b` con `b < a` sea un rango vacío cuando la dirección no
se declara con paso explícito, y que el recorrido descendente se pida con
`a..b:paso` — que es la forma que la guía ya documenta para ese caso. Alternativa
menos invasiva: un aviso del analizador cuando los dos extremos de un rango no
son literales.

---

## HLZ-CHA-003 — el alcance del modo numeral no es el que documenta la guía

GUIDE.md dice del cambio de escritura de cifras:

> The token is **purely a runtime directive** — it emits no output and leaves no
> variable. One mode-switch persists until the next one **in the same file**.

Lo segundo no es lo que ocurre. El modo es **global al proceso**: activado dentro
de una función de un módulo, afecta a la salida de todos los demás módulos y del
programa principal.

```zymbol
// nm/setter.zy
# .nm_setter {
    #> { activar }
    activar(cod) { ? cod == "sa" { #०९# }  <~ 0 }
}
// principal.zy
s::activar("sa")
p::mostrar(42)        // → ४२   (otro fichero)
>> "aquí: " 42 ¶      // → ४२
```

Ambos motores coinciden, así que no es una divergencia: es la documentación la
que va por detrás del comportamiento. Y el comportamiento real es el útil — es
justo lo que permite IDEA-CHA-001.

La frase de la guía probablemente describe la persistencia *léxica* (dentro de un
fichero, el modo sigue vigente hasta el siguiente cambio), que es verdad pero se
lee como si fuera el alcance.

---

## HLZ-CHA-004 — la VM es ~38× más rápida aquí, no ~4×

Medido en la máquina que escribió esto, con `परीक्षा/गतिपरीक्षा.zy`:

| Carga | tree-walker | VM | factor |
|-------|-------------|-----|--------|
| perft(3) desde la posición inicial (4 448 nodos) | 5,17 s | 0,141 s | **37×** |
| `परीक्षा/मतिपरीक्षा.zy` completa | 40,7 s | 0,93 s | **44×** |
| 200 000 iteraciones (llamada + índice + aritmética) | 0,43 s | 0,043 s | **10×** |

`ARCHITECTURE.md` dice «~4× más rápida». 囲碁 ya había informado de 8–14× en su
carga de trabajo. Aquí la distancia es mayor todavía, y la forma del programa
explica por qué: la búsqueda es recursión con parámetros de salida y acceso a
array en el bucle más interno, que es donde el tree-walker paga por cada marco.

No es un bug — es que el número publicado se quedó pequeño y sigue citándose.

**Consecuencia de diseño.** El nivel `उच्चः` (profundidad 3) cuesta ~2 s por
jugada en el tree-walker y ~0,05 s en la VM. El juego se juega en los dos, y la
recomendación de `--vm` para el nivel alto está medida, no supuesta.

---

## IDEA-CHA-001 — el modo numeral como capa de i18n

囲碁 tiene dos mecanismos de i18n: cadenas de interfaz en ejecución y traducción
de identificadores por reexportación. Este proyecto encontró un tercero, y no
está documentado como tal en [`I18N.md`](../interpreter/I18N.md) ni en
[`USERAPPI18N.md`](../interpreter/USERAPPI18N.md):

**elegir idioma puede elegir escritura de cifras.**

```zymbol
निर्धारणम्(संकेतः) {
    वर्तमानाभाषा = संकेतः
    ?? संकेतः {
        "fa" => { #۰۹# }      // arábigo-índico extendido
        "en" => { #09# }      // latino
        "es" => { #09# }
        _    => { #०९# }      // devanagari
    }
    <~ ०
}
```

Nada del código de dibujo sabe qué escritura está activa. La misma línea que
compone el nombre de una casilla produce `e४`, `e۴` o `e4`, y el panel entero
cambia de cifras con el idioma. Está verificado en
[`परीक्षा/भाषापरीक्षा.zy`](परीक्षा/भाषापरीक्षा.zy) y en
[`परीक्षा/चित्रपरीक्षा.zy`](परीक्षा/चित्रपरीक्षा.zy).

Dos advertencias que la técnica arrastra, ambas documentadas en la guía como
comportamiento intencionado y ninguna obvia al usarla así:

1. El modo alcanza a `io::write` y a `<\ … \>`. Un programa que escriba ficheros
   de datos con el modo activo creará `dato४२.txt`. Un registro de partidas debe
   volver a ASCII antes de nombrar ficheros.
2. `json::encode` sí emite siempre ASCII, así que los datos serializados quedan
   a salvo.

**Propuesta.** Documentar el patrón en `USERAPPI18N.md` como tercer mecanismo,
junto con las dos advertencias — que es donde alguien que construya una
aplicación multilingüe lo va a buscar.

---

## Lo que no falló

Riesgos declarados antes de empezar, y lo que dio la medición:

| Riesgo | Medido |
|--------|--------|
| Identificadores en devanagari con visarga (`अश्वः`), anusvara y conjuntos (`मन्त्री`, `अष्टापदम्`) | Funcionan en lexer, VM, `check` y LSP |
| Nombre de módulo con escrituras mezcladas (`.भाषा_فارسی`) | Funciona; `check` limpio |
| Profundidad de recursión de alfa-beta con parámetros de salida | 1 646 nodos a profundidad 3 sin problema; el tablero vuelve intacto |
| `कृति`/`प्रत्यावर्तनम्` como inversas exactas a través de miles de nodos | Verificado por aserción, no supuesto |
| Coincidencia tree-walker / VM | 6 suites, salida idéntica byte a byte en ambos motores |
| Ancho de columna con conjuntos devanagari (`रा` = 2 columnas, `र` = 1) | `std/term` acierta; el invariante de dos columnas se sostiene en los cuatro juegos de piezas |

Y un aviso honesto sobre lo último: el ancho *declarado* por Unicode y el ancho
*renderizado* por una fuente concreta no son lo mismo para devanagari. La
aritmética de este programa es correcta respecto a `std/term`; si una terminal
liga `ङ्ग` más estrecho de lo que sus puntos de código suman, la línea se verá
corrida aunque el cálculo esté bien. Por eso el juego trae el juego de piezas
`लातिनम्`, igual que 囲碁 trae el tema `字`.
