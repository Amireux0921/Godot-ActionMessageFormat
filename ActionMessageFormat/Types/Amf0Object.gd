##Amf0Object对象 支持将任意Object 转换成Amf0Object
class_name Amf0Object extends IAmfObject

var ClassName: String
var IsAnonymous: bool # 默认为匿名对象
var DynamicMembersAndValues: Dictionary = {}  # 存储属性键值对


##将数据进行还原
func ToObject():
	if self.IsAnonymous:
		return self.DynamicMembersAndValues
	else:
		var List:= ProjectSettings.get_global_class_list()
		for item in List:
			if item["base"] == "IMessage": #父类必须是IMessage
				if item['class'] == self.ClassName:
					var Custom:Script = load(item['path'])
					if(Custom.is_abstract()):#如果是抽象类则视为不存在此类 返回字典
						
						for v in self.DynamicMembersAndValues:
							self.DynamicMembersAndValues[v] = self.DynamicMembersAndValues[v]
						
						self.DynamicMembersAndValues[ActionMessageFormat.CLASS_ALIAS] = self.ClassName
						
						return self.DynamicMembersAndValues
					else:#否则实例化设置参数
						var Class = Custom.new()
						for key in self.DynamicMembersAndValues:
							Class.set(key,self.DynamicMembersAndValues[key])
						return Class
	for v in self.DynamicMembersAndValues:
		self.DynamicMembersAndValues[v] = self.DynamicMembersAndValues[v]
	self.DynamicMembersAndValues[ActionMessageFormat.CLASS_ALIAS] = self.ClassName
	return self.DynamicMembersAndValues

func FromObject(value:Object) -> void:	
	#获取脚本实例
	var script:Script = value.get_script()
	if script == null:
		self.ClassName = ""
		self.DynamicMembersAndValues ={}
		self.IsAnonymous = true
	else:
		self.ClassName = script.get_global_name()
		
		self.IsAnonymous = self.ClassName.is_empty()
		
		var own_props = Amf0Object.ExcludeParent(script)
		
		for prop_name in own_props:
			self.DynamicMembersAndValues[prop_name] = value.get(prop_name)

static func ExcludeParent(value: Script) -> Dictionary:
	var own_properties := {}
	var base_script = value.get_base_script()
	
	# 获取当前脚本的所有属性（包括继承的）
	var all_props = value.get_script_property_list()
	
	# 如果有父脚本，获取父脚本的属性
	var base_props = []
	if base_script:
		base_props = base_script.get_script_property_list()
	
	# 创建父类属性名称集合
	var base_prop_names = {}
	for prop in base_props:
		base_prop_names[prop.name] = true
	
	# 筛选出当前类独有的属性
	for prop in all_props:
		# 只保留当前类定义的属性（排除父类属性）
		if not base_prop_names.has(prop.name):
			# 排除内置引擎属性（如 script）
			if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				own_properties[prop.name] = prop
	
	return own_properties
