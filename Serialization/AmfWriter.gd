##AmfWriter 提供将任意数据类型进行序列化,支持Godot原生类 和 class_name 自定义类的封装序列化
class_name AmfWriter extends ActionMessageFormat

var buffer:StreamPeerBuffer

var strings:PackedStringArray
var objects:Array[Variant]
var traits:Array[Amf3Trait]

var amf0References:Dictionary
var amf3References:Dictionary

var Timeverify:bool

##在首次实例化对象的时候 设置字节序 默认为大端序 用于网络传输 ，小端序通常用于本地存储  Timeverify默认为开启 自定义规则，开启于不开对于正常后端没有任何改变，只有魔改的后端才会进行时间戳校验
func _init(Endian:bool=true,Timeverify:bool=false) -> void:
	self.buffer = StreamPeerBuffer.new()
	self.buffer.big_endian = Endian
	self.Timeverify = Timeverify
	self.strings = []
	self.objects = []
	self.traits = []
	self.amf0References  = {}
	self.amf3References  = {}
	

func Get_bytes()->PackedByteArray:
	return self.buffer.data_array

func WriteByte(value:int):
	self.buffer.put_8(value)

func WriteBoolean(value:bool):
	self.buffer.put_8(value)

func WriteInt16(value:int):
	self.buffer.put_16(value)

func WriteUInt16(value:int):
	self.buffer.put_u16(value)

func WriteInt32(value:int):
	self.buffer.put_32(value)

func WriteUInt32(value:int):
	self.buffer.put_u32(value)

func WriteDouble(value:float):
	self.buffer.put_double(value)

func WriteString(value:String):
	self.buffer.put_data(value.to_utf8_buffer())

func WriteAmfMessages(value:AmfMessage):
	if value.Version:
		self.WriteInt16(3)
	else:
		self.WriteInt16(0)
	
	self.WriteAmfHeaders(value.Headers)
	self.WriteAmfBodys(value.Bodys)
	
	
	self.strings.clear()
	self.objects.clear()
	self.traits.clear()
	
func WriteAmfHeaders(value:Array):
	self.WriteInt16(value.size())
	
	for item in value:
		self.WriteString(item.Name)
		self.WriteBoolean(item.MustUnderstand)
		if self.Timeverify:
			self.WriteInt32(int(Time.get_unix_time_from_system())) 
		else:
			self.WriteInt32(-1)
		self.WriteAmf0(item.Content)

func WriteAmfBodys(value:Array):
	self.WriteInt16(value.size())
	
	for item in value:
		self.WriteAmf0String(item.TargetUri)
		self.WriteAmf0String(item.ResponseUri)
		if self.Timeverify:
			self.WriteInt32(int(Time.get_unix_time_from_system())) 
		else:
			self.WriteInt32(-1)
		
		self.WriteAmf0(item.Content)

func WriteAmf0(value:Variant):
	
	if value == null:
		self.WriteByte(Amf0Type.AMF0Type.NULL)
	elif value is float || value is int:
		self.WriteByte(Amf0Type.AMF0Type.NUMBER)
		self.WriteDouble(value)
	elif value is bool:
		WriteByte(Amf0Type.AMF0Type.BOOLEAN)
		WriteBoolean(value)
	elif value is String:
		var length = value.to_utf8_buffer().size()
		
		if length > AmfType.AmfType.AMF0_STRING_MAX_LENGTH:
			self.WriteByte(Amf0Type.AMF0Type.LONG_STRING)
			self.WriteAmf0LongString(value)
		else:
			self.WriteByte(Amf0Type.AMF0Type.STRING)
			self.WriteAmf0String(value)
		
	elif value is Amf0Object:
