# !/bin/bash

# 使用方式 
# 进入start.sh路径
# sh start.sh Debug|Release 工程路径 导出参数plist文件路径

outStr="耗时统计:\n"

buildModel=$1
project_path=$2
exportOptionsPlistPath=$3

ipaDirPath=""

# 脚本路径
shellPath=$(cd "$(dirname "$0")";pwd)

# 耗时统计
useTime() {
    startTime_s=`date +%s`
    $2
    endTime_s=`date +%s`
    sumTime=$[ $endTime_s - $startTime_s ]
    useTime=$[ $sumTime / 60 ]
    sumTime=$[ $sumTime % 60 ]
    outStr="$outStr$1 耗时: $useTime 分 $sumTime 秒\t"
}

# mac弹窗提醒脚本执行完毕
showNotify() {
    osascript -e "display notification \"$outStr\" sound name \"Ping\""
}

startBuildIpa() {
    source $shellPath/buildIpa.sh
    build $buildModel $project_path $exportOptionsPlistPath
    ipaDirPath=$exportFilePath
}

uploadIpa() {
    method=`/usr/libexec/PlistBuddy -c "Print :method" $exportOptionsPlistPath`
    # 进入包路径
    cd $ipaDirPath
    ipaName=`find . -name *.ipa | awk -F "[/.]" '{print $(NF-1)}'`
    ipaPath=$ipaDirPath/$ipaName.ipa

    source $shellPath/uploadIpa.sh
    if [[ $method == "app-store" ]]; then
        appStroeUpload $ipaPath
    else 
        if [[ $buildModel == "Debug" ]]; then
            firimUpload $ipaPath
        else
            pgyUpload $ipaPath
        fi
    fi

    # 上传成功删除ipa文件夹
    if [[ $? == 0 ]]; then
        echo "*** 删除ipa文件夹 ***"
        rm -rf $ipaDirPath
    fi

}

autoBuild() {
    # 打包
    useTime "打包" startBuildIpa

    useTime "上传" uploadIpa

    # 完成提示
    showNotify
}

useTime "总计" autoBuild

