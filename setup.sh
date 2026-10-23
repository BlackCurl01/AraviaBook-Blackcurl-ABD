#!/bin/bash
echo "Creating folders..."
mkdir -p app/src/main/java/com/blackcurl/araviabook
mkdir -p app/src/main/res/values
mkdir -p .github/workflows
mkdir -p gradle/wrapper

echo "Downloading gradle wrapper..."
wget -q -O gradlew https://raw.githubusercontent.com/Mantii04/Flickv4-Native/player-switcher/gradlew
wget -q -O gradle/wrapper/gradle-wrapper.jar https://raw.githubusercontent.com/Mantii04/Flickv4-Native/player-switcher/gradle/wrapper/gradle-wrapper.jar
wget -q -O gradle/wrapper/gradle-wrapper.properties https://raw.githubusercontent.com/Mantii04/Flickv4-Native/player-switcher/gradle/wrapper/gradle-wrapper.properties
chmod +x gradlew

echo "Writing project files..."
cat << 'INNER' > settings.gradle.kts
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement { repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS); repositories { google(); mavenCentral() } }
rootProject.name = "AraviaBook"
include(":app")
INNER

cat << 'INNER' > build.gradle.kts
plugins {
    id("com.android.application") version "8.5.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}
INNER

cat << 'INNER' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
INNER

cat << 'INNER' > app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}
android {
    namespace = "com.blackcurl.araviabook"
    compileSdk = 34
    defaultConfig { applicationId = "com.blackcurl.araviabook"; minSdk = 24; targetSdk = 34; versionCode = 1; versionName = "1.0" }
    buildTypes { release { isMinifyEnabled = false } }
    compileOptions { sourceCompatibility = JavaVersion.VERSION_17; targetCompatibility = JavaVersion.VERSION_17 }
    kotlinOptions { jvmTarget = "17" }
    buildFeatures { compose = true }
    composeOptions { kotlinCompilerExtensionVersion = "1.5.14" }
}
dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.3")
    implementation("androidx.activity:activity-compose:1.9.0")
    implementation(platform("androidx.compose:compose-bom:2024.06.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
}
INNER

cat << 'INNER' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <application android:allowBackup="true" android:label="AraviaBook" android:theme="@android:style/Theme.Material.Light.NoActionBar">
        <activity android:name=".MainActivity" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
INNER

cat << 'INNER' > app/src/main/java/com/blackcurl/araviabook/MainActivity.kt
package com.blackcurl.araviabook
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    Column(
                        modifier = Modifier.fillMaxSize().padding(24.dp),
                        verticalArrangement = Arrangement.Center,
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(text = "AraviaBook", style = MaterialTheme.typography.headlineLarge)
                        Text(text = "Auto-Built on GitHub Actions", style = MaterialTheme.typography.bodyMedium)
                    }
                }
            }
        }
    }
}
INNER

cat << 'INNER' > .github/workflows/build.yml
name: Build Android APK
on: [push, workflow_dispatch]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { java-version: '17', distribution: 'temurin' }
      - run: chmod +x gradlew
      - run: ./gradlew assembleRelease
      - uses: actions/upload-artifact@v4
        with:
          name: AraviaBook-APK
          path: app/build/outputs/apk/release/app-release-unsigned.apk
INNER

echo "Pushing to GitHub..."
git add .
git add -f gradle/wrapper/gradle-wrapper.jar
git commit -m "Auto-initialized Android project structure"
git push origin main

echo "DONE! Check GitHub Actions page."
