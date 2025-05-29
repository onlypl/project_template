import com.android.build.api.dsl.Packaging
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.template.project_template"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    signingConfigs {
        create("packJKS"){
            keyAlias = "key" // 别名
            keyPassword = "pl7611346" // 密码
            storeFile = file("${rootDir.absolutePath}/key.jks")//file("${rootDir.absolutePath}/keystore/key.jks") //file("/Users/onlypl/key.jks") // 存储keystore或者是jks文件的路径
            storePassword = "pl7611346" // 存储密码
          //  enableV1Signing = true
         //   enableV2Signing = true
        }

    }

    buildFeatures {
        buildConfig = true
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
            // 启用 ProGuard
            isMinifyEnabled = true
            isShrinkResources  = true
            ndk.abiFilters.addAll(arrayOf("armeabi-v7a", "arm64-v8a")) //优化体积 ，主流App都不包含x86/x86_64架构
          //  isCrunchPngs = true
            // 使用默认的 ProGuard 文件
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // 配置release 的签名信息
            signingConfig = mySignConfig
            applicationVariants.all {
                val variant = this
                variant.outputs
                    .filterIsInstance<com.android.build.gradle.internal.api.BaseVariantOutputImpl>()
                    .forEach { output ->
                        val outputFileName = "app-${variant.name}-v${variant.versionName}-${SimpleDateFormat("yyyyMMddHHmm").format(Date())}.apk"
                        output.outputFileName = outputFileName
                    }
            }
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


    /////////多渠道多资源

    ////纬度
    ///flavorDimensions表示flavor的维度。比如我们可以根据渠道区分打包方式，
    // 可以根据国家区分打包方式。在上面的例子中，我们以国家区分打包方式，
    // 假定了我们需要两个国家的包：china和usa。
    flavorDimensions += listOf( "market") // 市场维度 环境维度
    //, "environment"
    //dimension
    // 配置渠道对应appid，还支持配置其他渠道参数
    productFlavors {
        ///dev测试
        /// baidu 百度手机助手 yyb 应用宝  m360 360手机助手 pp pp助手
        /// anzhi安智市场 xiaomi小米商店 letv乐视商店 huawei华为商店 lenovomm联想乐商店
        /// other其它市场 official 官方版本
        ///applicationIdSuffix 版本名称后添加后缀
        register("dev") {
            dimension = "market" //环境维度
            applicationId = "com.template.channeldev"
            applicationIdSuffix = ".DEV"
            manifestPlaceholders += mapOf(
                "app_name" to "dev名称",
                "app_icon" to "@mipmap/ic_launcher"
            )
            buildConfigField("String", "API_ENV", "\"DEV\"")
            //额外的配置 字符串类型 key value
            resValue("string", "flavor_name", "Dev")
            matchingFallbacks += listOf("qa", "prod")  // 回退策略
        }

        register("pro") {
            dimension = "market" //环境维度
           // applicationId = "${defaultConfig.applicationId}.dev"
            applicationId = "com.template.channelpro"
            applicationIdSuffix = ".PRO"
            manifestPlaceholders += mapOf(
                "app_name" to "生产名称",
                "app_icon" to "@mipmap/ic_launcher"
            )
            buildConfigField("String", "API_ENV", "\"PRO\"")
            resValue("string", "flavor_name", "Pro")
          //  minSdk = 24  // 专业版提高最低API要求
        }

        register("baidu") {
            dimension = "market" //市场维度
            applicationId = "com.template.channelbaidu"
            applicationIdSuffix = ".BAIDU"
            manifestPlaceholders += mapOf(
                "app_name" to "百度名称",
                "app_icon" to "@mipmap/ic_launcher"
            )
            buildConfigField("String", "MARKET", "\"BAIDU\"")
    //        manifestPlaceholders += ["app_icon": "@mipmap/ic_launcher_cn"]
        }
        register("yyb") {
            dimension = "market" //市场维度
            applicationId = "com.template.channelyyb"
            manifestPlaceholders += mapOf(
                "app_name" to "应用宝名称",
                "app_icon" to "@mipmap/ic_launcher"
            )
            buildConfigField("String", "MARKET", "\"YYB\"")
            applicationIdSuffix = ".YYB"
        }
    }
    //配置渠道对应的安卓资源目录
    sourceSets {
        getByName("dev").res.srcDirs("src/main/res-dev");
        getByName("pro").res.srcDirs("src/main/res-pro");
        getByName("baidu").res.srcDirs("src/main/res-baidu");
        getByName("yyb").res.srcDirs("src/main/res-yyb");
    }
}

flutter {
    source = "../.."
}
