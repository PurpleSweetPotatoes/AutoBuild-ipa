# !/bin/bash

# 应用信息
ipaName=""
ipaVersion=""
ipaId=""

# 上传url
pgyUrl="https://www.pgyer.com/apiv2/app/upload"
firimUrl="http://api.bq04.com/apps"

# 图标信息
pgyIcon=""
firIcon=""

# 钉钉消息参数
ipaUrl=""
ipaType=""
iconUrl=""
pwdMsg=""

# 平台秘钥信息
pgyToken=""

firimToken=""

appStoreKey=""
appStoreIssuer=""

pgyUpload() {
    getIpaInfo $1
    echo "*** 正在上传至蒲公英,请稍后... ***"
    re=`curl -F "file=@$1" -F "_api_key=$pgyToken" $pgyUrl`
    # 替换掉回车
    result=`echo $re | sed 's/\n//g'`
    # 获取上传结果码
    code=`echo $result | sed 's/.*code":\(0\).*/\1/g'`
    if [[ $code == 0 ]]; then
        # 获取上传短链接
        shortUrl=`echo $result | sed 's/.*buildShortcutUrl":"\(....\)",.*/\1/g'`
        ipaUrl="https://www.pgyer.com/$shortUrl"
        ipaType="正式服"
        iconUrl=$pgyIcon
        pwdMsg="\n安装密码123456"
        # 发送钉钉消息
        sendDingTalk
        echo "*** 上传成功 ***"
        return 0
    else
        echo "*** 上传失败 ***"
        echo "$re"
        return 1
    fi
}

firimUpload() {
    getIpaInfo $1

    echo "*** 正在上传至Firim,请稍后... ***"
    echo "**** 获取上传凭证 ****"

    upInfo=`curl -X "POST" "$firimUrl" \
     -H "Content-Type: application/json" \
     -d "{\"type\":\"ios\", \"bundle_id\":\"$ipaId\", \"api_token\":\"$firimToken\"}"`

    binary=`echo $upInfo | sed 's/.*binary":\([^}]*}}\).*/\1/g'`
    # 得到匹配结果，不为原数据
    if [[ $binary != $upInfo ]]; then
        echo "**** 开始上传应用 ****"
        short=`echo $upInfo | sed 's/.*short":"\([^"]*\).*/\1/g'`
        ipaUrl="http://d.firim.top/$short"
        uploadUrl=`echo $binary | sed 's/.*upload_url":"\([^"]*\).*/\1/g'`
        key=`echo $binary | sed 's/.*key":"\([^"]*\).*/\1/g'`
        token=`echo $binary | sed 's/.*token":"\([^"]*\).*/\1/g'`

        ipaType="测试服"

        re=`curl --http1.1 -F "key=$key" -F "token=$token" -F "file=@$1" -F "x:name=$ipaName" -F "x:version=$ipaVersion" -F "x:build=1" -F "x:changelog=$ipaType" $uploadUrl`

        completed=`echo $re | sed 's/.*is_completed":\([^},"]*\).*/\1/g'`
        if [[ $completed == true ]]; then
            echo "**** 上传完成****"
            iconUrl=$firIcon
            sendDingTalk
            echo "*** 上传成功 ***"
            return 0
        else
            echo "*** 上传失败 ***"
            return 1
        fi 
    else
        echo "*** 上传失败 ***"
        return 1
    fi
}

appStroeUpload() {
    echo "*** 正在上传至appStroe,请稍后... ***"

    # # 验证(可忽略)
    # validate=`xcrun altool --validate-app -f $exportFilePath/$scheme_name.ipa -t ios --apiKey $key --apiIssuer $issuer --verbose`
    # result=`echo $validate | grep "No errors" |wc -l`

    # 上传
    upload=`xcrun altool --upload-app -f $1  -t ios --apiKey $appStoreKey --apiIssuer $appStoreIssuer --verbose`
    result=`echo $upload | grep "No errors" | wc -l`
    if [ $result == 1 ]; then
        echo "*** 上传成功 ***"
        return 0
    else
        echo "*** 上传失败 ***"
        return 1
    fi
}

getIpaInfo() {
    # 获取应用信息
    echo "*** 正在获取应用信息 ***"
    shellPath=$(cd "$(dirname "$0")";pwd)
    source $shellPath/ipaInfo.sh
    loadIpaInfo $1
    ipaName=$appName
    ipaVersion=$appVersion
    ipaId=$appBundleId
    echo "应用:$ipaName\n版本号:$ipaVersion\n标识符:$ipaId"
}

sendDingTalk() {

    echo "应用下载链接: $ipaUrl"

    echo "*** 发送钉钉消息 ***"
    # 配置消息
    msg="{\"msgtype\":\"link\",\"link\":{\"title\":\"${ipaName}${ipaType}(${ipaVersion})\",\"messageUrl\":\"$ipaUrl\",\"text\":\"请使用safari安装,此包仅供测试使用$pwdMsg\",\"picUrl\":\"$iconUrl\"}}"
    # 上传完成 发送钉钉消息
    curl 'https://oapi.dingtalk.com/robot/send?access_token=xxxx' \
    -H 'Content-Type: application/json' \
    -d $msg
}
