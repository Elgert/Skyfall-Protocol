extends Node
## Global signal hub. No state, no logic — just decoupled communication.
## Systems emit/listen here instead of holding direct references.

# --- Player ---
signal player_spawned(player: Node)
signal player_died
signal player_damaged(amount: float, current_hp: float, max_hp: float)
signal player_healed(amount: float, current_hp: float, max_hp: float)

# --- Enemies ---
signal enemy_spawned(enemy: Node)
signal enemy_died(enemy: Node, position: Vector2, xp_value: int)

# --- XP / Leveling ---
signal xp_collected(amount: int, total: int)
signal player_leveled_up(new_level: int)
signal upgrade_chosen(upgrade: Resource)

# --- Run state ---
signal run_started
signal run_ended(survived_seconds: float)
signal wave_changed(wave_index: int)
