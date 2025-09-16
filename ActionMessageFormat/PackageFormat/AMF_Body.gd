##AMF消息体
class_name AMF_Body extends ActionMessageFormat
##请求目标地址
@export var TargetUrl:String
##响应回调地址
@export var ResponseUrl:String
##封装的变体数据 可以是任意类型的数据
@export var Content:Variant

func _init(TargetUrl:String="",ResponseUrl:String="",Content:Variant=null) -> void:
	self.TargetUrl = TargetUrl
	self.ResponseUrl = ResponseUrl
	self.Content = Content
