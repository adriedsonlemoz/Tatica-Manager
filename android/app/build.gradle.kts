import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeystorePath = System.getenv("TATICA_KEYSTORE_PATH")
val releaseKeystorePassword = System.getenv("TATICA_KEYSTORE_PASSWORD")
val releaseKeyAlias = System.getenv("TATICA_KEY_ALIAS")
val releaseKeyPassword = System.getenv("TATICA_KEY_PASSWORD")
val hasReleaseSigning = listOf(
    releaseKeystorePath,
    releaseKeystorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { !it.isNullOrBlank() }

android {
    namespace = "com.taticamanager.tatica_manager"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.taticamanager.tatica_manager"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 83
        versionName = "0.1.1.81"
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseKeystorePath!!)
                storePassword = releaseKeystorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            // Distributed CI APKs must always use the same persistent key.
            // Local builds may omit credentials and remain unsigned by this block.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}


flutter {
    source = "../.."
}


kotlin {
    // Keep Kotlin bytecode aligned with Android's Java 17 target.
    // This prevents compileReleaseJavaWithJavac (17) vs compileReleaseKotlin (21).
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}
