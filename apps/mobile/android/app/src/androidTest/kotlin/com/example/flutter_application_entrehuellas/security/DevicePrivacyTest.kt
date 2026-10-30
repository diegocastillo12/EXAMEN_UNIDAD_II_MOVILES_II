package com.example.flutter_application_entrehuellas.security

import android.content.pm.ApplicationInfo
import android.view.WindowManager
import androidx.test.core.app.ActivityScenario
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.example.flutter_application_entrehuellas.MainActivity
import org.junit.Assert.*
import org.junit.Test
import org.junit.runner.RunWith
import org.xmlpull.v1.XmlPullParser

@RunWith(AndroidJUnit4::class)
class DevicePrivacyTest {
    @Test
    fun windowSecureLeasesAreScopedAndReleased() {
        ActivityScenario.launch(MainActivity::class.java).use { scenario ->
            scenario.onActivity { activity ->
                val protection = SecureScreenProtection(activity)
                fun secure() = activity.window.attributes.flags and WindowManager.LayoutParams.FLAG_SECURE != 0
                protection.setProtected("first", true)
                assertTrue(secure())
                protection.onBackground()
                assertTrue(protection.isCovered)
                protection.onForeground()
                protection.onFocusChanged(true)
                assertFalse(protection.isCovered)
                protection.onFocusChanged(false)
                assertTrue(protection.isCovered)
                protection.setProtected("second", true)
                protection.setProtected("first", false)
                assertTrue(secure())
                protection.setProtected("second", false)
                assertFalse(secure())
                assertFalse(protection.isCovered)
            }
        }
    }

    @Test
    fun installedManifestAndCloudTransferRulesDisableBackup() {
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        assertEquals(0, context.applicationInfo.flags and ApplicationInfo.FLAG_ALLOW_BACKUP)
        for (name in listOf("backup_rules", "data_extraction_rules")) {
            val id = context.resources.getIdentifier(name, "xml", context.packageName)
            assertTrue(id != 0)
            val parser = context.resources.getXml(id)
            var excludes = 0
            while (parser.eventType != XmlPullParser.END_DOCUMENT) {
                if (parser.eventType == XmlPullParser.START_TAG && parser.name == "exclude") {
                    assertEquals(".", parser.getAttributeValue(null, "path"))
                    excludes++
                }
                parser.next()
            }
            assertEquals(if (name == "backup_rules") 9 else 18, excludes)
            parser.close()
        }
    }
}
