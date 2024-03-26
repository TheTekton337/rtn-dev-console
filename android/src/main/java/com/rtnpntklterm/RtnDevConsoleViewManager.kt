package com.rtndevconsole

import android.graphics.Color
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

@ReactModule(name = RtnDevConsoleViewManager.NAME)
class RtnDevConsoleViewManager :
  RtnDevConsoleViewManagerSpec<RtnDevConsoleView>() {
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
