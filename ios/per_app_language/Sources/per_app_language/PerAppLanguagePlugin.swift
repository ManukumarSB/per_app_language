import Flutter
import UIKit

/// iOS keeps the per-app language in the app's own `AppleLanguages` default.
/// That's what Settings › <App> › Language writes, so reading and writing it
/// here keeps the two in sync. iOS applies it at launch: changing it in
/// Settings relaunches the app, and changing it from code takes effect for
/// native strings on the next launch (the Dart side switches Flutter
/// immediately).
public class PerAppLanguagePlugin: NSObject, FlutterPlugin {
  private static let key = "AppleLanguages"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "per_app_language", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(PerAppLanguagePlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getLanguage":
      result(appLanguage())
    case "setLanguage":
      let tag = (call.arguments as? [String: Any])?["tag"] as? String
      setAppLanguage(tag)
      result(nil)
    case "systemLanguage":
      result(systemLanguage())
    case "openSettings":
      openSettings(result)
    case "hasSystemSettings":
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Only the app's own domain. `UserDefaults.standard.object(forKey:)` would
  /// fall through to the global value and make "follow the system" look like
  /// an explicit choice.
  private func appLanguage() -> String? {
    guard let id = Bundle.main.bundleIdentifier,
      let domain = UserDefaults.standard.persistentDomain(forName: id),
      let languages = domain[Self.key] as? [String]
    else { return nil }
    return languages.first
  }

  private func setAppLanguage(_ tag: String?) {
    if let tag = tag {
      UserDefaults.standard.set([tag], forKey: Self.key)
    } else {
      UserDefaults.standard.removeObject(forKey: Self.key)
    }
  }

  /// The device language, ignoring any per-app choice. Needed after resetting
  /// to "follow the system" mid-session, because Flutter's locales were
  /// computed at launch from the old per-app choice.
  private func systemLanguage() -> String? {
    let global = CFPreferencesCopyValue(
      Self.key as CFString, kCFPreferencesAnyApplication,
      kCFPreferencesCurrentUser, kCFPreferencesAnyHost) as? [String]
    return global?.first ?? Locale.preferredLanguages.first
  }

  private func openSettings(_ result: @escaping FlutterResult) {
    guard let url = URL(string: UIApplication.openSettingsURLString) else {
      result(false)
      return
    }
    DispatchQueue.main.async {
      UIApplication.shared.open(url) { opened in result(opened) }
    }
  }
}
