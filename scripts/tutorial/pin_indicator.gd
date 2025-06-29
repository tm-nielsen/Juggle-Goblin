extends Node2D

@export var display_threshold: float = 50
@export var checkpoint_manager: CheckpointManager

@export var bounce_amplitude: float = 8
@export var bounce_frequency: float = 1

var player: PlayerController
var enabled: bool

var base_position: float
var bounce_timer: float


func _ready() -> void:
    LevelSignalBus.ball_caught.connect(func(_ball_index): set_active(false))
    LevelSignalBus.ball_dropped.connect(set_active)
    LevelSignalBus.player_died.connect(set_active)
    visibility_changed.connect(reset_bounce)
    player = checkpoint_manager.player
    base_position = position.y;
    set_active(true)


func _process(delta: float) -> void:
    if !enabled: return
    visible = _get_checkpoint_offset() > display_threshold
    _update_bounce_position(delta);

func _get_checkpoint_offset() -> float:
    return player.position.x - checkpoint_manager.active_checkpoint_position.x

func reset_bounce() -> void:
    position.y = base_position
    bounce_timer = 0

func _update_bounce_position(delta: float) -> void:
    bounce_timer += delta
    var t = abs(cos(bounce_timer * bounce_frequency * TAU))
    position.y = base_position - bounce_amplitude * t

func set_active(active := true) -> void:
    enabled = active
    hide()
