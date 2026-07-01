# Go Direct Dev Container Feature

This feature installs Go directly from the official Go distribution, along with the tools needed by the VS Code Go extension, including `gopls`, `dlv`, and `golangci-lint`.

## Use The Feature

Add the feature to your `devcontainer.json`:

```jsonc
{
	"features": {
		"ghcr.io/amadigan/dev-containers/go-direct:1": {}
	}
}
```

To pin a specific Go release, set the `version` option:

```jsonc
{
	"features": {
		"ghcr.io/amadigan/dev-containers/go-direct:1": {
			"version": "1.26.3"
		}
	}
}
```

If `version` is omitted, the feature installs the latest Go release reported by `go.dev`.

## Implementation details

This feature:

 * If `version` is not specified, queries `https://go.dev/VERSION?m=text` to determine the latest Go release.
 * Installs Go by downloading `https://go.dev/dl/${VERSION}.linux-${ARCH}.tar.gz` and extracting it to `/usr/local`.
 * Symlinks the Go binaries to `/usr/local/bin` (from `/usr/local/go/bin`).
 * Adds `${HOME}/go/bin` to the `PATH` environment variable in sh, bash, and zsh shells.
 * Installs the latest versions of the following packages to `/usr/local/bin`:
   * `github.com/go-delve/delve/cmd/dlv`
   * `golang.org/x/tools/gopls`
   * `github.com/golang/vscode-go/vscgo`
   * `github.com/haya14busa/goplay/cmd/goplay`
   * `github.com/fatih/gomodifytags`
   * `github.com/josharian/impl`
   * `github.com/cweill/gotests/gotests`
   * `github.com/golangci/golangci-lint/v2/cmd/golangci-lint`

## Reference

The feature entrypoint is [install.sh](src/go-direct/install.sh).
