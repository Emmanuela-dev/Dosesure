plugins {
    id("com.google.gms.google-services") version "4.4.4" apply false
}

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
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Workaround: some plugin packages (in pub cache) may not declare an Android
// namespace which is required by newer Android Gradle Plugin versions. After
// evaluation, set a default namespace for any Android library module that
// doesn't have one to avoid "Namespace not specified" build errors.
// Apply namespace fixes after all projects are evaluated to avoid "project is
// already evaluated" errors when Gradle has progressed past the configuration
// phase.
// When the Android library plugin is applied to a subproject, configure a
// default namespace immediately. Using `plugins.withId` ensures this runs as
// soon as the library plugin is applied (before variants are created).
subprojects {
    plugins.withId("com.android.library") {
        try {
            val androidExt = extensions.findByName("android")
            if (androidExt != null) {
                val getNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "getNamespace" }
                val setNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "setNamespace" }
                val current = getNamespace?.invoke(androidExt) as? String
                if (current.isNullOrEmpty()) {
                    val ns = "bite.lab.${project.name.replace('-', '_')}"
                    setNamespace?.invoke(androidExt, ns)
                }
            }
        } catch (ignored: Exception) {
            // Best-effort; ignore failures.
        }
    }
}