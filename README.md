# setup-scoop

- `setup-scoop` action installs `scoop` and update `PATH` for GitHub Actions workflow on Windows environment.

## Sample usage

- Put codes like this into your workflow
```yaml
      - uses: MinoruSekine/setup-scoop@v2
```

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

### `add_extras_bucket`

- If `true`, `extras` bucket will be added
- If `false` (default), it will not
- This parameter will be obsoleted in the future, use `buckets` instead in your new workflow(s)

### `add_nonportable_bucket`

- If `true`, `nonportable` bucket will be added
- If `false` (default), it will not
- This parameter will be obsoleted in the future, use `buckets` instead in your new workflow(s)

### `buckets`

- Specify bucket(s) to add
  - Delimit several buckets by white space like as `java games php`
  - Bucket(s) specified by this parameter must be "known" buckets, you can confirm them by `scoop bucket known` command

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
- If cache is available, `install_scoop` will be `false`to skip installation and only `update_path` will be `true`
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
      uses: actions/cache@v3
      with:
        path: ${{ matrix.to_cache_dir }}
        key: cache_version_${{ env.cache_version }}-${{ hashFiles(env.cache_hash_seed_file_path) }}

    - name: Install scoop (Windows)
      uses: MinoruSekine/setup-scoop@main
      if: steps.restore_cache.outputs.cache-hit != 'true'
      with:
        install_scoop: 'true'
        add_extras_bucket: 'true'
        scoop_update: 'true'
        update_path: 'true'

    - name: Setup scoop PATH (Windows)
      uses: MinoruSekine/setup-scoop@main
      if: steps.restore_cache.outputs.cache-hit == 'true'
      with:
        install_scoop: 'false'
        add_extras_bucket: 'false'
        scoop_update: 'false'
        update_path: 'true'
```
