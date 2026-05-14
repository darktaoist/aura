import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties().apply {
    if (keyPropertiesFile.exists()) load(keyPropertiesFile.inputStream())
}

android {
    namespace = "kr.co.taoist.gwansang"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "kr.co.taoist.gwansang"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 28
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String
            keyPassword = keyProperties["keyPassword"] as String
            storeFile = file("${keyProperties["storeFile"]}")
            storePassword = keyProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // mediapipe_face_mesh 와 hand_landmarker 가 동일한 JNI 라이브러리를 중복 제공하므로
    // 첫 번째 발견된 버전을 사용하도록 지정 (두 패키지 모두 같은 0.10.x 버전 사용)
    packaging {
        jniLibs {
            pickFirst("lib/arm64-v8a/libmediapipe_tasks_vision_jni.so")
            pickFirst("lib/armeabi-v7a/libmediapipe_tasks_vision_jni.so")
            pickFirst("lib/x86/libmediapipe_tasks_vision_jni.so")
            pickFirst("lib/x86_64/libmediapipe_tasks_vision_jni.so")
        }
    }
}

flutter {
    source = "../.."
}

// tasks-vision-image-generator 가 tasks-vision 의 일부 클래스를 fat-bundle 하여 충돌.
// 이 앱은 Gemma 를 텍스트 전용으로 사용하므로 image-generator 를 제외해도 무방.
// HandLandmarker 클래스는 tasks-vision 에만 있으므로 tasks-vision 은 유지.
configurations.configureEach {
    exclude(group = "com.google.mediapipe", module = "tasks-vision-image-generator")
}
