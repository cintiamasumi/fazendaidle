extends Node
class_name GameManager

const FarmModelType := preload("res://scripts/models/farm_model.gd")
const InventoryModelType := preload("res://scripts/models/inventory_model.gd")
const PlotModelType := preload("res://scripts/models/plot_model.gd")

const GRID_WIDTH := 4
const GRID_HEIGHT := 4
const GROW_DURATION_SECONDS := 10.0

var farm_model: FarmModel

@onready var farm_root: Node = get_parent().get_node("FarmRoot")
@onready var ui_root: Node = get_parent().get_node("UIRoot")


func _ready() -> void:
	call_deferred("_initialize_game")


func _initialize_game() -> void:
	farm_model = _build_farm_model()
	farm_root.setup(farm_model, GROW_DURATION_SECONDS)
	ui_root.set_wheat_count(farm_model.inventory.wheat)
	farm_root.plot_clicked.connect(_on_plot_clicked)


func _build_farm_model() -> FarmModel:
	var model := FarmModelType.new()
	model.inventory = InventoryModelType.new()

	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var plot := PlotModelType.new()
			plot.grid_x = x
			plot.grid_y = y
			model.plots.append(plot)

	return model


func _on_plot_clicked(plot_model: PlotModel) -> void:
	match plot_model.state:
		PlotModel.PlotState.EMPTY:
			plot_model.state = PlotModel.PlotState.GROWING
			plot_model.ready_at_seconds = Time.get_ticks_msec() / 1000.0 + GROW_DURATION_SECONDS
			print("Estado alterado para GROWING: (%d, %d)" % [
				plot_model.grid_x,
				plot_model.grid_y,
			])
		PlotModel.PlotState.READY:
			plot_model.state = PlotModel.PlotState.EMPTY
			plot_model.ready_at_seconds = 0.0
			farm_model.inventory.wheat += 1
			ui_root.set_wheat_count(farm_model.inventory.wheat)
			print("Trigo colhido. Total=%d. Plot (%d, %d) voltou para EMPTY" % [
				farm_model.inventory.wheat,
				plot_model.grid_x,
				plot_model.grid_y,
			])
		_:
			print("Clique ignorado em plot GROWING: (%d, %d)" % [
				plot_model.grid_x,
				plot_model.grid_y,
			])
			return

	farm_root.refresh_plot(plot_model)
