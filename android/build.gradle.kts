allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    configurations.configureEach {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.glance") {
                useVersion("1.1.1")
                because("glance 1.3 alpha requires compileSdk 37")
            }
        }
    }
}

subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { android ->
            val options = android.javaClass.getMethod("getCompileOptions").invoke(android)
            val java17 = JavaVersion.VERSION_17
            options.javaClass
                .getMethod("setSourceCompatibility", JavaVersion::class.java)
                .invoke(options, java17)
            options.javaClass
                .getMethod("setTargetCompatibility", JavaVersion::class.java)
                .invoke(options, java17)
        }
        tasks.configureEach {
            if (!javaClass.name.contains("KotlinCompile")) return@configureEach
            val kotlinOptions =
                javaClass.methods.firstOrNull { it.name == "getKotlinOptions" }?.invoke(this)
            kotlinOptions?.javaClass?.methods
                ?.firstOrNull { it.name == "setJvmTarget" }
                ?.invoke(kotlinOptions, "17")
            val compilerOptions =
                javaClass.methods.firstOrNull { it.name == "getCompilerOptions" }?.invoke(this)
            val jvmTarget = compilerOptions?.javaClass?.methods
                ?.firstOrNull { it.name == "getJvmTarget" }
                ?.invoke(compilerOptions)
            jvmTarget?.javaClass?.methods
                ?.firstOrNull { it.name == "set" && it.parameterTypes.size == 1 }
                ?.invoke(jvmTarget, org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