# 					核心问题 无限递归引用 Array Reference  子类继承父类，套娃引用 2025/8/7
#		if self.objects.has(value):
#			self.WriteByte(Amf0Type.AMF0Type.REFERENCE)
#			self.WriteAmf0ObjectReference(value)
#		else:
			
			if value.IsAnonymous:
				self.WriteByte(Amf0Type.AMF0Type.OBJECT)
				self.WriteAmf0Object(value)
			else:
				self.WriteByte(Amf0Type.AMF0Type.TYPED_OBJECT)
				self.WriteAmf0TypedObject(value)
		
	elif value is Dictionary:
		self.WriteByte(Amf0Type.AMF0Type.ECMA_ARRAY)
		self.WriteAmf0Array(value)
	elif value is Array:
		self.WriteByte(Amf0Type.AMF0Type.STRICT_ARRAY)
		self.WriteAmf0StrictArray(value)
	elif value is DateTime:
		self.WriteByte(Amf0Type.AMF0Type.DATE)
		self.WriteAmf0Date(value)
	elif value is XmlDocument:
		self.WriteByte(Amf0Type.AMF0Type.XML_DOCUMENT)
		self.WriteAmf0XmlDocument(value)
	else:
		WriteByte(Amf0Type.AMF0Type.AMF3)
		self.WriteAmf3(value)
		
		var amf0Rererence:Amf0Object
		
		if !self.amf0References.has(value):
			
			amf0Rererence = Amf0Object.new()
			amf0Rererence.ClassName = ''
			amf0Rererence.DynamicMembersAndValues = {}
			
			amf0Rererence.FromObject(value)
			
			self.amf0References[value]=amf0Rererence
			
		
		self.WriteAmf0(amf0Rererence)
		

func WriteAmf0String(value:String):
	self.WriteInt16(value.to_utf8_buffer().size())
	self.WriteString(value)

func WriteAmf0LongString(value:String):
	self.WriteInt32(value.to_utf8_buffer().size())
	self.WriteString(value)

func WriteAmf0Object(value:Amf0Object):
	
	self.objects.append(value)
	
	for item in value.DynamicMembersAndValues:
		self.WriteAmf0String(item)
		self.WriteAmf0(value.DynamicMembersAndValues[item])
	
	self.WriteAmf0String('')
	self.WriteByte(Amf0Type.AMF0Type.OBJECT_END)

func WriteAmf0TypedObject(value:Amf0Object):
	
	self.objects.append(value)
	
	self.WriteAmf0String(value.ClassName)
	
	for key in value.DynamicMembersAndValues:
		self.WriteAmf0String(key)
		self.WriteAmf0(value.DynamicMembersAndValues[key])
	
	self.WriteAmf0String('')
	self.WriteByte(Amf0Type.AMF0Type.OBJECT_END)

func WriteAmf0ObjectReference(value):
	self.WriteInt32(self.objects.find(value))

func WriteAmf0Array(value:Dictionary):
	self.WriteInt32(value.size())
	
	for key in value:
		self.WriteAmf0String(key)
		self.WriteAmf0(value[key])
	
	self.WriteAmf0String('')
	self.WriteByte(Amf0Type.AMF0Type.OBJECT_END)

func WriteAmf0StrictArray(value:Array[Variant]):
	self.WriteInt32(value.size())
	
	for item in value:
		self.WriteAmf0(item)
	

func WriteAmf0Date(value:DateTime):
	self.WriteDouble(Time.get_unix_time_from_datetime_dict(value.Times))
	self.WriteInt16(0)

func WriteAmf0XmlDocument(value:XmlDocument):
	WriteAmf0LongString(value.OuterXml)

