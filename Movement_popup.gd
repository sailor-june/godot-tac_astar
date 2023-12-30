extends PopupMenu

func _on_menu_item_selected(id):
	match id:
		0:
			_on_attack_selected()
		1:
			_on_item_selected()
		2:
			_on_cancel_selected()

func _on_attack_selected():
	print("Attack selected")

func _on_item_selected():
	print("Item selected")

func _on_cancel_selected():
	print("Cancel selected")
