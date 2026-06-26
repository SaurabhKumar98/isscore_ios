import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.firstedu.app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

   signingConfigs {
    create("release") {
        val storeFilePath = keystoreProperties["storeFile"]?.toString()
        if (storeFilePath != null && storeFilePath.isNotEmpty()) {
            storeFile = file(storeFilePath)
        }
        keyAlias = keystoreProperties["keyAlias"]?.toString() ?: ""
        keyPassword = keystoreProperties["keyPassword"]?.toString() ?: ""
        storePassword = keystoreProperties["storePassword"]?.toString() ?: ""
    }
}



    defaultConfig {
        applicationId = "com.firstedu.app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // Use release signing config
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.3.0"))
    implementation("com.google.firebase:firebase-messaging")
    
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

}
