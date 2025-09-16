class_name AMF_Header extends ActionMessageFormat

@export var Name:String
@export var MustUnderstand:bool
##封装的变体数据 可以是任意类型的数据
@export var Content:Variant

func _init(Name:String = "",MustUnderstand:bool = false , Content:Variant = null) -> void:
	self.Name = Name
	self.MustUnderstand = MustUnderstand
	self.Content = Content
	
