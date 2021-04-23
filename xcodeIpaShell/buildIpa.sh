# !/bin/bash

# 使用方法
# buildModel 一般为 Debug 或 Release
# source buildIpa.sh
# build $1 $2 $3
# echo $exportFilePath

# 导包路径
exportFilePath=""

# 构建ipa包
build() {

    # 构建环境
    configuration=$1
    # 工程路径
    project_path=$2
    # 导包参数路径
    exportOptionsPlistPath=$3

    # 进入打包项目文件夹
    cd $project_path

    # 工程名 注意工程名须与scheme名一致否则需要单独配置scheme
    project_name=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`

    echo "***  开始打包 ${project_name} ***"

    # 导出.ipa文件所在路径
    exportFilePath=$project_path/$project_name-ipa

    # 打包操作
    if [[ ! -d $exportFilePath ]]; then

        # 删除build包
        if [[ -d build ]]; then
            rm -rf build -r
        fi

        echo "*** 正在 清理工程 ***"
        xcodebuild clean -configuration ${configuration} -quiet || return
        echo "*** 清理完成 ***"

        echo "*** 正在 编译打包工程 For ${configuration}"
        xcodebuild archive -workspace ${project_name}.xcworkspace -scheme $project_name -configuration ${configuration} -archivePath build/${project_name}.xcarchive -quiet || return
        echo "*** 编译打包完成 ***"

        echo "*** 正在 导出ipa文件 ***"
        xcodebuild -exportArchive -archivePath build/${project_name}.xcarchive -configuration ${configuration} -exportPath ${exportFilePath} -exportOptionsPlist ${exportOptionsPlistPath} -allowProvisioningUpdates YES -quiet || return
        echo "*** 导包完成 ***"

        # 删除build包
        if [[ -d build ]]; then
            rm -rf build -r
        fi

    else
        echo "*** 已有ipa包，继续操作 ***"
    fi
}