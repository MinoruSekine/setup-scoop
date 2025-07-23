# setup-scoop

[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/MinoruSekine)

![v4.0.2 status of typical usage](https://github.com/MinoruSekine/setup-scoop/actions/workflows/typical_usage.yml/badge.svg?event=schedule)
![v4.0.2 status of edge case](https://github.com/MinoruSekine/setup-scoop/actions/workflows/edge_case.yml/badge.svg?event=schedule)
- `setup-scoop` action provides functions below
  - Install `scoop` to your Windows runner
  - Update `PATH` environment variable
  - Install applications by `scoop`

## Sample usage

- If you want to install "Doxygen" and "PlantUML", put codes like this into your workflow YAML
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
  - For example, it is unnecessary to install scoop because cached `~/scoop/` will be recovered

### `run_as_admin`

- If `true` (default), `scoop` will be installed with option `-RunAsAdmin`
  - Windows Runners provided by GitHub may need this, because currently they run with Administrator privilege
- If `false`, `scoop` will be installed without option `-RunAsAdmin`

### `buckets`

- Specify bucket(s) to add
  - Delimit several buckets by white space like as `extras nonportable games`
  - Bucket(s) specified by this parameter must be "known" buckets, you can confirm them by `scoop bucket known` command
- This parameter is optional, no extra buckets will be added if omitted

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
- If cache is available, `install_scoop` will be `false` to skip installation and only `update_path` will be `true`
- Include `packages_to_install` into cache seed to validate cache is including enough apps or not
- Increment `cache_version` if cache should be expired without changing `packages_to_install`
```yaml
env:
  packages_to_install: shellcheck
  cache_version: v0
  cache_hash_seed_file_path: './.github/workflows/cache_seed_file_for_scoop.txt'
```
(snipped)
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
