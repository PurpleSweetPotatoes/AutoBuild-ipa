# AutoBuild-ipa

iOS自动构建应用并上传至蒲公英或firim, 具体参看buildIpa.sh文件

## 语言 

> python3 shell 

三方库 requests(网络请求)

## 文件

+ buildIpa.sh 打包上传文件需配置`pgyToken`参数
+ options.plist 导出参数文件,可用xcode打包导出ipa后使用其中的plist配置即可,建议使用自动创建证书
+ firIm.py firim上传文件需配置`firToken`参数
+ uploadTools.py 辅助工具用于ipa信息读取和钉钉机器人消息发送,需配置`DDTalk.sendMsg`方法中`token`值(钉钉机器人的token),如不使用注释上传文件中sendMsg方法即可

## 使用

> 项目路径为*.xcodeproj上级目录

终端直接调用`buildIpa.sh`并追加2个参数,`$1`为数字,`$2`为对应项目路径

若无sh文件执行权限，可先执行`chmod +x sh文件路径`

```
# 0代表debug 1代表release
./buildIpa.sh 0 项目路径
```

