extends Area2D
class_name PlotView

signal plot_pressed(plot_model: PlotModel)

var plot_model: PlotModel

@onready var visual: Polygon2D = $Visual
@onready var label: Label = $StateLabel


func setup(model: PlotModel, world_position: Vector2) -> void:
	plot_model = model
	position = world_position
	refresh()


func refresh() -> void:
	match plot_model.state:
		PlotModel.PlotState.EMPTY:
			visual.color = Color("8d6e63")
			label.text = "Empty"
		PlotModel.PlotState.GROWING:
			visual.color = Color("66bb6a")
			label.text = "Growing"
		PlotModel.PlotState.READY:
			visual.color = Color("fdd835")
			label.text = "Ready"


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Plot clicado: (%d, %d) estado=%s" % [
			plot_model.grid_x,
			plot_model.grid_y,
			PlotModel.PlotState.keys()[plot_model.state],
		])
		plot_pressed.emit(plot_model)
