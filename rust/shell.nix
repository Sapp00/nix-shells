let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.11";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShellNoCC {
  buildInputs = with pkgs; [
    openssl
    cargo
    perl
    nix
    libiconv
    rust-analyzer
    rustc
  ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  nativeBuildInputs = [ pkgs.pkg-config ];

  shellHook = ''
    export LDFLAGS="-L${pkgs.libiconv}/lib -L${pkgs.openssl.dev}/lib -liconv"
    export PKG_CONFIG_PATH="${pkgs.libiconv}/lib/pkgconfig:${pkgs.openssl.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
    export LD_LIBRARY_PATH="${pkgs.libiconv}/lib:${pkgs.openssl.dev}/lib:$LD_LIBRARY_PATH"
    
    # Add both the system and Nix-provided framework paths to RUSTFLAGS
    export RUSTFLAGS="-L${pkgs.libiconv}/lib -L${pkgs.openssl.dev}/lib -liconv \
      -C link-arg=-F/System/Library/Frameworks \
      -C link-arg=-F$(nix-build '<nixpkgs>' -A darwin.apple_sdk.frameworks.Security)/Library/Frameworks \
      -C link-arg=-framework -C link-arg=Security"

    echo "LDFLAGS: $LDFLAGS"
    echo "PKG_CONFIG_PATH: $PKG_CONFIG_PATH"
    echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
    echo "RUSTFLAGS: $RUSTFLAGS"
  '';
}
