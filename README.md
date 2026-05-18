# setup-scoop

- `setup-scoop` action provides functions below
  - Install `scoop` to your Windows runner
  - Update `PATH` environment variable
  - Install applications by `scoop`

## Status

| Type | ref | Status |
| --- | --- | --- |
| Latest release | `v4.0.2` | ![v4.0.2 status of typical usage](https://github.com/MinoruSekine/setup-scoop/actions/workflows/typical_usage_release.yml/badge.svg) ![v4.0.2 status of edge case](https://github.com/MinoruSekine/setup-scoop/actions/workflows/edge_case_release.yml/badge.svg) |
| Development branch | `main` | ![main status of typical usage](https://github.com/MinoruSekine/setup-scoop/actions/workflows/typical_usage_dev.yml/badge.svg?branch=main) ![main status of edge case](https://github.com/MinoruSekine/setup-scoop/actions/workflows/edge_case_dev.yml/badge.svg?branch=main) ![main status of lint](https://github.com/MinoruSekine/setup-scoop/actions/workflows/lint.yml/badge.svg?branch=main) |

[![Sponsors](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/MinoruSekine)

## Sample usage

- If you want to install "Doxygen" and "PlantUML",
  put codes like this into your workflow YAML

```yaml
      - uses: MinoruSekine/setup-scoop@v4.0.2
        with:
          buckets: extras
          apps: doxygen plantuml
```

## Supported environments

- `windows-2025`
- `windows-latest`

## Parameters

- Parameters can be specified by `with:` like this

```yaml
        with:
          buckets: extras
          scoop_checkup: 'true'
```

### `install_scoop`

| Value | Behavior | Use case |
| --- | --- | --- |
| `true` (default) | Install `scoop` only if unavailable. If already exists, safely skip installation. | Standard use. Also combine with `actions/cache`. |
| `false` | Always skip `scoop` installation. | When always restore `~/scoop/`, or already installed `scoop`. |
| `force` | Forcefully reinstall `scoop` even if already exists. | Troubleshooting or solution for cache corruption. |

### `run_as_admin`

> [!NOTE]
> `run_as_admin` will be ignored when `install_scoop: false`.

| Value | Behavior | Use case |
| --- | --- | --- |
| `true` (default) | Install `scoop` with option `-RunAsAdmin`. | Standard use on GitHub-hosted Windows runner. |
| `false` | Install `scoop` without option `-RunAsAdmin`. | For self-hosted Windows runners without admin privilege. |

> [!IMPORTANT]
> For `run_as_admin`,
> both `true` or `false` will work on GitHub-hosted Windows runners,
> because the latest installer of `scoop` has a workaround
> for GitHub Actions and admin privilege.

### `buckets`

- Specify bucket(s) to add
  - Delimit several buckets by white space like as `extras nonportable games`
  - Bucket(s) specified by this parameter must be "known" buckets,
    you can confirm them by `scoop bucket known` command
- This parameter is optional, no extra known buckets will be added if omitted

### `custom_buckets`

- Specify not-known-bucket(s) to add by URL
  - Custom buckets as "name repo_url" pairs, one per line
  - This parameter only supports URL-styled repo (e.g. https, ssh, git, ...)
- This parameter is optional, no extra custom buckets will be added if omitted

#### Example

> [!NOTE]
> `custom_buckets` parameter is available in `v5` or later.

```YAML
      uses: MinoruSekine/setup-scoop@v5
        with:
          custom_buckets: |
            my-bucket https://github.com/UserName/bucket.git
            mybucket2 https://github.com/UserName/bucket2.git
```

> [!WARNING]
> If a repo URL contains authentication credentials
> (e.g.,
> `https://${{ secrets.MY_PAT }}@github.com/user/private-repo.git`),
> always use `${{ secrets.* }}` to reference the token so it is automatically
> masked in workflow logs. Never hardcode a PAT directly in the workflow YAML.
>
> If you must hide repo URL completely in your workflow log,
> please use `::add-mask` in your workflow.
> See
> [Workflow commands for GitHub Actions](https://docs.github.com/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#masking-a-value-in-a-log)
> for details.

### `apps`

- Specify application(s) to add
  - Delimit several applications by white space like as `plantuml doxygen`
- This parameter is optional, no applications will be installed if omitted

### `scoop_update`

| Value | Behavior | Use case |
| --- | --- | --- |
| `true` (default) | Process `scoop update` before installing `apps`. | Standard use. |
| `false` | Skip `scoop update`. | Reducing duration when skipping update is safe. |

### `scoop_checkup`

| Value | Behavior | Use case |
| --- | --- | --- |
| `true` | Process `scoop checkup`. | Diagnostics for troubleshooting. |
| `false` (default) | Skip `scoop checkup`. | Standard use. |

### `update_path`

| Value | Behavior | Use case |
| --- | --- | --- |
| `true` (default) | Add default `scoop` path to environment variable `PATH`. | Standard use. |
| `false` | Skip updating environment variable `PATH`. | When another step sets `PATH` or will not use `scoop`. |

## Advanced usage

### Sample to improve workflow performance with `actions/cache`

- If cache is available, `install_scoop` will be `false`
  to skip installation and only `update_path` will be `true`
- Include `packages_to_install` into cache seed
  to validate cache is including enough apps or not
- Increment `cache_version`
  if cache should be expired without changing `packages_to_install`

```yaml
env:
  packages_to_install: shellcheck
  cache_version: v0
  cache_hash_seed_file_path: './.github/workflows/cache_seed_file_for_scoop.txt'
```

(snipped)

<!-- markdownlint-disable line-length -->

```yaml
jobs:
  build:
    steps:
    - name: Create cache seed file
      run: echo ${{ env.packages_to_install }} >> ${{ env.cache_hash_seed_file_path }}

    - name: Restore cache if available
      id: restore_cache
      uses: actions/cache@v4
      with:
        path: '~/scoop'
        key: cache_version_${{ env.cache_version }}-${{ hashFiles(env.cache_hash_seed_file_path) }}

    - name: Install scoop (Windows)
      uses: MinoruSekine/setup-scoop@v4.0.2
      if: steps.restore_cache.outputs.cache-hit != 'true'
      with:
        install_scoop: 'true'
        buckets: extras
        apps: ${{ env.packages_to_install }}
        scoop_update: 'true'
        update_path: 'true'

    - name: Setup scoop PATH (Windows)
      uses: MinoruSekine/setup-scoop@v4.0.2
      if: steps.restore_cache.outputs.cache-hit == 'true'
      with:
        install_scoop: 'false'
        scoop_update: 'false'
        update_path: 'true'
```

<!-- markdownlint-enable line-length -->
