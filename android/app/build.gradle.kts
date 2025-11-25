import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) {
        file.inputStream().use { this.load(it) }
    }
}
val mapsApiKey: String = localProperties.getProperty("MAPS_API_KEY") ?: ""

android {
    namespace = "com.example.coredo_app"
    compileSdk = 36   // ← flutter.compileSdkVersion の代わりに直接指定
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
        minSdk = flutter.minSdkVersion       // ← flutter.minSdkVersion の代わりに直接指定
        targetSdk = 36     // ← flutter.targetSdkVersion の代わりに直接指定
        versionCode = 1    // ← flutter.versionCode の代わりに直接指定
        versionName = "1.0"// ← flutter.versionName の代わりに直接指定

        // ✅ Manifest に APIキーを渡す
        manifestPlaceholders.put("MAPS_API_KEY", mapsApiKey)
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
