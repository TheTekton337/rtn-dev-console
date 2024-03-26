package com.rtndevconsole

import android.view.View

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.viewmanagers.RtnDevConsoleViewManagerDelegate
import com.facebook.react.viewmanagers.RtnDevConsoleViewManagerInterface

abstract class RtnDevConsoleViewManagerSpec<T : View> : SimpleViewManager<T>(), RtnDevConsoleViewManagerInterface<T> {
  private val mDelegate: ViewManagerDelegate<T>

  init {
    mDelegate = RtnDevConsoleViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<T>? {
    return mDelegate
  }
}
