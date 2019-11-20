# AutoBuild-ipa

### 手动创建证书

####配置信息

DevelopmentExportOptionsPlist文件中的信息(打包方式，标识符及对应的描述文件名称)

将xcodebuild.sh中appName置换为项目工程名

#### 操作

1. 将xcodebuild及DevelopmentExportOptionsPlist文件放置于项目文件中和*.xcodeproj平级
2. 在终端中进入*.xcodeproj上级目录
3. 输入`./xcodebuild.sh`即可自动打包

### 自动创建证书

> 语言: shell python3 插件: requests 

> 应用分发使用蒲公英上传分发，文件中包含firim上传脚本可参照下列内容修改使用

####配置信息

+ options.plist: teamID(开发者teamID)
+ buildIpa: pgyToken(蒲公英账号apiToken) dingToken(钉钉机器人通知token,不填则不进行钉钉通知)

#### 操作

1. 将新版打包文件夹中内容放置于项目文件中和*.xcodeproj平级
2. 在终端中进入*.xcodeproj上级目录
3. 输入`./buildIpa.sh`即可自动打包

### 无sh文件执行权限

终端执行`chmod +x sh文件路径`
 