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
from iPdInfo import iPdModel


class PgyUpload(object):
    """docstring for PgyUpload"""
    def __init__(self, token, ipaPath, updateInfo, ddToken, pwd = "123456"):
        super(PgyUpload, self).__init__()
        self.token = token
        self.ipaPath = ipaPath
        self.updateInfo = updateInfo
        self.pwd = pwd
        self.ddToken = ddToken
        self.model = iPdModel(ipaPath)
        self.uploadCount = 3

    def uploadApp(self):
        # 蒲公英上传地址
        url = "https://www.pgyer.com/apiv2/app/upload"
        if self.uploadCount > 0:
            headers = {"enctype":"multipart/form-data"}
            apkfile = {"file":open(self.ipaPath,"rb")}
            params = {
                "_api_key":self.token,
                "buildInstallType":"2",
                "buildPassword":self.pwd,
                "buildUpdateDescription":self.updateInfo
            }
            print("**** 开始上传 ****")
            r = requests.post(url,data=params,headers=headers,files= apkfile)
            result = r.json()
            if result["code"] == 0:
                print("**** 上传成功 删除包文件 ***")
                print("**** 下载地址 ****\n" + "https://www.pgyer.com/"+result["data"]["buildShortcutUrl"])
                pathArr = os.path.split(sys.argv[1])
                shutil.rmtree(pathArr[0])
                if len(self.ddToken) > 0: 
                    self.sendMsgToDingtalk(result)
            else:
                print(result)
                print("尝试重新上传") 
                self.uploadCount -= 1
                self.uploadApp()
        else:
            print("无法上传，请手动上传")

    def sendMsgToDingtalk(self, result):
        iconUrl = "https://appicon.pgyer.com/image/view/app_icons/" + result["data"]["buildIcon"]
        shorUlr = "https://www.pgyer.com/" + result["data"]["buildShortcutUrl"]
        title = self.model.appName + self.updateInfo
        params = {
            "msgtype":"link",
            "link":{
                "title":title,
                "messageUrl":shorUlr,
                "text":"请使用safari安装,此包仅供测试使用,安装密码:" + self.pwd,
                "picUrl":iconUrl
            }
        }
        r = requests.post(url='https://oapi.dingtalk.com/robot/send?access_token='+self.ddToken,data=json.dumps(params),headers={'Content-Type':'application/json'})
        print(r.text)
        

if __name__ == '__main__':
    pgy = PgyUpload(sys.argv[2], sys.argv[1], sys.argv[3], sys.argv[4])
    pgy.uploadApp()

