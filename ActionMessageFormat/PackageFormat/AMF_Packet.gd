class_name AMF_Packet extends ActionMessageFormat

enum AmfVersion
{
	AMF0 = 0,
	AMF3 = 3
}


##AMF版本号 此版本好仅适用于数据包 真正的AMF版本号得从字节流中读取AMF3标识 才算真正的AMF3
var Version:AmfVersion
##消息头数组
var Headers:Array[AMF_Header]
##消息体数组
var Bodys:Array[AMF_Body]

func _init(Version:AmfVersion = AmfVersion.AMF3,Headers:Array[AMF_Header]=[],Bodys:Array[AMF_Body]=[]) -> void:
	self.Version = Version
	self.Headers = Headers
	self.Bodys = Bodys
	

##将AMF_Packet 反序列化为字节数组
func Serialization()->PackedByteArray:
	var Writ:=AmfWriter.new()
	Writ.WriteAmfPacket(self)
	return Writ.Get_bytes()

##将字节数组进行反序列化为当前数据包
static func Deserialization(value:PackedByteArray)->AMF_Packet:
	var Read:=AmfReader.new()
	Read.Call_buffer(value)
	return Read.ReadAmfPacket()

##解码Body返回指针索引的Body数据 默认第一个Body 指针不匹配返回null
func Body(offset:int=0)->AMF_Body:
	if offset > self.Bodys.size():
		if self.Bodys.size()==0:
			printerr(str("读取失败,空数组无法读取!"))
			return AMF_Body.new()
		printerr(str("Body方法offset指针超出最大上限，Max: ",self.Bodys.size()," Value: ",offset," 默认返回最大值!"))
		return self.Bodys[self.Bodys.size()-1]
	else:
		return self.Bodys[offset-1]
		
##解码Headers返回指针索引的Header数据 默认第一个Header 指针不匹配返回null
func Header(offset:int=0)->AMF_Header:
	if offset > self.Headers.size():
		if self.Headers.size()==0:
			printerr(str("读取失败,空数组无法读取!"))
			return AMF_Header.new()
		printerr(str("Header方法offset指针超出最大上限，Max:",self.Headers.size(),"Value:",offset,"默认返回最大值!"))
		return self.Headers[self.Headers.size()-1]
	else:
		return self.Headers[offset-1]

func AddBody(value:AMF_Body)->int:
	self.Bodys.append(value)
	return self.Bodys.size()

func AddHeader(value:AMF_Header)->int:
	self.Headers.append(value)
	return self.Headers.size()
