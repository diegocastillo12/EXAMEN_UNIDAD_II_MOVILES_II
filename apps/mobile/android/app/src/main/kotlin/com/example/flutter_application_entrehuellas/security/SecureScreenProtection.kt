package com.example.flutter_application_entrehuellas.security

import android.app.Activity
import android.os.Build
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager

/** UI-thread leases prevent one closing route from unprotecting another. */
class SecureScreenProtection(private val activity: Activity) {
    private val leases = mutableSetOf<String>()
    private var background = false
    private var focused = true
    private var curtain: View? = null
    internal val isCovered: Boolean get() = curtain != null

    fun onBackground() { background = true; updateCurtain() }
    fun onForeground() { background = false; focused = activity.hasWindowFocus(); updateCurtain() }
    fun onFocusChanged(hasFocus: Boolean) { focused = hasFocus; updateCurtain() }

    private fun updateCurtain() {
        val root = activity.window.decorView as ViewGroup
        val conceal = leases.isNotEmpty() && (background || !focused)
        if (conceal && curtain == null) {
            curtain = View(activity).apply {
                setBackgroundColor(Color.BLACK)
                importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS
            }
            root.addView(curtain, ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
            root.bringChildToFront(curtain)
            root.invalidate()
        } else if (!conceal && curtain != null) {
            root.removeView(curtain)
            curtain = null
        }
    }

    fun setProtected(token: String, enabled: Boolean) {
        require(token.length in 1..128)
        if (enabled) leases.add(token) else leases.remove(token)
        if (leases.isNotEmpty()) {
            activity.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
        if (Build.VERSION.SDK_INT >= 33) {
            activity.setRecentsScreenshotEnabled(leases.isEmpty())
        }
        updateCurtain()
    }
}
