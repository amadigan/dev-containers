#! /bin/bash
set -eo pipefail

# Determine the Go version, including the go prefix
TARGET_GO_VERSION="${VERSION:-"latest"}"

if [ "${TARGET_GO_VERSION}" = "latest" ]; then
	TARGET_GO_VERSION="$(curl -sSL 'https://go.dev/VERSION?m=text' | head -n 1)"
else
	TARGET_GO_VERSION="go${TARGET_GO_VERSION}"
fi

# Determine the target architecture
TARGET_ARCH="$(uname -m)"

case "${TARGET_ARCH}" in
	x86_64)
		TARGET_ARCH="amd64"
		;;
	aarch64)
		TARGET_ARCH="arm64"
		;;
esac

# Download and install Go directly to /usr/local
mkdir -p /usr/local

GO_DOWNLOAD_URL="https://go.dev/dl/${TARGET_GO_VERSION}.linux-${TARGET_ARCH}.tar.gz"
echo "Downloading Go from ${GO_DOWNLOAD_URL}...."
curl -sSL "${GO_DOWNLOAD_URL}" | tar -C /usr/local -xz

# Create symlinks for Go binaries in /usr/local/bin
for f in /usr/local/go/bin/*; do
	ln -s "$f" "/usr/local/bin/$(basename $f)"
done

echo "Installed Go version: $(go version)"

printf '%s\n' 'export PATH="$HOME/go/bin:$PATH"' > /etc/profile.d/go-path.sh
ln -f /etc/profile.d/go-path.sh /etc/bash/
ln -f /etc/profile.d/go-path.sh /etc/zsh/zshrc.d

# Install Go tools needed by the VS Code Go extension to /usr/local/bin
export GOBIN=/usr/local/bin

packages=(
	"github.com/go-delve/delve/cmd/dlv"
	"golang.org/x/tools/gopls"
	"github.com/golang/vscode-go/vscgo"
	"github.com/haya14busa/goplay/cmd/goplay"
	"github.com/fatih/gomodifytags"
	"github.com/josharian/impl"
	"github.com/cweill/gotests/gotests"
	"github.com/golangci/golangci-lint/v2/cmd/golangci-lint"
)

for package in "${packages[@]}"; do
	go install "${package}@latest"
done
