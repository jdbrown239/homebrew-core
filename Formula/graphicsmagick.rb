class Graphicsmagick < Formula
  desc "Image processing tools collection"
  homepage "http://www.graphicsmagick.org/"
  url "https://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.26/GraphicsMagick-1.3.26.tar.xz"
  sha256 "fba015f3d5e5d5f17e57db663f1aa9d338e7b62f1d415b85d13ee366927e5f88"
  revision 1
  head "http://hg.code.sf.net/p/graphicsmagick/code", :using => :hg

  bottle do
    sha256 "be742f28bc435cd4fd7192f29a292badbd20977bd095124599daa3af390de57f" => :sierra
    sha256 "42065085d8c50a4bccbb1104c947a38a12817fe1e1a1e8e5d46907f06f6ff136" => :el_capitan
    sha256 "b0d22faec53beef1e8cc238a4f299a4f9534c0671feafdd0d6b36cc5597476a9" => :yosemite
  end

  option "without-magick-plus-plus", "disable build/install of Magick++"
  option "without-svg", "Compile without svg support"
  option "with-perl", "Build PerlMagick; provides the Graphics::Magick module"

  depends_on "pkg-config" => :build
  depends_on "libtool" => :run
  depends_on "jpeg" => :recommended
  depends_on "libpng" => :recommended
  depends_on "libtiff" => :recommended
  depends_on "freetype" => :recommended
  depends_on "little-cms2" => :optional
  depends_on "jasper" => :optional
  depends_on "libwmf" => :optional
  depends_on "ghostscript" => :optional
  depends_on "webp" => :optional
  depends_on :x11 => :optional

  skip_clean :la

  def ghostscript_fonts?
    File.directory? "#{HOMEBREW_PREFIX}/share/ghostscript/fonts"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-shared
      --disable-static
      --with-modules
      --without-lzma
      --disable-openmp
      --with-quantum-depth=16
    ]

    args << "--without-gslib" if build.without? "ghostscript"
    args << "--with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts" if build.without? "ghostscript"
    args << "--without-magick-plus-plus" if build.without? "magick-plus-plus"
    args << "--with-perl" if build.with? "perl"
    args << "--with-webp=yes" if build.with? "webp"
    args << "--without-x" if build.without? "x11"
    args << "--without-ttf" if build.without? "freetype"
    args << "--without-xml" if build.without? "svg"
    args << "--without-lcms2" if build.without? "little-cms2"

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"
    system "./configure", *args
    system "make", "install"
    if build.with? "perl"
      cd "PerlMagick" do
        # Install the module under the GraphicsMagick prefix
        system "perl", "Makefile.PL", "INSTALL_BASE=#{prefix}"
        system "make"
        system "make", "install"
      end
    end
  end

  def caveats
    if build.with? "perl"
      <<-EOS.undent
        The Graphics::Magick perl module has been installed under:

          #{lib}

      EOS
    end
  end

  test do
    fixture = test_fixtures("test.png")
    assert_match "PNG 8x8+0+0", shell_output("#{bin}/gm identify #{fixture}")
  end
end
