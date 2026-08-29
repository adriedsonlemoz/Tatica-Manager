import org.gradle.api.DefaultTask
import org.gradle.api.file.ConfigurableFileCollection
import org.gradle.api.file.DirectoryProperty
import org.gradle.api.tasks.InputFiles
import org.gradle.api.tasks.OutputDirectory
import org.gradle.api.tasks.TaskAction
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

val gdxVersion = "1.14.2"
val gdxNatives by configurations.creating

dependencies {
    implementation("com.badlogicgames.gdx:gdx:$gdxVersion")
    implementation("com.badlogicgames.gdx:gdx-backend-android:$gdxVersion")
    implementation("androidx.fragment:fragment-ktx:1.9.0")

    gdxNatives("com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-arm64-v8a")
    gdxNatives("com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-armeabi-v7a")
    gdxNatives("com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-x86")
    gdxNatives("com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-x86_64")
}

abstract class ExtractGdxNativesTask : DefaultTask() {
    @get:InputFiles
    abstract val nativeJars: ConfigurableFileCollection

    @get:OutputDirectory
    abstract val outputDirectory: DirectoryProperty

    @TaskAction
    fun extract() {
        val outputRoot = outputDirectory.get().asFile
        project.delete(outputRoot)
        outputRoot.mkdirs()

        nativeJars.files.forEach { jar ->
            val abi = when {
                jar.name.contains("natives-arm64-v8a") -> "arm64-v8a"
                jar.name.contains("natives-armeabi-v7a") -> "armeabi-v7a"
                jar.name.contains("natives-x86_64") -> "x86_64"
                jar.name.contains("natives-x86") -> "x86"
                else -> null
            } ?: return@forEach

            project.copy {
                from(project.zipTree(jar))
                include("*.so")
                into(outputRoot.resolve(abi))
                includeEmptyDirs = false
            }
        }
    }
}

val extractGdxNatives = tasks.register<ExtractGdxNativesTask>("extractGdxNatives") {
    nativeJars.from(gdxNatives)
    outputDirectory.set(layout.buildDirectory.dir("generated/gdxNatives"))
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


    packaging {
        resources {
            excludes += setOf(
                "META-INF/robovm/ios/robovm.xml",
                "META-INF/DEPENDENCIES.txt",
                "META-INF/DEPENDENCIES",
                "META-INF/dependencies.txt",
                "**/*.gwt.xml",
            )
            pickFirsts += setOf(
                "META-INF/LICENSE.txt",
                "META-INF/LICENSE",
                "META-INF/license.txt",
                "META-INF/LGPL2.1",
                "META-INF/NOTICE.txt",
                "META-INF/NOTICE",
                "META-INF/notice.txt",
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.taticamanager.tatica_manager"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 111
        versionName = "0.1.1.110"
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


androidComponents {
    onVariants { variant ->
        variant.sources.jniLibs?.addGeneratedSourceDirectory(
            extractGdxNatives,
            ExtractGdxNativesTask::outputDirectory,
        )
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
