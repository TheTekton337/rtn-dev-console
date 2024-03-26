package com.rtndevconsole

import android.graphics.Color
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.RtnDevConsoleViewManagerInterface
import com.facebook.react.viewmanagers.RtnDevConsoleViewManagerDelegate

@ReactModule(name = RtnDevConsoleViewManager.NAME)
class RtnDevConsoleViewManager : SimpleViewManager<RtnDevConsoleView>(),
  RtnDevConsoleViewManagerInterface<RtnDevConsoleView> {
  private val mDelegate: ViewManagerDelegate<RtnDevConsoleView>

  init {
    mDelegate = RtnDevConsoleViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<RtnDevConsoleView>? {
    return mDelegate
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): RtnDevConsoleView {
    return RtnDevConsoleView(context)
  }

  @ReactProp(name = "color")
  override fun setColor(view: RtnDevConsoleView?, color: String?) {
    view?.setBackgroundColor(Color.parseColor(color))
  }

  companion object {
    const val NAME = "RtnDevConsoleView"
  }
}
