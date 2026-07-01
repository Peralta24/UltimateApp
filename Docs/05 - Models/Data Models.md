Nuestro modelo de datos actual contiene dos Entidades que son Issue y Tag
- Issue tienen los siguientes atributos
	- Title
	- Priority
	- ModificationDate
	- CreationDate
	- Content
	- Completed
- Tag tiene los siguientes atributos
	- Id
	- Name
Tenemos una relacion de Issue a tag de uno a muchos indicando que un issue puede estar en diferentes tag, y de la misma manera un tag puede estar en diferentes issues.
