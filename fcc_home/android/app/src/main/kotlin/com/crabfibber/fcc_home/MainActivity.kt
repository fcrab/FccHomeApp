package com.crabfibber.fcc_home

import android.Manifest
import android.app.Activity
import android.os.Bundle
import android.os.PersistableBundle
import android.provider.MediaStore
import android.util.Log
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.crabfibber.fcc_home/event"

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)


    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
//                    testBroadcast()
                    requestPhonePermission(this) { granted ->
                        result.success(granted)
                    }
                }
                "getAllPics" -> {

                }
            }

        }
    }


    fun requestPhonePermission(activity: Activity, callback: (isGranted: Boolean) -> Unit) {

//            Permissions(activity).request(Manifest.permission.READ_PHONE_STATE) { permission, granted, shouldShowRequestPermissionRationale ->
        val requestCode = PermissionRequestUtil.getRequestCode()
        PermissionRequestUtil.addRequestPermission(
            requestCode, arrayListOf(
                Manifest.permission.INTERNET,
                Manifest.permission.READ_PHONE_STATE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.READ_EXTERNAL_STORAGE
            )
        ) { granted, _ ->
            Log.d("testAgree", "call granted callback")
            if (granted) {
                callback(granted)
            } else {
                Toast.makeText(activity, "权限未开放", Toast.LENGTH_SHORT).show()
            }

            true
        }.ensurePermissionGranted(requestCode, activity)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        PermissionRequestUtil.handlePermissionResultsAndReset(
            requestCode,
            permissions,
            grantResults
        )
    }

    private val STORE_IMAGES = arrayOf(
        MediaStore.Images.Media.DISPLAY_NAME,  // 显示的名字
//        MediaStore.Images.Media.DATA, MediaStore.Images.Media.LONGITUDE,  // 经度
        MediaStore.Images.Media.DATE_ADDED,
        MediaStore.Images.Media.SIZE,
        MediaStore.Images.Media._ID,  // id
        MediaStore.Images.Media.BUCKET_ID,  // dir id 目录
        MediaStore.Images.Media.BUCKET_DISPLAY_NAME // dir name 目录名字
    )

    val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"

    fun getPics() {

    }
}
