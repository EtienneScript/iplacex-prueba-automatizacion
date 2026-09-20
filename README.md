# Iplacex — Prueba de automatización

Repositorio Git con flujo de ramas **GitFlow** y proyecto Maven de pruebas (JUnit 5 + Selenium).

## Requisitos

- JDK 17 o superior
- Google Chrome (para las pruebas de Selenium)
- Maven 3.9+ o el wrapper incluido (`mvnw.cmd`)

## Dependencias de prueba

| Librería | Uso |
| --- | --- |
| JUnit 5 (Jupiter) | Ejecutar y afirmar pruebas |
| Selenium 4 | Automatizar el navegador |
| SLF4J Simple | Logs de las pruebas |

Selenium Manager (incluido en Selenium 4) descarga ChromeDriver automáticamente.

## Ejecutar pruebas

En PowerShell hay que anteponer `.\` (no carga ejecutables del directorio actual):

```powershell
.\mvnw.cmd test
```

Si Maven está instalado de forma global:

```powershell
mvn test
```

Para ver el navegador (sin headless):

```powershell
.\mvnw.cmd test -Dheadless=false
```

Solo la prueba unitaria, sin abrir Chrome:

```powershell
.\mvnw.cmd test -Dtest=SanityTest
```

## Flujo de ramas

Este proyecto usa GitFlow. Las ramas de larga duración son:

| Rama | Rol |
| --- | --- |
| `main` | Producción. Solo código estable y versionado. |
| `develop` | Integración. Base para nuevas funcionalidades. |

Las ramas de corta duración se crean y se eliminan al integrar:

| Prefijo | Origen | Destino | Uso |
| --- | --- | --- | --- |
| `feature/*` | `develop` | `develop` | Nueva funcionalidad |
| `release/*` | `develop` | `main` y `develop` | Preparar una versión |
| `hotfix/*` | `main` | `main` y `develop` | Corrección urgente en producción |

La guía completa está en [`docs/flujo-de-ramas.md`](docs/flujo-de-ramas.md).

## Arranque local

```bash
git clone <url-del-repositorio>
git checkout develop
```

Trabaja siempre desde `develop`, no desde `main`.
