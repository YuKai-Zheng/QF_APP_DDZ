# coding: utf8

"""
生成假的数据到指定目录
"""

import os
import random
import uuid
import sys
import shutil

SUFIX_LIST = ('png', 'jpg', 'json', 'lua')


def genstr(length):
    chars = 'abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)'
    return ''.join([random.choice(chars) for i in xrange(length)])


def create_fake_data(dst_dir, total_size, min_file_num, max_file_num):
    """
    生成数据
    :param dst_dir: 指定目录
    :param total_size: 一共多大
    :param min_file_num: 最少多少个文件
    :param max_file_num: 最多多少个文件
    :return:
    """

    # 如果目录不存在，要创建目录

    if os.path.exists(dst_dir):
        # 如果已经有这个目录，要进行删除
        if os.path.isfile(dst_dir):
            raise Exception('dst_dir is path. dst_dir: %s' % dst_dir)
        else:
            shutil.rmtree(dst_dir)

    # 重新创建
    os.makedirs(dst_dir)

    file_num = random.randint(min_file_num, max_file_num)

    remain_size = total_size
    avg_file_size = int(total_size / file_num)

    for i in xrange(0, file_num):

        if remain_size <= 0:
            break

        filename = os.path.join(dst_dir, uuid.uuid4().hex + '.' + random.choice(SUFIX_LIST))

        file_size = random.randint(int(avg_file_size/5*3), int(avg_file_size/5*7))
        remain_size -= file_size

        with open(filename, 'wb') as f:
            f.write(genstr(file_size))


def main():
    if len(sys.argv) < 5:
        print 'please input: dst_dir, total_size(M), min_file_num, max_file_num'
        return

    create_fake_data(
        sys.argv[1],
        int(sys.argv[2]) * 1024 * 1024,
        int(sys.argv[3]),
        int(sys.argv[4]),
    )

    print 'done'


if __name__ == '__main__':
    main()
