#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import hashlib
import argparse
import zipfile


def process(base_dir, src_path_list, dst_dir, filename):
    # 这样可以确保写入md5的路径是相对的
    os.chdir(base_dir)

    if not os.path.exists(dst_dir):
        os.makedirs(dst_dir)

    dst_file_path = os.path.join(dst_dir, filename)
    zfile = zipfile.ZipFile(dst_file_path, 'w')

    def walk_cb(zfile, dirname, names):
        for name in names:
            path = os.path.join(dirname, name)
            if os.path.isfile(path):
                zfile.write(path)

    for src_path in src_path_list:
        if os.path.isfile(src_path):
            zfile.write(src_path)
        else:
            os.path.walk(src_path, walk_cb, zfile)

    zfile.close()
    return True


def build_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('-b', '--base', help='base dir', required=True)
    parser.add_argument('-s', '--src', help='src file/dir', action='append', required=True)
    parser.add_argument('-d', '--dst', help='dst dir', required=True)
    parser.add_argument('-n', '--name', help='md5 filename', required=True)
    return parser

def main():
    args = build_parser().parse_args()

    process(args.base, args.src, args.dst, args.name)

if __name__ == '__main__':
    main()
