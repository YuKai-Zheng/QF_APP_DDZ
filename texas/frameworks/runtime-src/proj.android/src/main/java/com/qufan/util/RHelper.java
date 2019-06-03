package com.qufan.util;

import com.qufan.texas.BuildConfig;
import com.qufan.texas.R;

public class RHelper {
	public static final int anim = 0;
	public static final int attr = 1;
	public static final int color = 2;
	public static final int dimen = 3;
	public static final int drawable = 4;
	public static final int id = 5;
	public static final int layout = 6;
	public static final int string = 7;
	public static final int style = 8;
    public static final int raw = 9;

	public static boolean isDebug() {
		return BuildConfig.DEBUG;
	}

	public static int getValue(int type, String name) {
		try {

			switch (type) {
			case anim:
				return R.anim.class.getField(name).getInt(null);
			case attr:
				return R.attr.class.getField(name).getInt(null);
			case color:
				return R.color.class.getField(name).getInt(null);
			case dimen:
				return R.dimen.class.getField(name).getInt(null);
			case drawable:
				return R.drawable.class.getField(name).getInt(null);
			case id:
				return R.id.class.getField(name).getInt(null);
			case layout:
				return R.layout.class.getField(name).getInt(null);
			case string:
				return R.string.class.getField(name).getInt(null);
			case style:
				return R.style.class.getField(name).getInt(null);
            case raw:
                return R.raw.class.getField(name).getInt(null);
			default:
				break;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

}
