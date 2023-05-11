class Dcmtk < Formula
  desc "OFFIS DICOM toolkit command-line utilities"
  homepage "http://dicom.offis.de/dcmtk.php.en"
  
  # Current snapshot used for stable now.
  url "https://github.com/universalsoftware/dcmtk/archive/refs/tags/DCMTK-3.6.7-EMSOW.tar.gz"
  sha256 "352828f4433f37f4956a26ecb0ef4e2b8a2d0caaf7ea7dbedaa9c28eadc4400f"
  version "3.6.7"
  
  head "https://github.com/universalsoftware/dcmtk.git"

  option "with-docs", "Install development libraries/headers and HTML docs"
  option "with-openssl", "Configure DCMTK with support for OpenSSL"
  option "with-libiconv", "Build with brewed libiconv. Dcmtk and system libiconv can have problems with utf8."

  depends_on "cmake" => :build
  depends_on "doxygen" => :build if build.with? "docs"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "openssl"
  depends_on "libiconv" => :optional
  
  #patch do
  #  url "file://" + File.dirname(__FILE__) + "/patches/dcmtk-m1.patch"
  #  sha256 "533cfe46414f6c76dcdf56fd9633a399f813707a0cb8fe2630126cbd747134c8"
  #end

  def install
#    ENV.m64 if MacOS.prefer_64_bit?

    args = std_cmake_args
    args << "-DDCMTK_WITH_DOXYGEN=YES" if build.with? "docs"
    args << "-DDCMTK_WITH_OPENSSL=YES" if build.with? "openssl"
    args << "-DDCMTK_WITH_ICONV=YES -DLIBICONV_DIR=#{Formula["libiconv"].opt_prefix}" if build.with? "libiconv"
    args << ".."

    mkdir "build" do
      system "cmake", *args
      system "make", "DOXYGEN" if build.with? "docs"
      system "make", "install"
    end
  end

  test do
    system bin/"pdf2dcm", "--verbose",
           test_fixtures("test.pdf"), testpath/"out.dcm"
    system bin/"dcmftest", testpath/"out.dcm"
  end
end
