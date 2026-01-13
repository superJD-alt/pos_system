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

subprojects {
    // Buscamos la extensión "android" directamente en cada subproyecto
    val androidExtension = project.extensions.findByName("android")
    if (androidExtension != null) {
        try {
            // Intentamos obtener el namespace actual usando reflexión
            val getNamespace = androidExtension.javaClass.getMethod("getNamespace")
            val currentNamespace = getNamespace.invoke(androidExtension)

            // Si no tiene uno definido, se lo inyectamos basado en el nombre del proyecto
            if (currentNamespace == null) {
                val setNamespace = androidExtension.javaClass.getMethod("setNamespace", String::class.java)
                val packageName = "id.flutter_plugins.${project.name.replace("-", "_")}"
                setNamespace.invoke(androidExtension, packageName)
                println(">>> Parche aplicado: Namespace configurado para ${project.name} como $packageName")
            }
        } catch (e: Exception) {
            // Si el proyecto ya tiene namespace o usa una versión vieja, ignoramos el error
        }
    }
}