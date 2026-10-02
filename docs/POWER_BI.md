# Reporte y dos dashboards

## 1. Conectar Desktop a Azure SQL

En Azure Portal abre el servidor `sql-bnp-<sufijo>` → Redes → acceso público → agrega la IP de tu equipo como regla de firewall y guarda. No necesitas permitir todas las IP.

En Power BI Desktop:

1. Inicio → Obtener datos → Base de datos Azure SQL o SQL Server.
2. Servidor: `sql-bnp-<sufijo>.database.windows.net`.
3. Base: `bibliotecas`; modo **Importar**.
4. Autenticación de base de datos: usuario `bnpadmin`, contraseña igual al secreto SQL_PASSWORD.
5. En el navegador selecciona únicamente `dbo.vw_bibliotecas` y pulsa Cargar.
6. Renombra la tabla importada a `bibliotecas`. Conserva texto para registro_id y los campos descriptivos; fila_origen es entero.
7. Verifica que el total de filas coincide con `data/provenance.json`.

Las credenciales se introducen en Desktop, no en el código ni en medidas. Usa la conexión SQL real para evidenciar que el reporte utiliza la base desplegada.

## 2. Crear tres páginas

Importa el tema con Vista → Temas → Examinar temas → `powerbi/theme.json`. Añade individualmente las tres medidas de `powerbi/medidas.dax` con Modelado → Nueva medida.

| Página | Visual | Configuración |
|---|---|---|
| Registro nacional | 3 tarjetas | Total registros, Departamentos registrados, Tipos registrados |
| Registro nacional | Barras | Eje departamento; valor Total registros; orden descendente |
| Registro nacional | Columnas | Eje tipo_biblioteca; valor Total registros |
| Registro nacional | Segmentador | tipo_biblioteca |
| Distribución territorial | Segmentador | departamento |
| Distribución territorial | Barras | Eje provincia; valor Total registros |
| Distribución territorial | Barras | Eje distrito; valor Total registros |
| Distribución territorial | Matriz | Filas departamento y provincia; valor Total registros |
| Detalle de bibliotecas | Tabla | nombre_biblioteca, tipo_biblioteca, departamento, provincia, distrito, entidad_responsable |
| Detalle de bibliotecas | Segmentador | departamento; opcionalmente otro para tipo_biblioteca |

En la página de tabla, selecciona un departamento y comprueba que cambian las filas. Esto demuestra el filtro exigido. Usa títulos descriptivos; no llames al indicador Bibliotecas únicas si cuentas filas.

Si la fuente no incluye entidad responsable, ese campo será nulo y puedes retirarlo de la tabla. Si se quieren indicadores de infraestructura o servicios, habrá que seleccionar y documentar también esas columnas; no son necesarias para el alcance mínimo propuesto.

Guarda como `powerbi/bibliotecas.pbix`. Actualiza los datos en Desktop antes de guardar la versión final.

## 3. Preparar la publicación automática

En [Power BI Service](https://app.powerbi.com), crea un workspace llamado `Bibliotecas BI` con una licencia y permisos que permitan publicar y compartir. Copia su ID de la URL `/groups/<ID>/...`. No uses Mi área de trabajo.

En Microsoft Entra → Registros de aplicaciones:

1. Registra una aplicación llamada `bnp-powerbi-deploy` en el tenant donde está el workspace.
2. Copia el ID de aplicación y el ID del directorio.
3. Certificados y secretos → Nuevo secreto; copia el **valor**, no el ID del secreto.
4. Pide al administrador de Power BI/Fabric que autorice el uso de las API por entidades de servicio para esa aplicación o su grupo de seguridad. El nombre de la opción puede aparecer como Allow service principals to use Power BI APIs o Service principals can call Fabric public APIs.
5. En el workspace → Administrar acceso, agrega la entidad de servicio o su grupo como **Miembro** o **Administrador**. No se necesita añadir permisos delegados de Power BI a esta aplicación para el flujo con entidad de servicio.

Configura en GitHub:

| Secreto | Valor |
|---|---|
| PBI_TENANT_ID | ID del directorio donde está Power BI |
| PBI_CLIENT_ID | ID de aplicación de bnp-powerbi-deploy |
| PBI_CLIENT_SECRET | Valor de su secreto |
| PBI_WORKSPACE_ID | ID del workspace Bibliotecas BI |

Haz commit del PBIX y publica el cambio. `deploy.yml` se ejecuta al cambiar el PBIX en main, o manualmente desde Actions. La primera subida de los workflows también puede dispararlo sin PBIX; en ese caso fallará con el mensaje de archivo faltante y podrás repetirlo cuando lo añadas.

El resumen de Actions solo mostrará Reporte publicado después de confirmar que la importación terminó. Abre la URL y verifica las tres páginas. Si aparece HTTP 403, revisa permisos del tenant y del workspace. Publicar manualmente no demuestra la automatización requerida.

## 4. Crear los dos dashboards en Service

Las páginas de Desktop no son dashboards de Service. Para cumplir literalmente el enunciado, crea los dos después de publicar:

1. Abre el reporte publicado y ve a Registro nacional.
2. Usa Más opciones → Anclar a un dashboard para anclar la página completa, o el icono de chincheta de sus visuales.
3. Elige Nuevo dashboard y escribe **Registro nacional**.
4. Ve a Distribución territorial y repite, creando **Distribución territorial**.
5. Verifica que el workspace muestra un reporte y dos elementos Dashboard con esos nombres. La tabla con filtro queda en la tercera página del reporte.

Al publicar futuras versiones del reporte, revisa que los tiles de los dashboards sigan apuntando al reporte correcto.

## 5. Compartir y entregar

Abre el reporte → Compartir → Personas específicas. Introduce el correo correcto del docente y concede visualización. Comparte también los dos dashboards si deben evaluarse por sus enlaces.

El texto recibido contiene `patcuadrosqœupt.pe`, que no es una dirección de correo válida porque no incluye @. Verifica la dirección exacta en el aula o con el docente antes de compartir; no la adivines.

Compartir puede requerir licencia Pro para emisor y receptor, o capacidad compatible. Si el docente pertenece a otro tenant también intervienen las políticas de invitados. No uses Publicar en web como sustituto de conceder acceso a su cuenta.

Copia las URL reales en README.md. En la respuesta del examen entrega el enlace público del repo y el enlace del reporte. No entregues un enlace inventado ni una ruta de archivo local.
