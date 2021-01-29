
startTime_s=`date +%s`

# 当前路径
curPath=`pwd`

# 导包参数路径
exportOptionsPlistPath=$curPath/options.plist

# 蒲公英上传文件路径
pgyPyPath=$curPath/pgyer.py

# fir上传文件路径
firPyPath=$curPath/firIm.py

# 进入打包项目文件夹
cd $2

# 工程名
project_name=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`

# scheme名
scheme_name=$project_name

# 导出.ipa文件所在路径
exportFilePath=~/Desktop/$scheme_name-ipa

# ipa导出路径
ipaPath=$exportFilePath/$scheme_name.ipa

if [[ $(($1%2)) == 0 ]]; then
    development_mode=Debug
    info="测试服"
else
    development_mode=Release
    info="正式服"
fi


# 打包操作
if [[ ! -d $exportFilePath ]]; then

    # 删除build包
    if [[ -d build ]]; then
        rm -rf build -r
    fi

    echo '*** 正在 清理工程 ***'
    xcodebuild clean -configuration ${development_mode} -quiet  || exit 
    echo '*** 清理完成 ***'


    echo '*** 正在 编译工程 For '${development_mode}
    xcodebuild archive -workspace ${project_name}.xcworkspace \
    -scheme ${scheme_name} -configuration ${development_mode} \
    -archivePath build/${project_name}.xcarchive -quiet  || exit
    echo '*** 编译完成 ***'


    echo '*** 正在 打包 ***'
    xcodebuild -exportArchive -archivePath build/${project_name}.xcarchive \
    -configuration ${development_mode} -exportPath ${exportFilePath} \
    -exportOptionsPlist ${exportOptionsPlistPath} \
    -allowProvisioningUpdates YES -quiet || exit

    endTime_s=`date +%s`
    sumTime=$[ $endTime_s - $startTime_s ]
    useTime=$[ $sumTime / 60 ]
    sumTime=$[ $sumTime % 60 ]

    echo "*** 打包完成,耗时: $useTime 分 $sumTime 秒 ***"

    # 删除build包
    if [[ -d build ]]; then
        rm -rf build -r
    fi
fi

# 上传操作
if [ -e $ipaPath ]; then
    echo "*** .ipa文件导出完成 ***"
    startTime_s=`date +%s`

    # 应用分发
    if [[ $development_mode == Debug ]]; then
        # 上传至firim
        echo "*** 准备上转至fir应用分发平台 ***"
        echo | python3 $firPyPath $ipaPath $info
    else
        # 上传蒲公英
        echo "*** 准备上转至蒲公英应用分发平台 ***"
        echo | python3 $pgyPyPath $ipaPath $info
    fi

    endTime_s=`date +%s`
    sumTime=$[ $endTime_s - $startTime_s ]
    useTime=$[ $sumTime / 60 ]
    sumTime=$[ $sumTime % 60 ]
    echo "*** 上传耗时: $useTime 分 $sumTime 秒 ***"

else
    echo "*** 创建.ipa文件失败 ***"
fi
