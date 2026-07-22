extends Control
class_name LoadingUI

@onready var bg: ColorRect = %Bg
@onready var label: Label = %Label
@onready var progress_bar: ProgressBar = %ProgressBar

func show_loading(text: String = "加载中..."):
	visible = true
	label.text = text
	progress_bar.value = 0

func hide_loading():
	visible = false

func update_progress(value: float):
	progress_bar.value = value
