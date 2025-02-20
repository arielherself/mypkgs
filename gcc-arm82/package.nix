with import <nixpkgs> {};
pkgs.stdenv.mkDerivation {
	name = "gcc-arm82";
	src = pkgs.fetchurl {
		url = "https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-a/8.2-2018.11/gcc-arm-8.2-2018.11-x86_64-arm-linux-gnueabihf.tar.xz";
		hash = "sha256-P5vHpo90Sl7cfK6/9fPyw7wf+disiwX3aAoAcUYd7t4=";
	};

	nativeBuildInputs = [ pkgs.autoPatchelfHook ];
	propagatedBuildInputs = with pkgs; [
		# libstdcxx
		gcc
		# libtinfo
		ncurses5
		python2
		expat
	];
	sourceRoot = ".";

	installPhase = ''
		mkdir -p $out
		cp -r * $out/
	'';
}
