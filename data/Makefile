dash_src = $(wildcard dash-*.tar.*)
dash_dir = $(basename $(basename $(dash_src)))

CPPFLAGS = -D_FORTIFY_SOURCE=2
CFLAGS   = -march=i686 -mtune=generic -O2 -pipe -fstack-protector-strong --param=ssp-buffer-size=4
CXXFLAGS = -march=i686 -mtune=generic -O2 -pipe -fstack-protector-strong --param=ssp-buffer-size=4
LDFLAGS  = -Wl,-O1,--sort-common,--as-needed,-z,relro,--hash-style=gnu

export

default:

dash: $(dash_src)
	bsdtar xvf $(dash_src)
	cd $(dash_dir) ; ./configure --enable-static
	$(MAKE) -C $(dash_dir)
	mv $(dash_dir)/src/dash .
