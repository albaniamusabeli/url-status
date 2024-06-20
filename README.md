# Revisión de Sitios Web

## Objetivos

Revisar e informar el estado actual de los sitios en producción.

## Funcionamiento

Primero es necesario registrar las URLs de producción en un archivo de texto (txt), así el script de Powershell se encargará de leer cada URL obteniendo su nombre, código de estado y su estado en palabras, para luego agregarlos a una lista.

Esta lista se guardará en un archivo CSV creado por la aplicación, el cual es enviado por correo, como respaldo, con la información de los sitios que están en linea y los que no.

## Ejecución

Por medio de una tarea programada de Windows, la aplicación puede ser configurable para ejecutarse las veces que se requiera.
