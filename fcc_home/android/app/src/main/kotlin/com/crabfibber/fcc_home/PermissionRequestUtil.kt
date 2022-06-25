package com.crabfibber.fcc_home

import android.app.Activity
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import java.util.concurrent.atomic.AtomicInteger

object PermissionRequestUtil {

    private var REQUEST_CODE: AtomicInteger = AtomicInteger(3)

    private val requestMap = HashMap<Int, ArrayList<String>>()
    private val observerMap = HashMap<Int, ArrayList<(Boolean, Map<String, Int>) -> Boolean>>()


    fun getRequestCode(): Int {
        return REQUEST_CODE.getAndAdd(1)
    }

    fun addRequestPermission(
        requestCode: Int,
        requestPermission: String,
        callback: (Boolean, Map<String, Int>) -> Boolean
    ): PermissionRequestUtil {
        return addRequestPermission(requestCode, ArrayList(listOf(requestPermission)), callback)
    }

    fun addRequestPermission(
        requestCode: Int,
        requestPermission: ArrayList<String>,
        callback: (Boolean, Map<String, Int>) -> Boolean
    ): PermissionRequestUtil {
        if (!requestMap.containsKey(requestCode) || requestMap[requestCode] == null) {
            requestMap[requestCode] = arrayListOf()
        }
        if (!observerMap.containsKey(requestCode) || observerMap[requestCode] == null) {
            observerMap[requestCode] = arrayListOf()
        }
        requestMap[requestCode]?.addAll(requestPermission)
        observerMap[requestCode]?.add(callback)
        return this
    }

    fun ensurePermissionGranted(requestCode: Int, context: Activity) {
        if (requestMap.containsKey(requestCode) && requestMap[requestCode] != null) {
            var hasGranted = true
            for (request in requestMap[requestCode]!!) {
                if (ContextCompat.checkSelfPermission(
                        context,
                        request
                    ) == PackageManager.PERMISSION_DENIED
                ) {
                    hasGranted = false
                    break
                }
            }
            if (hasGranted) {
                handlePermissionResultsAndReset(requestCode, arrayOf(), intArrayOf())
            } else {
                ActivityCompat.requestPermissions(
                    context,
                    requestMap[requestCode]!!.toTypedArray(),
                    requestCode
                )
                requestMap.remove(requestCode)
            }
        }
    }

    fun handlePermissionResultsAndReset(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        if (observerMap.containsKey(requestCode) && observerMap[requestCode] != null) {
            val resultMap = HashMap<String, Int>()
            var isGranted = true
            for (index in permissions.indices) {
                resultMap[permissions[index]] = grantResults[index]
                if (grantResults[index] != PackageManager.PERMISSION_GRANTED) {
                    isGranted = false
                }
            }
            for (observer in observerMap[requestCode]!!) {
                observer(isGranted, resultMap)
            }
            observerMap.remove(requestCode)
        }
    }


}