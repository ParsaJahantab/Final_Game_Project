extends Node

class_name GraphGenerator

# Node class to represent each vertex in the graph
class CustomGraphNode:
	var id: int
	var connections: Dictionary
	
	func _init(node_id: int):
		id = node_id
		connections = {
			"top": null,
			"down": null,
			"left": null,
			"right": null
		}
	
	func _to_string() -> String:
		return "Node(%d)" % id

# Main class variables
var rng = RandomNumberGenerator.new()
var visited: Dictionary = {}
var max_attempts = 100

func _ready() -> void:
	rng.randomize()

# Create a random graph with specified constraints
func create_random_graph() -> Array:
	# Create random number of nodes between 5 and 10
	var num_nodes = rng.randi_range(5, 10)
	var num_nodes_in_main_path 
	if num_nodes %2 ==0 : 
		num_nodes_in_main_path = rng.randi_range(num_nodes/2 , num_nodes)
	else :
		num_nodes_in_main_path = rng.randi_range((num_nodes/2 +1 ), num_nodes)
	var num_nodes_in_sub_path = num_nodes - num_nodes_in_main_path
	#var num_nodes = 3
	var nodes = []
	var prev_node: CustomGraphNode
	var available_directions
	var random_pair
	#print("num_nodes_in_main_path: ",num_nodes_in_main_path ," num_nodes_in_sub_path: ",num_nodes_in_sub_path,'\n')
	# Initialize nodes
	for i in range(num_nodes_in_main_path):
		var node := CustomGraphNode.new(i)
		if i != 0: 
			available_directions = get_available_directions(node , prev_node)
			random_pair = available_directions[randi() % available_directions.size()]
			#print(available_directions)
			#print(random_pair)
			connect_nodes(node , prev_node, random_pair[0], random_pair[1])
			var connections = []
			for direction in node.connections.keys():
				var connected_node = node.connections[direction]
				if connected_node != null:
					connections.append("%s: Node(%d)" % [direction, connected_node.id])
			#print("Node %d -> %s" % [node.id, ", ".join(connections)], '\n')

		nodes.append(node)
		prev_node = node
	var filtered_array = nodes.duplicate()
	filtered_array.remove_at(0)
	filtered_array.remove_at(filtered_array.size()-1)
	#print(filtered_array)

	for i in range(num_nodes_in_sub_path):
		var random_node = filtered_array[randi_range(0, filtered_array.size()-1)]
		var node := CustomGraphNode.new(num_nodes_in_main_path  + i)
		available_directions = get_available_directions(random_node , node)
		if available_directions.size() != 0:
			random_pair = available_directions[randi() % available_directions.size()]
			connect_nodes(random_node , node, random_pair[0], random_pair[1])
			nodes.append(node)
			filtered_array.append(node)


	#print_all_connections(nodes)
	return nodes


func print_all_connections(nodes:Array):
	for node in nodes:
		#print("node : ", node,'\n')
		var connections = []
		for direction in node.connections.keys():
			var connected_node = node.connections[direction]
			if connected_node != null:
				connections.append("%s: Node(%d)" % [direction, connected_node.id])
		#print("Node %d -> %s" % [node.id, ", ".join(connections)], '\n')

# Get available directions for connecting two nodes
func get_available_directions(node1: CustomGraphNode, node2: CustomGraphNode) -> Array:
	var opposites = {
		"top": "down",
		"down": "top",
		"left": "right",
		"right": "left"
	}
	
	var available = []
	for dir1 in opposites.keys():
		var opposite = opposites[dir1]
		if node1.connections[dir1] == null and node2.connections[opposite] == null:
			available.append([dir1, opposite])
	
	return available

# Connect two nodes bidirectionally
func connect_nodes(node1: CustomGraphNode, node2: CustomGraphNode, dir1: String, dir2: String) -> void:
	node1.connections[dir1] = node2
	node2.connections[dir2] = node1
