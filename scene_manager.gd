extends Node

var persistent_nodes: Dictionary = {}
var current_scene: Node = null
var next_scene_path: String = ""


enum LoadState {
	READY,
	LOADING,
	TRANSITIONING
}
var current_state: LoadState = LoadState.READY

signal scene_changed(new_scene_name)
func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
	_register_initial_persistent_nodes()

func _register_initial_persistent_nodes():
	var persistent_group = "persistent"
	if current_scene.has_node("Player"):
		var player = current_scene.get_node("Player")
		if not player.is_in_group(persistent_group):
			player.add_to_group(persistent_group)
	
	get_tree().get_nodes_in_group(persistent_group).map(register_persistent_node)
	
func register_persistent_node(node: Node, node_id: String = ""):
	if node_id.is_empty():
		node_id = node.name
	
	#if node.get_parent():
		#node.get_parent().remove_child(node)
	
	persistent_nodes[node_id] = node
	node.process_mode = Node.PROCESS_MODE_ALWAYS
	
func unregister_persistent_node(node_id: String):
	if persistent_nodes.has(node_id):
		var node = persistent_nodes[node_id]
		if node.get_parent():
			node.get_parent().remove_child(node)
		persistent_nodes.erase(node_id)
		
func goto_scene(path: String,params):
	if current_state != LoadState.READY:
		print("Scene transition already in progress!")
		return
		
	next_scene_path = path
	current_state = LoadState.LOADING
	
	call_deferred("_deferred_goto_scene",path,params)
	
func _deferred_goto_scene(path,params):
	for node in persistent_nodes.values():
		if node.get_parent():
			node.get_parent().remove_child(node)
	
	current_scene.free()
	

	var new_scene = load(path)
	current_scene = new_scene.instantiate()
	for node in persistent_nodes.values():
		if node.get_parent():
			node.get_parent().remove_child(node)
	_attach_persistent_nodes()
	#get_tree().root.call_deferred("add_child", current_scene)
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	
	if current_scene.has_method("initialize"):
		current_scene.initialize(params)
	
	
	current_state = LoadState.READY
	emit_signal("scene_changed", current_scene.name)

func _attach_persistent_nodes():
	for node_id in persistent_nodes:
		var node = persistent_nodes[node_id]
		
		if current_scene.has_node(NodePath(node.name)):
			current_scene.get_node(NodePath(node.name)).queue_free()
	   
			
		current_scene.add_child(node)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
