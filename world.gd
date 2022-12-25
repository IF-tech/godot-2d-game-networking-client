extends Node2D

var last_world_state = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	print(NetworkConnection.multiplayer.get_unique_id())
	NetworkConnection.FetchPlayerData(NetworkConnection.multiplayer.get_unique_id())

func _on_connect_pressed():
	NetworkConnection.join_server()

func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state.erase("T")
		world_state.erase(NetworkConnection.multiplayer.get_unique_id())
		for player in world_state.keys():
			if get_tree().get_root().get_node("World").get_node("Peers").has_node(str(player)):
				get_node("Peers/" + str(player)).MovePeer(world_state[player]["P"])

