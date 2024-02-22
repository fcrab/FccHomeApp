package com.crabfibber.fcc_home

import android.content.ContentUris
import android.content.Context
import android.graphics.Bitmap
import android.os.Environment
import android.provider.MediaStore
import android.provider.MediaStore.Images.Thumbnails
import android.util.Log
import androidx.annotation.Nullable
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.SimpleTarget
import com.bumptech.glide.request.target.Target
import com.bumptech.glide.request.transition.Transition
import com.google.gson.Gson
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.File
import java.io.FileOutputStream
import java.io.IOException


class LocalAlbum {

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

    private val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"

    private val localPicsList = mutableListOf<String>()


    fun getPics(context: Context, callback: (list: List<String>) -> Unit) {
        val thumbDir = context.getExternalFilesDir(null)!!.path + "/" + "thumb"
        Log.d("localAlbum", "thumb dir: $thumbDir")
        val originPath = Environment.getExternalStorageDirectory()
        val systemPath = Environment.DIRECTORY_DCIM

        val gson = Gson()
        val query = context.applicationContext.contentResolver.query(
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
                valueMap["size"] = size
                valueMap["bucketId"] = bucketId.toString()
                valueMap["bucketName"] = bucketName
                valueMap["uri"] = uri.path ?: ""
                valueMap["data"] = it.getString(dataColumn)

//                Log.d("MainAct", infos)
                val fullPath = "${originPath}/${systemPath}"
                if (valueMap["data"]!!.contains(fullPath)) {

                    val relativePath = valueMap["data"]!!.split(fullPath)
                    val thumbPath = thumbDir + relativePath[1]
                    if (isThumbExist(thumbPath)) {
                        Log.d("localAlbum", "thumb exist")
                        valueMap["thumb"] = thumbPath
                    } else {
                        valueMap["thumb"] = ""
                        generateThumbFile(context, valueMap["data"]!!, thumbPath)
                    }
//                    for(path in relativePath){
//                        Log.d("localAlbum","split relative path :${path}")
//                    }


//                    Log.d("localAlbum", "data ${valueMap["data"]} syspath:${fullPath}")
                    val infos = gson.toJson(valueMap)
                    localPicsList += infos
                }
            }
            callback(localPicsList)
        }
    }

    private fun isThumbExist(path: String): Boolean {
        val thumbFile = File(path)
        return thumbFile.exists()
    }

    private fun generateThumbFile(context: Context, path: String, thumbPath: String) {
        GlobalScope.launch(Dispatchers.IO) {
            val file = File(path)
            val scaleFactor = 4 // 缩小的倍数
// 使用Glide加载文件并生成按照倍数缩小后的Bitmap
            Glide.with(context)
                .asBitmap()
                .load(file)
//            .override(
//                Target.SIZE_ORIGINAL / scaleFactor,
//                Target.SIZE_ORIGINAL / scaleFactor
//            ) // 按照倍数缩小Bitmap的尺寸
                .into(object : SimpleTarget<Bitmap>(
                    Target.SIZE_ORIGINAL / scaleFactor,
                    Target.SIZE_ORIGINAL / scaleFactor
                ) {
                    override fun onResourceReady(
                        resource: Bitmap,
                        @Nullable transition: Transition<in Bitmap>?
                    ) {
                        // 在这里处理加载成功后的按照倍数缩小后的Bitmap
//                    imageView.setImageBitmap(resource)
                        val thumbFile = File(thumbPath)
                        try {
                            val outputStream = FileOutputStream(thumbFile)
                            Log.d("localAlbum", "generate thumb path $thumbPath")
                            resource.compress(Bitmap.CompressFormat.JPEG, 100, outputStream)
                            outputStream.close()
                        } catch (ex: IOException) {
                            ex.printStackTrace()
                        }
                    }
                })
        }

    }

    private val THUMB_IMAGES = arrayOf(
        Thumbnails.IMAGE_ID,
        Thumbnails.DATA
    )

    fun getThumbs(context: Context, callback: (list: List<String>) -> Unit) {
        val query = context.applicationContext.contentResolver.query(
            Thumbnails.EXTERNAL_CONTENT_URI,
            THUMB_IMAGES,
            null,
            null,
            Thumbnails.DEFAULT_SORT_ORDER,
//            "${Thumbnails.IMAGE_ID} DESC"
        )
        val gson = Gson()
        query?.use {
            Log.d("album", "length : ${query.count}")
            val idColumn = it.getColumnIndexOrThrow(Thumbnails.IMAGE_ID)
            val dataColumn = it.getColumnIndexOrThrow(Thumbnails.DATA)

            while (it.moveToNext()) {
                val valueMap = mutableMapOf<String, String>()
                val id = it.getLong(idColumn)
                val uri =
                    ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)
                valueMap["id"] = id.toString()
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