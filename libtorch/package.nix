with import <nixpkgs> {};
let
  # The binary libtorch distribution statically links the CUDA
  # toolkit. This means that we do not need to provide CUDA to
  # this derivation. However, we should ensure on version bumps
  # that the CUDA toolkit for `passthru.tests` is still
  # up-to-date.
  version = "2.7.0.dev20250312";
  device = "cuda";
  srcs = {
    x86_64-linux-cuda = {
      name = "libtorch-cxx11-abi-shared-with-deps-2.7.0.dev20250312+cu128.zip";
      url = "https://download.pytorch.org/libtorch/nightly/cu128/libtorch-cxx11-abi-shared-with-deps-2.7.0.dev20250312%2Bcu128.zip";
	  hash = "sha256-XsZBdqIhVHszvn1m6dDolYfd7FTbSlDMjrqsYSdQ/y4=";
    };
  };
  unavailable = throw "libtorch is not available for this platform";
  libcxx-for-libtorch = (pkgs.lib.getLib pkgs.stdenv.cc.cc);
in
pkgs.stdenv.mkDerivation {
  inherit version;
  pname = "libtorch-cuda";

  src = pkgs.fetchzip srcs."${pkgs.stdenv.hostPlatform.system}-${device}" or unavailable;

  nativeBuildInputs = [ pkgs.patchelf pkgs.addDriverRunpath ];

  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  installPhase = ''
    # Copy headers and CMake files.
    mkdir -p $dev
    cp -r include $dev
    cp -r share $dev

    install -Dm755 -t $out/lib lib/*${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}*

    # We do not care about Java support...
    rm -f $out/lib/lib*jni* 2> /dev/null || true

    # Fix up library paths for split outputs
    substituteInPlace $dev/share/cmake/Torch/TorchConfig.cmake \
      --replace \''${TORCH_INSTALL_PREFIX}/lib "$out/lib" \

    substituteInPlace \
      $dev/share/cmake/Caffe2/Caffe2Targets-release.cmake \
      --replace \''${_IMPORT_PREFIX}/lib "$out/lib" \
  '';

  postFixup =
    let
      rpath = pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc ];
    in
    pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
      find $out/lib -type f \( -name '*.so' -or -name '*.so.*' \) | while read lib; do
        echo "setting rpath for $lib..."
        patchelf --set-rpath "${rpath}:$out/lib" "$lib"
		addDriverRunpath "$lib"
      done
    '';

  outputs = [
    "out"
    "dev"
  ];

  passthru.tests.cmake = pkgs.callPackage ./test {
	  cudaSupport = true;
  };

  meta = with pkgs.lib; {
    description = "C++ API of the PyTorch machine learning framework";
    homepage = "https://pytorch.org/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    # Includes CUDA and Intel MKL, but redistributions of the binary are not limited.
    # https://docs.nvidia.com/cuda/eula/index.html
    # https://www.intel.com/content/www/us/en/developer/articles/license/onemkl-license-faq.html
    license = licenses.bsd3;
    maintainers = with maintainers; [ junjihashimoto ];
    platforms = [
      "x86_64-linux"
    ];
  };
}
