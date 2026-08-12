# चतुरङ्गम् — Technical Design

Implementation specification for [चतुरङ्गम्](README.md). Written against Zymbol
v0.0.9, verified in both the tree-walker and the register VM.

This document exists because most of the interesting decisions here are forced
by two things: the language, and the fact that this is **not chess**. Where a
decision was measured rather than reasoned, the measurement is given.

---

## 1. Language constraints that drive the design

| Constraint | Source | Consequence here |
|------------|--------|------------------|
| Functions called by name see **only their parameters** | GUIDE §9 | The board is never global. It is a parameter on every engine function. |
| Top-level `:=` constants **do** pierce function scope | GUIDE §4 | Piece codes, colours and weights are constants, not parameters. |
| A module constant must be a **bare literal** | HLZ-001 (囲碁) | Every status code is positive; `:= -१` does not parse. |
| Mutation across a call requires `<~` output params | GUIDE §9 | `कृति` takes `स्थितिः<~` and hands the captured piece back through `गृहीतम्<~`. |
| Module bodies allow only literal initializers | GUIDE §17 | String tables are `??` matches inside functions, not tables built at load. |
| Module private state persists per file path | GUIDE §17 | The active locale lives there; no render function carries a language. |
| **Arrays are homogeneous** | measured | Returning `(Int, String)` is impossible — `_चयनम्` returns the Int and the message leaves through `<~`. |
| String interpolation takes `{identifier}` only | HLZ-007 (囲碁) | A number is bound to a name before it can be interpolated. |
| `@ i:a..b` **infers its direction** | GUIDE, *Reverse Range* | `@ i:२..n` with `n = १` counts *down* and indexes off the end. Guarded explicitly. HLZ-CHA-002. |
| `@ <bare identifier>` means different things per engine | HLZ-CHA-001 | Never written. Loops are `@ { } … @!` or `@ <call>` or `@ <comparison>`. |
| The numeral mode is **process-global**, not per file | HLZ-CHA-003 | One call sets the digit script for the whole program — which is the feature, not the bug. |
| `>>\|` errors when stdout is not a TTY | GUIDE §3b | The game refuses to run redirected; the suites drive the modules directly. |

---

## 2. Board representation

```
स्थितिः : flat array, length 64, 1-indexed
value   : 0 = रिक्तम्     1..6 = श्वेतः      7..12 = कृष्णः
kind    : 1 पत्तिः  2 अश्वः  3 गजः  4 रथः  5 मन्त्री  6 राजा
```

