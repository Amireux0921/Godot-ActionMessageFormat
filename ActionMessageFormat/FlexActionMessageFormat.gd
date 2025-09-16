@tool
## [img width=64]res://addons/ActionMessageFormat/flash.png[/img] bilibili & [url=https://space.bilibili.com/489827602]访问作者[/url].
extends EditorPlugin


func _enter_tree():
	add_custom_type("ActionMessageFormat", "Object", preload("ActionMessageFormat.gd"), preload("flash.png"))

func _exit_tree():
	remove_custom_type("ActionMessageFormat")
	
