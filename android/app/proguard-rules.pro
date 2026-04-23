# MediaPipe proto classes referenced via reflection/JNI
-keep class com.google.mediapipe.proto.** { *; }
-keep class com.google.mediapipe.framework.** { *; }

# flutter_gemma / LiteRT
-keep class com.google.mediapipe.tasks.** { *; }
-keep class org.tensorflow.** { *; }
-dontwarn com.google.mediapipe.proto.**
-dontwarn com.google.mediapipe.framework.**
