RUST_VERSION=1.84.1
rustup install $RUST_VERSION

# Rust analyzer (LSP) v2022-05-30
git clone https://github.com/rust-analyzer/rust-analyzer.git $INSTALL_PATH/rust-analyzer
cd $INSTALL_PATH/rust-analyzer && git checkout -b build f94fa62d69faf5bd63b3772d3ec4f0c76cf2db57 && cargo xtask install --server
