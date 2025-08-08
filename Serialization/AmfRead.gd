##AmfRead 提供将AMF原始字节数组进行反序列化 因为Godot本身不支持动态类创建，所有解码的Class 都将转为字典，并且不会附带类名 仅保留属性键值对
class_name AmfRead extends ActionMessageFormat

var buffer:StreamPeerBuffer

var strings:PackedStringArray
var objects:Array[Variant]
var traits:Array[Amf3Trait]

var amf0References:Dictionary
var amf3References:Dictionary

##默认大端序读取数据
func _init(Endian:bool=true) -> void:
	self.buffer = StreamPeerBuffer.new()
	self.buffer.big_endian = Endian
	self.strings = []
	self.objects = []
	self.traits = []
	self.amf0References  = {}
	self.amf3References  = {}

func CanReadByte()->bool:
	
	return self.offset < self.buffer.get_size()

func Call_buffer(bytes:PackedByteArray):
	self.buffer.clear()
	self.buffer.put_data(bytes)
	self.buffer.seek(0)

func Readbyte()->int:
	var value = self.buffer.get_8()
	return value

func ReadBoolean()->int:
	var value = self.buffer.get_8()
	return value

func ReadInt16()->int:
	var value = self.buffer.get_16()
	return value

func ReadUInt16()->int:
	var value = self.buffer.get_u16()
	return value

func ReadInt32()->int:
	var value = self.buffer.get_32()
	return value

func ReadUInt32()->int:
	var value = self.buffer.get_u32()
	return value

func ReadDouble()->float:
	var value = self.buffer.get_double()
	return value

func ReadString(length:int)->String:
	var value = self.buffer.get_utf8_string(length)
	return value

func ReadAmfMessage()->AmfMessage:
	var PacketMessage = AmfMessage.new()
	PacketMessage.Version = self.ReadInt16()
	PacketMessage.Headers = self.ReadAmfHeaders()
	PacketMessage.Bodys = self.ReadBodys()
	return PacketMessage


func ReadAmfHeaders()->Array[AmfHeader]:
	
	var value:Array[AmfHeader]=[]
	
	var HeaderCount = self.ReadInt16()

	for i in HeaderCount:
		
		var Header:= AmfHeader.new()
		
		Header.Name = self.ReadAmf0String()
		Header.MustUnderstand = self.ReadBoolean()
		
		var headerLength = self.ReadInt32()
		
		Header.Content = self.ReadAmf0()
		
		value.append(Header)
		
		self.strings.clear()
		self.objects.clear()
		self.traits.clear()
	
	return value

func ReadBodys()->Array[AmfBody]:
	
	var value:Array[AmfBody]=[]
	
	var messageCount = self.ReadInt16()
	
	for i in messageCount:
		
		var Body:= AmfBody.new()
		
		Body.TargetUri = self.ReadAmf0String()
		Body.ResponseUri = self.ReadAmf0String()
		
		var messageLength = self.ReadInt32()
		
		Body.Content = self.ReadAmf0()
		value.append(Body)
		
		self.strings.clear()
		self.objects.clear()
		self.traits.clear()
	
	return value


func ReadAmf0()->Variant:
	var type = self.Readbyte()
	
	match type:
		Amf0Type.AMF0Type.NUMBER:
			return self.ReadDouble()
		Amf0Type.AMF0Type.BOOLEAN:
			return self.ReadBoolean()
		Amf0Type.AMF0Type.STRING:
			return self.ReadAmf0String()
		Amf0Type.AMF0Type.OBJECT:
			return self.ReadAmf0Object()
		Amf0Type.AMF0Type.NULL:
			return null
		Amf0Type.AMF0Type.UNDEFINED:
			return null
		Amf0Type.AMF0Type.REFERENCE:
			return self.ReadAmf0ObjectReference()
		Amf0Type.AMF0Type.ECMA_ARRAY:
			return self.ReadAmf0Array()
		Amf0Type.AMF0Type.STRICT_ARRAY:
			return self.ReadAmf0StrictArray()
		Amf0Type.AMF0Type.DATE:
			return self.ReadAmf0Date()
		Amf0Type.AMF0Type.LONG_STRING:
			return self.ReadAmf0LongString()
		Amf0Type.AMF0Type.UNSUPPORTED:
			return null
		Amf0Type.AMF0Type.XML_DOCUMENT:
			return self.ReadAmf0XmlDocument()
		Amf0Type.AMF0Type.TYPED_OBJECT:
			return self.ReadAmf0TypedObject()
		Amf0Type.AMF0Type.AMF3:
			return self.ReadAmf3()
		
	return null

