#!/usr/bin/env python
# -*- coding: utf-8 -*-


"""
key_list.txt 中定义了需要替换的关键字列表，每行的格式为:

key
key,len

如果只有一个key，代表函数替换
如果后面跟着一个len，则是长度为len的随机字符串

生成的结果导出到code_confuse.h

格式为:

#define key value
"""

import uuid
import random


KEY_LIST_FILENAME = './proj.ios_mac/confuses/key_list.txt'
OUTPUT_FILENAME = './proj.ios_mac/confuses/code_confuse.h'

OUTPUT_LINE_TPL = '#define {key} {value}\n'


def genstr(length):
    chars = 'abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)'
    return ''.join([random.choice(chars) for i in xrange(length)])


def main():
    output_list = []

    head_guard = '__CODE_CONFUSE_H_%s__' % random.randint(0, 2100000000)

    output_list.append('#ifndef %s\n' % head_guard)
    output_list.append('#define %s\n\n' % head_guard)

    for line in open(KEY_LIST_FILENAME, 'r'):
        key_tuple = line.split(',')

        if not key_tuple:
            continue

        key = key_tuple[0].strip()

        if len(key_tuple) == 1:
            value = 'f_' + uuid.uuid4().hex
        else:
            value = '"' + genstr(int(key_tuple[1])) + '"'

        output_list.append(OUTPUT_LINE_TPL.format(key=key, value=value))

    output_list.append('\n#endif\n')

    with open(OUTPUT_FILENAME, 'w') as f:
        f.writelines(output_list)

    print 'done'


if __name__ == '__main__':
    main()
