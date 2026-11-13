# Flutter Wrapper & Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**
-dontwarn androidx.**

# App Package & Keep Annotations
-keep class com.notisboard.mobile.** { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}
-keep class kotlin.Metadata { *; }
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod,SourceFile,LineNumberTable

# Stripe SDK & Jetpack Compose
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**
-keep class androidx.compose.** { *; }
-dontwarn androidx.compose.**

# Razorpay
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Cashfree
-keep class com.cashfree.** { *; }
-dontwarn com.cashfree.**

# Zego Express & Effects & Honor Audio
-keep class **.zego.** { *; }
-keep interface **.zego.** { *; }
-dontwarn **.zego.**
-keep class com.zego.** { *; }
-keep interface com.zego.** { *; }
-dontwarn com.zego.**
-keep class im.zego.** { *; }
-keep interface im.zego.** { *; }
-dontwarn im.zego.**
-keep class com.hihonor.** { *; }
-dontwarn com.hihonor.**

# Native JNI Methods (Crucial to prevent java_class == null in RegisterNatives)
-keepclasseswithmembernames class * {
    native <methods>;
}
-keepclassmembers class * {
    native <methods>;
}

# PDF viewer
-keep class com.shockwave.** { *; }
-keep class com.github.barteksc.** { *; }

# Firebase & Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Awesome Notifications & Local Notifications
-keep class me.carda.awesome_notifications.** { *; }
-dontwarn me.carda.awesome_notifications.**
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Google Play In-App Billing
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

# JSON & Network Libraries
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keep class com.squareup.okhttp3.** { *; }
-keep interface com.squareup.okhttp3.** { *; }
-dontwarn com.squareup.okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**

# Webview
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String);
}
-keepclassmembers class * extends android.webkit.WebChromeClient {
    public void *(android.webkit.WebView, java.lang.String);
}
