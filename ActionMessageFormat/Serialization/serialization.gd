class_name serialization extends ActionMessageFormat  

##标准化数据还原
static func Normalize(value):
	if value is IAmfObject:
		return value.ToObject()
	else:
		return value

##外部化数据还原
static func ToExternalizable(value:Object):
	return IExternalizable.Deserialization(value)

static func FromExternalizable(value:Object):
	return IExternalizable.Serialization(value)
