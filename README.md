# Godot4.4.1-ActionMessageFormat
适用于Godot引擎的ActionMessageFormat脚本 支持AMF3 AMF0协议的序列化和反序列化

# 编码示例

var Msg := AmfMessage.new()

var Body := AmfBody.new()

Body.TargetUri =  'api.user.login'
Body.ResponseUri = '/1'
Body.Content = [1,2,3]  #此处可以传入任意数据类型 包括自定义类

Msg.Bodys.append(Body)

var Write := AmfWriter.new()

Write.WriteAmfMessages(Msg)

var bytes = Write.Get_bytes()
或者
var bytes = Write.buffer.data_array


反序列化示例 在反序列化的时候，目前不支持创建自定义类，返回的Object 均转换为字典形式

var Read :+ AmfRead()

Read.Call_buffer(bytes)  此处传入字节数组

var Msg := Read.ReadMessage()




