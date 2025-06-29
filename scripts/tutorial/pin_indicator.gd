extends FlashingDisplay

@export var display_threshold: float = 50
@export var checkpoint_manager: CheckpointManager

var player: PlayerController
var enabled: bool


func _ready() -> void:
    LevelSignalBus.ball_caught.connect(func(_ball_index): set_active(false))
    LevelSignalBus.ball_dropped.connect(set_active)
    LevelSignalBus.player_died.connect(set_active)
    player = checkpoint_manager.player
    set_active(true)


func _process(_delta: float) -> void:
    if !enabled: return
    var checkpoint_position = checkpoint_manager.active_checkpoint_position.x
    var checkpoint_offset = player.position.x - checkpoint_position
    visible = checkpoint_offset > display_threshold


func set_active(active := true) -> void:
    print("setting active: ", active)
    enabled = active
    if (active): start_flashing()
    else: stop_flashing()
    hide()
