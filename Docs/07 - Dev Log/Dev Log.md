
## 2026-07-01

### Avances

- Se creó el proyecto UltimateApp.
- Se configuró GitHub.
- Se configuró GitHub Desktop.
- Se configuró SwiftLint.
- Se creó la documentación del proyecto usando Obsidian.

### Problemas encontrados

- GitHub no aceptaba contraseña desde terminal.
- Se resolvió usando autenticación correcta.
- SwiftLint marcó error inicial en Xcode.
- Se corrigió el Run Script y permisos.

### Próximos pasos

- Definir estructura de carpetas en Xcode.
- Crear primera pantalla.
- Crear README del repositorio.
- Diseñar pantallas base en Figma.



## 2026-07-01/2

### Avances

- Se creó la clase `DataController`, que será la responsable de administrar toda la comunicación entre la aplicación y Core Data.
- Se implementó el protocolo `ObservableObject` para que SwiftUI pueda observar automáticamente los cambios en los datos y actualizar la interfaz cuando sea necesario.
- Se configuró un `NSPersistentCloudKitContainer`, encargado de cargar el modelo de Core Data, administrar el almacenamiento persistente y permitir la sincronización con iCloud.
- Se inicializó el contenedor indicando el nombre del modelo de datos (`.xcdatamodeld`).
- Se agregó el parámetro `inMemory`, permitiendo utilizar almacenamiento en memoria para pruebas y SwiftUI Previews, o almacenamiento persistente en disco para la aplicación.
- Se comprendió la diferencia entre almacenar datos en memoria y almacenarlos de forma permanente.
- Se crearon datos de ejemplo (`Issue` y `Tag`) para facilitar las pruebas de la interfaz sin necesidad de capturar información manualmente.
- Se aprendió a obtener el `viewContext` desde el contenedor para crear y administrar objetos de Core Data.
- Se comprendió que todas las entidades deben crearse indicando el contexto al que pertenecen (`Issue(context:)` y `Tag(context:)`).
- Se implementó el método `save()` para guardar los cambios realizados en el contexto.
- Se creó un método para eliminar objetos individuales utilizando `NSManagedObject`.
- Se implementó una eliminación masiva mediante `NSBatchDeleteRequest` para borrar múltiples registros de forma más eficiente.
- Se utilizó `mergeChanges()` para sincronizar el `viewContext` después de realizar eliminaciones por lotes.
- Se implementó el método `deleteAll()` para eliminar todos los registros de prueba de las entidades `Issue` y `Tag`.
- Se integró el `DataController` en el punto de entrada de la aplicación utilizando `@StateObject`.
- Se compartió el `viewContext` con SwiftUI mediante `.managedObjectContext`.
- Se compartió el `DataController` con toda la aplicación utilizando `.environmentObject()`.

---

### Conceptos aprendidos

#### DataController

- Centraliza toda la lógica relacionada con Core Data.
- Evita que cada vista tenga que administrar directamente la persistencia de datos.
- Facilita el mantenimiento y reutilización del código.

#### ObservableObject

- Permite que SwiftUI detecte automáticamente los cambios en los datos.
- Las vistas que observan el objeto se actualizan sin necesidad de refrescarlas manualmente.

#### NSPersistentCloudKitContainer

- Carga el modelo de Core Data.
- Administra el almacenamiento persistente.
- Configura automáticamente el Core Data Stack.
- Puede sincronizar la información con iCloud mediante CloudKit.

#### Almacenamiento en memoria

- Guarda los datos únicamente en RAM.
- Los datos desaparecen al cerrar la aplicación.
- Es útil para pruebas y SwiftUI Previews.

#### ViewContext

- Representa el contexto principal donde viven los objetos mientras la aplicación está ejecutándose.
- Mantiene los cambios únicamente en memoria hasta llamar a `save()`.
- Todos los objetos administrados pertenecen a un contexto.

#### save()

- Escribe todos los cambios pendientes en el almacenamiento persistente.
- Debe ejecutarse después de crear, modificar o eliminar objetos.

