plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 環境変数からキーを取得
val mapsApiKey: String = System.getenv("GOOGLE_API_KEY") ?: ""

android {
    namespace = "com.example.coredo_app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        applicationId = "com.coredo_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"

        // ✅ Manifest に APIキーを渡す
        manifestPlaceholders.put("PLACES_API_KEY", mapsApiKey)
    }

    buildTypes {
        debug {
            resValue("string", "maps_api_key", mapsApiKey)
        }
        release {
            resValue("string", "maps_api_key", mapsApiKey)
        }
    }
}

flutter {
    source = "../.."
}