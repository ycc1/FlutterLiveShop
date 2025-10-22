import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_live_shop"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_live_shop"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // If a key.properties file exists at the android/ folder, use it to sign the release build.
            // Otherwise fall back to the debug signing config so local release builds still work.
            val keyPropsFile = rootProject.file("../key.properties")
            if (keyPropsFile.exists()) {
                val keyProps = Properties()
                keyPropsFile.inputStream().use { stream -> keyProps.load(stream) }
                val storeFilePath = keyProps.getProperty("storeFile")
                val storeFile = if (storeFilePath != null) file(storeFilePath) else null
                signingConfigs.create("release") {
                    storeFile?.let { this.storeFile = it }
                    storePassword = keyProps.getProperty("storePassword")
                    keyAlias = keyProps.getProperty("keyAlias")
                    keyPassword = keyProps.getProperty("keyPassword")
                }
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Signing with the debug keys for now.
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
