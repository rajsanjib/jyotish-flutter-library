plugins {
    id("com.android.library")
}

android {
    namespace = "com.astronaksh.jyotish"
    compileSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        minSdk = 21
    }
}

dependencies {
    testImplementation("junit:junit:4.13.2")
}
