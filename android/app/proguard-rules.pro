# ML Kit Text Recognition rules to ignore missing dependencies for unsupported languages
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google.mlkit.vision.common.**
