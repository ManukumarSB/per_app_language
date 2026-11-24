package dev.manukumarsb.per_app_language

import android.app.LocaleManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.LocaleList
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Android 13+ has a real per-app language setting (LocaleManager). The
 * choice shows up in system settings, and because Flutter's activity handles
 * `locale` config changes itself, the engine sends the new locale to Dart
 * without the activity being recreated.
 *
 * Older versions have no such setting, so we just remember the choice and
 * let the Dart side apply it through MaterialApp.locale.
 */
class PerAppLanguagePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "per_app_language")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getLanguage" -> result.success(getLanguage())
            "setLanguage" -> {
                setLanguage(call.argument<String>("tag"))
                result.success(null)
            }
            "openSettings" -> result.success(openSettings())
            "hasSystemSettings" -> result.success(hasSystemSettings)
            else -> result.notImplemented()
        }
    }

    private val hasSystemSettings get() = Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU

    private val prefs get() = context.getSharedPreferences("per_app_language", Context.MODE_PRIVATE)

    private fun getLanguage(): String? {
        if (hasSystemSettings) {
            val locales = context.getSystemService(LocaleManager::class.java).applicationLocales
            return if (locales.isEmpty) null else locales[0].toLanguageTag()
        }
        return prefs.getString(KEY, null)
    }

    private fun setLanguage(tag: String?) {
        if (hasSystemSettings) {
            context.getSystemService(LocaleManager::class.java).applicationLocales =
                if (tag == null) LocaleList.getEmptyLocaleList() else LocaleList.forLanguageTags(tag)
            return
        }
        prefs.edit().apply {
            if (tag == null) remove(KEY) else putString(KEY, tag)
        }.apply()
    }

    private fun openSettings(): Boolean {
        if (!hasSystemSettings) return false
        val intent = Intent(Settings.ACTION_APP_LOCALE_SETTINGS)
            .setData(Uri.fromParts("package", context.packageName, null))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return try {
            context.startActivity(intent)
            true
        } catch (e: ActivityNotFoundException) {
            // Some OEM builds strip the screen out.
            false
        }
    }

    private companion object {
        const val KEY = "language_tag"
    }
}