Index arithmetic, with rank 1 (white's home) at the head of the array:

```zymbol
पदम्(पङ्क्तिः, स्तम्भः) { <~ (पङ्क्तिः - १) * ८ + स्तम्भः }
```

The display layer flips rows so rank 1 is drawn at the bottom; the engine never
knows.

### Why the colour is packed, not signed

An earlier draft stored black as the negative of white — the shape the project's
first skeleton used. Every piece test then had to normalise the sign before it
could ask what kind of piece it had, and `स्थितिः[क] <> ०` stopped being a
sufficient "is there something here". Packing as `1..6` / `7..12` keeps the whole
array non-negative, makes `०` mean empty everywhere, and reduces colour and kind
to two comparisons:

```zymbol
अङ्गवर्णः(अङ्गम्) { ? अङ्गम् == ० { <~ ० }  ? अङ्गम् <= ६ { <~ १ }  <~ २ }
अङ्गप्रकारः(अङ्गम्) { ? अङ्गम् == ० { <~ ० }  ? अङ्गम् <= ६ { <~ अङ्गम् }  <~ अङ्गम् - ६ }
```

Nothing outside `अष्टापदम्.zy` knows the packing.

### A move is one integer

```zymbol
चालरचना(आदिः, अन्तः) { <~ आदिः * १०० + अन्तः }
```

Not a two-element array. Move generation is the innermost loop of the search: an
array per move costs two allocations and an integer costs none. The decimal
packing is also legible in a debugger — `१२३४` is `१२ → ३४`.

**There is no promotion field**, and that is a property of the game rather than a
shortcut. A पत्तिः reaching the far rank becomes a मन्त्री and nothing else, so
the promotion is implied by the move. This is one of the few places where the old
game is simpler than the new one.

---

## 3. मूल/चालाः.zy — how the pieces move

Three pieces differ from chess, and those three are the whole difference:

| Piece | Rule | Consequence |
|-------|------|-------------|
| मन्त्री | one step diagonally | 4 moves from the centre, where a queen has 28 |
| गजः | jumps exactly two diagonally, **over** whatever is between | reaches 8 of 64 squares and never leaves them |
| पत्तिः | one step, always; captures one diagonally | no double step, no en passant, no choice at promotion |

The elephant's orbit is worth stating precisely because it drives the evaluation:
from a1 it reaches exactly eight squares for the whole game. Two elephants on
different orbits never meet, and one elephant guards an eighth of the board.
`परीक्षा/गतिपरीक्षा.zy` computes the closure and asserts the 8.

### Pseudo-legal, and why the split is not tidiness

Moves generated here obey the piece's own rule and say nothing about check. The
legality filter lives in `नियमाः.zy` — and the split is **required**, not
stylistic: the check test is itself written in terms of move generation, so a
generator that asked about check would recurse forever.

### Attack detection walks outward from the target

`आक्रान्तम्(स्थितिः, लक्ष्यम्, वर्णः)` does not generate every enemy move and
search the list. That reads better and is the wrong shape — the check test sits
in the innermost loop and is asked once per candidate move. Instead the walk runs
outward from the target square: *whatever could take me, I could reach by that
same piece's move.*

The symmetry holds for every piece except the foot soldier, whose capture is not
its move, so that one case is written the other way round. This is the single
most-called function in the program and the first place to look if a turn feels
slow.

---

## 4. मूल/नियमाः.zy — legality and endings

```zymbol
कृति(स्थितिः<~, चालः, गृहीतम्<~)              plays a move; promotion happens here
प्रत्यावर्तनम्(स्थितिः<~, चालः, अङ्गम्, गृहीतम्)  the exact inverse
संकटे(स्थितिः, वर्णः)                          is this colour's king attacked
वैधः(स्थितिः<~, चालः, वर्णः)                    one move, played and taken back
वैधचालाः(स्थितिः<~, वर्णः)                      every legal move
परिणामः(स्थितिः<~, वर्णः)                      प्रवृत्तम् / मातः / गतिरोधः / निर्वस्त्रः / समता
```

### Make and unmake, never copy

The search visits thousands of positions. A 64-element copy at each is the
expensive path, so every move is played and taken back on the one board.

Undo needs exactly two facts: the piece that **left** the origin square (before
any promotion) and the piece that was taken. The first is the caller's business,
because the caller is who saw it there — which is also why the controller's
history keeps three parallel arrays rather than two.

`परीक्षा/नियमपरीक्षा.zy` asserts the inverse property directly, over all sixteen
opening moves, comparing all 64 squares each time. If it ever stopped holding,
the engine would corrupt the board a few thousand nodes deep and nothing else
here would notice.

### `वैधचालाः` hoists the king's square

The naive form calls `वैधः` per move, and `वैधः` calls `संकटे`, which calls
`राजपदम्` — a 64-square scan per candidate. `वैधचालाः` finds the king once and
tracks the one case where it changes:

```zymbol
निरीक्ष्यम् = राजस्थानम्
? आदिः == राजस्थानम् { निरीक्ष्यम् = अ::अन्तपदम्(चालः) }
```

Measured effect: 5.48 s → 5.17 s on perft(3) in the tree-walker. Real but small —
the cost is in `आक्रान्तम्`, not in finding the king. Recorded because the
opposite was assumed before it was measured.

### Ending precedence — mate before bareness

```zymbol
परिणामः(स्थितिः<~, वर्णः) {
    चालाः = वैधचालाः(स्थितिः, वर्णः)
    ? (चालाः$#) == ० {
        ? संकटे(स्थितिः, वर्णः) { <~ १ }      // मातः
        <~ २                                   // गतिरोधः
    }
    // …then bareness
}
```

The order matters. A king that is both alone and mated lost to the mate, not to
the poverty. In the other order every endgame mate would be reported as a bare
king — true, and misleading. The first version had it the other way and the tests
caught it.

### Stalemate is a loss

This is a rules decision, not an implementation one, and it is the sharpest in
the project. In modern chess stalemate is a draw. Here it is a **loss for the
stalemated player**, which is the shatranj tradition.

The reason is the endgame. The counsellor moves one square diagonally and the
elephant reaches eight squares; a bare-ish endgame has very little force in it.
Under the modern rule almost every game between even opponents would end drawn,
and the ending would be a formality rather than a fight.

It touches the search in exactly one place — the leaf that returns
`० - १०००० - गभीरता` for both mate and stalemate — which is the evidence that the
rule was written where it belongs.

A visible consequence, and a nice one: the engine is genuinely indifferent
between mating you and sealing you in. `परीक्षा/मतिपरीक्षा.zy` asks "does it
win", not "does it mate", because asking the second one failed and the engine was
right.

---

## 5. मूल/आकलनम्.zy — evaluation

```
पत्तिः  १००     गजः  १५०     मन्त्री  २००     अश्वः  ३००     रथः  ५००
```

Not chess values, because these are not chess pieces. The chariot outweighs the
counsellor and the horse outweighs the elephant and counsellor together. In a
game where the queen is a one-step piece and the bishop is an eight-square
jumper, the rook is the board's king — and most games are decided by it.

The king has no value: it is never captured, and its loss is counted as mate.

### The square tables are one flat array

Six 64-entry tables in one array of 384, indexed `(प्रकारः - १) × ६४ + पदम्`,
built **once** and carried into every leaf:

```zymbol
मूल्याङ्कनम्(स्थितिः, वर्णः, सारणी)
```

The first version had each piece call a function that built its own table afresh
— 32 pieces, roughly two thousand array allocations per leaf. Passing the table
in is uglier than a self-contained `मूल्याङ्कनम्(स्थितिः, वर्णः)` and it is the
difference between a search that runs and one that does not.

Black reads the same table with the rank mirrored, which is what makes the
evaluation **symmetric**: `मूल्याङ्कनम्(p, श्वेतः) + मूल्याङ्कनम्(p, कृष्णः) == ०`
for every position. `परीक्षा/मतिपरीक्षा.zy` asserts it, because an asymmetric
evaluation lets the search gain material simply by changing whose turn it is.

**Mobility is not counted.** Counting it means generating every move, which
doubles the cost of a leaf. In a game this slow, material and placement already
say who is winning.

---

## 6. मूल/मतिः.zy — the search

Negamax with alpha-beta: one search serving both colours, since "best for me" is
exactly "worst for you".

### Why search, where the go engine could not

This is the deepest contrast with 囲碁, and it is about the game rather than the
language:

| | 囲碁 | चतुरङ्गम् |
|---|---|---|
| Moves per position | ~300 | ~20 |
| What a move changes | little, locally | material, immediately |
| What the engine does | layered heuristics | alpha-beta search |
| What it rewards | knowing shapes | counting |

The go engine measured MCTS at roughly 6 000× the available budget and chose
deterministic heuristics. Here a depth-3 search is 1 646 nodes and finishes in
0.05 s on the VM. Search is affordable *because the branching factor is fifteen
times smaller*, and it is worth having because in this game a move that wins a
chariot is simply better.

### Move ordering earns its place

Captures first, ordered by victim value minus attacker value, then the quiet
moves. Alpha-beta lives on ordering: seeing the best move first is what makes the
cutoff happen early. Without it, depth 3 costs about four times more.

The sort is a selection sort. The list is short — usually under ten captures —
and a real sort would cost more to write than to run.

This is also where HLZ-CHA-002 bit: `@ क:२..संख्या` over the remaining candidates
counted *downwards* when one candidate was left, and indexed off the end. The
guard is explicit and commented.

### Levels are a tolerance, not a handicap

| Level | Depth | Tolerance |
|-------|-------|-----------|
| आरम्भकः | 1 | 200 |
| मध्यमः | 2 | 60 |
| निपुणः | 3 | 20 |

`चालचयनम्` scores every root move, gathers everything within the tolerance of the
best, and picks one of those at random.

Not "take the best and add noise" — that does not make the play varied, only
occasionally stupid. This says *below this margin I cannot tell the difference*,
and then chooses freely among the moves it cannot tell apart. Which is what
playing like a beginner actually is. 200 is the price of a piece, which is why
the beginner will hand you one.

### Depth is tested before moves are generated

```zymbol
? गभीरता <= ० { <~ आ::मूल्याङ्कनम्(स्थितिः, वर्णः, सारणी) }
चालाः = नि::वैधचालाः(स्थितिः, वर्णः)
```

Leaves are most of the tree, and generating moves at a node that only needs a
number is double the work. The price is that mate is not seen *at* a leaf — every
search engine accepts that; the mate is found one ply earlier.

### Measured

| | tree-walker | VM |
|---|---|---|
| perft(3), 4 448 nodes | 5.17 s | 0.141 s |
| depth-3 opening move, 1 646 nodes | ~2 s | ~0.05 s |
| `परीक्षा/मतिपरीक्षा.zy` | 40.7 s | 0.93 s |

The ~38× factor is far above the ~4× the interpreter documents; see
HALLAZGOS_ES.md HLZ-CHA-004. Both engines visit **exactly the same nodes** —
16 / 272 / 1 646 for levels 1/2/3 from the opening — which is asserted, because a
divergence there would not show in the chosen move (the choice is random at the
end).

---

## 7. दर्शनम्/ — the two-column rule

Every cell occupies exactly two terminal columns, in every piece set. The go
engine established why: if a cell's width depends on its contents, the row label
jitters the moment a piece lands in the last file.

Where 囲碁 settled this per theme — a rule for stones and another for ASCII —
here it is one function:

```zymbol
कोष्ठपूरणम्(चिह्नम्, पूरकम्) {
    व = विस्तारः(चिह्नम्)
    ? व >= २ { <~ चिह्नम् }
    ? व == १ { <~ "{चिह्नम्}{पूरकम्}" }
    <~ "{पूरकम्}{पूरकम्}"
}
```

The measurement answers it, so a piece set nobody has written yet comes out right
anyway. This matters more here than in go because Devanagari widths are not
uniform:

| Glyph | Graphemes | Columns |
|-------|-----------|---------|
| `र` (chariot) | 1 | 1 |
| `रा` (king) | 2 | 2 |
| `कृ` | 2 | 1 |
| `🐘` | 1 | 2 |
| `♔` | 1 | 1 |

`परीक्षा/चित्रपरीक्षा.zy` asserts every one of those, then asserts every board
row is 16 columns in all four sets with pieces in the first and last files.

### Layout arithmetic

```
gutter        3 columns   (" ८ ")
board        16 columns   (8 cells × 2)
right label   2 columns
block        21 × 10
panel        26 columns
```

| Condition | Layout |
|-----------|--------|
| width ≥ 49 and height ≥ 13 | panel beside the board |
| width ≥ 23 and height ≥ 15 | panel collapsed to one line below |
| otherwise | refuse, and say what was needed |

The framed screens (setup, help, end) size themselves to `min(46, width - 4)` and
**truncate before padding**. That was not defensive programming, it was a bug:
`दक्षिणपूरणम्` returns an overlong string untouched — truncation is not its job —
and Spanish `‹ Símbolos de ajedrez ›` is 23 columns in an 18-column slot. Without
the truncation one translation broke the whole frame.

### Colour carries the side in two of the four sets

`शतरञ्जम्` (♔ vs ♚) and `लातिनम्` (K vs k) put the side in the glyph, so they
read on a terminal with no colour at all. `चित्रम्` and `अक्षरम्` cannot: an emoji
has no light and dark variant, and Devanagari has no letter case. In those two
the cell background says whose piece it is and the board pattern steps aside.

That is a cost, and it is stated rather than hidden — `रूपम्::पक्षवर्णेन(रूपम्)`
is the function the drawing layer asks before choosing a background.

---

## 8. भाषा/ — three mechanisms, not two

### Runtime strings

60 keys, five locales, one dispatcher holding the choice as module state. Keys
are Sanskrit with a **domain prefix** (`खण्ड.गृहीतानि`, never plain `गृहीतानि`),
which is what keeps completeness decidable: a key can never equal its own
translation, so a missing one falls through to itself and the gate sees it.
`परीक्षा/भाषापरीक्षा.zy` walks the catalogue against all five, Sanskrit included.

### Composed sentences

A static table cannot decline. Each locale implements three functions beyond the
lookup:

| Function | What varies |
|----------|-------------|
| `अङ्गनाम(प्रकारः)` | the six piece names |
| `जयवाक्यम्(वर्णः, कारणम्)` | Sanskrit instrumental (मातेन), Hindi से, Persian با, English preposition, Spanish feminine plural |
| `ग्रहणवाक्यम्(प्रकारः)` | English needs *an* elephant against *a* horse |

### Numerals — the mechanism this project adds

`निर्धारणम्(संकेतः)` sets the locale **and** the digit script:

```zymbol
?? संकेतः {
    "fa" => { #۰۹# }      // Extended Arabic-Indic, U+06F0 — not U+0660
    "en" => { #09# }
    "es" => { #09# }
    _    => { #०९# }      // Devanagari, U+0966
}
```

The mode is process-global (HLZ-CHA-003), so one call changes every number the
program will print — interpolation, juxtaposition, positioned output, numbers
inside arrays. No drawing code knows which script is active:

```zymbol
पदनाम(स्थानम्) {
    अक्षरम् = रू::स्तम्भनाम(अ::स्तम्भाङ्कः(स्थानम्))
    पङ्क्तिः = अ::पङ्क्त्यङ्कः(स्थानम्)
    <~ "{अक्षरम्}{पङ्क्तिः}"          // e४ · e۴ · e4
}
```

**File letters stay Latin a–h** across every locale, deliberately: move notation
is shared internationally, and a game record that reads differently per language
is two records. The digits follow the locale because they are read aloud, not
exchanged.

Two hazards the technique carries, both documented in the guide as intended
behaviour and neither obvious when used this way:

1. The mode reaches `io::write` and `<\ … \>`. A program writing data files with
   it active creates `dato४२.txt`. Anything that names a file must return to
   ASCII first. This is why the game keeps no records yet.
2. `json::encode` always emits ASCII, so serialized data is safe.

---

## 9. api/ — identifier-level translation

Pure re-export layers, no logic, no runtime cost — the three-layer pattern from
[I18N.md](../interpreter/I18N.md) over a working engine. Constants re-export with
`.`, functions with `::`, and they read as declared: `en.BLACK`, `en::play(…)`.

The piece names are chaturanga's: `ELEPHANT` and not `BISHOP`, `CHARIOT` and not
`ROOK`, `COUNSELLOR` and not `QUEEN`. Naming a piece for its descendant would
describe the wrong game — the elephant jumps two squares and reaches eight of
them, which no bishop does.

One thing is deliberately not translated: `कारणसूत्रम्` returns an i18n *key*, and
a key is not a word. Translating it would break the lookup it exists for.
`परीक्षा/अनुप्रयोगपरीक्षा.zy` asserts that too.

---

## 10. Test strategy

`>>|` refuses to run without a TTY, so the interface cannot be tested by piping.
The split:

- **Engine modules** are tested by ordinary scripts with recorded goldens.
  Positions are text diagrams so a case can be checked by eye.
- **The search** is tested for properties, never for a chosen move: it never
  proposes an illegal move, it takes a piece left hanging, it converts a forced
  win in one, it leaves the board untouched, and both engines visit the same
  nodes.
- **Rendering** is tested through `पङ्क्तिपाठः`, which returns colourless text —
  so the column arithmetic is asserted down a pipe, without a terminal.
- **The interface itself** is driven through a pseudo-terminal
  (`zyquality/tui/ptydrive.py`), which is the only way to exercise `<<|`.

Three tests failed while being written, and every one of them was the test's
mistake rather than the engine's. They are commented in place, because a test
that was wrong once is the most useful comment a suite can carry:

1. A "checkmate" diagram where black had only its king — the bare-king rule fired
   first, correctly.
2. A "mate in one" where the mating chariot was blocked by its own king. Played
   by hand it worked, because `कृति` does not check legality; the engine only ever
   sees legal moves. The test said *the engine cannot see the win* when the truth
   was *there was no win there*.
3. A midgame move count written as `28` from a guess rather than a derivation.
   The engine said 26 and the engine was right.

---

## 11. What was measured

| Question | Answer |
|----------|--------|
| Do Devanagari identifiers with visarga and conjuncts work? | Yes — lexer, VM, `check` and LSP |
| Does a module name with mixed scripts work (`.भाषा_فارسی`)? | Yes, clean |
| Is alpha-beta affordable in the tree-walker? | Depth 2 comfortably; depth 3 at ~2 s a move |
| How much faster is the VM here? | ~38×, against ~4× documented |
| Do the two engines agree? | Six suites, byte-identical output |
| Does `std/term` measure Devanagari correctly? | Yes for code points; a terminal's *font* may still ligate narrower |
| Can the numeral mode be switched by locale at runtime? | Yes, and it is process-global |
