package com.qufan.special.sdk;
import com.qufan.special.sdk.SpecialFactoryModel;

public class SpecialFactory extends SpecialFactoryModel {
	private static SpecialFactory specialInstance = null;
    public static SpecialFactory getInstance(){
        if (specialInstance == null){
            specialInstance = scyCreateInstance();
        }
        return specialInstance;
    }
    private static synchronized SpecialFactory scyCreateInstance(){
        if (specialInstance == null){
            specialInstance =  new SpecialFactory();
        }
        return specialInstance;
    }
}
