
## 封装自ActionMessageFormat 的所有动作消息格式 所有子类均未实现 作者因为作者用不到,后续可能会更新实现
class_name Message extends ActionMessageFormat

var Body:Variant
var ClientId:String
var ClientIdBytes:PackedByteArray
var Destination:String
var Headers:Variant
var MessageId:String
var MessageIdBytes:PackedByteArray
var Timestamp:float
var TimeToLive:float
