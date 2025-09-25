# Keep core MLKit text recognizers
-keep class com.google.mlkit.vision.text.** { *; }

# Don't warn about optional language recognizers (not included for 16KB page size compatibility)
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
