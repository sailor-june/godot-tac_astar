extends PopupMenu
@onready var Cursor_ref = get_node("/root/Main/TurnOrder/PlayerCommander/Cursor")
func _ready():
	add_menu_items()
	set_item_disabled(0, true) 
	connect("id_pressed", _on_item_selected)

func add_menu_items():
	add_item("Attack", 0)  # Add an item with label "Attack" and ID 0
	add_item("Item", 1)    # Add an item with label "Item" and ID 1
	add_item("Wait", 2)  # Add an item with label "Cancel" and ID 2
	
func _on_item_selected(id):
	match id:
		0:
			_on_attack_selected()
		1:
			_on_inventory_selected()
		2:
			_on_cancel_selected()

func _on_attack_selected():
	Cursor_ref.attack_phase=true
	print("Attack selected")

func _on_inventory_selected():
	Cursor_ref.selection_phase=true
	print("Item selected")

func _on_cancel_selected():
	Cursor_ref.selection_phase=true
	print("Wait selected")
