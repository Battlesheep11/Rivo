plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.rivo.app"
    compileSdk = 36  // bump to 36 for the newer plugins

    defaultConfig {
        applicationId = "com.rivo.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Toolchain is on JDK 21 (AGP 8.7.3 + Gradle 8.9 support it)
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            // isMinifyEnabled = true
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
    }

    // If you ever hit META-INF duplicate errors, uncomment:
    // packaging {
    //     resources {
    //         excludes += setOf(
    //             "META-INF/AL2.0", "META-INF/LGPL2.1",
    //             "META-INF/DEPENDENCIES", "META-INF/INDEX.LIST"
    //         )
    //     }
    // }
}

kotlin {
    jvmToolchain(21)
}

flutter {
    source = "../.."
}
