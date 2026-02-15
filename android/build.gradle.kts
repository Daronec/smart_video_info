plugins {
    id("com.android.library")
    id("kotlin-android")
}

group = "com.daronec.smart_video_info"
version = "1.0.0"

android {
    namespace = "com.daronec.smart_video_info"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        minSdk = 26
    }
}

repositories {
    google()
    mavenCentral()
    maven { url = uri("https://jitpack.io") }
}

dependencies {
    implementation("com.github.Daronec:smart-ffmpeg-android:1.0.6")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}
