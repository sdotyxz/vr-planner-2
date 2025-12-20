extends Area3D

func _ready():
	# Connect body entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if it's the player (or the rail system's mover?)
	# Assuming Player node is the one colliding
	if body.name == "Player" or body.is_in_group("player"):
		GameManager.set_state(GameManager.GameState.BREACH)
		# Disable this trigger so it doesn't trigger again immediately?
		set_deferred("monitoring", false)
