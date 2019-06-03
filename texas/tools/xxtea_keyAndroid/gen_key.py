#!/usr/bin/env python
# -*- coding: utf-8 -*-

import random
size = 32

l = ['\\x%02x' % (random.choice(range(1, 255))) for it in range(size)]

# print l

print ''.join(l)
