# Fantasy Pivot — Content Roadmap

Reference for retheming Skyfall Protocol from "arcade plane shooter" to "holy knight
vs. beasts of hell". The architecture is theme-agnostic — most of this is content
swaps + sprites + naming. Mechanics changes are called out explicitly.

---

## 1. Naming map (code → fantasy)

| Code identifier (keep) | In-game name (rename in UI / descriptions) |
|---|---|
| `Player` (class) | Holy Knight / Crusader / Paladin |
| `Enemy` (class) | Beast / Hellspawn |
| basic_drone | Skeleton Grunt |
| elite_drone | Skeleton Champion |
| turret_drone | Skeletal Archer |
| boss_alpha | Demon Lord |
| `XPGem` | Soul Shard |
| `WeaponMount` | Loadout |
| machine_gun | Hurled Daggers |
| laser | Holy Lance |
| drones (orbit) | Seraphic Blades |
| `boost` (already removed) | n/a |
| `Bullet`, `LaserBolt` | Dagger, Lance |
| `EnemyBullet` | Bone Arrow |

Code symbols stay — only `display_name` and `description` fields on resources
need to change. Refactoring class names later is optional.

---

## 2. Weapon roster (current + planned)

| Existing | Fantasy theme | Sprite needs |
|---|---|---|
| Machine Gun | **Hurled Daggers** — auto-thrown blades, fast, weak | Spinning dagger glyph |
| Laser | **Holy Lance** — bright piercing beam-bolt | Long golden bolt |
| Orbit Drones | **Seraphic Blades** — angelic swords orbiting the knight | Floating sword sprite |

### Planned new weapons (one .tres each, possibly one new script)

| New weapon | Mechanic | Architecture fit |
|---|---|---|
| **Crusader Sword Sweep** | Periodic arc swing around the knight, damages everything in cone | New `weapon_sweep.gd` — similar to `weapon_drones.gd` but a hitbox arc that pulses |
| **Consecration** | Drops a holy circle on the ground that damages enemies inside for N seconds | New `weapon_aoe.gd` — spawns a persistent Area2D |
| **Smite** | Strikes a random enemy with a holy bolt from above | Variant of projectile weapon with target-picking logic |
| **Wrath of Light** | Slow, big projectile that explodes on first hit (AoE damage) | Projectile + on-hit AoE spawn |

All four can reuse the existing weapon-unlock + per-weapon-upgrade system.

---

## 3. Enemy roster

### Already implemented (just rename + reskin)

| Code | Fantasy reskin | Notes |
|---|---|---|
| basic_drone | **Skeleton Grunt** | Walks at the knight |
| elite_drone | **Skeleton Champion** | Bigger, tougher, more dangerous |
| turret_drone | **Skeletal Archer** | Slow, fires bone arrows |
| boss_alpha | **Demon Lord** | Looming, scaling per spawn |

### Planned beasts (priority order)

| Beast | Behavior | Effort | Why |
|---|---|---|---|
| **Hellhound** | Fast, low HP, charges in straight lines | Trivial — new `.tres` only | Movement variety, punishes camping |
| **Stone Golem** | Slow, very high HP, high contact damage | Trivial — new `.tres` only | Forces focus-fire commitment |
| **Ghoul / Splitter** | Medium drone, spawns 2–3 ghouls on death | Small — new on_died callback | Wave-density spikes |
| **Imp Swarm** | Spawn in clusters of 6 from one anchor | Small — WaveDirector tweak | Vampire-Survivors mass feel |
| **Hellbat Kamikaze** | Fast charge, explodes on contact (AoE) | Small — death AoE hurtbox | "Back off!" moments |
| **Necromancer** | Stationary, periodically births skeleton grunts | Medium — minion spawn loop | Priority-target enemy |
| **Cultist Caster** | Like the archer, but fires 3-shot spreads on a longer cooldown | Trivial — reuses shooter logic | Denser ranged threat |
| **Demonic Knight** | Slow, immune from front arc; vulnerable from rear | Medium — arc check on hitbox | Rewards positioning |
| **Will-o-Wisp** | Phases invulnerable for 1s on cycle | Small — invuln toggle on a timer | Timing element |
| **Wraith Healer** | Beams nearby enemies to regen them | Medium — heal beam + AoE pulse | Threat prioritisation |
| **Lesser Demon Lord** | Mini-boss between full bosses (every 90s?) | Small — new `.tres` + wave hook | Pacing between big bosses |

### Boss escalation

Existing system already scales the boss per spawn and doubles count every 3rd
spawn. Theme each boss tier differently to keep visual variety:

| Spawn # | Theme | Reskin |
|---|---|---|
| 1, 2, 3 | Demon Lord | Big horned demon |
| 4, 5, 6 (2 bosses) | Twin Wraiths | Pale shrieking spectres |
| 7, 8, 9 (4 bosses) | Chained Abominations | Beasts wrapped in bone |
| 10+ (8 bosses) | The Choir | Eight identical screaming heads |

---

## 4. Upgrade rename pass

All existing upgrade `.tres` files keep their mechanics, just retheme `display_name`
and `description`:

