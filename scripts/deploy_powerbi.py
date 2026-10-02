"""Importa un PBIX real, espera el resultado y escribe su URL en Actions."""
import os
import time
from pathlib import Path
import requests

ROOT = Path(__file__).resolve().parents[1]

def checked(response, operation):
    if not response.ok:
        # No imprimir tokens, secretos ni cuerpos arbitrarios de respuestas.
        raise RuntimeError(f'{operation}: HTTP {response.status_code}. Revisa permisos del tenant y workspace; request-id={response.headers.get("RequestId", "sin id")}.')
    return response.json()

def main():
    pbix = ROOT / 'powerbi/bibliotecas.pbix'
    if not pbix.is_file() or pbix.stat().st_size < 1024:
        raise RuntimeError('Falta powerbi/bibliotecas.pbix real. Créalo en Power BI Desktop; consulta docs/POWER_BI.md.')
    if pbix.stat().st_size >= 1_000_000_000:
        raise RuntimeError('Este flujo está preparado para PBIX menores de 1 GB.')
    tenant = os.environ['PBI_TENANT_ID']
    workspace = os.environ['PBI_WORKSPACE_ID']
    token = checked(requests.post(f'https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token', data={
        'grant_type': 'client_credentials', 'client_id': os.environ['PBI_CLIENT_ID'],
        'client_secret': os.environ['PBI_CLIENT_SECRET'], 'scope': 'https://analysis.windows.net/powerbi/api/.default'
    }, timeout=60), 'Autenticación')['access_token']
    print(f'::add-mask::{token}')
    headers = {'Authorization': f'Bearer {token}'}
    base = f'https://api.powerbi.com/v1.0/myorg/groups/{workspace}'
    with pbix.open('rb') as f:
        result = checked(requests.post(f'{base}/imports', headers=headers,
            params={'datasetDisplayName': 'bibliotecas.pbix', 'nameConflict': 'CreateOrOverwrite'},
            files={'file': (pbix.name, f, 'application/octet-stream')}, timeout=300), 'Importación')
    import_id = result['id']
    deadline = time.monotonic() + 900
    while time.monotonic() < deadline:
        result = checked(requests.get(f'{base}/imports/{import_id}', headers=headers, timeout=60), 'Estado de importación')
        state = result.get('importState')
        if state == 'Failed':
            raise RuntimeError('Power BI rechazó la importación. Revisa el PBIX y los permisos en el workspace.')
        if state == 'Succeeded':
            reports = result.get('reports', [])
            if not reports:
                raise RuntimeError('La importación terminó sin reporte. Verifica que el PBIX incluya visualizaciones.')
            url = reports[0].get('webUrl') or f"https://app.powerbi.com/groups/{workspace}/reports/{reports[0]['id']}"
            print(f'Reporte publicado: {url}')
            if os.getenv('GITHUB_STEP_SUMMARY'):
                with open(os.environ['GITHUB_STEP_SUMMARY'], 'a', encoding='utf-8') as f:
                    f.write(f'## Reporte publicado\n\n[Ver reporte]({url})\n\nCrea los dos dashboards y comparte el reporte según docs/POWER_BI.md.\n')
            return
        time.sleep(10)
    raise TimeoutError('Power BI no terminó la importación en 15 minutos.')

if __name__ == '__main__':
    main()
