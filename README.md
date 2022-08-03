
<br>

<div align = center>

![Badge Version]

# Automatic Screen  <br> Resolution Switcher

This program allows starting `ST-Low` resolution <br>
color games from various environments.

It is intended for `fullscreen` **Games** <br>
and **Demos** that aren't using **GEM**.

*The video mode is automatically switched when* <br>
*applications are launched and restored afterwards.*

</div>

<br>
<br>

## Releases

- [`MODESW.INF`][INF]

- [`MODESW.PRG`][PRG]

<br>
<br>

## Supported Environments

-   **Overscan** desktops using `LaceScan` cards.   *Experimental*

-   **Graphical** desktops using `ET4000` cards.

-   **Mono** desktops using **[Ubeswitch]**.



<br>
<br>

## Usage

Place `MODESW.PRG` & `MODESW.INF` into the `AUTO` folder.

This program *must be run* ***before*** any program <br>
listed in the configuration you are using.

<br>

| Default |     ET4000     |    LaceScan    |
|:-------:|:--------------:|:--------------:|
|         | `nvdi.prg`     | `lacescan.prg` |
|         | `redirect.prg` |                |
|         | `slct_dev.prg` |                |

<br>
<br>

## Selective Activation

You can edit the  `MODESW.INF`  file to specify <br>
`folders / files`  that will automatically <br>
activate this program.

<br>

-   Up to `256` rules

-   One rule per line

-   Each line must start with `00` <br>
    followed by the search string

<br>

### Example Rules

All programs launched from `F:`

```
00 F:\
```

<br>

All programs launched from the `GAMES` directory <br>

```
00 \GAMES\
```

<br>

All programs called `MYGAME.PRG` located anywhere <br>

```
00 \MYGAME.PRG
```

<br>


<!----------------------------------------------------------------------------->

[Ubeswitch]: https://github.com/planeturban/ubeswitchmk6

[PRG]: Release/MODESW.PRG
[INF]: Release/MODESW.INF


<!----------------------------------[ Badges ]--------------------------------->

[Badge Version]: https://img.shields.io/badge/Version-201127-7a1a43.svg?style=for-the-badge&labelColor=A9225C

