with import <nixpkgs> {};
let
    opusWithCustomModes = pkgs.libopus.override { withCustomModes = true; };
in
pkgs.stdenv.mkDerivation rec {
    name = "thorium-${version}";
    version = "124.0.6367.218";

    dontPatchELF = true;

    src = pkgs.fetchurl {
        url = "https://github.com/Alex313031/thorium/releases/download/M${version}/thorium-browser_${version}_AVX2.deb";
        hash = "sha256-nXz5ocZYDBWLIaARk8lN9LhP+7p8bEx+Kk+JAT2tG5c=";
    };
    sourceRoot = ".";
    unpackPhase = "dpkg-deb --fsys-tarfile ${src} | tar -x --no-same-owner";


    rpath = lib.makeLibraryPath buildInputs + ":" + lib.makeSearchPathOutput "lib" "lib64" buildInputs;


    nativeBuildInputs = [
        pkgs.dpkg
        pkgs.qt6.wrapQtAppsHook
    ];

    buildInputs = with pkgs; [
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        bzip2
        cairo
        coreutils
        cups
        curl
        dbus
        expat
        flac
        fontconfig
        freetype
        gcc-unwrapped.lib
        gdk-pixbuf
        glib
        harfbuzz
        icu
        libcap
        libdrm
        liberation_ttf
        libexif
        libglvnd
        libkrb5
        libpng
        xorg.libX11
        xorg.libxcb
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        libxkbcommon
        xorg.libXrandr
        xorg.libXrender
        xorg.libXScrnSaver
        xorg.libxshmfence
        xorg.libXtst
        mesa
        nspr
        nss
        opusWithCustomModes
        pango
        pciutils
        pipewire
        snappy
        speechd
        systemd
        util-linux
        wayland
        wget
        libpulseaudio
        libva
        gtk3
        gtk4
        libgcc
        qt5.full
        qt6.full
        qt6.qtbase
        libGL
    ];

    # dontConfigure = true;
    # dontBuild = true;

    installPhase= ''
        runHook preInstall

        appname=thorium

        mkdir -p $out/bin
        mkdir -p $out/share
        cp -R usr/bin $out/
        cp -R usr/share $out/
        cp -R opt $out/
        substituteInPlace $out/share/applications/thorium-browser.desktop --replace /usr/bin/ $out/bin/
        substituteInPlace $out/share/applications/thorium-shell.desktop --replace /usr/bin/ $out/bin/
        substituteInPlace $out/share/applications/thorium-shell.desktop --replace /opt/ $out/opt/
        substituteInPlace $out/bin/thorium-shell --replace /opt/ $out/opt/

        ln -fs ${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm $out/opt/chromium.org/thorium/WidevineCdm

        patchelf $out/opt/chromium.org/thorium/thorium --add-needed libGL.so.1
        for exe in $out/opt/chromium.org/thorium/{thorium,chrome_crashpad_handler}; do
          patchelf \
              --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
              --set-rpath "${rpath}" $exe
      done

        ln -fs $out/opt/chromium.org/thorium/thorium-browser $out/bin/thorium-browser

        runHook postInstall
    '';

    meta = with lib; {
        homepage = "https://thorium.rocks";
        description = "Web Browser";
        platforms = platforms.linux;
        license = licenses.unfree;
    };
}
