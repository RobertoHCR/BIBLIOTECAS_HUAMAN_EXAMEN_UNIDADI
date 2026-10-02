# Validación de la base del proyecto

Verificaciones realizadas el 1 de octubre de 2026:

- Compilación de los scripts Python y lectura de los archivos JSON.
- Lectura del YAML de los tres workflows y revisión de sintaxis Bash de sus pasos.
- Generación del CSV y SQL con un Excel temporal de prueba de 260 filas: caracteres Unicode, apóstrofes, nulos, lotes de INSERT, conteos, determinismo y rechazo de mapeo incorrecto.
- Revisión del cliente de Power BI con respuestas HTTP simuladas: espera de importación, confirmación de éxito y error de permisos HTTP 403.

Los datos temporales de prueba no están incluidos en la entrega y no pertenecen a la BNP.

No se ha descargado el Excel oficial: el portal rechazó la descarga desde este entorno. No se ha ejecutado Terraform validate con el proveedor descargado, ni SQL contra una base SQL Server, ni los workflows contra Azure y Power BI. Estas verificaciones necesitan acceso a las cuentas y se completan ejecutando los workflows con sus secretos. No existe todavía un PBIX ni URL publicada.

La evaluación final debe comprobar las tres ejecuciones verdes, el total de filas contra el Excel oficial, el PBIX real, dos dashboards de Service, el filtro de la tabla y el acceso del docente.
