#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2019-11-14 11:25:53
# @Author  : MrBai
# @Email   : 568604944@qq.com

import sys
import os
import shutil
import json
import requests
from uploadTools import iPdModel, DDTalk

class PgyUpload(object):
    """docstring for PgyUpload"""
    def __init__(self, token, ipaPath, updateInfo = "无更新信息", pwd = "123456"):
        super(PgyUpload, self).__init__()
        self.token = token
        self.ipaPath = ipaPath
        self.updateInfo = updateInfo
        self.pwd = pwd
        self.model = iPdModel(ipaPath)

    def uploadApp(self):
        # 蒲公英上传地址
        url = "https://www.pgyer.com/apiv2/app/upload"
        headers = {"enctype":"multipart/form-data"}
        apkfile = {"file":open(self.ipaPath,"rb")}
        params = {
            "_api_key":self.token,
            "buildInstallType":"2",
            "buildPassword":self.pwd,
            "buildUpdateDescription":self.updateInfo
        }
        print("**** 开始上传 请稍后 ****")
        r = requests.post(url,data=params,headers=headers,files=apkfile)
        result = r.json()
        if result["code"] == 0:
            print("**** 上传成功 ***")
            print("**** 下载地址 ****\n" + "https://www.pgyer.com/"+result["data"]["buildShortcutUrl"])
            print("**** 删除ipa文件包 ****")
            pathArr = os.path.split(sys.argv[1])
            shutil.rmtree(pathArr[0])
            self.sendMsgToDingtalk(result)            

    def sendMsgToDingtalk(self, result):
        shorUlr = "https://www.pgyer.com/" + result["data"]["buildShortcutUrl"]
        params = {
            "msgtype":"link",
            "link":{
                "title":self.model.appName + self.updateInfo,
                "messageUrl":shorUlr,
                "text":"请使用safari安装,此包仅供测试使用,安装密码:" + self.pwd,
                "picUrl":"http://blog-imgs.nos-eastchina1.126.net/1611908503.jpg"
            }
        }
        DDTalk.sendMsg(params)
        

if __name__ == '__main__':
    # 蒲公英token
    pgyToken="xxxxxxxxxxx"
    filePath=sys.argv[1]
    info=sys.argv[2]
    pgy = PgyUpload(pgyToken, filePath, info)
    pgy.uploadApp()

