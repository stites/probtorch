{ pkgs ? import ./nix/pin/nixpkgs.nix {}, arg-python ? pkgs.python36 }:

let
  my_cudatoolkit = pkgs.cudatoolkit_10_0;
  my_cudnn = pkgs.cudnn_cudatoolkit_10_0;
  my_nccl = pkgs.nccl_cudatoolkit_10;
  mklSupport = true;

  my_magma = pkgs.callPackage ./nix/deps/magma_250.nix {
    inherit mklSupport;
    cudatoolkit = my_cudatoolkit;
  };

  mypackageOverrides = gpu: self: super:
    let
      pytorchFull = self.callPackage ./nix/pytorch {
        inherit mklSupport;
        openMPISupport = true; openmpi = pkgs.callPackage ./nix/deps/openmpi.nix { };
        buildNamedTensor = true;
        buildBinaries = true;
      };

      pytorchWithCuda10Full = self.callPackage ./nix/pytorch {
        inherit mklSupport;
        openMPISupport = true; openmpi = pkgs.callPackage ./nix/deps/openmpi.nix { cudaSupport = true; cudatoolkit = my_cudatoolkit; };
        cudaSupport = true; cudatoolkit = my_cudatoolkit; cudnn = my_cudnn; nccl = my_nccl; magma = my_magma;
        buildNamedTensor = true;
        buildBinaries = true;
      };

      pytorch = if gpu then pytorchWithCuda10Full else pytorchFull;
      probtorch = self.callPackage ./. { inherit pytorch; };
    in
      { inherit probtorch pytorch; };

  generic = { gpu }:
    let
      mypython = arg-python.override {
        packageOverrides = mypackageOverrides gpu;
        self = mypython;
      };
    in mypython.withPackages (ps: [ ps.pytorch ps.probtorch ]);
in
{
  probtorch = generic { gpu = false; };
  probtorchWithCuda = generic { gpu = true; };
}

