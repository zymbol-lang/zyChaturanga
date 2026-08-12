# चतुरङ्गम् (Chaturanga)

> **Targets Zymbol v0.0.9**

The ancestor of chess, for the terminal, written entirely in Zymbol — in
Sanskrit — with an alpha-beta opponent, the historical rules, and an interface
in five languages and three numeral scripts.

चतुरङ्गम् is the fourth real TUI game written in Zymbol, after
[Serpiente](https://github.com/zymbol-lang/zySerpiente),
[Hov veS](https://github.com/zymbol-lang/zyKlingonGalaxy) and
[囲碁](https://github.com/zymbol-lang/zy-GO). It exists to validate a different
class of capability from the go engine: **Devanagari identifiers** with
conjuncts and visarga, **recursive alpha-beta search** threading a board through
output parameters, and **numerals that change script with the language**.

> **Sanskrit:** [README_SA.md](README_SA.md) · **हिन्दी:** [README_HI.md](README_HI.md)
> · **Español:** [README_ES.md](README_ES.md)
> · **Technical spec:** [DESIGN.md](DESIGN.md)
> · **Language findings:** [HALLAZGOS_ES.md](HALLAZGOS_ES.md)

---

## Why Sanskrit?

The game is Indian. It is first described in Sanskrit, and its own name is a
Sanskrit compound: **चतुर्-अङ्ग**, *four limbs* — the four divisions of an army.
The pieces are those divisions:

| Sanskrit | Division | Became |
|----------|----------|--------|
| पत्तिः | infantry | pawn |
| अश्वः | cavalry | knight |
| रथः | chariotry | rook |
| गजः | elephantry | bishop |
| मन्त्री | the counsellor | queen |
| राजा | the king | king |

So the code is written in Sanskrit. Every identifier, module name and file name
uses Devanagari, and the vocabulary in the source is the vocabulary the game was
described with. This also fills a gap in the Zymbol project: Japanese (囲碁),
Korean, Chinese (ZyAudit), Klingon (Hov veS), Spanish and Greek were covered —
an Indic script was not.

The **interface** is available in five languages: Sanskrit (संस्कृतम्), Hindi
(हिन्दी), Persian (فارسی), English and Spanish — the language it was born in,
the language it is played in today, the language it travelled west through, and
the two this project documents itself in.

---

## How to play

Requires the [Zymbol interpreter](https://github.com/zymbol-lang/interpreter)
v0.0.9 or later:

```bash
git clone https://github.com/zymbol-lang/zyChaturanga
cd zyChaturanga
zymbol run चतुरङ्गम्.zy          # Sanskrit
zymbol run --vm चतुरङ्गम्.zy     # the same game, ~38× faster
```

Four entry points, one game. They differ only in the language they preselect,
and any of them can change it from the setup screen:

| File | Interface | Numerals |
|------|-----------|----------|
| `चतुरङ्गम्.zy` | संस्कृतम् | देवनागरी `०१२३` |
| `चतुरंग.zy` | हिन्दी | देवनागरी `०१२३` |
| `شطرنج.zy` | فارسی | Persian `۰۱۲۳` |
| `chaturanga.zy` | English | Latin `0123` |

> **On `--vm`.** The register VM is measured at ~38× the tree-walker on this
> workload — far above the ~4× the interpreter documents. The game plays well on
> both; the top difficulty is comfortable only on the VM. See
> [HALLAZGOS_ES.md](HALLAZGOS_ES.md) HLZ-CHA-004.

### Terminal size

The game reads the real terminal size with `>>?` at startup and refuses to draw
a broken board. Every cell is exactly **two columns** wide, so the board block is
21 columns by 10 rows.

| Layout | Minimum terminal |
|--------|------------------|
| Panel beside the board | 49 × 13 |
| Panel below the board | 23 × 15 |
| Below that | refuses, and says what it needed |

---

## Controls

| Key | Action | संस्कृतम् |
|-----|--------|-----------|
| `↑` `↓` `←` `→` | Move the cursor | सूचकस्य गतिः |
| `↵` | Pick up a piece · play the move | अङ्गचयनम् · चालः |
| `u` | Take back your move and the machine's reply | प्रत्यावर्तनम् |
| `t` | Cycle the piece set | रूपपरिवर्तनम् |
| `?` | Help | साहाय्यम् |
| `q` | Resign · quit | त्यागः |

Pressing `↵` on another of your own pieces moves the selection there instead of
failing, so you never have to cancel first.

> **On the arrow keys.** `<<|` returns the arrow glyphs themselves — `'↑'`,
> `'↓'`, `'←'`, `'→'` — not the letters `'U'` `'D'` `'L'` `'R'` that GUIDE.md
> §3b documents. The guide is wrong; Serpiente has been matching on the glyphs
> since v0.0.5.

---

## Screens

### The board — 80 × 24, Sanskrit

```
    a b c d e f g h     ╭────────────────────────╮
  ८ ♜ ♞ ♝ ♛ ♚   ♞ ♜  ८  │ हस्तः       श्वेतः        │
  ७ ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟  ७  │ चालाः      २           │
  ६       ♝          ६  │ गृहीतानि    ० · ०       │
  ५                  ५  ├────────────────────────┤
  ४                  ४  │ स्तरः       मध्यमः       │
  ३         ♙        ३  │ अन्तिमः     f८–d६       │
  २ ♙ ♙ ♙ ♙   ♙ ♙ ♙  २  │ सामग्री     —           │
  １ ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖  १  ╰────────────────────────╯
    a b c d e f g h
```

Black's second move is the गजः from f8 to d6 — two squares diagonally, over
whatever stands between. That is the elephant, and it is the clearest sign that
this is not chess.

### The same game in Persian, with the picture set

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

The rank numbers are `۸ ۷ ۶`, not `8 7 6`. Nothing in the drawing code knows
that — see [Numerals](#numerals-are-translated-too) below.

### Setup — सज्जा

```
     ╭────────────────────────────────────╮
     │              चतुरङ्गम्              │
     │          अष्टापदम् · ८ × ८          │
     ├────────────────────────────────────┤
     │ ► स्तरः          ‹    मध्यमः    ›   │
     │   तव वर्णः       ‹ श्वेतः (त्वम्) › │
     │   अङ्गरूपम्      ‹ शतरञ्जचिह्नानि › │
     │   फलकम्          ‹   अष्टापदम्   ›  │
     │   भाषा           ‹   संस्कृतम्   ›  │
     ├────────────────────────────────────┤
     │  ↑↓ चयनम्   ←→ परिवर्तनम्   ↵ आरम्भः │
     ╰────────────────────────────────────╯
```

---

## Piece sets — अङ्गरूपम्

Four, switchable mid-game with `t`. Every cell stays exactly two columns wide in
all four, so the layout never shifts:

| Set | White | Black | Side shown by |
|-----|-------|-------|---------------|
| शतरञ्जम् | ♔ ♕ ♖ ♗ ♘ ♙ | ♚ ♛ ♜ ♝ ♞ ♟ | the glyph — readable with no colour at all |
| चित्रम् | 👑 🧙 🛞 🐘 🐎 🚶 | the same | the cell background |
| अक्षरम् | रा म र ग अ प | the same | the cell background |
| लातिनम् | K Q R B N P | k q r b n p | the glyph |

Two of the four carry the side in colour rather than in shape, and the reason is
stated rather than hidden: an emoji has no light and dark variant, and Devanagari
has no letter case. In those two sets the board pattern steps aside so the
background can say whose piece it is. `लातिनम्` is the portable fallback, for
terminals that mis-measure emoji or ligate Devanagari conjuncts narrow.

## Boards — फलकम्

| Style | What it is |
|-------|-----------|
| अष्टापदम् | The historical board: one colour, with the sixteen cross-marked cells of the ashtapada (files a, d, e, h × ranks 1, 4, 5, 8) |
| चित्रितम् | Chequered light and dark — a European invention, centuries after this game, and the one everyone recognises |

---

## Rules implemented

These are the moves of historical chaturanga, not of modern chess. Three pieces
differ, and those three are the whole difference between the two games.

| Piece | Moves | Not |
|-------|-------|-----|
| राजा | one square, any direction | no castling — that is 15th-century Europe |
| मन्त्री | **one square diagonally** | not a queen: the weakest piece after the foot soldier |
| रथः | any distance orthogonally | as the rook always has |
| अश्वः | the knight's leap | unchanged in two thousand years |
| गजः | **jumps exactly two squares diagonally**, over whatever is between | not a bishop: it reaches 8 squares of the 64 and never leaves them |
| पत्तिः | one step forward, captures one diagonally | **no double first step**, no en passant |

| Rule | Behaviour |
|------|-----------|
| Promotion | A पत्तिः reaching the far rank becomes a मन्त्री — and nothing else. There is no choice to make. |
| Check | A move that leaves your own king attacked is not legal |
| Checkmate — मातः | Loss |
| **Stalemate — गतिरोधः** | **Loss for the stalemated player**, the old shatranj rule |
| Bare king — निर्वस्त्रः | Reduced to the king alone: loss, unless both are bare, which is a draw |

**Why the opening position has 16 moves and chess has 20.** Eight foot soldiers
step once each, the horses have two moves apiece and the elephants two apiece;
the chariots, counsellor and king are all blocked in. The missing four are the
double pawn steps this game does not have. `परीक्षा/गतिपरीक्षा.zy` asserts it.

**Why stalemate is a win here.** The counsellor and the elephant are weak and the
endgame board is nearly empty. Under the modern rule almost every game between
even opponents would end drawn. This is the choice the shatranj tradition made
and it is what makes the ending sharp — the engine will happily seal your king
in rather than mate it, and that counts.

---

## The opponent — मतिः

Alpha-beta search in negamax form. This is the deepest difference from the go
engine: **go offers three hundred moves a position and search is hopeless;
chaturanga offers about twenty and search is the right instrument.** Go rewards
knowing shapes, chaturanga rewards counting.

| Level | Depth | Tolerance | Behaviour |
|-------|-------|-----------|-----------|
| आरम्भकः | 1 | 200 | Sees what can be taken right now. Will hand you a piece. |
| मध्यमः | 2 | 60 | Sees the reply. Stops giving pieces away. |
| निपुणः | 3 | 20 | Sees the counter-reply. Sets simple traps. |

The level is not "play badly on purpose". It is a **tolerance**: how far below
the best a move may score and still be chosen at random from the survivors. A
beginner is not a program that plays badly; it is one that cannot tell a good
move from a nearly-good one, and 200 points is exactly the price of a piece.

Evaluation is material plus square tables. The piece values are this game's, not
chess's — and the ordering is the interesting part:

```
पत्तिः  100     गजः  150     मन्त्री  200     अश्वः  300     रथः  500
```

The chariot outweighs the counsellor, and the horse outweighs the elephant and
the counsellor together. In a game where the queen is a one-step piece and the
bishop is an eight-square jumper, the rook is the board's king.

**Honest strength estimate:** a weak club beginner. It takes what you hang, does
not hang its own, finds a mate or a stalemate in one, and cannot see three moves
of tactics. That is the point — the engine exists to prove the language can
express a real search, not to beat you.

Measured: **1 646 nodes** for a depth-3 opening move, against **4 448** for the
same tree unpruned. Alpha-beta is doing its work, and both interpreters visit
exactly the same nodes.

---

## Numerals are translated too

This is what चतुरङ्गम् adds to the i18n architecture 囲碁 established. The go
engine has two mechanisms — runtime UI strings and identifier-level API
translation. This one has a third:

**choosing a language chooses a digit script.**

```zymbol
निर्धारणम्(संकेतः) {
    वर्तमानाभाषा = संकेतः
    ?? संकेतः {
        "fa" => { #۰۹# }      // Extended Arabic-Indic, U+06F0
        "en" => { #09# }      // Latin
        "es" => { #09# }
        _    => { #०९# }      // Devanagari, U+0966
    }
    <~ ०
}
```

No drawing code knows which script is active. The one line that composes a
square's name yields `e४`, `e۴` or `e4`; the move counter, the capture counts and
the rank labels all follow. `परीक्षा/भाषापरीक्षा.zy` asserts all three scripts
and `परीक्षा/चित्रपरीक्षा.zy` asserts the square names.

Persian gets **Extended** Arabic-Indic digits (`۰۹`, U+06F0) and not the Arabic
ones (`٠٩`, U+0660). They are different scripts and using the wrong set is an
error a reader notices immediately.

The other two mechanisms are here as well:

**Runtime UI strings** (`भाषा/`) — 60 keys, five locales, one dispatcher holding
the choice as module state so no render function carries a language parameter.
The keys are Sanskrit with a domain prefix (`खण्ड.गृहीतानि`, never plain
`गृहीतानि`), which is what makes completeness *decidable*: a key can never equal
its own translation, so a missing one comes back as itself and the gate sees it.

Each locale also composes three sentences, because a table cannot decline:

| | संस्कृतम् | हिन्दी | فارسی | English | Español |
|---|---|---|---|---|---|
| `जयवाक्यम्(1, 1)` | श्वेतः मातेन जयति | सफ़ेद मात से जीता | سفید با مات برد | White wins by checkmate | ganan las blancas por jaque mate |
| `ग्रहणवाक्यम्(3)` | गजः गृहीतः | हाथी पिट गया | فیل گرفته شد | took an elephant | capturó el elefante |

Sanskrit puts the cause in the instrumental (मातेन, *by means of* mate), Hindi
builds it with से, Persian with با, English inflects the article (*an* elephant),
and Spanish makes the colours feminine plural (*las blancas ganan*). None of that
survives a lookup table.

**Identifier-level API translation** (`api/`) — pure re-export layers exposing the
whole engine under English and Spanish names, zero logic and zero runtime cost.
Constants re-export with `.` and functions with `::`:

```zymbol
<# ./api/english => en
board = en::new_board()
en::setup(board)
moves = en::legal_moves(board, en.WHITE)
```

The piece names are chaturanga's, not chess's: `en.ELEPHANT`, not `BISHOP`.
Naming it for its descendant would describe the wrong game.

---

## Architecture

```
zyChaturanga/
├── चतुरङ्गम्.zy         entry, Sanskrit         ┐
├── चतुरंग.zy            entry, Hindi            │ same game,
├── شطرنج.zy             entry, Persian          │ preselected language
├── chaturanga.zy        entry, English          ┘
├── क्रीडा.zy            match controller — setup, turn loop, undo
├── मूल/                 the engine
│   ├── अष्टापदम्.zy      board shape, piece codes, indices, moves as integers
│   ├── चालाः.zy         how the pieces move; attack detection
│   ├── नियमाः.zy        legality, check, mate, stalemate, bare king
│   ├── आकलनम्.zy        evaluation — material and square tables
│   └── मतिः.zy          alpha-beta search, move ordering, levels
├── दर्शनम्/              presentation
│   ├── अक्षरम्.zy        display width, padding, the two-column rule
│   ├── रूपम्.zy          four piece sets, two boards, layout arithmetic
│   └── चित्रणम्.zy       board, panel, screens, cursor
├── मानकम्/              Sanskrit layer over the standard library
│   ├── पटलम्.zy          std/term
│   ├── यादृच्छिकम्.zy    std/random
│   └── निवेशनिर्गमः.zy   std/io
├── भाषा/                runtime UI strings
│   ├── प्रेषकः.zy        dispatcher, locale state, numeral script, key catalogue
│   ├── संस्कृतम्.zy      sa    ├── हिन्दी.zy    hi    ├── فارسی.zy   fa
│   ├── English.zy       en    └── Español.zy   es
├── परीक्षा/              test suites, each with a recorded golden
│   ├── सर्वपरीक्षा.sh    runs everything
│   ├── आकृतिः.zy         text-diagram parser for readable test positions
│   ├── नियमपरीक्षा.zy    the rules
│   ├── गतिपरीक्षा.zy     perft — move generation counts
│   ├── मतिपरीक्षा.zy     the engine, by property
│   ├── चित्रपरीक्षा.zy   the two-column invariant
│   ├── भाषापरीक्षा.zy    i18n completeness, all five locales
│   └── अनुप्रयोगपरीक्षा.zy  api/ resolves to the same engine
└── api/                 identifier-level API translation
    ├── english.zy
    └── espanol.zy
```

The board is a **flat array of 64 squares**, 1-indexed. White pieces are 1..6 and
black 7..12, so the array is never negative and `0` means empty everywhere. A
move is **one integer**, `from × 100 + to` — not a two-element array, because
move generation is the innermost loop of the search and an array per move costs
two allocations where an integer costs none.

Because Zymbol functions called by name have **isolated scope**, the board is
never global state. It is passed explicitly and mutated through `<~` output
parameters. `कृति()` and `प्रत्यावर्तनम्()` are exact inverses and the search
never copies the board — a property the tests assert directly, because if it
ever stopped holding, the engine would corrupt the board a few thousand nodes
deep and nothing else would notice.

---

## Testing

The gate is [ZyQuality](https://github.com/zymbol-lang/zyquality), which runs
every suite against its golden in every engine that can:

```bash
cd ../zyquality && bash project/run.sh --only chaturanga
```

```
── chaturanga
  goldens   6 goldens via `run`: 6 match, 0 stale, 0 unchecked
  engines   7 files: 6 agree, 0 diverge, 1 with too few engines
```

Locally, and additionally sweeping `zymbol check` over every source:

```bash
bash परीक्षा/सर्वपरीक्षा.sh
```

Test positions are written as diagrams so the expected answer can be checked by
eye:

```zymbol
गजबाधा = आ::पठनम्([
    "........",
    "........",
    "........",
    "....P...",     // the elephant leaps over this
    "...B....",
    "........",
    "........",
    "........"
])
निवेदनम्("elephant leaps over a piece", अस्ति(गजबाधा, "d4", "f6"), #1, दोषाः)
```

The letters are the international ones — R N B Q K P — for one reason: Devanagari
has no letter case, so a single character cannot distinguish white from black.
And those letters descend from these very pieces. Borrowing them back is a
homecoming, not a loan.

---

## Limitations

1. **No repetition or fifty-move draw yet.** The position hash exists
   (`नियमाः::स्थितिसंकेतः`) and the controller does not yet keep a history of it.
   A game can in principle repeat forever.
2. **Beginner-strength engine.** Depth 3, no quiescence search, so it will walk
   into a capture sequence that resolves on the fourth ply.
3. **Devanagari rendering depends on your terminal and font.** The column
   arithmetic is correct with respect to `std/term`; a terminal that ligates
   `ङ्ग` narrower than its code points sum will still look shifted. Switch to the
   `लातिनम्` piece set.
4. **Right-to-left is the terminal's business.** The Persian locale stores its
   strings in logical order and measures them correctly; how they are shaped on
   screen is up to the emulator.
5. **The top level wants `--vm`.** Two seconds a move under the tree-walker
   against a twentieth of a second under the VM.

---

## Status

| Phase | Content | State |
|-------|---------|-------|
| 1 | Board, piece encoding, move-as-integer | **done** |
| 2 | Historical movement rules, attack detection | **done** |
| 3 | Legality, check, mate, stalemate, bare king, promotion | **done** |
| 4 | Evaluation and alpha-beta search with three levels | **done** |
| 5 | Five locales, dispatcher, three numeral scripts, completeness gate | **done** |
| 6 | Display width, four piece sets, two boards, layout gating | **done** |
| 7 | Controller, TUI, undo, four entry points | **done** |
| 8 | Six suites with goldens, registered in ZyQuality | **done** |
| 9 | api/english and api/espanol | **done** |
| 10 | Repetition and fifty-move draws; game records | pending |
| 11 | Engine-vs-engine harness, as 囲碁's 棋戦 | pending |

---

## Language findings

Bugs, gaps and ideas found while writing this are in
[HALLAZGOS_ES.md](HALLAZGOS_ES.md). The sharp one: `@ <identifier>` is a *while*
loop in the tree-walker and a *times* loop in the register VM when the identifier
holds a `Bool` — the VM aborts, `zymbol check` says nothing, and no file in the
parity corpus writes that form.

The three findings the project's first skeleton recorded are also discussed
there: two of them were not findings, and saying so matters — a findings log
that accepts anything stops being one.

---

## Credits

Created by [**OscarEEspinozaB**](https://github.com/OscarEEspinozaB), in
collaboration with **Claude Code**.

Part of the [Zymbol](https://github.com/zymbol-lang) project, whose method for
validating a language by writing real programs in it is described in
[LDV.md](https://github.com/zymbol-lang/interpreter/blob/main/LDV.md).
