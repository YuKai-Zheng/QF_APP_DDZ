#!/usr/bin/env python
# -*- coding: utf-8 -*-

KEY = "\xc0\x39\x6a\x56\x87\xdf\x77\x19\x29\xa7\xfc\xf8\x6f\x21\x3d\xae\xb0\x46\x44\x95\xc0\x65\x83\xcf\x65\xf3\x6c\x94\x89\xd2\xbd\x56"

with open('xxtea.key', 'wb') as f:
    f.write(KEY)
