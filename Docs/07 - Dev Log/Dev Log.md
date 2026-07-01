
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

### Empezando con la UI

#### NavigationSplitView

- Se comenzó a construir la interfaz principal utilizando `NavigationSplitView`.
- Este componente permite dividir la navegación en tres áreas principales:

| Sección | Función |
|---|---|
| **Sidebar** | Muestra filtros, secciones o categorías. |
| **Content View** | Muestra el contenido principal seleccionado. |
| **Detail View** | Muestra los detalles del elemento seleccionado. |

La idea principal es que la aplicación permita visualizar fácilmente todos los issues, los issues recientes y los issues filtrados por etiquetas.

---

#### Creación del modelo Filter

- Se creó una estructura llamada `Filter`.
- Esta estructura representa los filtros que se mostrarán en la barra lateral.
- Cada filtro contiene un nombre, un icono y, opcionalmente, una etiqueta (`Tag`) asociada.

```swift
struct Filter: Identifiable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var minModificationDate = Date.distantPast
    var tag: Tag?
}
```

---

#### Propiedades del filtro

| Propiedad | Descripción |
|---|---|
| `id` | Identificador único del filtro. |
| `name` | Nombre que se mostrará en pantalla. |
| `icon` | Icono del sistema utilizado en la interfaz. |
| `minModificationDate` | Fecha mínima para mostrar issues recientes. |
| `tag` | Etiqueta opcional usada para filtrar issues por categoría. |

`minModificationDate` se inicializa con `Date.distantPast`, lo que permite mostrar todos los issues por defecto, a menos que se indique una fecha más reciente.

---

#### Filtros inteligentes

- Se agregaron dos filtros principales para la aplicación:

```swift
static var all = Filter(id: UUID(), name: "All Issues", icon: "tray")

static var recent = Filter(
    id: UUID(),
    name: "Recent Issues",
    icon: "clock",
    minModificationDate: .now.addingTimeInterval(86400 * -7)
)
```

| Filtro | Función |
|---|---|
| `All Issues` | Muestra todos los issues. |
| `Recent Issues` | Muestra los issues modificados en los últimos 7 días. |

El filtro de issues recientes utiliza `86400 * -7`, ya que un día tiene 86,400 segundos. Esto permite calcular aproximadamente los últimos siete días.

---

#### Personalización de Hashable y Equatable

- Se personalizó la comparación entre filtros.
- Aunque un filtro tenga nombre, icono, fecha o etiqueta, lo único importante para identificarlo es su `id`.

```swift
func hash(into hasher: inout Hasher) {
    hasher.combine(id)
}

static func ==(lhs: Filter, rhs: Filter) -> Bool {
    lhs.id == rhs.id
}
```

Esto evita comportamientos extraños si una etiqueta cambia con el tiempo.

---

#### Selección del filtro actual

- Se agregó una propiedad publicada dentro de `DataController` para almacenar el filtro seleccionado por el usuario:

```swift
@Published var selectedFilter: Filter? = Filter.all
```

Esto permite que SwiftUI actualice la interfaz cuando el usuario seleccione un filtro diferente.

---

#### Configuración de SidebarView

- En `SidebarView` se lee la instancia compartida de `DataController` desde el entorno:

```swift
@EnvironmentObject var dataController: DataController
```

- También se creó un arreglo con los filtros inteligentes:

```swift
let smartFilters: [Filter] = [.all, .recent]
```

---

#### Lista de filtros inteligentes

- Se creó una lista para mostrar los filtros dentro del sidebar:

```swift
List(selection: $dataController.selectedFilter) {
    Section("Smart Filters") {
        ForEach(smartFilters) { filter in
            NavigationLink(value: filter) {
                Label(filter.name, systemImage: filter.icon)
            }
        }
    }
}
```

Con esto se puede seleccionar un filtro desde la barra lateral y almacenar esa selección dentro del `DataController`.

---

#### Soporte para previews

- Para que las vistas previas de Xcode funcionen correctamente, se agregó el `DataController` como objeto de entorno:

```swift
static var previews: some View {
    SidebarView()
        .environmentObject(DataController.preview)
}
```

---

#### Carga de etiquetas desde Core Data

- Como ya existe una entidad llamada `Tag`, se agregó una consulta para cargar todas las etiquetas en orden alfabético:

```swift
@FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
```

`@FetchRequest` permite que SwiftUI actualice automáticamente la interfaz cuando se agregan, eliminan o modifican etiquetas.

---

#### Conversión de Tag a Filter

- Las etiquetas de Core Data no se muestran directamente.
- Primero se convierten en filtros para que puedan usarse igual que los filtros inteligentes.

```swift
var tagFilters: [Filter] {
    tags.map { tag in
        Filter(
            id: tag.id ?? UUID(),
            name: tag.name ?? "No name",
            icon: "tag",
            tag: tag
        )
    }
}
```

Esto permite que cada etiqueta tenga:

- Un identificador.
- Un nombre.
- Un icono.
- Una referencia a la entidad `Tag`.

---

#### Nota sobre opcionales en Core Data

- Aunque un atributo sea marcado como obligatorio dentro del modelo de Core Data, Xcode puede generarlo como opcional en Swift.
- Esto sucede porque Core Data valida los datos principalmente al momento de guardar el contexto.
- Por eso se utilizan valores por defecto como:

```swift
tag.id ?? UUID()
tag.name ?? "No name"
```

Esto evita errores cuando Swift intenta leer valores opcionales.

---

#### Mostrar etiquetas en el sidebar

- Se agregó una segunda sección a la lista para mostrar las etiquetas creadas por el usuario:

```swift
Section("Tags") {
    ForEach(tagFilters) { filter in
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon)
        }
    }
}
```

De esta forma, la barra lateral puede mostrar tanto filtros inteligentes como filtros basados en etiquetas.

---

#### Botón para crear datos de ejemplo

- Se agregó un botón temporal en la barra de herramientas para borrar los datos actuales y crear datos de ejemplo:

```swift
.toolbar {
    Button {
        dataController.deleteAll()
        dataController.createSampleData()
    } label: {
        Label("ADD SAMPLES", systemImage: "flame")
    }
}
```

Este botón es útil durante el desarrollo porque permite probar rápidamente la interfaz con información realista.

---

#### Resultado de esta sección

- Se configuró la estructura inicial de la interfaz con `NavigationSplitView`.
- Se crearon filtros inteligentes para mostrar todos los issues y los issues recientes.
- Se integraron las etiquetas de Core Data como filtros dinámicos.
- Se conectó la selección del usuario con el `DataController`.
- Se agregó soporte para datos de prueba mediante `createSampleData()`.

---

#### Próximos pasos

- Mostrar los issues correspondientes al filtro seleccionado.
- Crear la vista de contenido principal.
- Crear la vista de detalle de cada issue.
- Permitir crear nuevas etiquetas desde la interfaz.
- Implementar búsqueda y ordenamiento de issues.
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