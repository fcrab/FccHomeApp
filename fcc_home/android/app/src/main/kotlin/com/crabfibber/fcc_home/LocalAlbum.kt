package com.crabfibber.fcc_home

import android.content.ContentUris
import android.content.Context
import android.provider.MediaStore
import android.provider.MediaStore.Images.Thumbnails
import android.service.controls.templates.ThumbnailTemplate
import android.util.Log
import com.google.gson.Gson

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