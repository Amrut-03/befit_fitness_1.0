# Keep rules for R8 release builds. Firebase, ML Kit (mobile_scanner) and
# most plugins ship their own consumer rules; these cover the gaps.

# flutter_local_notifications serializes scheduled notifications with Gson
# and restores them after reboot via reflection.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# Readable Crashlytics stack traces (the Crashlytics Gradle plugin uploads
# the mapping file).
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# The Flutter embedding references Play Core (deferred components), which
# this app doesn't use.
-dontwarn com.google.android.play.core.**
