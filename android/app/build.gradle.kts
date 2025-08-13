plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.rivo.app"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.rivo.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
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

    // Optional – only if you hit META-INF duplicate errors
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
    jvmToolchain(17)
}

flutter {
    source = "../.."
}