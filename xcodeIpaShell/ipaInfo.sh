
#!/bin/sh


# 使用方法
# source ipaInfo.sh
# loadIpaInfo ipa路径
# echo ${appName}
# echo ${appVersion}
# echo ${appBundleId}

appName=""
appVersion=""
appBundleId=""

loadIpaInfo() {
    basePath=$(cd "$(dirname "$0")";pwd)
    # echo "基础目录地址 basePath : $basePath"

    # ipa路径
    ipaFilePath=$1
    
    if [ ! -f "$ipaFilePath" ]; then
        echo "未找到ipa包 $ipaFilePath"
        exit 2
    fi

    # 当前ipa解压路径
    temIpaDirName="TempPayload"
    temIpaDirPath="${basePath}/${temIpaDirName}"
    # echo "临时解压路径: $temIpaDirPath"

    # 解包IPA
    if [[ -f "$ipaFilePath" ]]; then
        # echo "解压中到临时目录,请稍后..."
        # 不输出解压过程
        re=`unzip "$ipaFilePath" -d "$temIpaDirPath"`
    fi 

    # 定位到 *.app 目录及 info.plist
    appDir="$temIpaDirPath/Payload/`ls "$temIpaDirPath/"Payload`"
    lcmInfoPlist="${appDir}/Info.plist"
    # echo "info.plist文件路径 lcmInfoPlist : $lcmInfoPlist"

    # 获取app的名称、版本号、build号
    appName=`/usr/libexec/PlistBuddy -c "Print :CFBundleName" $lcmInfoPlist`
    appVersion=`/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" $lcmInfoPlist`
    # appBuild=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" $lcmInfoPlist`
    appBundleId=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" $lcmInfoPlist`

    # 删除临时解包目录
    if [ -d "$temIpaDirPath" ]; then
        # echo "删除临时解包目录 rm ${temIpaDirPath}"
        rm -rf "${temIpaDirPath}"
    fi
}
