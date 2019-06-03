package com.qufan.pay.unity_pay;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by dantezhu on 16/4/14.
 */
public class BillParams {
    public int billType;        // 支付类型
    public String userid;       // 用户ID
    public String itemID;       // 物品id
    public double amt;          // 金额
    public String channel;      // 渠道
    public int appVersion;      // 应用版本号
    public int ref;             // 触发支付的位置
    public String passInfo;     // 原样透传的信息

    // 额外的字段，给支付SDK使用，不会传入到支付服务器
    public Map<String, String> extra = new HashMap<String, String>();

    public JSONObject toJSON() {
        // json

        JSONObject jsonObject = new JSONObject();
        try {

            jsonObject.put("bill_type", billType);
            jsonObject.put("userid", userid);
            jsonObject.put("item_id", itemID);
            jsonObject.put("amt", amt);
            jsonObject.put("channel", channel);
            jsonObject.put("app_version", appVersion);
            jsonObject.put("ref", ref);
            jsonObject.put("passinfo", passInfo);
        }
        catch (Exception e) {
            XLog.e("e: " + e);
            return null;
        }

        return jsonObject;
    }
}
