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

- If `true` (default), `scoop` will be installed
- If `false`, `scoop` will not be installed
  - For example,
    it is unnecessary to install scoop
    because cached `~/scoop/` will be recovered

### `run_as_admin`

- If `true` (default), `scoop` will be installed with option `-RunAsAdmin`
- If `false`, `scoop` will be installed without option `-RunAsAdmin`
- Now both `true` or `false` will work on Windows Runners provided by GitHub,
  because latest installer of scoop has workaround
  for GitHub Actions and admin privilege
  - The `false` value is still meaningful
    for self-hosted Windows runner without administrator privilege

### `buckets`

- Specify bucket(s) to add
  - Delimit several buckets by white space like as `extras nonportable games`
  - Bucket(s) specified by this parameter must be "known" buckets,
    you can confirm them by `scoop bucket known` command
- This parameter is optional, no extra known buckets will be added if omitted

### `custom_buckets`

> [!IMPORTANT]
> This is available in v5 or later.

- Specify not-known-bucket(s) to add by URL
  - Custom buckets as "name repo_url" pairs, one per line
  - This parameter only supports URL-styled repo (e.g. https, ssh, git, ...)
- This parameter is optional, no extra custom buckets will be added if omitted

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

#### Example

```YAML
        with:
          custom_buckets: |
            my-bucket https://github.com/UserName/bucket.git
            mybucket2 https://github.com/UserName/bucket2.git
```

### `apps`

- Specify application(s) to add
  - Delimit several applications by white space like as `plantuml doxygen`
- This parameter is optional, no applications will be installed if omitted

### `scoop_update`

- If `true` (default), `scoop update` will be processed after installation
- If `false`, it will not

### `scoop_checkup`

- If `true`, `scoop checkup` will be processed after installation
- If `false` (default), it will not

### `update_path`

- If `true` (default), path to `scoop` will be added into environment variable `PATH`
- If `false`, environment variable `PATH` will not be updated

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
