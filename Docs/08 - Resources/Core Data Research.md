# Core Data

> [!info]
> **Core Data** es el framework oficial de Apple para administrar el modelo de datos de una aplicación. Permite crear, leer, actualizar y eliminar información (CRUD), además de persistirla de forma eficiente en el dispositivo.
>
> Aunque muchas personas lo comparan con una base de datos, **Core Data no es una base de datos**. Es un framework de gestión de objetos que puede utilizar SQLite (u otros tipos de almacenamiento) como mecanismo de persistencia.

---

# ¿Qué hace Core Data?

Core Data representa la información mediante un **grafo de objetos**, donde cada objeto corresponde a una **entidad** y puede estar relacionado con otros objetos mediante **relaciones**.

Gracias a esto, podemos trabajar con objetos de Swift en lugar de escribir consultas SQL manualmente.

---

# Ventajas

- No es necesario escribir consultas SQL.
- Permite almacenar datos de forma persistente.
- Gestiona automáticamente las relaciones entre objetos.
- Facilita ordenar, agrupar y filtrar información.
- Optimiza el uso de memoria mediante **Faulting**.
- Se integra perfectamente con SwiftUI y UIKit.

---

# Faulting

> [!tip]
> **Faulting** es una técnica utilizada por Core Data para reducir el consumo de memoria.

### ¿Cómo funciona?

Imagina el siguiente modelo:

Usuario
├── Autos
├── Cuentas
└── Direcciones

Si realizamos una consulta para obtener únicamente un **Usuario**, Core Data **no carga automáticamente** todos sus Autos, Cuentas o Direcciones.

En su lugar, crea un **Fault**, que es un objeto "vacío" que únicamente contiene la información necesaria para saber que esa relación existe.

Solo cuando accedemos a esa relación:

```swift
usuario.autos
```

Core Data consulta el almacenamiento y carga esos datos.

Gracias a esto:

- Consume menos memoria.
- Las consultas son más rápidas.
- Solo carga la información que realmente necesitamos.

---

#  Core Data Stack

El **Core Data Stack** es el conjunto de objetos que permite que Core Data funcione correctamente. Actúa como intermediario entre la aplicación y el almacenamiento persistente.

## Componentes principales

| Componente                       | Función                                                                                                                             |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **NSManagedObjectModel**         | Define el esquema de la aplicación: entidades, atributos y relaciones.                                                              |
| **NSPersistentStoreCoordinator** | Coordina la comunicación entre Core Data y el almacenamiento físico (SQLite, memoria, XML, etc.).                                   |
| **NSManagedObjectContext**       | Espacio donde se crean, modifican, eliminan y consultan objetos.                                                                    |
| **NSPersistentContainer**        | Contenedor que configura automáticamente todo el Core Data Stack. Es el componente que normalmente usamos en aplicaciones modernas. |

---

# Flujo de funcionamiento

```text
SwiftUI / UIKit
        │
        ▼
NSManagedObjectContext
        │
        ▼
NSPersistentContainer
        │
        ▼
NSPersistentStoreCoordinator
        │
        ▼
SQLite
```

---

# Conceptos importantes

- **Entidad:** equivalente a una tabla.
- **Atributo:** equivalente a una columna.
- **Objeto administrado (Managed Object):** una instancia de una entidad.
- **Relación:** conexión entre entidades.
- **Contexto:** lugar donde viven temporalmente los objetos antes de guardarse.
- **Store:** almacenamiento físico de los datos.

---

# Resumen

> [!summary]
>
> Core Data es el framework de persistencia de Apple que administra objetos, relaciones y almacenamiento de datos de forma eficiente. Gracias a características como **Faulting**, el **Core Data Stack** y la gestión automática de objetos, permite desarrollar aplicaciones con un alto rendimiento sin tener que escribir SQL manualmente.