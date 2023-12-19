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

class MainActivity : FlutterActivity() {

    private val TAG = "HomeApp"

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
                    getPics { list ->
                        result.success(list)
                    }
                }
                "delete" -> {
                    val uri = call.arguments
                    Log.d(TAG,"delete uri :$uri")
                    if(deleteImg(uri.toString())){
                        result.success(true)
                    }else{
                        result.error("-100","","")
                    }
                }
            }

        }
    }


    private fun deleteImg(uriPath:String):Boolean{
        val imgUri = Uri.parse(uriPath)
        val deleted = contentResolver.delete(imgUri,null,null)
        return deleted>0
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
        MediaStore.Images.Media.BUCKET_DISPLAY_NAME, // dir name 目录名字
        MediaStore.Images.Media.DATA
    )

    val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"

    val localPicsList = mutableListOf<String>()

    fun getPics(callback: (list: List<String>) -> Unit) {
        val gson = Gson()
        val query = applicationContext.contentResolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            STORE_IMAGES,
            null,
            null,
            sortOrder
        )

        query?.use {
            val idColumn = it.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
            val nameColumn = it.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME)
            val dateColumn = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_ADDED)
            val sizeColumn = it.getColumnIndexOrThrow(MediaStore.Images.Media.SIZE)
            val bucketColumn = it.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_ID)
            val bucketNameColumn =
                it.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_DISPLAY_NAME)
            val dataColumn = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)

            while (it.moveToNext()) {
                val valueMap = mutableMapOf<String, String>()
                val id = it.getLong(idColumn)
                val name = it.getString(nameColumn)
                val date = it.getString(dateColumn)
                val size = it.getString(sizeColumn) ?: ""
                val bucketId = it.getLong(bucketColumn)
                val bucketName = it.getString(bucketNameColumn)
                val uri =
                    ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)
                valueMap["id"] = id.toString()
                valueMap["name"] = name
                valueMap["date"] = date
                valueMap["size"] = size ?: "0"
                valueMap["bucketId"] = bucketId.toString()
                valueMap["bucketName"] = bucketName
                valueMap["uri"] = uri.path ?: ""
                valueMap["data"] = it.getString(dataColumn)
                val infos = gson.toJson(valueMap)
//                Log.d("MainAct", infos)
                localPicsList += infos
            }
            callback(localPicsList)
        }
    }
}
