# setup-scoop

- `setup-scoop` action installs `scoop` and update `PATH` for GitHub Actions workflow on Windows environment.

## Sample usage

- Put codes like this into your workflow
```yaml
      - uses: MinoruSekine/setup-scoop@v1
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

### `scoop_update`

- If `true` (default), `scoop update` will be processed after installation
- If `false`, it will not

### `scoop_checkup`

- If `true`, `scoop checkup` will be processed after installation
- If `false` (default), it will not

### `update_path`

- If `true` (default), path to `scoop` will be added into environment variable `PATH`
- If `false`, environment variable `PATH` will not be updated
