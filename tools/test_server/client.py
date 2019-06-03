#!/usr/bin/env python
# -*- coding: utf-8 -*-

from netkit.contrib.tcp_client import TcpClient
from netkit.box import Box
import texas_net_pb2

client = TcpClient(Box, '127.0.0.1', 7777)
client.connect()

send_box = Box()

req = texas_net_pb2.UserRegReq()
req.nick = 'dantezhu'

send_box.cmd = 1
send_box.body = req.SerializeToString()

ret = client.write(send_box)
print 'send:', ret

recv_box = client.read()

if not recv_box:
    print 'recv None'
else:
    rsp = texas_net_pb2.UserRegRsp()
    rsp.ParseFromString(recv_box.body)
    print rsp.max_history_cards