func WriteAmf3(value:Variant):
	
	if value == null:
		self.WriteByte(Amf3Type.AMF3Type.NULL)
	elif value is bool:
		
		if value:
			self.WriteByte(Amf3Type.AMF3Type.TRUE)
		else:
			self.WriteByte(Amf3Type.AMF3Type.FALSE)
	elif value is int:
		
		if value < AmfType.AmfType.INT29_MIN_VALUE || value > AmfType.AmfType.INT29_MAX_VALUE:
			self.WriteByte(Amf3Type.AMF3Type.DOUBLE)
			self.WriteDouble(value)
		else:
			self.WriteByte(Amf3Type.AMF3Type.INTEGER)
			self.WriteAmf3UInt29(value)
	
	elif value is float:
		self.WriteByte(Amf3Type.AMF3Type.DOUBLE)
		self.WriteDouble(value)
	elif value is String:
		self.WriteByte(Amf3Type.AMF3Type.STRING)
		self.WriteAmf3String(value)
	elif value is XmlDocument:
		self.WriteByte(Amf3Type.AMF3Type.XML_DOC)
		self.WriteAmf3XmlDocument(value)
	elif value is DateTime:
		self.WriteByte(Amf3Type.AMF3Type.DATE)
		self.WriteAmf3Date(value)
	elif value is Amf3Array:
		self.WriteByte(Amf3Type.AMF3Type.ARRAY)
		self.WriteAmf3Array(value)
	elif value is Amf3Object:
		self.WriteByte(Amf3Type.AMF3Type.OBJECT)
		self.WriteAmf3Object(value)
	elif value is PackedByteArray:
		self.WriteByte(Amf3Type.AMF3Type.BYTE_ARRAY)
		self.WriteAmf3ByteArray(value)
	elif value is Array[int]:
		self.WriteByte(Amf3Type.AMF3Type.VECTOR_INT)
		self.WriteAmf3Int32List(value)
	#elif value is Array[]  godot 缺少uint判断 我自己也懒得写
	elif value is Array[float]:
		self.WriteByte(Amf3Type.AMF3Type.VECTOR_DOUBLE)
		self.WriteAmf3DoubleList(value)
	elif value is Array[Object]:
		self.WriteByte(Amf3Type.AMF3Type.VECTOR_OBJECT)
		self.WriteAmf3ObjectList(value)
	elif value is Dictionary:
		self.WriteByte(Amf3Type.AMF3Type.DICTIONARY)
		self.WriteAmf3Dictionary(value)
	else:
		var amf3Rererence:Amf3Object
		
		if !self.amf3References.has(amf3Rererence):
			
			amf3Rererence = Amf3Object.new()
			
			amf3Rererence.Trait.ClassName = ''
			amf3Rererence.Trait.IsDynamic = false 
			amf3Rererence.Trait.IsExternalizable = false
			amf3Rererence.Trait.Members = []
			
			amf3Rererence.FromObject(value)
			self.amf3References[value] = amf3Rererence
		
		self.WriteAmf3(amf3Rererence)

func WriteAmf3UInt29(value:int):
	value = value & 0x1FFFFFFF  # 确保29位范围
	
	if value < 0x80:            # 1字节范围 [0, 0x7F]
		self.WriteByte(value)
	elif value < 0x4000:        # 2字节范围 [0x80, 0x3FFF]
		self.WriteByte(0x80 | (value >> 7))
		self.WriteByte(value & 0x7F)
	elif value < 0x200000:      # 3字节范围 [0x4000, 0x1FFFFF]
		self.WriteByte(0x80 | (value >> 14))
		self.WriteByte(0x80 | ((value >> 7) & 0x7F))
		self.WriteByte(value & 0x7F)
	else:                       # 4字节范围 [0x200000, 0x1FFFFFFF]
		self.WriteByte(0x80 | (value >> 22))
		self.WriteByte(0x80 | ((value >> 15) & 0x7F))
		self.WriteByte(0x80 | ((value >> 8) & 0x7F))
		self.WriteByte(value & 0xFF)  # 直接写入低8位
	

func WriteAmf3String(value:String):
	
	if value != '':
		
		if !self.objects.has(value):
			
			self.strings.append(value)
			
			self.WriteAmf3UInt29(value.to_utf8_buffer().size() << 1 | 0x01)
			
			self.WriteString(value)
		else:
			self.WriteAmf3UInt29(self.objects.find(value) << 1 | 0x00)
	else:
		self.WriteAmf3UInt29(value.to_utf8_buffer().size() << 1 | 0x01)
		
		self.WriteString(value)

func WriteAmf3XmlDocument(value:XmlDocument):
	if !self.objects.has(value):
		self.objects.append(value)
		self.WriteAmf3UInt29(value.OuterXml.to_utf8_buffer().size() << 1 | 0x01)
		self.WriteString(value.OuterXml)
	else:
		self.WriteAmf3UInt29(self.objects.find(value) << 1 | 0x00)

func WriteAmf3Date(value:DateTime):
	
	if !self.objects.has(value):
		self.objects.append(value)
		self.WriteAmf3UInt29(0x01)
		self.WriteDouble(Time.get_unix_time_from_datetime_dict(value.Times))
	else:
		self.WriteAmf3UInt29(self.objects.find(value) << 1 | 0x00)

func WriteAmf3Array(value:Amf3Array):
	
	if !self.objects.has(value):
		
		self.objects.append(value)
		
		self.WriteAmf3UInt29(value.StrictDense.size() << 1 | 0x01)
		
		for item in value.SparseAssociative:
			self.WriteAmf3String(item)
			self.WriteAmf3(value.SparseAssociative[item])
		
		self.WriteAmf3String('')
		
		for item in value.StrictDense:
			self.WriteAmf3(item)
	else:
		
		self.WriteAmf3UInt29(self.objects.find(value) << 1 | 0x00)