func ReadAmf0String()->String:
	var length = self.ReadInt16()
	return self.ReadString(length)

func ReadAmf0LongString()->String:
	var length = self.ReadInt32()
	return self.ReadString(length)

func ReadAmf0Object():
	var value = Amf0Object.new()
	value.ClassName = ''
	value.DynamicMembersAndValues = {}
	
	self.objects.append(value)
	
	while true:
		
		var key = self.ReadAmf0String()
		
		if key.is_empty():
			self.Readbyte()
			break
		
		var data = ReadAmf0()
		
		value.DynamicMembersAndValues[key]=data
	
	return value.ToObject()

func ReadAmf0TypedObject():
	
	var ClassName = self.ReadAmf0String()
	
	var value = Amf0Object.new()
	value.ClassName = ClassName
	value.DynamicMembersAndValues = {}
	
	self.objects.append(value)
	
	while true:
		
		var key = self.ReadAmf0String()
		
		if key.is_empty():
			self.Readbyte()
			break
		
		var data = self.ReadAmf0()
		
		value.DynamicMembersAndValues[key]=data
	
	return value.ToObject()


func ReadAmf0ObjectReference():
	
	var reference = self.ReadInt32()
	
	return self.objects[reference]

func ReadAmf0Array()->Dictionary:
	
	var value={}
	
	var length = self.ReadInt32()
	
	for i in length:
		
		var key = self.ReadAmf0String()
		var data = self.ReadAmf0()
		
		value[key]=data
	
	return value

func ReadAmf0StrictArray()->Array:
	
	var value = []
	
	var length = self.ReadInt32()
	
	for i in length:
		
		var data = self.ReadAmf0()
		
		value.append(data)
	
	return value

func ReadAmf0Date()->DateTime:
	
	var milliseconds = self.ReadDouble() / 1000.0
	var timeZone = self.ReadInt16()
	
	var value = DateTime.new()
	value.Times = Time.get_date_dict_from_unix_time(milliseconds)
	return value

func ReadAmf0XmlDocument()->XmlDocument:
	var xml = self.ReadAmf0LongString()
	var value = XmlDocument.new()
	value.OuterXml = xml
	
	return value

func ReadAmf3():
	var type = self.Readbyte()
	
	match type:
		Amf3Type.AMF3Type.UNDEFINED:
			return null
		Amf3Type.AMF3Type.NULL:
			return null
		Amf3Type.AMF3Type.FALSE:
			return false
		Amf3Type.AMF3Type.TRUE:
			return true
		Amf3Type.AMF3Type.INTEGER:
			return self.ReadAmf3UInt29()
		Amf3Type.AMF3Type.DOUBLE:
			return self.ReadDouble()
		Amf3Type.AMF3Type.STRING:
			return self.ReadAmf3String()
		Amf3Type.AMF3Type.XML_DOC:
			return self.ReadAmf3XmlDocument()
		Amf3Type.AMF3Type.DATE:
			return self.ReadAmf3Date()
		Amf3Type.AMF3Type.ARRAY:
			return self.ReadAmf3Array()
		Amf3Type.AMF3Type.OBJECT:
			return self.ReadAmf3Object()
		Amf3Type.AMF3Type.XML:
			return self.ReadAmf3XmlDocument()
		Amf3Type.AMF3Type.BYTE_ARRAY:
			return self.ReadAmf3ByteArray()
		Amf3Type.AMF3Type.VECTOR_INT:
			return self.ReadAmf3Int32List()
		Amf3Type.AMF3Type.VECTOR_UINT:
			return self.ReadAmf3UInt32List()
		Amf3Type.AMF3Type.VECTOR_DOUBLE:
			return self.ReadAmf3DoubleList()
		Amf3Type.AMF3Type.VECTOR_OBJECT:
			return self.ReadAmf3ObjectList()
		Amf3Type.AMF3Type.DICTIONARY:
			return self.ReadAmf3Dictionary()
	
	return null


