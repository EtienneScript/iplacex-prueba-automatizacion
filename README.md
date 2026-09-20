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

| Tipo | Archivos | Plugin | Comando |
| --- | --- | --- | --- |
| Unitarias | `*Test.java` | Surefire | `.\mvnw.cmd test` |
| Integración | `*IT.java` | Failsafe | `.\mvnw.cmd verify -DskipUnitTests=true -DskipATs=true` |
| Aceptación | `*AT.java` | Failsafe | `.\mvnw.cmd verify -DskipUnitTests=true -DskipITs=true` |

```powershell
.\mvnw.cmd test
.\mvnw.cmd verify -DskipUnitTests=true -DskipATs=true
.\mvnw.cmd verify -DskipUnitTests=true -DskipITs=true
```

Las unitarias no abren el navegador. Integración y aceptación usan Chrome (headless por defecto).

## Deployment pipeline

Orden: **Tests → Acceptance → Despliegue en ambiente de prueba**. Si tests o acceptance fallan, no se despliega.

| Stage | Qué hace |
| --- | --- |
| **Build** | Compila, sin pruebas |
| **Tests** | Unitarias (`*Test`) e integración Selenium (`*IT`) |
| **Acceptance** | Criterio de negocio: el usuario envía el formulario y ve confirmación (`*AT`) |
| **Despliegue ambiente de prueba** | Blue-Green: publica en el slot inactivo (`blue`/`green`), canary 10% y luego 100% |
| **Rollback** | Devuelve el tráfico 100% al slot anterior |

Despliegue local, después de empaquetar:

```powershell
.\mvnw.cmd -DskipUnitTests=true -DskipITs=true -DskipATs=true package
.\scripts\desplegar-ambiente-prueba.ps1
.\scripts\desplegar-ambiente-prueba.ps1
.\scripts\rollback-ambiente-prueba.ps1
```

El primer deploy llena `blue`. El segundo hace canary en `green` (10%) y promueve a 100%. El rollback vuelve a `blue`.

Quedan `ambiente-prueba/ACTIVO.txt`, `ANTERIOR.txt`, `TRAFICO.txt` e `HISTORIAL.txt`.

Rollback en CI (manual):

- GitHub: Actions → workflow **Rollback** → Run workflow
- GitLab: botón manual del job `rollback-prueba`
- Jenkins: Build with Parameters → `ACCION=rollback`

Definiciones del mismo flujo:

- `Jenkinsfile` — Jenkins (declarativo). El agente debe tener JDK 17 (`JDK17`) y Google Chrome.
- `.gitlab-ci.yml` — GitLab CI/CD (imagen con Maven + Chromium). El job de deploy usa el environment `prueba`.
- `.github/workflows/ci.yml` — GitHub Actions; publica el artefacto `ambiente-prueba`.

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

Los commits van en español con tipo `feature:` o `fix:`. Ejemplo: `feature: Agrega el pipeline de CI.`

## Arranque local

```bash
git clone <url-del-repositorio>
git checkout develop
```

Trabaja siempre desde `develop`, no desde `main`.
