-dontwarn com.yalantis.ucrop**
-keep class com.yalantis.ucrop** { *; }
-keep interface com.yalantis.ucrop** { *; }
-keep class com.example.myapp.** { *; }
-keepclasseswithmembernames class * {
    native <methods>;
}
-keep class org.xmlpull.v1.** { *; }