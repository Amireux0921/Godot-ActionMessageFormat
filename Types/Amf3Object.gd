class_name Amf3Object extends AmfType

var Trait:Amf3Trait
var Values:Array
var DynamicMembersAndValues:Dictionary

func _init() -> void:
	self.Trait = Amf3Trait.new()

func ToObject()->Dictionary:
	return self.DynamicMembersAndValues

func FromObject(value:Variant):
	
	var script = value.get_script()
	
	if script != null:
		
		if value is IExternalizable:
			#外部化支持
			self.Trait.IsExternalizable = true
		
		#获取类名
		self.Trait.ClassName = script.get_global_name()
		
		var properties:Dictionary = Amf0Object.get_only_custom_properties(value)
		
		for traitMember in properties:
			
			if traitMember != null:
				self.Trait.Members.append(traitMember)
				self.Values.append(properties[traitMember])
		
	else:
		#获取类型
		#self.Trait.ClassName  = value.get_class()
		self.Trait.IsDynamic = true
		
		if value is Dictionary:
			
			for item in value:
				self.DynamicMembersAndValues[item]=value[item]
		else:
			for property in Amf0Object.get_only_custom_properties(value):
				self.DynamicMembersAndValues[property]=value[property]
