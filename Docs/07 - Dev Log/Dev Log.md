
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










## 2026-07-02

### Avances

- Se analizó el problema de la opcionalidad en Core Data y la diferencia entre los opcionales de Core Data y los opcionales de Swift.
- Se comprendió por qué no es recomendable modificar manualmente las clases generadas por Core Data para eliminar los opcionales.
- Se estudió el funcionamiento de **Codegen** y cómo Xcode genera automáticamente las clases `NSManagedObject`.
- Se aprendió a crear subclases manuales de `NSManagedObject` mediante **Editor → Create NSManagedObject Subclass**, entendiendo sus ventajas y desventajas.
- Se decidió mantener la generación automática de clases (`Class Definition`) y resolver la opcionalidad mediante extensiones.
- Se creó el archivo `Issue-CoreDataHelpers.swift` para encapsular toda la lógica relacionada con las propiedades de `Issue`.
- Se agregaron propiedades calculadas (`issueTitle`, `issueContent`, `issueCreationDate` e `issueModificationDate`) para evitar utilizar coalescencia de nulos (`??`) en toda la aplicación.
- Se implementaron getters y setters para facilitar la lectura y escritura de propiedades de Core Data.
- Se creó una propiedad estática `example` en `Issue` para generar datos de ejemplo utilizando un `DataController` en memoria.
- Se creó el archivo `Tag-CoreDataHelpers.swift` para centralizar los helpers relacionados con la entidad `Tag`.
- Se agregaron propiedades calculadas (`tagID` y `tagName`) para eliminar la necesidad de trabajar directamente con opcionales.
- Se implementó una propiedad estática `example` para generar etiquetas de ejemplo durante las vistas previas de SwiftUI.
- Se simplificó el manejo de las relaciones entre entidades utilizando propiedades calculadas.
- Se creó la propiedad `issueTags` para convertir el `NSSet` de etiquetas en un arreglo ordenado de objetos `Tag`.
- Se implementó la conformidad de `Issue` con el protocolo `Comparable` para ordenar los issues por título y, en caso de empate, por fecha de creación.
- Se creó la propiedad `tagActiveIssues` para obtener únicamente los issues activos asociados a una etiqueta.
- Se implementó la conformidad de `Tag` con el protocolo `Comparable` para ordenar las etiquetas por nombre y garantizar un orden estable.
- Se simplificó `SidebarView` utilizando los nuevos helpers (`tagID`, `tagName` y `tagActiveIssues`).
- Se agregó un contador (`badge`) que muestra el número de issues activos asociados a cada etiqueta.

---

### Conceptos aprendidos

#### Opcionales en Core Data

- Los atributos marcados como obligatorios en el modelo de Core Data siguen generándose como opcionales en Swift.
- Core Data únicamente valida los valores obligatorios cuando se guarda el contexto mediante `save()`.
- Debido a esto, eliminar manualmente los opcionales puede producir comportamientos inesperados.

---

#### Codegen

- `Codegen` es el mecanismo mediante el cual Xcode genera automáticamente las clases `NSManagedObject`.
- Existen distintos modos de generación, siendo **Class Definition** el recomendado para la mayoría de los proyectos.
- Cambiar a **Manual/None** permite editar las clases, pero incrementa el mantenimiento del código.

---

#### ¿Por qué no eliminar los opcionales manualmente?

Se identificaron varias desventajas:

- Swift asume que la propiedad siempre tendrá un valor, aunque Core Data aún pueda contener `nil`.
- Al regenerar las clases, todos los cambios manuales se pierden.
- Se dificulta aprovechar futuras mejoras realizadas por Apple.
- Se modifica el comportamiento esperado por Core Data.

Por estas razones se decidió mantener la generación automática y crear extensiones auxiliares.

---

#### Extensiones auxiliares

Las extensiones permiten:

- Centralizar toda la lógica relacionada con Core Data.
- Eliminar la repetición de código.
- Evitar escribir `??` constantemente.
- Mejorar la legibilidad del proyecto.
- Facilitar el mantenimiento futuro.

---

#### Propiedades calculadas

Se agregaron propiedades calculadas para trabajar con valores seguros:

```swift
issueTitle
issueContent
issueCreationDate
issueModificationDate

tagID
tagName
```

Gracias a ellas, el resto del proyecto ya no necesita preocuparse por la opcionalidad.

---

#### Datos de ejemplo

Se implementaron propiedades estáticas llamadas `example` tanto para `Issue` como para `Tag`.

Estas propiedades crean datos temporales utilizando:

```swift
DataController(inMemory: true)
```

Esto facilita:

- SwiftUI Previews.
- Pruebas rápidas.
- Desarrollo de la interfaz.

---

#### Relaciones entre entidades

Se aprendió que Core Data almacena las relaciones utilizando `NSSet`.

Sin embargo, trabajar directamente con `NSSet` resulta poco cómodo porque:

- No conoce el tipo de objetos almacenados.
- Requiere conversiones.
- Obliga a utilizar opcionales.

Para solucionar esto se crearon propiedades calculadas que convierten esas relaciones en arreglos de Swift.

