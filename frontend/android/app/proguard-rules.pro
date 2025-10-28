# 🔒 Mantiene las clases de ML Kit y Flutter necesarias
-keep class io.flutter.embedding.** { *; }
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn javax.annotation.**
-dontwarn org.checkerframework.**
