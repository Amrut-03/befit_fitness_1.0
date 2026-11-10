allprojects {
    repositories {
        google()
        mavenCentral()
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
// pedometer_2 hard-codes compileSdk 33, but its AndroidX dependencies need 34+.
// Must be registered before evaluationDependsOn(":app") below.
subprojects {
    if (project.name == "pedometer_2") {
        afterEvaluate {
            extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
                ?.compileSdk = 36
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
