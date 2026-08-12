import java.util.Properties
import java.io.FileInputStream
import java.io.FileNotFoundException

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
try {
    val keystorePropertiesFile = rootProject.file("key.properties")
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} catch (e: FileNotFoundException) {
    println("Warning: key.properties file not found. Ensure the file is present before building the release version.")
}

android {
    namespace = "com.rchrdariza.retropod"
    compileSdk = 37
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.rchrdariza.retropod"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk.abiFilters.addAll(arrayOf("armeabi-v7a", "arm64-v8a", "x86_64"))
    }

    buildFeatures {
        resValues = true
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as? String
            keyPassword = keystoreProperties["keyPassword"] as? String
            storePassword = keystoreProperties["storePassword"] as? String
            val storeFilePath = keystoreProperties["storeFile"] as? String
            if (storeFilePath != null) {
                storeFile = file(keystoreProperties["storeFile"] as String)
            }
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            // Fallback to debug signing if the release keystore isn't configured
            val storeFilePath = keystoreProperties["storeFile"] as? String
            signingConfig = if (storeFilePath != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }

    flavorDimensions += "default"
    productFlavors {
        create("production") {
            dimension = "default"
            resValue("string", "app_name", "RetroPod")
            applicationIdSuffix = ""
        }
        create("dev") {
            dimension = "default"
            resValue("string", "app_name", "RetroPod Dev")
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
