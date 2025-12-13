{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    zig
    cmake
    gcc
    gdb
  ];

  shellHook = ''
    echo "Entering Zig Development Shell..."
    echo "Zig version: $(zig version)"
  '';
}
