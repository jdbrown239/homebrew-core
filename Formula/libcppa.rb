require 'formula'

class Libcppa < Formula
  homepage 'http://libcppa.blogspot.it'
  url 'http://github.com/Neverlord/libcppa/archive/V0.9.3.tar.gz'
  sha1 'b9fce68bc4e5688cc75cfc9add5ec1feb105ab7d'

  depends_on 'cmake' => :build

  needs :cxx11

  option 'with-opencl', 'Build with OpenCL actors'
  option 'with-examples', 'Build examples'

  def install
    ENV.cxx11

    args = %W[
      --prefix=#{prefix}
      --build-static
      --disable-context-switching
    ]

    args << '--with-opencl' if build.with? 'opencl'
    args << '--no-examples' if build.without? 'examples'

    system "./configure", *args
    system "make"
    system "make", "test"
    system "make", "install"
  end
end
