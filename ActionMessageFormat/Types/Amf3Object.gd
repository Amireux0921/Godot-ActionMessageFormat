class_name Amf3Object extends IAmfObject

var Trait:Amf3Trait
var Values:Array
var DynamicMembersAndValues:Dictionary

func _init() -> void:
	self.Trait = Amf3Trait.new()

##返回字典或者类
func ToObject()->Variant:
	
	if self.Trait.IsExternalizable:
		return serialization.ToExternalizable(self)
	
	if self.Trait.IsDynamic:
		return self.DynamicMembersAndValues
	elif self.Trait.IsAnonymous:
		var instance = Object.new()
		for i in self.Trait.Members.size():
			var v = serialization.Normalize(self.Values[i])
			instance.set_meta(self.Trait.Members[i],v)
	else:
		var List:= ProjectSettings.get_global_class_list()
		for item in List:
			if item["base"] == "IMessage":
				if item['class'] == self.Trait.ClassName:
					var Custom:Script = load(item['path'])
					if(Custom.is_abstract()):
						var dic:Dictionary
						for i in self.Trait.Members.size():
							var v = serialization.Normalize(self.Values[i])
							dic[self.Trait.Members[i]]=v
						dic[ActionMessageFormat.CLASS_ALIAS] = self.Trait.ClassName
					else:
						var Class = Custom.new()
						for i in self.Trait.Members.size():
							var v = serialization.Normalize(self.Values[i])
							Class.set(self.Trait.Members[i],v)
						return Class
	var instance = Object.new()
	for i in self.Trait.Members.size():
		var v = serialization.Normalize(self.Values[i])
		instance.set_meta(self.Trait.Members[i],v)
	return instance
func FromObject(value:Object):
	var script:Script = value.get_script()
	#不为null说明为自定义对象
	if script != null:
		
		if value is IExternalizable:
			self.Trait.IsExternalizable = true
			serialization.FromExternalizable(value)
		
		self.Trait.ClassName = script.get_global_name()
		
		self.Trait.IsAnonymous = self.Trait.ClassName.is_empty()
		
		var own_props = Amf0Object.ExcludeParent(script)
		
		for prop_name in own_props:
			self.Trait.Members.append(prop_name)
			self.Values.append(value.get(prop_name)) 
	else: #为null说明为动态对象
		
		self.Trait.IsDynamic = true
		
		for item in value.get_meta_list():
			self.DynamicMembersAndValues[item]=value.get_meta(item)
