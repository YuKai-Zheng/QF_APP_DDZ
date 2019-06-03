package com.qufan.pay.unity_pay;

/**
 * Created by dantezhu on 17/2/28.
 */
public abstract class ResultListener {

    // 结果通知
    // result: 0: 成功；其他: 失败
    // billID: >0 订单ID; 其他: 尚未生成
    public void onResult(int result, int billID) {
    }

}
