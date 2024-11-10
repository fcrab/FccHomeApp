package com.crabfibber.fcc_home

import android.Manifest
import android.app.Activity
import android.content.ContentUris
import android.net.Uri
import android.os.Bundle
import android.os.PersistableBundle
import android.provider.MediaStore
import android.util.Log
import android.widget.Toast
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private val TAG = "HomeApp"

    private val CHANNEL = "com.crabfibber.fcc_home/event"

    private val album = LocalAlbum()

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
                    val id = call.arguments as String
                    album.getPics(this, id) { list ->
//                    album.getThumbs(this) { list ->
                        result.success(list)
                    }
                }

                "getFolder" -> {
                    album.getFolders { map ->
                        result.success(map)
                    }
                }
                "deleteFiles" -> {
                    val uri: List<String> = call.arguments as List<String>
                    album.deleteFiles(this, uri)
                    result.success(true)
                }

                "delete" -> {
                    val uri = call.arguments
                    Log.d(TAG,"delete uri :$uri")
                    if(deleteImg(uri.toString())){
                        result.success(true)
                    } else {
                        result.error("-100", "", "")
                    }
                }
            }

        }
    }


    private fun deleteImg(id: String): Boolean {
        val imgUri =
            ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id.toLong())
//        val imgUri = Uri.parse(uriPath)
        val deleted = contentResolver.delete(imgUri, null, null)
        return deleted > 0
    }

    private fun requestPhonePermission(activity: Activity, callback: (isGranted: Boolean) -> Unit) {

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


}