| Existing | Fantasy name | Description |
|---|---|---|
| Heavier Rounds (+25% dmg) | **Sanctified Steel** | "Your strikes are blessed. +25% damage." |
| Hot Barrel (+20% rate) | **Zealous Fervor** | "Attack faster in the heat of battle. +20% attack rate." |
| Tuned Engine (+30 spd) | **Crusader's Stride** | "Faster on the field. +30 movement speed." |
| Reinforced Hull (+25 HP) | **Holy Vigor** | "+25 max HP and heal." |
| Twin Cannons (+1 proj) | **Twin Strike** | "+1 projectile per attack." |
| AP Rounds (+1 pierce) | **Blessed Edge** | "Your blades pierce one extra enemy." |
| Magnetic Field (+40 radius) | **Soul Magnet** | "Soul shards pull from farther away." |
| Laser: Overcharge | **Lance: Divine Wrath** | (when Holy Lance equipped) |
| Laser: Focusing Lens | **Lance: Piercing Light** | (when Holy Lance equipped) |
| Laser: Rapid Optics | **Lance: Swift Judgement** | (when Holy Lance equipped) |
| Drones: Swarm | **Seraphim: Choir** | (when Seraphic Blades equipped) |
| Drones: Plasma Edge | **Seraphim: Sharpened Wings** | (when Seraphic Blades equipped) |
| Drones: Spin Up | **Seraphim: Whirlwind** | (when Seraphic Blades equipped) |
| EQUIP: Laser | **EQUIP: Holy Lance** | |
| EQUIP: Orbit Drones | **EQUIP: Seraphic Blades** | |

### New theme-specific upgrades worth adding

- **Aura of Light** — passive damage to nearby enemies per second
- **Resurrection** — survive a lethal hit once per run
- **Holy Wrath** — +50% damage to enemies above 75% HP
- **Last Stand** — +40% damage when below 30% HP
- **Vampiric Edge** — small heal on kill
- **Indulgence** — extra upgrade choice rolls per level-up

---

## 5. Player feel — mechanical tweaks during pivot

These are the only *code* changes worth making during the pivot:

1. **Remove movement momentum.** Knights don't drift. In `PlayerStats`:
   - `acceleration` → set very high (3000+) so it feels instant
   - `friction` → set very high (2000+) so stopping is immediate
   - Or refactor `player.gd._apply_movement` to set velocity directly to `input * move_speed`
2. **Drop rotation toward target.** Top-down knights don't rotate to face. Either:
   - Remove `_apply_rotation` entirely (knight stays upright)
   - OR rotate the sprite only (leave the body unrotated, rotate the Visual node)
3. **Sprite faces down.** Most VS-likes use front-facing character sprites. The
   "facing north sprite + π/2 offset" trick from the plane is removed.
4. **Background swap.** Crypt floor / cathedral tiles instead of dark sky.

After these changes, weapons that read `global_transform.x` (plane's forward) need
a fallback — they should target the nearest visible enemy directly, since there's
no plane-nose direction anymore. Two-line change in `weapon.gd._fire`.

---

## 6. Sprite shopping list

Everything needed for the pivot (priority order):

### Critical (game stops looking like a plane)
1. **Knight character** — top-down, front-facing, ~32×32 or 64×64
2. **Skeleton Grunt** (replaces basic drone)
3. **Soul Shard** (replaces XP gem)
4. **Dagger projectile** (replaces yellow bullet)

### High-impact (full visual coherence)
5. **Skeletal Archer** (replaces turret_drone)
6. **Skeleton Champion** (replaces elite_drone)
7. **Demon Lord boss**
8. **Bone Arrow** (replaces red enemy_bullet)
9. **Holy Lance bolt** (replaces green laser_bolt)
10. **Seraphic Blade** (replaces orbit drone visual)

### New content (when adding beasts)
11. Hellhound, Stone Golem, Ghoul, Imp, Hellbat, Necromancer, Cultist, Demonic Knight,
    Will-o-Wisp, Wraith Healer

### Polish
12. Background tile (crypt / cathedral)
13. Aura / consecration ground texture
14. Particle textures for hit-flash / death-burst

### Recommended specs

- 16×16 or 32×32 for tight pixel art
- 64×64 for slightly more detail
- Top-down view (camera looks straight down)
- Front-facing for the knight (sprite shows the top of head + shoulders)
- Consistent palette across all sprites

---

## 7. Suggested pivot order

If we actually do the pivot:

1. **Mechanical tweaks first** — momentum off, rotation off, weapon-direction
   fallback. ~30 min of code.
2. **Knight + Skeleton Grunt sprites** — replaces 90% of what's on screen. The
   game already *looks* fantasy at this point.
3. **XP gem + dagger projectile** — the next two most-seen things.
4. **Rename all `display_name` / `description` fields in upgrade .tres files.**
   Pure data, no code changes.
5. **Sprites for remaining existing enemies (elite, turret, boss).**
6. **Sprites for new weapons (lance, seraphic blade).**
7. **Add new beasts** one by one from the roster — start with Hellhound (trivial)
   and Imp Swarm (juicy mass feel).
8. **Add new weapons** — Crusader Sword Sweep is the most fun next addition.

---

## 8. What we KEEP from the current build

- All systems: WaveDirector, EventBus, UpgradeDatabase, LevelUpMenu, HUD, GameOver
- Health / Hitbox / Hurtbox components
- The visibility-gated auto-aim + plane-forward firing (becomes "aim at nearest
  visible beast, fire from knight's position")
- Portrait viewport + invisible joystick
- Camera shake on damage
- Damage flash on enemies
- Boss scaling + doubling schedule
