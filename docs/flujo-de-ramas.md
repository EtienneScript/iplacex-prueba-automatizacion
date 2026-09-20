# Flujo de ramas — GitFlow

Este repositorio sigue **GitFlow**. El objetivo es separar el código de producción del trabajo en curso y hacer explícito cuándo una versión está lista.

```
main ─────────────────────────────────────────────●────●──
                                                   ▲    ▲
                                                   │    │
develop ──────●────●────●────────────●────●────────┘    │
              ▲    ▲    ▲            ▲                  │
              │    │    │            │                  │
feature/* ────┘    │    │            │                  │
release/* ─────────┘    │            │                  │
hotfix/* ───────────────┴────────────┴──────────────────┘
```

## Ramas permanentes

### `main`

- Refleja el estado de **producción**.
- Cada commit en `main` corresponde a una versión liberada.
- Se etiqueta con semver: `v1.0.0`, `v1.1.0`, `v1.1.1`.
- Nadie desarrolla ni hace commits directos aquí.

### `develop`

- Rama de **integración**.
- Aquí aterrizan las features ya revisadas.
- Es la rama por defecto para clonar y trabajar.
- Debe permanecer en un estado que pueda convertirse en release.

## Ramas temporales

### `feature/<ticket>-<slug>`

Nueva funcionalidad o mejora.

```bash
git checkout develop
git pull
git checkout -b feature/001-login
# ... commits ...
git checkout develop
git merge --no-ff feature/001-login
git branch -d feature/001-login
```

Reglas:

- Se crea siempre desde `develop`.
- Se integra solo en `develop`.
- Se elimina después del merge.
- El merge usa `--no-ff` para conservar el historial de la feature.

### `release/<version>`

Congela `develop` para preparar una versión: ajustes finales, notas y número de versión. No se agregan features nuevas.

```bash
git checkout develop
git checkout -b release/1.0.0
# ... ajustes de versión y correcciones menores ...
git checkout main
git merge --no-ff release/1.0.0
git tag -a v1.0.0 -m "Release 1.0.0"
git checkout develop
git merge --no-ff release/1.0.0
git branch -d release/1.0.0
```

Reglas:

- Se crea desde `develop`.
- Se fusiona en `main` **y** en `develop`.
- Tras el merge a `main` se crea un tag anotado.
- Se elimina después de integrar en ambas ramas.

### `hotfix/<ticket>-<slug>`

Corrección urgente sobre producción, sin esperar a la siguiente release.

```bash
git checkout main
git checkout -b hotfix/002-fix-timeout
# ... corrección ...
git checkout main
git merge --no-ff hotfix/002-fix-timeout
git tag -a v1.0.1 -m "Hotfix 1.0.1"
git checkout develop
git merge --no-ff hotfix/002-fix-timeout
git branch -d hotfix/002-fix-timeout
```

Reglas:

- Se crea desde `main`.
- Se fusiona en `main` **y** en `develop`.
- Si hay una `release/*` abierta, el hotfix también se integra allí.
- Se etiqueta en `main` con el siguiente parche (patch).

## Convención de nombres

```
feature/<id>-<descripcion-corta>
release/<major.minor.patch>
hotfix/<id>-<descripcion-corta>
```

Ejemplos válidos: `feature/014-reporte-pdf`, `release/1.2.0`, `hotfix/088-error-login`.

## Qué no hacer

- No commitear directo en `main`.
- No abrir una `feature/*` desde `main`.
- No mezclar una feature en `main` saltándose `develop` o `release/*`.
- No dejar ramas temporales vivas después del merge.
- No usar `--force` sobre `main` ni `develop`.

## Relación con Trunk-Based

Se eligió GitFlow y no Trunk-Based porque este repositorio necesita:

- una rama de producción estable (`main`);
- una rama de integración visible (`develop`);
- un ciclo explícito de release y hotfix, útil para evaluar y versionar entregas.

Trunk-Based concentraría todo en `main` con ramas de horas y feature flags. Ese modelo encaja mejor en equipos con CI/CD continuo; aquí el flujo debe ser auditable paso a paso.
