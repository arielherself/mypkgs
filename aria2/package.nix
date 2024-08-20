with import <nixpkgs> {};
pkgs.stdenv.mkDerivation {
  pname = "aria2";
  version = "1.37.0";

  src = fetchFromGitHub {
    owner = "arielherself";
    repo = "aria2";
    rev = "b9e23f3";
    sha256 = "sha256-hwA0M00gZyKXDNqJNs4INEHKGjmo7yq0h0Km5tX0JxA=";
  };

  strictDeps = true;
  nativeBuildInputs = with pkgs; [ pkg-config autoreconfHook sphinx ];

  buildInputs = with pkgs; [ gnutls c-ares libxml2 sqlite zlib libssh2 ];

  outputs = [ "bin" "dev" "out" "doc" "man" ];

  configureFlags = [
    "--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
    "--enable-libaria2"
    "--with-bashcompletiondir=${placeholder "bin"}/share/bash-completion/completions"
  ];

  prePatch = ''
    patchShebangs --build doc/manual-src/en/mkapiref.py
  '';

  nativeCheckInputs = [ cppunit ];
  doCheck = false; # needs the net

  enableParallelBuilding = true;

  meta = with lib; {
    homepage = "https://aria2.github.io";
    description = "aria2 fork which supports up to 1024 connections per server.";
    mainProgram = "aria2c";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ Br1ght0ne koral arielherself ];
  };
}
