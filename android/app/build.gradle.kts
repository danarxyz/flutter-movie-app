plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Apply signing configuration if key.properties exists
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    apply(from = keystorePropertiesFile.parent + "/signing.gradle")
}

android {
    namespace = "com.danar.watchlyapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.danar.watchlyapp"
        minSdk = flutter.minSdkVersion
        targetSdk = 35  // Updated to Android 15 (Vanilla Ice Cream) per user request
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Temporarily disable minification to troubleshoot
            isMinifyEnabled = false
            isShrinkResources = false
            
            // ProGuard/R8 configuration files (disabled for now)
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
            
            // Signing config will be set by signing.gradle if it exists
            // Otherwise defaults to debug
            if (!keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
