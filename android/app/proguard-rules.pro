# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Preserve generic signatures (for reflection and generics)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# SQLite (sqflite package)
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# HTTP & Network (http package, dio)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Gson/JSON serialization
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# Keep app model classes from being obfuscated
-keep class com.danar.watchlyapp.models.** { *; }

# Shared Preferences
-keep class android.content.SharedPreferences** { *; }
-keep class androidx.preference.** { *; }

# Image Picker and Camera
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class androidx.camera.** { *; }

# Cached Network Image
-keep class com.github.bumptech.glide.** { *; }

# Provider (state management)
-keep class * extends androidx.lifecycle.ViewModel { *; }
-keep class * extends androidx.lifecycle.AndroidViewModel { *; }

# Prevent runtime crashes from missing constructors
-keepclassmembers class * {
    <init>(...);
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep methods used via reflection
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}
