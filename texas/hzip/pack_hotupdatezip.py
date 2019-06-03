#coding=utf8
import os
import shutil
import zipfile
import sys
import re
import xml.dom.minidom
import time
import codecs

timetag=time.strftime('%Y-%m-%d_%H%M%S',time.localtime(time.time()))
dirname="hzip"
zipfilename="update"+timetag+".zip"
def mkdir(dir):
    try:
        os.makedirs(dir)
        print(" -- mkdir " + dir + " success !")
    except Exception, e:
        pass

def removeDir(dir):
    try:
        shutil.rmtree(dir, ignore_errors=True)
    except Exception, e:
        print(e)

def deleteLua(file):
    if os.path.isfile(file) is True and re.match('.*\.(lua)$', file):
        print "--- delete lua = " + file
        os.remove(file)


def removeLua(dir):
    if os.path.isfile(dir):
        deleteLua(dir)
    elif os.path.isdir(dir):
        for item in os.listdir(dir):
            itemsrc = os.path.join(dir,item)
            removeLua(itemsrc)
def copyDir(src,dest):
	shutil.copytree(src,dest)

def compileLua(src):
    os.system('cocos luacompile -s %s -d %s' % (fullPath(src),fullPath(src)))

def fullPath(dir):
    return os.path.abspath(dir)



def doZip(zipfp,path):
    for dirpath, dirnames, filenames in os.walk(path, True):
        for filaname in filenames:
            filet = os.path.join( dirpath , filaname )
            print 'Add... ' + filet
            zipfp.write(filet)

if __name__ == '__main__':
    removeDir("res")
    removeDir("src")
    copyDir("../res","res")
    copyDir("../src","src")
    compileLua("src")
    removeLua("src")
    zipfp = zipfile.ZipFile(zipfilename,'a',zipfile.ZIP_DEFLATED)
    doZip(zipfp,"src")
    doZip(zipfp,"res")
    zipfp.close()
    removeDir("res")
    removeDir("src")
