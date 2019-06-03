package com.qufan.texas.util;

import java.lang.reflect.Field;

import android.content.Context;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.ViewGroup.MarginLayoutParams;
import android.widget.TextView;

public class RelayoutTool {
	public static float SCREEN_WIDTH = 0;
	public static float SCREEN_HEIGHT = 0;

	private static float scaleX = 1.0f;
	private static float scaleY = 1.0f;

	public RelayoutTool(Context ctx, float width, float height) {
		DisplayMetrics displayMetrics = ctx.getResources().getDisplayMetrics();
		int metr_width = displayMetrics.widthPixels;
		int metr_height = displayMetrics.heightPixels;
		if(metr_width<metr_height){//保证是横屏比例
			Log.i("长宽比例出现错误", metr_width+"<"+metr_height);
			int temp = metr_width;
			metr_width = metr_height;
			metr_height = temp;
		}
		scaleX = metr_width / width;
		scaleY = metr_height / height;
		scaleX = scaleY;
		SCREEN_WIDTH = width;
		SCREEN_HEIGHT = height;
	}

	// 设置缩放比
	public static void relayoutViewHierarchy(View view) {
		if (view == null) {
			return;
		}

		scaleView(view);
		if (view instanceof ViewGroup) {
			View[] children = null;
			try {
				Field field = ViewGroup.class.getDeclaredField("mChildren");
				field.setAccessible(true);
				children = (View[]) field.get(view);
			} catch (NoSuchFieldException e) {
				e.printStackTrace();
			} catch (IllegalArgumentException e) {
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				e.printStackTrace();
			}

			if (children != null) {
				for (View child : children) {
					relayoutViewHierarchy(child);
				}
			} else { // 反射失败可以通过方法遍历，虽然效率稍差但至少可用。
                int count = ((ViewGroup) view).getChildCount();
                for (int i = 0; i < count; ++i) {
                    View child = ((ViewGroup) view).getChildAt(i);
                    if (null != child) {
                        relayoutViewHierarchy(child);
                    }
                }
            }
		}
	}

	// 将视图按比例缩放，不考虑嵌套视图
	private static void scaleView(View view) {
		if (view instanceof TextView) {
			resetTextSize((TextView) view, scaleY);
		}

		int pLeft = convertFloatToInt(view.getPaddingLeft() * scaleX);
		int pTop = convertFloatToInt(view.getPaddingTop() * scaleY);
		int pRight = convertFloatToInt(view.getPaddingRight() * scaleX);
		int pBottom = convertFloatToInt(view.getPaddingBottom() * scaleY);
		view.setPadding(pLeft, pTop, pRight, pBottom);
		LayoutParams params = view.getLayoutParams();
		scaleLayoutParams(params);

	}

	// 将视图布局属性按比例设置
	public static void scaleLayoutParams(LayoutParams params) {
		if (params == null) {
			return;
		}
		if (params.width > 0) {
			params.width = convertFloatToInt(params.width * scaleX);
		}
		if (params.height > 0) {
			params.height = convertFloatToInt(params.height * scaleY);
		}
		if (params instanceof MarginLayoutParams) {
			MarginLayoutParams mParams = (MarginLayoutParams) params;
			if (mParams.leftMargin > 0) {
				mParams.leftMargin = convertFloatToInt(mParams.leftMargin * scaleX);
			}
			if (mParams.topMargin > 0) {
				mParams.topMargin = convertFloatToInt(mParams.topMargin * scaleY);
			}
			if (mParams.rightMargin > 0) {
				mParams.rightMargin = convertFloatToInt(mParams.rightMargin * scaleY);
			}
			if (mParams.bottomMargin > 0) {
				mParams.bottomMargin = convertFloatToInt(mParams.bottomMargin * scaleY);
			}
		}
	}

	// 字体设置
	private static void resetTextSize(TextView textView, float scale) {
		float size = textView.getTextSize();
		textView.setTextSize(TypedValue.COMPLEX_UNIT_PX, size * scale);
	}

	// float 转 int 四舍五入
	private static int convertFloatToInt(float sourceNum) {
		return (int) (sourceNum + 0.5f);
	}

	public static float getScaleX() {
		return scaleX;
	}

	public static float getScaleY() {
		return scaleY;
	}
	
}
