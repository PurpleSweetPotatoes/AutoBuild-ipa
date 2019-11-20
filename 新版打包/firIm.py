#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2019-11-14 16:01:06
# @Author  : MrBai
# @Email   : 568604944@qq.com

import sys
import os
import json
import requests
from iPdInfo import iPdModel

class FirUpload(object):
    """docstring for FirUpload"""
    def __init__(self, token, appName, bundleId, filePath, version, buildVersion, type, info = "无更新说明"):
        super(FirUpload, self).__init__()
        self.token = token
        self.appName = appName
        self.type = type
        self.bundleId = bundleId
        self.filePath = filePath
        self.version = version
        self.buildVersion = buildVersion
        self.info = info

    # 获取上传凭证
    def startUpload(self):
        print("**** 获取上传凭证 ****")
        url="http://api.fir.im/apps"
        params = {
            "type":self.type,
            "bundle_id":self.bundleId,
            "api_token":self.token
        }
        r = requests.post(url,data=json.dumps(params),headers={'Content-Type':'application/json'})
        result = r.json()
        if result["cert"] is None:
            print("获取上传凭证失败")
        else:
            print(result["cert"])
            self.loadUrl = "https://fir.im/"+result["short"]
            print("**** 上传app ****")
            self.uploadAppToFir(result["cert"]["binary"])

    # 上传app及icon
    def uploadAppToFir(self,cert):
        url = cert["upload_url"]
        appfile = {"file":open(self.filePath,"rb")}
        params = {
            "key":cert["key"],
            "token":cert["token"],
            "x:name":self.appName,
            "x:version":self.version,
            "x:build":self.buildVersion,
            "x:changelog":self.info
        }
        r = requests.post(url,data=params,files= appfile)
        result = r.json()
        if result["is_completed"] == True:
            print("**** 上传完成 ****")
            print("下载地址: %s" % self.loadUrl)

def unzip_ipa(path):
    ipa_file = zipfile.ZipFile(path)
    plist_path = find_path(ipa_file, 'Payload/[^/]*.app/Info.plist')
    # 读取plist内容
    plist_data = ipa_file.read(plist_path)
    # 解析plist内容
    plist_detail_info = plistlib.loads(plist_data)
    # 获取plist信息
    get_ipa_info(plist_detail_info)

# 获取plist路径
def find_path(zip_file, pattern_str):
    name_list = zip_file.namelist()
    pattern = re.compile(pattern_str)
    for path in name_list:
        m = pattern.match(path)
        if m is not None:
            return m.group()

# 获取ipa信息
def get_ipa_info(plist_info):
    # print('软件信息: %s' % str(plist_info))
    fir = FirUpload("0c1267fcd8981adc9fc3f9f6d729a60f",plist_info['CFBundleDisplayName'],plist_info['CFBundleIdentifier'],"/Users/teach/Desktop/CloudEye-ipa/CloudEye.ipa",plist_info['CFBundleShortVersionString'],plist_info['CFBundleVersion'],"ios")
    fir.startUpload()


def main():
    # model = iPdModel("/Users/teach/Desktop/CloudEye-ipa/CloudEye.ipa")
    # print(model.appName, model.identifier, model.version, model.build)
    pass

if __name__ == '__main__':
    main()
