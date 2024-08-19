extends Node

func assign_network_master(subject: Node, is_server_object: bool, peer_id: int):
	subject.set_network_master(determine_network_master(is_server_object, peer_id))

func determine_network_master(is_server_object: bool, peer_id: int):
	if (is_server_object):
		return 1
	if get_tree().is_network_server():
		return peer_id
	else:
		return get_tree().get_network_unique_id()
