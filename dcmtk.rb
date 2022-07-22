class Dcmtk < Formula
  desc "OFFIS DICOM toolkit command-line utilities"
  homepage "http://dicom.offis.de/dcmtk.php.en"
  
  # Current snapshot used for stable now.
  url "https://dicom.offis.de/download/dcmtk/snapshot/dcmtk-3.6.1_20170228.tar.gz"
  sha256 "8de2f2ae70f71455288ec85c96a2579391300c7462f69a4a6398e9ec51779c11"
  version "3.6.1-20170228"
  
  head "http://git.dcmtk.org/dcmtk.git"

  option "with-docs", "Install development libraries/headers and HTML docs"
  option "with-openssl", "Configure DCMTK with support for OpenSSL"
  option "with-libiconv", "Build with brewed libiconv. Dcmtk and system libiconv can have problems with utf8."

  depends_on "cmake" => :build
  depends_on "doxygen" => :build if build.with? "docs"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "openssl"
  depends_on "homebrew/dupes/libiconv" => :optional

  patch do
    url "file://" + File.dirname(__FILE__) + "/patches/dcmtk-3.6.1-dcm2xml-offsets.patch"
    sha256 "535264fb3b579ba6532b36bc78bddd26bd228d4dc1b43f598bd541161d8d7833"
  end

  patch do
    url "file://" + File.dirname(__FILE__) + "/patches/dcmtk-3.6.1-dcm2xml-rd.patch"
    sha256 "b8ba78e78acdf938e40f3ab1718647dc7a388560857a39282aae47d18b03eab8"
  end

  def install
    ENV.m64 if MacOS.prefer_64_bit?

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