func WriteAmf3Object(value:Amf3Object):
	
	if !self.objects.has(value):
		
		self.objects.append(value)
		
		if !self.traits.has(value.Trait):
			var members_count = 0
			if not value.Trait.IsExternalizable:
				members_count = value.Trait.Members.size()
			var members_part = members_count << 4
		
			var dynamic_part = 0
			if value.Trait.IsDynamic:
				dynamic_part = 0x01 << 3
		
			var externalizable_part = 0
			if value.Trait.IsExternalizable:
				externalizable_part = 0x01 << 2
		
			var fixed_part1 = 0x01 << 1
			var fixed_part2 = 0x01
		
			var total_value = members_part | dynamic_part | externalizable_part | fixed_part1 | fixed_part2
		
			self.WriteAmf3UInt29(total_value)
			self.WriteAmf3String(value.Trait.ClassName)
		
			if !value.Trait.IsExternalizable:
				
				for item in value.Trait.Members:
					self.WriteAmf3String(item)
				
		else:
			self.WriteAmf3UInt29(self.traits.find(value.Trait) << 2 | 0x00 << 1 | 0x01)
				
			
		if value.Trait.IsExternalizable:
			var externizable = value.to_string()
			pass
		else:
			
			for item in value.Values:
				
				self.WriteAmf3(item)
			
			if value.Trait.IsDynamic:
				
				for item in value.DynamicMembersAndValues:
					
					self.WriteAmf3String(item)
					self.WriteAmf3(value.DynamicMembersAndValues[item])
				
				self.WriteAmf3String('')
				
	else:
		self.WriteAmf3UInt29(objects.find(value) << 1 | 0x00)

func WriteAmf3ByteArray(value:PackedByteArray):
	
	if !self.objects.has(value):
		
		self.objects.append(value)
		
		self.WriteAmf3UInt29(value.size() << 1 | 0x01)
		
		for i in value:
			self.WriteByte(i)
	else:
		self.WriteAmf3UInt29(objects.find(value) << 1 | 0x00)

func WriteAmf3Int32List(value:Array[int]):
	
	if !self.objects.has(value):
		
		self.objects.append(value)
		
		self.WriteAmf3UInt29(value.size() << 1 | 0x01)
		self.WriteBoolean(false)
		
		for i in value:
			self.WriteInt32(i)
	else:
		self.WriteAmf3UInt29(objects.find(value) << 1 | 0x00)

func WriteAmf3UInt32List(value:Array[int]):
	
	if !self.objects.has(value):
		
		self.objects.append(value)
		
		self.WriteAmf3UInt29(value.size() << 1 | 0x01)
		self.WriteBoolean(false)
		
		for i in value:
			self.WriteUInt32(i)
	else:
		self.WriteAmf3UInt29(objects.find(value) << 1 | 0x00)

func WriteAmf3DoubleList(value:Array[float]):
	if !self.objects.has(value):
		
		self.objects.append(value)
		
		self.WriteAmf3UInt29(value.size() << 1 | 0x01)
		self.WriteBoolean(false)
		
		for i in value:
			self.WriteDouble(i)
	else:
		self.WriteAmf3UInt29(objects.find(value) << 1 | 0x00)

func WriteAmf3ObjectList(value:Array):
	
	if !self.objects.has(value):
		
		self.objects.append(value)
		
		self.WriteAmf3UInt29(value.size() << 1 | 0x01)
		self.WriteBoolean(false)
		self.WriteAmf3String('*')
		for i in value:
			self.WriteAmf3(i)
	else:
		self.WriteAmf3UInt29(objects.find(value) << 1 | 0x00)


func WriteAmf3Dictionary(value:Dictionary):
	
	if !self.objects.has(value):
		
		self.objects.append(value)
		
		self.WriteAmf3UInt29(value.size() << 1 | 0x01)
		self.WriteBoolean(false)
		for key in value:
			self.WriteAmf3(key)
			self.WriteAmf3(value[key])
	else:
		self.WriteAmf3UInt29(objects.find(value) << 1 | 0x00)
