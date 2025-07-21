{
  fetchFromGitHub,
  flash-attn,
  lib,
  pkgs,
  formatron,
  python3Packages,
}: let
  inherit (python3Packages.torch) cudaCapabilities cudaPackages cudaSupport;
  inherit (cudaPackages) backendStdenv;
in
  python3Packages.buildPythonPackage rec {
    pname = "exllamav3";
    version = "0.0.5";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "turboderp-org";
      repo = "exllamav3";
      rev = "v${version}";
      hash = "sha256-0dWQ+EYtV61gyuYJ3YGLOs0QMQ7sMMqq7D9tHklJ55c=";
    };

    build-system = with python3Packages; [
      setuptools
      wheel
    ];

    buildInputs = with pkgs; [
      # python3Packages.pybind11
      cudatoolkit
    ];

    preConfigure = ''
      export CC=${lib.getExe' backendStdenv.cc "cc"}
      export CXX=${lib.getExe' backendStdenv.cc "c++"}
      export TORCH_CUDA_ARCH_LIST="8.9+PTX;8.9"
      export FORCE_CUDA=1
    '';

    env.CUDA_HOME = lib.optionalString cudaSupport (lib.getDev cudaPackages.cuda_nvcc);

    dependencies = with python3Packages; [
      flash-attn
      ninja
      numpy
      rich
      safetensors
      tokenizers
      torch
      typing-extensions
      formatron
      marisa-trie
    ];

    pythonImportsCheck = [
      "exllamav3"
    ];

    meta = {
      description = "An optimized quantization and inference library for running LLMs locally on modern consumer-class GPUs";
      homepage = "https://github.com/turboderp-org/exllamav3";
      license = lib.licenses.mit;
    };
  }
