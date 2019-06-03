
iOS 打包流程
 
一、开发打包
 1.新建target
 	（1）复制target文件  
 		配置appicon图和loading图
 	（2）复制loadImg文件 
 		配置longing图
 		配置分享icon
 		配置邀请icon
 	（3）将配置好的target文件夹add到Xode中
 	（4）Xcode中Duplicate 新的Target
 		Build Phases中去除旧的bundleResource，添加新的资源（确认是15个）
 2.添加混淆文件
 3.配置Plist info
 	（1）bundleId
 	（2）版本号、build号
 	（3）display Name
 	（4）Channel
 	（5）BuglyId
 	（6）MobSMSAppID
 	（7）MobSMSSecret
 	（8）配置URL Types
 		QQ
 		Weixin
 		App URL
 		baicuan
 4.配置run Script（名称和渠道号一致）
 5.JPush创建配置，上传证书
 6.AppController 配置极光推送Key
 7.配置计费点信息
 8.Mac下打包
 	（1）确认混淆脚本路径正确，跑混淆脚本
 	（2）跑完混淆后，将混淆文件夹除第一个其他的文件add到Compile Source中（确认是2099个）
 	（3）AppStore包取消上报

 9.【后端】配置渠道信息，配置开关【测试】
 10.测试完成后，上传Appstore包

二、打热更包
	安卓：
		直接build，加密打开，然后上传update压缩文件到luasource后台。再删除相关游戏文件，打包为正式包。
	iOS：
		文件混淆，不删除游戏，然后将上传update压缩文件到luasource后台。再删除相关游戏文件，打包为正式包。


三、需要的资源
 	1.计费点及包信息
 	2.icon图（icon背景需要是透明的） 注意：Xcode9打包的包AppStore（1024尺寸），需要白底的
 	3.loading图，需要增加iPhoneX的loading（1125x2436）
 	4.其他要求
 	5.更换过审图片（路径：res/review/cn/ui下）
 	6.如果没有提供账号，需要提供打包证书、推送证书