func ReadFlags()->PackedByteArray:
	var flags = []
	
	while true:
		
		var flag = self.Readbyte()
		flags.append(flag)
		
		if (flag & 0x80) == 0x00:
			break
		
	
	return flags


# 读取 AMF3 格式的 29 位整数（对应 C# 的 ReadAmf3UInt29 方法）
func ReadAmf3UInt29() -> int:
	# 读取第一个字节
	var value_a: int = self.Readbyte()  # 假设 read_byte() 是读取单字节的方法
	
	# 1 字节情况（值在 0-0x7F 范围内）
	if value_a <= 0x7F:
		return value_a
	
	# 读取第二个字节
	var value_b: int = self.Readbyte() 
	
	# 2 字节情况（第二个字节在 0-0x7F 范围内）
	if value_b <= 0x7F:
		return (value_a & 0x7F) << 7 | value_b
	
	# 读取第三个字节
	var value_c: int = self.Readbyte() 
	
	# 3 字节情况（第三个字节在 0-0x7F 范围内）
	if value_c <= 0x7F:
		return (value_a & 0x7F) << 14 | (value_b & 0x7F) << 7 | value_c
	
	# 4 字节情况（完整 29 位）
	var value_d: int = self.Readbyte() 
	var ret: int = (value_a & 0x7F) << 22 | (value_b & 0x7F) << 15 | (value_c & 0x7F) << 8 | value_d
	
	# 处理符号位（对应 C# 中的负数转换逻辑）
	if (ret & 0x10000000) == 0x10000000:  # 268435456 = 0x10000000
		ret |= -0x20000000  # -536870912 = -0x20000000
	return ret


func ReadAmf3String()->String:
	var reference = self.ReadAmf3UInt29()
	
	if (reference & 0x01) == 0x01:
		var length = reference >> 1
		var value = self.ReadString(length)
		self.strings.append(value)
		return value
	
	return self.strings[reference >> 1]

func ReadAmf3XmlDocument()->XmlDocument:
	var reference = self.ReadAmf3UInt29()
	
	if (reference & 0x01) == 0x01:
		var length = reference >> 1
		var xml = self.ReadString(length)
		var value = XmlDocument.new()
		value.OuterXml = xml
		self.objects.append(value)
		
		return value
	
	return self.objects[reference >> 1]

func ReadAmf3Date()->DateTime:
	var reference = self.ReadAmf3UInt29()
	
	if (reference & 0x01) == 0x01:
		
		var milliseconds = self.ReadDouble() / 1000.0
		var value = DateTime.new()
		value.Times = Time.get_date_dict_from_unix_time(milliseconds)
		
		self.objects.append(value)
		
		return value
		
	return self.objects[reference >> 1]

func ReadAmf3Array()->Amf3Array:
	var reference = self.ReadAmf3UInt29()
	
	if (reference & 0x01) == 0x01:
		
		var length = reference >> 1
		
		var value = Amf3Array.new()
		
		value.StrictDense = []
		value.SparseAssociative = {}
		
		self.objects.append(value)
		
		while true:
			
			var key = self.ReadAmf3String()
			
			if key.is_empty():
				break
			
			var data = self.ReadAmf3()
			value.SparseAssociative[key]=data
		
		for i in length:
			
			var data = self.ReadAmf3()
			value.StrictDense.append(data)
		
		return value
	
	return self.objects[reference >> 1]

