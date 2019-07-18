{ lib, buildPythonPackage, pytorch, pytest }:

buildPythonPackage rec {
  pname = "probtorch";
  version = "0.0";
  # version = builtins.readFile ./probtorch/version.py;

  src = ./.;

  doCheck = false;
  # checkInputs = [ pytest ];
  propagatedBuildInputs = [ pytorch ];

  meta = with lib; {
    homepage = https://github.com/probtorch/probtorch;
    description = "Probabilistic Torch is library for deep generative models that extends PyTorch";
    license = licenses.apache2;
    maintainers = with maintainers; [ stites ];
  };
}
