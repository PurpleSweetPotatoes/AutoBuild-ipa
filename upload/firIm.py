#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2019-11-14 16:01:06
# @Author  : MrBai
# @Email   : 568604944@qq.com

import sys
import os
import shutil
import json
import requests
from uploadTools import iPdModel, DDTalk

class FirUpload(object):
    """docstring for FirUpload"""
    def __init__(self, token, filePath, info = "无更新说明"):
        super(FirUpload, self).__init__()
        self.token = token
        self.type = "ios"
        self.filePath = filePath
        self.info = info
        self.model = iPdModel(filePath)

    # 获取上传凭证
    def startUpload(self):
        print("**** 获取上传凭证 ****")
        url="http://api.bq04.com/apps"
        params = {
            "type":self.type,
            "bundle_id":self.model.identifier,
            "api_token":self.token
        }
        r = requests.post(url,data=json.dumps(params),headers={'Content-Type':'application/json'})
        result = r.json()
        if result["cert"] is None:
            print("获取上传凭证失败")
        else:
            self.loadUrl = "http://d.firim.top/"+result["short"]
            print("**** 上传app ****")
            self.uploadAppToFir(result["cert"]["binary"])

    # 上传app及icon
    def uploadAppToFir(self,cert):
        url = cert["upload_url"]
        appfile = {"file":open(self.filePath,"rb")}
        params = {
            "key":cert["key"],
            "token":cert["token"],
            "x:name":self.model.appName,
            "x:version":self.model.version,
            "x:build":self.model.build,
            "x:changelog":self.info
        }
        r = requests.post(url,data=params,files= appfile)
        result = r.json()
        if result["is_completed"] == True:
            print("**** 上传完成 ****")
            print("下载地址: %s" % self.loadUrl)
            print("**** 删除ipa文件包 ****")
            pathArr = os.path.split(self.filePath)
            shutil.rmtree(pathArr[0])
            params = {
                "msgtype":"link",
                "link":{
                    "title":self.model.appName + self.info,
                    "messageUrl":self.loadUrl,
                    "text":"请使用safari安装,此包仅供测试使用",
                    "picUrl":"http://blog-imgs.nos-eastchina1.126.net/1611903481.jpeg"
                }
            }
            DDTalk.sendMsg(params)

def main():
    # firim token
    firToken="xxxxxxxxxxx"
    ipaPath=sys.argv[1]
    info=sys.argv[2]
    fir = FirUpload(firToken, ipaPath, info)
    fir.startUpload()

if __name__ == '__main__':
    main()
