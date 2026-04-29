import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun keystoreProperty(name: String): String? =
    keystoreProperties.getProperty(name)?.trim()?.takeIf { it.isNotEmpty() }

fun validateReleaseSigning() {
    if (!keystorePropertiesFile.exists()) {
        throw GradleException(
            "Release signing is not configured. Copy android/key.properties.example " +
                "to android/key.properties and fill it with your real keystore values."
        )
    }

    val requiredProperties = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
    val missingProperties = requiredProperties.filter { keystoreProperty(it) == null }
    if (missingProperties.isNotEmpty()) {
        throw GradleException(
            "Missing release signing properties in android/key.properties: " +
                missingProperties.joinToString(", ")
        )
    }

    val placeholderProperties = requiredProperties.filter {
        val value = keystoreProperty(it)
        value != null && value.startsWith("REPLACE_WITH_")
    }
    if (placeholderProperties.isNotEmpty()) {
        throw GradleException(
            "Replace placeholder values in android/key.properties: " +
                placeholderProperties.joinToString(", ")
        )
    }

    val releaseKeystoreFile = rootProject.file(keystoreProperty("storeFile")!!)
    if (!releaseKeystoreFile.exists()) {
        throw GradleException(
            "Release keystore file not found: ${releaseKeystoreFile.absolutePath}"
        )
    }
}

android {
    namespace = "com.ochag.ochag_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.ochag.ochag_mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperty("keyAlias")
            keyPassword = keystoreProperty("keyPassword")
            storeFile = keystoreProperty("storeFile")?.let { rootProject.file(it) }
            storePassword = keystoreProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

gradle.taskGraph.whenReady {
    val releaseSigningRequired = allTasks.any { task ->
        task.path == ":app:assembleRelease" || task.path == ":app:bundleRelease"
    }
    if (releaseSigningRequired) {
        validateReleaseSigning()
    }
}
