{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  nativeBuildInputs = with pkgs; [
    elixir_1_16
  ];

  # shellHook = ''
  # '';
}
