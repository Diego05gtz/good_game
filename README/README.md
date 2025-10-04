# MarioLike (Godot 4.4)

Plataformas 2D estilo Mario. Un nivel corto (30–60 s), parallax, cámara, enemigos, monedas, HUD y meta por bandera.

## Controles
- **A / D** o **← / →**: mover
- **Espacio**: saltar
- **R**: reiniciar tras ganar o morir

## Objetivo
Llega a la **bandera** para ganar. Evita enemigos o elimínalos saltando **encima**. Caer al vacío = derrota.

## Estructura de escenas
- `scenes/Main/Main.tscn` — Game manager + HUD + música
- `scenes/Level/Level.tscn` — TileMap, KillZoneBottom, GoalFlag
- `scenes/Player/Player.tscn` — jugador (CharacterBody2D)
- `scenes/Enemy/Enemy.tscn` — patrulla, daño lateral, stomp
- `scenes/Coin/Coin.tscn` — coleccionable (≥10), SFX y partículas
- `scenes/UI/HUD.tscn` — contador de monedas + mensajes win/lose

## Constantes y código
- `Player.gd`: `SPEED`, `GRAVITY`, `JUMP_VELOCITY`, animaciones `idle/run/jump/dead`.
- `Enemy.gd`: `speed`, `gravity`, `stomp_bounce`, raycasts para giro, `DamageArea`/`StompArea`.

## Build / Export
- **Windows**: `build/windows/MarioLike.exe`
