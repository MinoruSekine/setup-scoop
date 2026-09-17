# setup-scoop

- `setup-scoop` action provides functions below
  - Install `scoop` to your Windows runner
  - Update `PATH` environment variable
  - Install applications by `scoop`
    with known buckets and/or your own custom buckets

## Status

<!-- markdownlint-disable no-inline-html -->
| Type | ref | Status |
| --- | --- | --- |
| Latest release | `v5.0.0` | ![v5.0.0 status of typical usage](https://github.com/MinoruSekine/setup-scoop/actions/workflows/typical_usage_release.yml/badge.svg) ![v5.0.0 status of edge case](https://github.com/MinoruSekine/setup-scoop/actions/workflows/edge_case_release.yml/badge.svg) |
| Development branch | `main` | ![main status of typical usage](https://github.com/MinoruSekine/setup-scoop/actions/workflows/typical_usage_dev.yml/badge.svg?branch=main) ![main status of edge case](https://github.com/MinoruSekine/setup-scoop/actions/workflows/edge_case_dev.yml/badge.svg?branch=main)<br>![main status of lint](https://github.com/MinoruSekine/setup-scoop/actions/workflows/lint.yml/badge.svg?branch=main)<br>![release commits unmerged to main](https://github.com/MinoruSekine/setup-scoop/actions/workflows/detect_unmerged.yml/badge.svg) |

[![Sponsors](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/MinoruSekine)
<!-- markdownlint-enable no-inline-html -->

## Sample usage

- If you want to install "Doxygen" and "PlantUML",
  put codes like this into your workflow YAML

```yaml
      - uses: MinoruSekine/setup-scoop@v5
        with:
          buckets: extras
          apps: doxygen plantuml
```

## Supported environments

- `windows-2025`
- `windows-2022`
- `windows-11-arm`

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

> [!NOTE]
> `custom_buckets` parameter is available in `v5` or later.

- Specify not-known-bucket(s) to add by URL
  - Custom buckets as "name repo_url" pairs, one per line
  - This parameter only supports URL-styled repo (e.g. https, ssh, git, ...)
    - Use `local_buckets` for path-styled local buckets
- This parameter is optional, no extra custom buckets will be added if omitted

#### `custom_buckets` example

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

### `local_buckets`

> [!NOTE]
> `local_buckets` parameter is available in `v5` or later.

- Specify not-known-bucket(s) to add by local path
  - Local buckets as "name path" pairs, one per line
  - This parameter only supports path-styled repo
    - Use `custom_buckets` for URL-styled remote buckets
  - Path can be both absolute or relative path
- This parameter is optional, no extra custom buckets will be added if omitted

#### `local_buckets` example

```YAML
      uses: actions/checkout@v6
      with:
        path: bucket1
        persist-credentials: false
        ref: main  # Detached head is not supported as `scoop` bucket.

      uses: actions/checkout@v6
      with:
        path: bucket2
        persist-credentials: false
        ref: main  # Detached head is not supported as `scoop` bucket.

      uses: MinoruSekine/setup-scoop@v5
      with:
        local_buckets: |
          local-bucket .\bucket1
          localbucket2 ${{ github.workspace }}/bucket2
```

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

### Cache parameters

> [!NOTE]
> `cache` and related parameters are available in `v6` or later.

- If parameter `cache: true`,
  - Restore cache instead of installing scoop and apps
  - If cache unavailable, create cache after installing scoop and apps
- Cache integrated into `setup-scoop` only caches only `~/scoop` dir
  - So cache will not work if apps install resources into outside of `~/scoop` dir
    (`Program Files` dir, system directory,  registry, ...)

#### `cache`

| Value | Behavior | Use case |
| --- | --- | --- |
| `true` | Cache `~/scoop` dir after setup. Skip setup if cache was restored. | All apps are installed into `~/scoop` dir |
| `false` (default) | Not create cache, and not restore cache. | Some app(s) are installed into outside of `~/scoop` dir (e.g. `Program Files`) |

#### `cache_key_prefix`

- Prefix string for cache key which will be used if `cache: true`
- `setup-scoop-v6` as default

#### `cache_key_suffix`

- Suffix string for cache key which will be used if `cache: true`
- If several jobs (also `matrix` processing)
  use `setup-scoop` with the same parameters and `cache: true`,
  specify each jobs' specific string to this parameter
  - `setup-scoop` includes runner information into cache key,
    so `cache_key_suffix` is not necessary
    if `matrix` is used only for multiple `runs-on:`
- Cache will be shared if all parameters except `cache_key_suffix` are the same
  even if `cache_key_suffix` is different
- Empty string as default

#### `cache_version`

- Version number of cache
- Update this to ignore old cache without changing other parameters
- `v1` as default

## FAQ

### Why is `cache: false` default?

- `cache: true` only caches `~/scoop` dir.
  Misunderstanding "All apps will be cached" makes serious confusion
- In some cases, performance improvement by cache is small or negative
