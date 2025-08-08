##Amf0Object对象 支持将任意Object 转换成Amf0Object
class_name Amf0Object extends AmfType

var ClassName: String = ""
var IsAnonymous: bool = true  # 默认为匿名对象
var DynamicMembersAndValues: Dictionary = {}  # 存储属性键值对



func ToObject()->Dictionary:
	return self.DynamicMembersAndValues


func FromObject(value:Object) -> void:	
	#获取脚本实例
	var script = value.get_script()

	if script != null:
		#获取类名
		self.ClassName = script.get_global_name()
	else:
		#获取类型
		self.ClassName = value.get_class()
	
	
	self.isAnonymous()
	
	self.dynamicMembersAndValues(value)
	

#判断自身是否是匿名对象
func isAnonymous():
	self.IsAnonymous = ClassDB.class_exists(self.ClassName)
	

func dynamicMembersAndValues(value:Object):
	var property_list = value.get_property_list()
	self.DynamicMembersAndValues = self.get_only_custom_properties(value)


static func get_only_custom_properties(obj: Object) -> Dictionary:
	var custom_props = {}
	if not obj:
		return custom_props
	
	# 获取当前类名和基类名
	var Class_name = obj.get_class()
	var base_class_name = ClassDB.get_parent_class(Class_name)
	
	# 获取基类的属性（用于排除继承属性）
	var base_prop_names = []
	if not base_class_name.is_empty():
		var base_obj = ClassDB.instantiate(base_class_name)
		if base_obj:
			for prop in base_obj.get_property_list():
				base_prop_names.append(prop.name)
			base_obj.free()
	
	# 过滤逻辑：
	# 1. 排除继承自基类的属性
	# 2. 排除引擎内置属性（如 script）
	for prop in obj.get_property_list():
		var prop_name = prop.name
		if not base_prop_names.has(prop_name) and prop_name != "script" and not prop_name.begins_with("_") and not prop_name.ends_with(".gd") :
			custom_props[prop_name] = obj.get(prop_name)
	
	return custom_props
