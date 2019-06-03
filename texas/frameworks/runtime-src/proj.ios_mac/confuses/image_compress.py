
#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import platform

def compress():
    os.system('find proj.ios_mac/LoadingImg/ -iname "*.png" -exec echo {} \; -exec convert {} {} \;')
    os.system('find proj.ios_mac/target/ -iname "*.png" -exec echo {} \; -exec convert {} {} \;')

def main():
    print 'image compress begin --->>'
    compress()
    print 'image compress successful!---<<< end'


if __name__ == '__main__':
    main()
