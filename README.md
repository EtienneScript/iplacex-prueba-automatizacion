# Iplacex — Prueba de automatización

Repositorio Git con flujo de ramas **GitFlow**.

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