---

#### issueTags

```swift
var issueTags: [Tag]
```

Esta propiedad:

- Convierte el `NSSet` en `[Tag]`.
- Elimina los opcionales.
- Ordena automáticamente las etiquetas.

---

#### Comparable

Se implementó el protocolo `Comparable` para ambas entidades.

##### Issue

Los issues se ordenan por:

1. Título.
2. Fecha de creación.

Esto garantiza un orden consistente en toda la aplicación.

##### Tag

Las etiquetas se ordenan por:

1. Nombre.
2. UUID (en caso de empate).

Esto evita cambios aleatorios en la interfaz.

---

#### tagActiveIssues

```swift
var tagActiveIssues: [Issue]
```

Esta propiedad devuelve únicamente los issues que aún no han sido completados.

Esto facilita mostrar estadísticas y contadores dentro de la interfaz.

---

#### Badge

Se agregó un contador utilizando:

```swift
.badge(filter.tag?.tagActiveIssues.count ?? 0)
```

Cada etiqueta muestra automáticamente el número de issues activos asociados.

---

### Código importante

#### Helpers para Issue

```swift
extension Issue {

    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }

    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }

    var issueCreationDate: Date {
        creationDate ?? .now
    }

    var issueModificationDate: Date {
        modificationDate ?? .now
    }

}
```

---

#### Issue de ejemplo

```swift
static var example: Issue
```

---

#### Helpers para Tag

```swift
extension Tag {

    var tagID: UUID {
        id ?? UUID()
    }

    var tagName: String {
        name ?? ""
    }

}
```

---

#### Tag de ejemplo

```swift
static var example: Tag
```

---

#### Conversión de NSSet a Array

```swift
var issueTags: [Tag]
```

---

#### Issues activos

```swift
var tagActiveIssues: [Issue]
```

---

#### Comparable para Issue

```swift
extension Issue: Comparable
```

Ordena por título y fecha de creación.

---

#### Comparable para Tag

```swift
extension Tag: Comparable
```

Ordena por nombre y UUID.

---

#### Badge

```swift
.badge(filter.tag?.tagActiveIssues.count ?? 0)
```

---




## 2026-07-04
### Avances

- Se corrigieron dos aspectos importantes del proyecto:
  - Se cambió `@State` por `@StateObject` para que `DataController` permanezca vivo durante todo el ciclo de vida de la aplicación.
  - Se actualizó el método `delete()` para notificar a SwiftUI antes de eliminar un objeto utilizando `objectWillChange.send()`.
- Se comenzó la implementación de la lógica para mostrar los issues según el filtro seleccionado en la barra lateral.
- Se agregó `DataController` como `EnvironmentObject` dentro de `ContentView`.
- Se creó una propiedad calculada llamada `issues`, encargada de obtener automáticamente los issues según el filtro activo.
- Se implementó la lógica para diferenciar entre filtros inteligentes y filtros basados en etiquetas (`Tag`).
- Se incorporó un `NSPredicate` para mostrar únicamente los issues modificados después de una fecha determinada, permitiendo el funcionamiento del filtro **Recent Issues**.
- Se comenzó la construcción de la interfaz principal mostrando todos los issues mediante un `List` y `ForEach`.
- Se creó una nueva vista llamada `IssueRow` para representar visualmente cada issue dentro de la lista.
- Se diseñó una fila personalizada que muestra:
  - Prioridad del issue.
  - Título.
  - Etiquetas.
  - Fecha de creación.
  - Estado (abierto o cerrado).
- Se implementó navegación utilizando `NavigationLink`, preparando la futura vista de detalle de cada issue.
- Se agregó soporte para eliminar etiquetas desde `SidebarView`.
- Se agregó soporte para eliminar issues desde `ContentView`.
- Se configuró Core Data para sincronizar automáticamente los cambios provenientes de otros dispositivos mediante CloudKit.
- Se habilitó la fusión automática de cambios utilizando `automaticallyMergesChangesFromParent`.
- Se configuró una política de fusión (`mergePolicy`) para resolver conflictos cuando existen cambios simultáneos entre dispositivos.
- Se implementó un observador para detectar cambios remotos del almacenamiento persistente y actualizar automáticamente la interfaz de usuario.

---

### Conceptos aprendidos

#### @StateObject

- `DataController` debe declararse como `@StateObject` para garantizar que exista una única instancia durante toda la ejecución de la aplicación.
- Utilizar `@State` provocaría que el controlador pudiera recrearse inesperadamente.

---

#### objectWillChange

- Antes de modificar los datos es recomendable notificar a SwiftUI mediante:

```swift
objectWillChange.send()
```

- Esto asegura que la interfaz se actualice correctamente cuando un objeto sea eliminado.

---

#### Filtros dinámicos

Se creó una propiedad calculada:

```swift
var issues: [Issue]
```

Su responsabilidad es:

- Obtener el filtro seleccionado.
- Determinar si el filtro corresponde a una etiqueta o a un filtro inteligente.
- Recuperar únicamente los issues que deben mostrarse.

