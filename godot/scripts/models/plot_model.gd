extends Resource
class_name PlotModel

enum PlotState {
	EMPTY,
	GROWING,
	READY,
}

@export var grid_x: int = 0
@export var grid_y: int = 0
@export var state: PlotState = PlotState.EMPTY

# Timestamp em segundos de engine para quando o crescimento termina.
@export var ready_at_seconds: float = 0.0
