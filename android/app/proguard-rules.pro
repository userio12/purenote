# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep classes used by flutter_quill
-keep class com.quill.** { *; }

# Keep classes used by drift
-keep class com.mta.** { *; }

# Keep classes used by flutter_local_notifications
-keep class com.dexterous.** { *; }

# Keep classes used by local_auth
-keep class androidx.biometric.** { *; }

# Keep classes used by workmanager
-keep class androidx.work.** { *; }

# Keep classes used by Sentry
-keep class io.sentry.** { *; }

# Keep model/data classes for JSON serialization
-keep class com.purenote.** { *; }

# Keep Kotlin home_widget classes
-keep class es.antonborri.** { *; }
