extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func join_server():
		#create client on the multiplayer network
	var client : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var gateway := SceneMultiplayer.new()	
	client.create_client("127.0.0.1", 9999)
	get_tree().set_multiplayer(gateway, self.get_path())
	multiplayer.set_multiplayer_peer(client)
	client.connection_succeeded.connect(self._Connected_Success)
	client.connection_failed.connect(self._Connection_Failed)

func _Connected_Success():
	print("Connection Sucessfully Established")
	print("waiting to start physics for player")
	await get_tree().create_timer(2).timeout
	get_tree().get_root().get_node("World").get_node("Player").set_physics_process(true)

func _Connection_Failed():
	print("Connection Failed")

@rpc func SendPlayerState(player_state):
	print(player_state)
	rpc_id(0, "RecievePlayerState", player_state)

@rpc(any_peer)
func RecievePlayerState(player_state):
	pass
	
@rpc func SendWorldState(world_state):
	pass
#below are server functions that can be called
@rpc
func RecieveWorldState(world_state):
	print(world_state)
	get_tree().get_root().get_node("World").UpdateWorldState(world_state)
	
@rpc
func FetchPlayerData(requester_id):
	rpc_id(0, "FetchPlayerData", requester_id)
	print("Asked server for data")
	
@rpc
func ReturnPlayerData(data):
	print(JSON.stringify(data))

@rpc(any_peer)
func spawn_peer(player_id):
	if NetworkConnection.get_multiplayer().get_unique_id() == player_id:
		pass
	else:
		print("adding peer")
		var new_peer = preload("res://peer.tscn").instantiate()
		new_peer.name = str(player_id)
		get_tree().get_root().get_node("World").get_node("Peers").add_child(new_peer)
	

	
