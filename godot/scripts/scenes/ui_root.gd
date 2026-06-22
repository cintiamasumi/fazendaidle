extends Control
class_name UIRootController

@onready var wheat_label: Label = $MarginContainer/WheatLabel


func set_wheat_count(value: int) -> void:
	wheat_label.text = "Trigo: %d" % value
