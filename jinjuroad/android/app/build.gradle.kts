    import java.util.Properties

    plugins {
        id("com.android.application")
        id("kotlin-android")
        id("dev.flutter.flutter-gradle-plugin")
    }

    android {
        namespace = "com.jinjuroad"
        compileSdk = flutter.compileSdkVersion
        ndkVersion = "27.0.12077973"

        // ✅ BuildConfig 사용 활성화 (이게 핵심!!)
        buildFeatures {
            buildConfig = true
        }

        // 🔹 local.properties에서 Kakao Map Key 불러오기
        val localProps = Properties()
        val localFile = rootProject.file("local.properties")
        if (localFile.exists()) {
            localFile.inputStream().use { localProps.load(it) }
        }
        val kakaoKey = localProps.getProperty("KAKAO_MAP_KEY") ?: ""

        defaultConfig {
            applicationId = "com.jinjuroad"
            minSdk = 23
            targetSdk = flutter.targetSdkVersion
            versionCode = flutter.versionCode
            versionName = flutter.versionName
            multiDexEnabled = true
            resValue("string", "kakao_native_key", kakaoKey)
        }

        buildTypes {
            getByName("debug") {
                buildConfigField("String", "KAKAO_MAP_KEY", "\"$kakaoKey\"")
            }
            getByName("release") {
                buildConfigField("String", "KAKAO_MAP_KEY", "\"$kakaoKey\"")
                signingConfig = signingConfigs.getByName("debug")
            }
        }

        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_11
            targetCompatibility = JavaVersion.VERSION_11
        }

        kotlinOptions {
            jvmTarget = "11"
        }
    }

    flutter {
        source = "../.."
    }

    dependencies {
        implementation("com.kakao.maps.open:android:2.12.18") // 필요하면 버전 조정
    }
