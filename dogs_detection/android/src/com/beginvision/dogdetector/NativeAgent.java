package com.beginvision.dogdetector;

import java.io.*; 
import java.net.*;

import android.net.*;
import android.util.Log;

public class NativeAgent{
    public static native int init();
    public static native int updatePicture(byte[]frame, int wid, int hei);
    public static native double updatePictureForResult(byte[]frame, Object obj, int wid, int hei);
    static {
        System.loadLibrary("beginvision");
    }
}