func ReadAmf3Object():
	var reference = self.ReadAmf3UInt29()
	
	if (reference & 0x01) == 0x01:
		
		reference = reference >> 1
		
		var Tiait:Amf3Trait
		
		if (reference & 0x01) == 0x01:
			
			Tiait = Amf3Trait.new()
			
			reference = reference >> 1
			
			Tiait.IsExternalizable = (reference & 0x01) == 0x01
			
			reference = reference >> 1
			
			Tiait.IsDynamic = (reference & 0x01) == 0x01
			
			reference = reference >> 1
			
			var length = reference
			
			Tiait.ClassName = self.ReadAmf3String()
			
			self.traits.append(Tiait)
			
			for i in length:
				
				var member = self.ReadAmf3String()
				
				Tiait.Members.append(member)
			
		else:
			Tiait = self.traits[reference >> 1]
		
		var value = Amf3Object.new()
		value.Trait = Tiait
		value.Values = []
		value.DynamicMembersAndValues = {}
		
		self.objects.append(value)
		
		if Tiait.IsExternalizable:
			print("需手动实现外部化")
			pass
		else:
			
			for i in Tiait.Members.size():
				
				var data = self.ReadAmf3()
				value.Values.append(data)
			
			if Tiait.IsDynamic:
				
				while true:
					
					var key = self.ReadAmf3String()
					
					if key.is_empty():
						break
					
					var data = self.ReadAmf3()
					
					value.DynamicMembersAndValues[key]=data
				
		return value.ToObject()
		
	return self.objects[reference >> 1]

func ReadAmf3ByteArray()->PackedByteArray:
	var reference = self.ReadAmf3UInt29()
	
	if (reference & 0x01) == 0x01:
		
		var length = reference >> 1
		
		var value = []
		
		self.objects.append(value)
		
		for i in length:
			
			var data = self.Readbyte()
			
			value.append(data)
		
		return value
		
	return self.objects[reference >> 1]

func ReadAmf3Int32List()->Array[int]:
	var reference = self.ReadAmf3UInt29()
	
	if (reference & 0x01) == 0x01:
		
		var length = reference >> 1
		
		var fixedVector = self.ReadBoolean()
		
		var value:Array[int]=[]
		
		self.objects.append(value)
		
		for i in length:
			
			var data = self.ReadInt32()
			value.append(data)
		
		return value
		
	return self.objects[reference >> 1]


func ReadAmf3UInt32List()->Array[int]:
	var reference = self.ReadAmf3UInt29()
	
	if (reference & 0x01) == 0x01:
		
		var length = reference >> 1
		
		var fixedVector = self.ReadBoolean()
		
		var value:Array[int]=[]
		
		self.objects.append(value)
		
		for i in length:
			
			var data = self.ReadUInt32()
			value.append(data)
		
		return value
		
	return self.objects[reference >> 1]

func ReadAmf3DoubleList()->Array[float]:
	var reference = self.ReadAmf3UInt29()
	
	if (reference & 0x01) == 0x01:
		
		var length = reference >> 1
		
		var fixedVector = self.ReadBoolean()
		
		var value:Array[float]=[]
		
		self.objects.append(value)
		
		for i in length:
			
			var data = self.ReadDouble()
			value.append(data)
		
		return value
		
	return self.objects[reference >> 1]

func ReadAmf3ObjectList()->Array[Object]:
	var reference = self.ReadAmf3UInt29()
	
	if (reference & 0x01) == 0x01:
		
		var length = reference >> 1
		
		var fixedVector = self.ReadBoolean()
		
		var objectTypeName = self.ReadAmf3String()
		
		var value:Array[Object]=[] 
		
		self.objects.append(value)
		
		for i in length:
			
			var data = self.ReadAmf3()
			
			value.append(data)
		
		return value
		
	return self.objects[reference >> 1]

func ReadAmf3Dictionary()->Dictionary:
	var reference = self.ReadAmf3UInt29()
	
	if (reference & 0x01) == 0x01:
		
		var length = reference >> 1
		
		var weakKeys = self.ReadBoolean()
		
		var value:Dictionary={}
		
		self.objects.append(value)
		
		for i in length:
			
			var key = self.ReadAmf3()
			
			var data = self.ReadAmf3()
			
			value[key]=data
		
		return value
		
	return self.objects[reference >> 1]
