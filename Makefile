all: lib doc

lib: .cabal-sandbox dist
	cabal build -j

# TODO: have real dependencies here.
.PHONY: doc
doc: .cabal-sandbox dist
	cabal haddock

.PHONY: cabal-init
cabal-init: .cabal-sandbox dist .cabal-sandbox/bin/hlint .cabal-sandbox/bin/hoogle

dist:
	cabal configure

.cabal-sandbox: bam.cabal
	cabal sandbox init
	cabal install -j --enable-documentation --haddock-html --haddock-hoogle --only-dependencies

.PHONY: cabal-clean
cabal-clean: real-clean
	rm -rf .cabal-sandbox cabal.sandbox.config Setup.hs

.PHONY: real-clean
real-clean: clean

.PHONY: clean
clean:
	cabal clean

.cabal-sandbox/bin/hlint:
	cabal install -j --enable-documentation --haddock-html --haddock-hoogle hlint

.PHONY: hlint
hlint: .cabal-sandbox/bin/hlint
	.cabal-sandbox/bin/hlint .

.cabal-sandbox/bin/hoogle:
	cabal install -j --enable-documentation --haddock-html --haddock-hoogle hoogle
	.cabal-sandbox/bin/hoogle data

.PHONY: hoogle
hoogle: .cabal-sandbox/bin/hoogle



