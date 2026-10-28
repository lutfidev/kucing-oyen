import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// TEMPEL ID ASLI DI SINI: ID aplikasi AdMob (Aplikasi → Setelan aplikasi,
// bentuknya ca-app-pub-...~...). Sementara masih ID aplikasi uji Google.
// ID unit iklan berhadiah ditempel di lib/app/ad_ids.dart.
val admobAppId = "ca-app-pub-3940256099942544~3347511713"
val admobTestAppId = "ca-app-pub-3940256099942544~3347511713"

// Kunci upload untuk Play Console (keystore di luar repo). Tanpa
// android/key.properties, APK release ditandatangani debug key supaya
// `flutter run --release` tetap jalan, sedangkan app bundle (untuk
// diunggah) ditolak. Lihat docs/store/README.md.
val keyProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseKey = keyProperties.getProperty("storeFile") != null

android {
    namespace = "com.gingerlogic.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.gingerlogic.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobAppId"] = admobAppId
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

// App bundle tanpa upload key ditolak (Play Console juga menolaknya);
// build release lain yang belum siap diunggah hanya diberi peringatan.
gradle.taskGraph.whenReady {
    if (allTasks.any { it.name == "bundleRelease" } && !hasReleaseKey) {
        throw GradleException(
            "Ginger Logic: android/key.properties tidak ada, jadi app bundle release tidak bisa ditandatangani upload key. " +
                "Buat keystore dan key.properties dulu (docs/store/README.md, bagian Signing). " +
                "Untuk mencoba build release tanpa kunci, pakai flutter build apk --release atau flutter run --release."
        )
    }
    if (allTasks.any { it.name.contains("Release") }) {
        if (!hasReleaseKey) {
            logger.warn("Ginger Logic: android/key.properties tidak ada, build release ditandatangani debug key (tidak bisa diunggah ke Play Console).")
        }
        if (admobAppId == admobTestAppId) {
            logger.warn("Ginger Logic: masih ID aplikasi AdMob uji. Tempel ID asli di android/app/build.gradle.kts dan lib/app/ad_ids.dart sebelum rilis produksi.")
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