Esto centraliza toda la lógica relacionada con Core Data en un solo lugar.

---

#### NSPredicate

Para el filtro **Recent Issues** se utilizó un predicado:

```swift
request.predicate = NSPredicate(
    format: "modificationDate > %@",
    filter.minModificationDate as NSDate
)
```

Este predicado permite que Core Data devuelva únicamente los issues modificados después de una fecha específica.

Se aprendió que Core Data trabaja con `NSDate`, por lo que es necesario convertir `Date` antes de utilizarlo en un predicado.

---

#### FetchRequest

Se utilizó un `FetchRequest` para recuperar los issues almacenados.

Cuando el filtro corresponde a una etiqueta:

- Los issues se obtienen directamente desde la relación `Tag`.

Cuando el filtro corresponde a un filtro inteligente:

- Se ejecuta una consulta (`fetch`) sobre Core Data.

---

#### IssueRow

Se creó una vista independiente llamada `IssueRow`.

Separar la interfaz en componentes reutilizables permite:

- Mejor organización del proyecto.
- Código más limpio.
- Reutilización en diferentes vistas.

Cada fila muestra:

- Prioridad.
- Título.
- Etiquetas.
- Fecha de creación.
- Estado del issue.

---

#### NavigationLink

Cada issue se encuentra envuelto dentro de un:

```swift
NavigationLink
```

Esto permitirá navegar posteriormente hacia la vista de detalle correspondiente.

---

#### Eliminación de registros

Se agregó soporte para eliminar información utilizando:

```swift
.onDelete()
```

Esto permite deslizar una fila y eliminar:

- Issues.
- Tags.

Toda la eliminación continúa siendo administrada por `DataController`.

---

#### Sincronización automática

Se habilitó:

```swift
container.viewContext.automaticallyMergesChangesFromParent = true
```

Con esto, el `viewContext` se mantiene sincronizado automáticamente con los cambios provenientes del almacenamiento persistente.

---

#### Merge Policy

Se configuró:

```swift
NSMergePolicy.mergeByPropertyObjectTrump
```

Esta política permite fusionar automáticamente cambios realizados desde distintos dispositivos.

Si dos dispositivos modifican propiedades diferentes del mismo objeto:

- Core Data conserva ambas modificaciones.

Si ambos modifican exactamente la misma propiedad:

- Se mantiene el valor del objeto actualmente cargado en memoria.

---

#### Cambios remotos

Se aprendió a detectar cambios provenientes de CloudKit mediante:

```swift
NotificationCenter
```

Cada vez que el almacenamiento persistente cambia, se ejecuta:

```swift
remoteStoreChanged()
```

Este método notifica a SwiftUI para actualizar automáticamente la interfaz sin necesidad de reiniciar la aplicación.

---

### Código importante

#### Obtener los issues

```swift
var issues: [Issue]
```

---

#### Filtrar mediante NSPredicate

```swift
request.predicate = NSPredicate(
    format: "modificationDate > %@",
    filter.minModificationDate as NSDate
)
```

---

#### Crear IssueRow

```swift
struct IssueRow: View
```

---

#### Eliminar registros

```swift
.onDelete()
```

---

#### Sincronización automática

```swift
container.viewContext.automaticallyMergesChangesFromParent = true
```

---

#### Política de fusión

```swift
container.viewContext.mergePolicy =
NSMergePolicy.mergeByPropertyObjectTrump
```

---

#### Detectar cambios remotos

```swift
NotificationCenter.default.addObserver(...)
```

---

### Problemas encontrados

- Comprender cuándo utilizar un filtro inteligente y cuándo utilizar una etiqueta.
- Entender el funcionamiento de `NSPredicate`.
- Comprender cómo Core Data realiza consultas utilizando `FetchRequest`.
- Entender cómo sincronizar automáticamente los cambios provenientes de CloudKit.
- Comprender cómo resolver conflictos cuando dos dispositivos modifican el mismo objeto.

---

### Recursos utilizados

- 100 Days of SwiftUI.
- Documentación oficial de Apple sobre Core Data. :contentReference[oaicite:0]{index=0}
- Xcode 26.
- SwiftUI.
- Core Data.
- CloudKit.

---

### Notas personales

- Toda la lógica relacionada con Core Data debe permanecer dentro del `DataController`.
- Las vistas únicamente deberían encargarse de mostrar la información.
- Separar componentes como `IssueRow` facilita enormemente el mantenimiento del proyecto.
- `NSPredicate` es una herramienta fundamental para realizar consultas eficientes en Core Data.
- Configurar correctamente la sincronización con CloudKit desde el inicio evita muchos problemas cuando la aplicación crece.

---

### Próximos pasos

- Implementar la vista de detalle de un issue.
- Editar información desde la interfaz.
- Crear nuevos issues.
- Crear nuevas etiquetas.
- Implementar búsqueda avanzada utilizando `NSPredicate`.
- Agregar ordenamiento dinámico mediante `SortDescriptor`.
- Mejorar la sincronización entre dispositivos utilizando CloudKit.
