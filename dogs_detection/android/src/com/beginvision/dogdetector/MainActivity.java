package com.beginvision.dogdetector;

import java.util.concurrent.locks.ReentrantLock;
import org.apache.http.conn.util.InetAddressUtils;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.hardware.Camera;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.PictureCallback;
import android.graphics.Bitmap;
import android.media.AudioFormat;
import android.media.MediaRecorder;
import android.media.AudioRecord;
import android.os.Bundle;
import android.os.Looper;
import android.os.Handler;
import android.graphics.Color;
import java.io.*;
import android.util.*;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

public class MainActivity extends Activity
        implements CameraView.CameraReadyCallback, OverlayView.UpdateDoneCallback
{
    public static String TAG="BV";
    
    private ReentrantLock previewLock = new ReentrantLock();
    private CameraView cameraView = null;
    private OverlayView overlayView = null;
    private TextView tv;
    private Button btn;
    
    private Bitmap  helpBitmap = null;
    private String myState = "INIT";
    private double detectResult = 0.0;

    //
    //  Activiity's event handler
    //
    @Override
    public void onCreate(Bundle savedInstanceState) {
        // application setting
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        Window win = getWindow();
        win.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);    

        // load and setup GUI
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        tv = (TextView)findViewById(R.id.tv_message);
        btn = (Button)findViewById(R.id.btn_control);
        btn.setOnClickListener(controlAction);
        
        // init NativeAgent
        NativeAgent.init();

        // init camera
        initCamera();
   }
    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onPause() {      
        super.onPause();

        if ( cameraView != null) {
            previewLock.lock();
            cameraView.StopPreview();
            previewLock.unlock();
        }

        //finish();
        System.exit(0);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }

    //
    //  Interface implementation
    //
    public void onCameraReady() {
        cameraView.StopPreview();
        cameraView.setupCamera(640, 480, 4, previewCb);
        
        helpBitmap = Bitmap.createBitmap(cameraView.Width(), cameraView.Height(), Bitmap.Config.ARGB_8888);
        int rectangleSize = helpBitmap.getHeight()/2;
        for(int x = (helpBitmap.getWidth() - rectangleSize)/2; x < (helpBitmap.getWidth() + rectangleSize)/2; x++) {
            int y = (helpBitmap.getHeight() - rectangleSize)/2;
            helpBitmap.setPixel(x, y, Color.argb(255, 255, 255, 255));
            helpBitmap.setPixel(x, y-1, Color.argb(255, 255, 255, 255));
            helpBitmap.setPixel(x, y+1, Color.argb(255, 255, 255, 255));
            y = (helpBitmap.getHeight() + rectangleSize)/2;
            helpBitmap.setPixel(x, y, Color.argb(255, 255, 255, 255));
            helpBitmap.setPixel(x, y-1, Color.argb(255, 255, 255, 255));
            helpBitmap.setPixel(x, y+1, Color.argb(255, 255, 255, 255));
        }
        for(int y = (helpBitmap.getHeight() - rectangleSize)/2; y < (helpBitmap.getHeight() + rectangleSize)/2; y++) {
            int x = (helpBitmap.getWidth() - rectangleSize)/2;
            helpBitmap.setPixel(x, y, Color.argb(255, 255, 255, 255));
            helpBitmap.setPixel(x-1, y, Color.argb(255, 255, 255, 255));
            helpBitmap.setPixel(x+1, y, Color.argb(255, 255, 255, 255));
            x = (helpBitmap.getWidth() + rectangleSize)/2;
            helpBitmap.setPixel(x, y, Color.argb(255, 255, 255, 255));
            helpBitmap.setPixel(x-1, y, Color.argb(255, 255, 255, 255));
            helpBitmap.setPixel(x+1, y, Color.argb(255, 255, 255, 255));
        }

        new Handler(Looper.getMainLooper()).post( new Runnable() {
                @Override 
                public void run() {
                    overlayView.DrawResult(helpBitmap);
                    btn.setText("检测");
                    tv.setText("将白框对准旺星人的脸,按下检测键");
                    cameraView.AutoFocus();
                }
            });
        
        myState = "IDLE";
        cameraView.StartPreview();
    }

    public void onUpdateDone() {
           
    }

    //
    //  Internal help functions
    //
    private void initCamera() {
        SurfaceView cameraSurface = (SurfaceView)findViewById(R.id.surface_camera);
        cameraView = new CameraView(cameraSurface);        
        cameraView.setCameraReadyCallback(this);

        overlayView = (OverlayView)findViewById(R.id.surface_overlay);
        //overlayView_.setOnTouchListener(this);
        overlayView.setUpdateDoneCallback(this);
    }
     
    //
    //  Internal help class and object definment
    //
    private PreviewCallback previewCb = new PreviewCallback() {
        public void onPreviewFrame(byte[] yuvFrame, Camera c) {
            processNewFrame(yuvFrame, c);
        }
    };

    private void processNewFrame(final byte[] yuvFrame, final Camera c) {
        if ( myState == "WAIT") { 
            myState = "DOING";
            cameraView.StopPreview();
            new Thread(new Runnable() {
                        public void run() {
                            previewLock.lock(); 
                            detectResult = NativeAgent.updatePictureForResult(yuvFrame, helpBitmap, cameraView.Width(), cameraView.Height());
                            c.addCallbackBuffer(yuvFrame);
                            new Handler(Looper.getMainLooper()).post( resultAction );
                            previewLock.unlock();
                        }
                    }).start();
        } else {
            c.addCallbackBuffer(yuvFrame);
        }
    }

    private Runnable resultAction = new Runnable() {
        @Override 
        public void run() {
            myState = "SHOW";
            int score = (int)(detectResult * 100);
            if ( score > 70) {
                tv.setText("旺星人指数:" + score + "%, 必是旺星人");
            } else if ( score > 50) {
                tv.setText("旺星人指数:" + score + "%, 疑是旺星人");
            } else {
                tv.setText("旺星人指数:" + score + "%, 不是旺星人");
            }
            btn.setText("重新开始");
            btn.setEnabled(true); 
        }
    };

    private OnClickListener controlAction = new OnClickListener() {
        @Override
        public void onClick(View v) {
            if ( myState == "IDLE" ) {
                myState = "WAIT";
                btn.setEnabled(false);
                tv.setText("计算中...");
            } else if (myState == "SHOW" ) {
                myState = "IDLE";
                btn.setText("检测");
                tv.setText("将白框对准旺星人的脸,按下检测键");
                cameraView.AutoFocus();
                cameraView.setupCamera(640, 480, 4, previewCb);
                cameraView.StartPreview();
            }
        }
    };

}
