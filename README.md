
[Ubeswitch]: https://github.com/planeturban/ubeswitchmk6

[PRG]: Release/MODESW.PRG
[INF]: Release/MODESW.INF


# Automatic Screen Resolution Switcher
*Version 201127*

This program allows starting `ST-Low` resolution <br>
color games from various environments.

It is intended for `fullscreen` **Games** <br>
and **Demos** that aren't using **GEM**.

*The video mode is automatically switched when* <br>
*applications are launched and restored afterwards.*

---

**Program:** ⸢ [PRG] ⸥ ⸢ [INF] ⸥

---

## Supported Environments

- **Mono** desktops using **[Ubeswitch]**

- **Graphical** desktops using `ET4000` cards

- **Overscan** desktops using `LaceScan` cards <br>
  ( *experimental* )

---

## Usage

Place `MODESW.PRG` & `MODESW.INF` into the `AUTO` folder.

This program *must be run* ***before*** any program <br>
listed in the configuration you are using.

| Default |     ET4000     |    LaceScan    |
|:-------:|:--------------:|:--------------:|
|         | `nvdi.prg`     | `lacescan.prg` |
|         | `redirect.prg` |                |
|         | `slct_dev.prg` |                |

---

## Selective Activation

You can edit the `MODESW.INF` file to <br>
specify `folders / files` that will <br>
automatically activate this program.

- Up to `256` rules
- One rule per line
- Each line must start with `00 `<br>
  followed by the search string

<br>

**Example Rules**

All programs launched from `F:` <br>
`00 F:\`

All programs launched from the `GAMES` directory <br>
`00 \GAMES\`

All programs called `MYGAME.PRG` located anywhere <br>
`00 \MYGAME.PRG`
