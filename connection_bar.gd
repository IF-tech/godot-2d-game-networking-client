extends HBoxContainer

#Taskbar nodes
@onready var join_button = $Join
@onready var host_button = $Host
@onready var status = $Status
@onready var colors = $Color
@onready var ip_address = $IP
@onready var user_name = $Name


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




#when host button is pressed, join a server
func _on_join_pressed():
	join_server()
	print("join button pressed")
	print("ip address is " + ip_address.text)


func create_server():
	#hide buttons
	join_button.hide()
	host_button.hide()
	
	#changed from godot 3.x, used to be NetworkedMultiplayerEnet
	var server : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var gateway := SceneMultiplayer.new()
	
	#create server on specified port
	server.create_server(9999, 32)
	get_tree().set_multiplayer(gateway, self.get_path())
	multiplayer.set_multiplayer_peer(server)
	
	#update status
	status.text = "Status: Hosting Server"
	#unique network id for server is 0
	print(get_tree().get_multiplayer().get_unique_id())

#called when join button is pressed	
func join_server():
	#hide buttons
	join_button.hide()
	host_button.hide()
	
	#create client on the multiplayer network
	var client : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var gateway := SceneMultiplayer.new()	
	client.create_client(ip_address.text,9999)
	get_tree().set_multiplayer(gateway, self.get_path())
	multiplayer.set_multiplayer_peer(client)
	
	#update status
	status.text = "Status: Joined server"


func _on_host_pressed():
	print("host button pressed")
	create_server()
