{ python310Packages, python310, stdenv, lib, binutils, tesseract, src}:
let
  python-env-pyghmi = python310.withPackages (ps: with ps; [
    cryptography
    dateutil
    pbr
    six
  ]);
  pyghmi-from-pypi = python310Packages.buildPythonPackage rec {
    pname = "pyghmi";
    version = "1.5.59";
    src = python310Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-9oSDfCVjMiApTBGwsb5ZJSlXBEYM6qlky03BVsO1yn8=";
    };
    doCheck = false;
    propagatedBuildInputs = [ python-env-pyghmi ];
  };

  python-env = python310.withPackages (ps: with ps; [
    aiofiles
    aiohttp
    dbus-next
    dbus-python
    hidapi
    netifaces
    pam
    passlib
    pillow
    psutil
    pyaml
    pyghmi-from-pypi
    pygments
    pyotp
    pyrad
    pyserial
    pyserial-asyncio
    python-periphery
    qrcode
    setproctitle
    six
    spidev
    systemd
    xlib
    zstandard
  ]);
in
python310Packages.buildPythonPackage
{
  pname = "kvmd";
  version = "unknown";
  inherit src;
  doCheck = false;
  propagatedBuildInputs = [
    python-env
    binutils
  ];
  makeWrapperArgs = [
    "--suffix-each"
    "LD_LIBRARY_PATH"
    ":"
    (lib.makeLibraryPath [ stdenv.cc.libc tesseract])
  ];
}