#### NSManagedObject

- Es la clase base de todas las entidades de Core Data.
- Gracias a ello es posible crear métodos genéricos para eliminar cualquier entidad.

#### NSBatchDeleteRequest

- Permite eliminar grandes cantidades de registros de forma mucho más eficiente que eliminarlos uno por uno.

#### mergeChanges()

- Actualiza el `viewContext` después de realizar una eliminación por lotes.
- Evita inconsistencias entre los objetos que están en memoria y los datos almacenados.

#### @StateObject

- Garantiza que exista una única instancia del `DataController` durante todo el ciclo de vida de la aplicación.

#### .managedObjectContext

- Conecta Core Data con SwiftUI.
- Permite utilizar herramientas como `@FetchRequest`.

#### .environmentObject

- Comparte el `DataController` con todas las vistas de la aplicación.
- Evita tener que pasar la instancia manualmente entre pantallas.

---

### Código importante

#### Crear el DataController

```swift
class DataController: ObservableObject {

}
```

#### Crear el contenedor

```swift
let container = NSPersistentCloudKitContainer(name: "main")
```

#### Guardar cambios

```swift
func save() {
    if container.viewContext.hasChanges {
        try? container.viewContext.save()
    }
}
```

#### Eliminar un objeto

```swift
func delete(_ object: NSManagedObject) {
    objectWillChange.send()
    container.viewContext.delete(object)
    save()
}
```

#### Eliminación por lotes

```swift
private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    batchDeleteRequest.resultType = .resultTypeObjectIDs

    if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {

        let changes = [
            NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []
        ]

        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: changes,
            into: [container.viewContext]
        )
    }
}
```

#### Eliminar todos los registros

```swift
func deleteAll() {
    let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
    delete(request1)

    let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
    delete(request2)
}
```

#### Integrar Core Data con SwiftUI

```swift
@StateObject var dataController = DataController()
```

```swift
.managedObjectContext(dataController.container.viewContext)
.environmentObject(dataController)
```

---

### Problemas encontrados

- Comprender la función específica del `DataController` dentro de la arquitectura de la aplicación.
- Diferenciar el `viewContext` del almacenamiento persistente.
- Entender por qué los cambios no se guardan automáticamente y es necesario llamar a `save()`.
- Comprender por qué todas las entidades deben crearse indicando un contexto.
- Entender el funcionamiento de `mergeChanges()` después de realizar una eliminación por lotes.
- Comprender cuándo utilizar almacenamiento en memoria (`inMemory`) y cuándo almacenamiento persistente.

---

### Recursos utilizados

- 100 Days of SwiftUI.
- Documentación oficial de Apple sobre Core Data.
- Xcode 26.
- SwiftUI.
- Core Data.

---

### Notas personales

- El `DataController` será el único responsable de administrar Core Data dentro del proyecto.
- El `viewContext` funciona como un espacio de trabajo donde viven temporalmente los objetos.
- Ningún cambio se guarda de forma permanente hasta ejecutar `save()`.
- Todas las entidades de Core Data heredan de `NSManagedObject`.
- `NSPersistentCloudKitContainer` simplifica toda la configuración del Core Data Stack.
- Las eliminaciones por lotes requieren sincronizar nuevamente el contexto mediante `mergeChanges()`.
- Compartir el `DataController` mediante `.environmentObject()` evita crear múltiples instancias del controlador.
- Compartir el `viewContext` mediante `.managedObjectContext` permite que cualquier vista pueda consultar datos usando `@FetchRequest`.

---

### Próximos pasos

- Aprender a utilizar `@FetchRequest`.
- Mostrar información almacenada en una lista de SwiftUI.
- Crear registros desde la interfaz.
- Editar registros existentes.
- Eliminar registros desde la interfaz.
- Comprender las relaciones entre entidades (`Issue` y `Tag`).
- Aprender a utilizar `NSPredicate`.
- Aprender a ordenar resultados mediante `SortDescriptor`.
- Implementar operaciones CRUD completas utilizando Core Data.