startTime_s=`date +%s`

# 工程名
project_name=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`

# 蒲公英token
pgyToken=""

# 钉钉消息发送token
dingToken=""

exportOptionsPlistPath=./options.plist

if [[ $1 == 0 ]]; then
    development_mode=Debug
    info="测试服"
    
elif [[ $1 == 1 ]];then
    development_mode=Release
    info="正式服"
elif [[ $1 == 2 ]];then
    development_mode=JXJYDebug
    info="测试服"
elif [[ $1 == 3 ]];then
    development_mode=JXJYRelease
    info="正式服"
fi

# scheme名
scheme_name=$project_name

# 导出.ipa文件所在路径
exportFilePath=~/Desktop/$scheme_name-ipa

echo '*** 正在 清理工程 ***'
xcodebuild -UseModernBuildSystem=NO \
clean -configuration ${development_mode} -quiet  || exit 
echo '*** 清理完成 ***'


echo '*** 正在 编译工程 For '${development_mode}
xcodebuild \
archive -workspace ${project_name}.xcworkspace \
-scheme ${scheme_name} \
-configuration ${development_mode} \
-archivePath build/${project_name}.xcarchive \
-UseModernBuildSystem=NO -quiet  || exit
echo '*** 编译完成 ***'


echo '*** 正在 打包 ***'
xcodebuild -exportArchive -archivePath build/${project_name}.xcarchive \
-configuration ${development_mode} \
-exportPath ${exportFilePath} \
-exportOptionsPlist ${exportOptionsPlistPath} \
-quiet || exit

endTime_s=`date +%s`
sumTime=$[ $endTime_s - $startTime_s ]

useTime=$[ $sumTime / 60 ]
sumTime=$[ $sumTime % 60 ]

echo "*** 打包完成,耗时: $useTime 分 $sumTime 秒 ***"

# 删除build包
if [[ -d build ]]; then
    rm -rf build -r
fi

if [ -e $exportFilePath/$scheme_name.ipa ]; then
    echo "*** .ipa文件已导出 ***"
    # 应用分发
    echo | python3 pgyer.py $exportFilePath/$scheme_name.ipa $pgyToken $info $dingToken
else
    echo "*** 创建.ipa文件失败 ***"
fi


