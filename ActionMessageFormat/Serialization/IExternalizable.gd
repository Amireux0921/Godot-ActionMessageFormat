##自有实现 外部化 外部化读写必须继承此类 IExternalizable [hr]
##继承IExternalizable的子类必须要实现以下方法 方法名称必须一致 [hr]
class_name IExternalizable extends ActionMessageFormat

#序列化
static func Serialization(valuer:Object)->PackedByteArray:
	return []
#反序列化
static func Deserialization(valuer:Object):
	return null
