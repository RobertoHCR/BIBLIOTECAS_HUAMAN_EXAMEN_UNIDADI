# Preparación y ejecución

## 1. Comprobar las cuentas

Necesitas GitHub, una suscripción Azure habilitada para crear SQL Database y Power BI Desktop en Windows. Usa la cuenta institucional para Power BI si tiene licencia Pro y acceso a un workspace.

La automatización de Power BI requiere una aplicación de Microsoft Entra, acceso al workspace y autorización del administrador del tenant para usar la API con esa aplicación. Comprueba esto primero: una cuenta universitaria puede impedirlo aunque puedas usar Desktop. Si está bloqueado, solicita al administrador que habilite una aplicación o un grupo autorizado; publicar manualmente no sustituye el requisito de deploy.yml.

Esta entrega usa un workspace normal compartido, no Mi área de trabajo ni un workspace PPU para la aplicación. No requiere contratar capacidad para insertar el reporte en una web externa: no hay una aplicación de embedding en este proyecto. Las licencias de publicación y visualización deben ser suficientes para tu cuenta y la del docente.

## 2. Descargar y preparar el Excel

1. Abre el [dataset del enunciado](https://www.datosabiertos.gob.pe/dataset/bibliotecas-p%C3%BAblicas-y-universitarias-verificadas-en-el-registro-nacional-de-bibliotecas-%E2%80%93).
2. Descarga el recurso **Bibliotecas públicas y universitarias verificadas en el RNB**, formato XLSX. Guarda una copia sin modificar en `data/raw/bibliotecas.xlsx`.
3. Descarga también el diccionario oficial y consérvalo en `docs/` para consultar los encabezados y el significado de las variables.
4. En una terminal, situado en la carpeta del proyecto, ejecuta en Windows:

```powershell
py -m pip install openpyxl==3.1.5
py scripts/prepare_data.py --inspect
```

5. Edita `data/mapping.json`: `sheet` es el nombre exacto de la hoja; `header_row` es el número de la fila de encabezado. Para cada variable escribe el encabezado exacto mostrado por la inspección. La entidad responsable es opcional y puede quedar vacía; nombre, tipo, departamento, provincia y distrito necesitan mapeo.
6. Si hay varias hojas de datos, selecciona una que contenga el conjunto solicitado o un corte completo y deja documentado el alcance. Este script procesa una sola hoja. No junta años ni hojas automáticamente. Si el archivo solo contiene códigos geográficos, hay que incorporar su catálogo antes de presentar nombres de departamentos.
7. Genera los archivos:

```powershell
py scripts/prepare_data.py
```

Obtendrás `data/bibliotecas.csv`, `data/provenance.json` y un `sql/02_load_data.sql` con INSERT reales. Verifica el conteo y algunas filas contra Excel. No envíes el SQL inicial que dice que falta preparar el dataset.

El script conserva categorías, no inventa datos y detiene la preparación si faltan columnas o nombres. Los vacíos de tipo o ubicación se muestran como Sin dato. No filtra silenciosamente subtítulos, totales ni filas inválidas: deben identificarse antes de la entrega.

## 3. Crear el repositorio

Crea un repositorio público en GitHub llamado `bibliotecas-bi`. Usa GitHub Desktop para añadir la carpeta del proyecto como repositorio local, hacer el primer commit y **Publish repository**, con la opción de mantenerlo privado desactivada. Así se conserva la carpeta `.github/workflows`.

Sube el contenido de la carpeta `bibliotecas-bi`, no una carpeta extra que la envuelva. En la raíz del repo deben estar README.md, requirements.txt, infra, sql y .github. No subas el ZIP como único archivo del repositorio.

## 4. Credenciales de Azure

En Azure Portal abre **Cloud Shell**, selecciona Bash y comprueba la suscripción con `az account show`. Si tu cuenta tiene permiso para crear identidades y asignar roles, ejecuta:

```bash
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
az ad sp create-for-rbac --name bnp-github --role Contributor --scopes "/subscriptions/$SUBSCRIPTION_ID"
```

El resultado contiene `appId`, `password` y `tenant`. Guarda esos valores como secretos de GitHub; la contraseña aparece una vez. Si no tienes permisos, el administrador debe crear una identidad autorizada. Para simplificar esta práctica se usa Contributor en la suscripción; utiliza una suscripción de práctica y retira la asignación al terminar. No pegues el resultado en el README.

En GitHub: **Settings → Secrets and variables → Actions → Secrets → New repository secret**.

| Secreto | Valor |
|---|---|
| ARM_CLIENT_ID | appId de la identidad de Azure |
| ARM_CLIENT_SECRET | password de esa identidad |
| ARM_TENANT_ID | tenant |
| ARM_SUBSCRIPTION_ID | ID de la suscripción, visible en az account show |
| SQL_PASSWORD | Contraseña nueva para bnpadmin: al menos 16 caracteres, mayúsculas, minúsculas, números y símbolos |

En **Variables → New repository variable**, crea `PROJECT_SUFFIX`: entre 6 y 12 letras minúsculas o números. Usa un sufijo propio y único; determina nombres globales de SQL y Storage. No lo cambies después del despliegue.

## 5. Ejecutar infraestructura y carga

1. En GitHub, **Actions → 1 - Infraestructura Azure SQL con Terraform → Run workflow**, rama main.
2. Espera el resultado verde. El resumen muestra `sql-bnp-<sufijo>.database.windows.net`.
3. Ejecuta **2 - Crear base, tablas y cargar dataset → Run workflow**.
4. Comprueba que aparece `Carga verificada: ... registros`. El artifact `dataset-procesado` contiene evidencia de los datos y del SQL utilizados.
5. Si falla, abre el primer paso rojo. Errores habituales: secreto incorrecto, proveedor Microsoft.Sql sin registrar, región sin cuota, sufijo ya utilizado, Excel ausente o mapeo incorrecto. Si Azure exige registrar un proveedor, hazlo en Suscripciones → Proveedores de recursos antes de reintentar.

Los workflows son independientes y se lanzan en ese orden. El primero crea el servidor, el segundo crea la base y los datos. Al repetir setup se reemplazan los datos del proyecto dentro de una transacción.

## 6. Crear y publicar Power BI

Sigue [POWER_BI.md](POWER_BI.md). Guarda el archivo como `powerbi/bibliotecas.pbix`. Si el PBIX supera 100 MB, GitHub necesita Git LFS y el checkout debe configurarse para LFS; con un dataset pequeño debería ser menor. No se ha configurado LFS en esta plantilla.

Después configura los cuatro secretos PBI y ejecuta deploy.yml. Su resumen entregará la URL real. Este script publica; no crea automáticamente las dos páginas del reporte ni los dashboards.

## 7. Completar la entrega

- Reemplaza los campos PENDIENTE del README por enlaces reales.
- Verifica que el repo público contiene los dos SQL con datos reales, Terraform, tres workflows y el PBIX.
- Crea los dos dashboards en Service y comparte reporte y dashboards con el docente.
- Guarda capturas de las tres ejecuciones verdes, los dashboards y el reporte de tabla filtrado.
- Entrega en la pregunta 7 la URL de GitHub y la URL del reporte. Comprueba el acceso con la cuenta del docente; la URL por sí sola no concede permisos.

No borres el proyecto antes de que lo evalúen. Después, elimina la base y servidor de práctica y revisa el almacenamiento del estado para evitar cargos continuos; esto elimina datos y requiere que ya no los necesites.
