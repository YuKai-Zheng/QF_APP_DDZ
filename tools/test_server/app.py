from haven import THaven
from netkit.box import Box
import logging
import texas_net_pb2

logger = logging.getLogger('haven')
logger.addHandler(logging.StreamHandler())
logger.setLevel(logging.DEBUG)

app = THaven(Box)

@app.route(1)
def index(request):
    req = texas_net_pb2.UserRegReq()

    req.ParseFromString(request.box.body)

    print 'nick', req.nick

    rsp = texas_net_pb2.UserRegRsp()
    rsp.max_history_cards.append(3)
    rsp.max_history_cards.append(2)

    request.write(
        dict(
            ret=0,
            body=rsp.SerializeToString()
        )
    )

app.run('0.0.0.0', 7777)
