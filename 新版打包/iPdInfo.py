#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2019-11-14 17:22:47
# @Author  : MrBai
# @Email   : 568604944@qq.com

import zipfile
import re
import plistlib

class iPdModel(object):
    """docstring for iPdModel"""
    def __init__(self, ipaPath):
        super(iPdModel, self).__init__()
        self.ipaPath = ipaPath
        self.getInfo()

    def getInfo(self):
        ipa_file = zipfile.ZipFile(self.ipaPath)
        plist_path = self.find_path(ipa_file, 'Payload/[^/]*.app/Info.plist')
        # 读取plist内容
        plist_data = ipa_file.read(plist_path)
        # 解析plist内容
        plist_info = plistlib.loads(plist_data)
        
        # 获取plist信息
        self.appName = plist_info['CFBundleDisplayName']
        self.identifier = plist_info['CFBundleIdentifier']
        self.version = plist_info['CFBundleShortVersionString']
        self.build = plist_info['CFBundleVersion']

    # 获取plist路径
    def find_path(self, zip_file, pattern_str):
        name_list = zip_file.namelist()
        pattern = re.compile(pattern_str)
        for path in name_list:
            m = pattern.match(path)
            if m is not None:
                return m.group()


if __name__ == '__main__':
    model = iPdModel("/Users/teach/Desktop/CloudEye-ipa/CloudEye.ipa")
    print(model.appName, model.identifier, model.version, model.build)