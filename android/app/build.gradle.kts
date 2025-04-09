import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
// 获取时间戳的工具函数 修改APK包名
fun getTimestamp(): String = SimpleDateFormat("yyyyMMddHHmm").format(Date())
android.applicationVariants.all {
        val variant = this
        variant.outputs
            .filterIsInstance<com.android.build.gradle.internal.api.BaseVariantOutputImpl>()
            .forEach { output ->
                val outputFileName = "app-${variant.name}-v${variant.versionName}-${getTimestamp()}.apk"
                output.outputFileName = outputFileName
            }
    }

android {
    namespace = "com.template.project_template"
    compileSdk = 35
    ndkVersion = "27.0.12077973"



    signingConfigs {
        create("packJKS"){
            keyAlias = "key" // 别名
            keyPassword = "pl7611346" // 密码
            storeFile = file("/Users/onlypl/key.jks")//file("${rootDir.absolutePath}/keystore/key.jks") //file("/Users/onlypl/key.jks") // 存储keystore或者是jks文件的路径
            storePassword = "pl7611346" // 存储密码
          //  enableV1Signing = true
         //   enableV2Signing = true
        }

    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.template.project_template"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23//flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
//        release {
//            // TODO: Add your own signing config for the release build.
//            // Signing with the debug keys for now, so `flutter run --release` works.
//            signingConfig = signingConfigs.getByName("debug")
//        }

        // 通过前面配置的签名信息对应的标识符：packJKS拿到签名的配置信息
        // 保存在mySignConfig中，分别在debug和release中配置上就行了
        val mySignConfig = signingConfigs.getByName("packJKS")
        release {
           // isDebuggable = true
            isMinifyEnabled = true
            isShrinkResources  = true
          //  isCrunchPngs = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // 配置release 的签名信息
            signingConfig = mySignConfig
        }

        debug {
         ///   isDebuggable = true
            isMinifyEnabled = false
            isShrinkResources  = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // 配置debug的签名信息
            signingConfig = mySignConfig
        }
    }
}

flutter {
    source = "../.."
}
