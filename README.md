# AutoBuild-ipa

> 对于M1脚本打包会出现不包含此设备的错误描述
> [解决方案](https://developer.apple.com/forums/thread/668952) xcodebuild archive 中添加 `-destination 'generic/platform=iOS'`即可

iOS自动构建应用并上传至蒲公英或firim或appstore

## xcodeIpaShell

> shell脚本编写，无需依赖环境，需要对应执行权限
>
> 可在任意路径下执行，建议导出配置使用自动构建证书方式，方便快捷

**注意**

1. 工程scheme名称须与工程名相同，对应`buildIpa.sh`文件
2. 上传测试应用后会发送对应的钉钉机器人消息，对应`uploadIpa.sh`文件
3. 如导包配置为app-store方式，会自动上传至应用商店，对应`uploadIpa.sh`文件
4. 脚本内部直接使用`xcworkspace`方式打包，对应`buildIpa.sh`文件

**文件目录结构**

```sh
xcodeIpaShell
├── buildIpa.sh 		# 构建脚本
├── ipaInfo.sh 			# 应用信息查询脚本
├── start.sh 				# 脚本入口
└── uploadIpa.sh		# 应用上传脚本
```

**使用**

`sh 脚本入口路径 构建环境 工程路径 导包plist文件路径`

+ 脚本入口路径:  start.sh路径
+ 构建环境: 一般为Debug或Release
+ 工程路径: *.xcodeproj所在目录
+ 导包plist文件路径：ipa包导出配置plist文件

## upload

### 环境 

> python3、requests，此脚本不包含appstore上传

#### 文件

+ buildIpa.sh 打包上传文件需配置`pgyToken`参数
+ options.plist 导出参数文件,可用xcode打包导出ipa后使用其中的plist配置即可,建议使用自动创建证书
+ firIm.py firim上传文件需配置`firToken`参数
+ uploadTools.py 辅助工具用于ipa信息读取和钉钉机器人消息发送,需配置`DDTalk.sendMsg`方法中`token`值(钉钉机器人的token),如不使用注释上传文件中sendMsg方法即可

#### 使用

> 项目路径为*.xcodeproj上级目录

终端直接调用`buildIpa.sh`并追加2个参数,`$1`为数字($1%2,0为debug,1为Release),`$2`为对应项目路径

若不想使用环境参数 可以直接修改`buildIpa`文件内容

若无sh文件执行权限，可先执行`chmod +x sh文件路径`

```
# 0代表debug 1代表release
./buildIpa.sh 0 项目路径
```
