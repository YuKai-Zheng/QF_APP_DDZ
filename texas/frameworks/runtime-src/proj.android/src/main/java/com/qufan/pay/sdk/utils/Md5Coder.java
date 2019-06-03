package com.qufan.pay.sdk.utils;

import java.security.NoSuchAlgorithmException;

/**
 * 
 * @author Junhong.Li
 * 项目名称：ActivityMgr  
 * 类名称：Md5Coder   MD5加密
 * 如有疑问请联系：haiyanmain@live.com
 * 修改时间：2014-4-2 下午10:44:56 
 * 修改人：Junhong
 */
public class Md5Coder {

	public final static String md5(String src) {
		java.security.MessageDigest md;
		try {
			md = java.security.MessageDigest.getInstance("MD5");
			byte[] bytes = src.getBytes();
			byte[] bytes_md5 = md.digest(bytes);
			StringBuffer md5StrBuff = new StringBuffer();

			for (int i = 0; i < bytes_md5.length; i++) {
				if (Integer.toHexString(0xFF & bytes_md5[i]).length() == 1)
					md5StrBuff.append("0").append(
							Integer.toHexString(0xFF & bytes_md5[i]));
				else
					md5StrBuff.append(Integer.toHexString(0xFF & bytes_md5[i]));
			}
			return md5StrBuff.toString();
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		return null;
	}

	public final static String md5Upper(String src) {
		return md5(src).toUpperCase();
	}

}
