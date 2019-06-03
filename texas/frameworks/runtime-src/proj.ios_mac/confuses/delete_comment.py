#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re

# 需要改的文件目录
deal_ios_Dir = './proj.ios_mac/ios'
deal_class_dir = './Classes'
dealFileType = set(['.h', '.m', '.mm'])

# 获取某个目录下所有文件
def getFileList(rootDirPath):
    fileList = []
    for dirpath,dirnames,filenames in os.walk(rootDirPath):
        for file in filenames:
            fullpath=os.path.join(dirpath,file)
            fileList.append(fullpath)
    return fileList

# 正则去除注释
def deleteComments(contents):
    newContents = re.sub('(\/\*(\s|.)*?\*\/)|(\/\/.*)', "", contents)
    if 'http' in contents:
        newContents = contents;
    return newContents

# 处理文件
def dealFile(workDir):
    for filePath in getFileList(workDir):
        fileDir, fileName = os.path.split(filePath)
        fileNameTxt, fileEx = os.path.splitext(fileName)
        if fileEx in dealFileType:
            print filePath
            with open(filePath, "r") as f:
                content = f.read()
                newContent = deleteComments(content)
                if  newContent != content:
                    with open(filePath, 'w') as f2:
                        f2.write(newContent)

def main():
    print '-------->>>>>start deal ios dir'
    dealFile(deal_ios_Dir)
    print '-------->>>>>start deal Class dir'
    dealFile(deal_class_dir)
    print '-------->>>>>deleteComments sucess！<<<<<-----------'

if __name__ == '__main__':
    main()
