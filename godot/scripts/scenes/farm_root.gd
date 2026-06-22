extends Node2D
class_name FarmRootController

const PLOT_SCENE := preload("res://scenes/plot/Plot.tscn")

signal plot_clicked(plot_model: PlotModel)

const TILE_SIZE := Vector2(96.0, 96.0)
const GRID_ORIGIN := Vector2(120.0, 120.0)

var _plot_views: Dictionary = {}
var _grow_duration_seconds: float = 10.0

@onready var plot_layer: Node2D = $PlotLayer


func setup(farm_model: FarmModel, grow_duration_seconds: float) -> void:
	_grow_duration_seconds = grow_duration_seconds

	for plot_model in farm_model.plots:
		var plot_view: PlotView = PLOT_SCENE.instantiate()
		plot_layer.add_child(plot_view)
		plot_view.setup(plot_model, _grid_to_world(plot_model.grid_x, plot_model.grid_y))
		plot_view.plot_pressed.connect(_on_plot_pressed)
		_plot_views[_plot_key(plot_model)] = plot_view


func refresh_plot(plot_model: PlotModel) -> void:
	var key := _plot_key(plot_model)
	if _plot_views.has(key):
		_plot_views[key].refresh()


func _process(_delta: float) -> void:
	for plot_view in _plot_views.values():
		if plot_view.plot_model.state == PlotModel.PlotState.GROWING:
			var now := Time.get_ticks_msec() / 1000.0
			if now >= plot_view.plot_model.ready_at_seconds:
				plot_view.plot_model.state = PlotModel.PlotState.READY
				plot_view.plot_model.ready_at_seconds = 0.0
				print("Estado alterado para READY: (%d, %d)" % [
					plot_view.plot_model.grid_x,
					plot_view.plot_model.grid_y,
				])
				plot_view.refresh()


func _on_plot_pressed(plot_model: PlotModel) -> void:
	print("Callback _on_plot_pressed executado: (%d, %d)" % [
		plot_model.grid_x,
		plot_model.grid_y,
	])
	plot_clicked.emit(plot_model)


func _grid_to_world(grid_x: int, grid_y: int) -> Vector2:
	return GRID_ORIGIN + Vector2(grid_x * TILE_SIZE.x, grid_y * TILE_SIZE.y)


func _plot_key(plot_model: PlotModel) -> String:
	return "%s:%s" % [plot_model.grid_x, plot_model.grid_y]
