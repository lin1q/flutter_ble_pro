# flutter_ble_pro

一个基于flutter_blue_plus的蓝牙功能app.

## Getting Started

修改checkIsNeedDevice方法里的前缀，过滤出需要的蓝牙设备，也可以不过滤。
发现设备后经过连接设备、发现服务、匹配特征、订阅消息(这部分操作在匹配特征的时候进行了)后
就可以写入数据了。
当然数据加密加密随便了。