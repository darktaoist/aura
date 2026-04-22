plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "kr.co.taoist.gwansang.gwansang"
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
        applicationId = "kr.co.taoist.gwansang.gwansang"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 28
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
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

// tasks-vision-image-generator 는 tasks-vision 의 슈퍼셋이므로
// standalone tasks-vision 을 제외해 클래스 중복을 해소
configurations.configureEach {
    exclude(group = "com.google.mediapipe", module = "tasks-vision")
}
