
all: .cabal-sandbox dist
	cabal build -j

.PHONY: cabal-init
cabal-init: .cabal-sandbox dist .cabal-sandbox/bin/hlint .cabal-sandbox/bin/hoogle

dist:
	cabal configure

.cabal-sandbox: bam.cabal
	cabal sandbox init
	cabal install -j --enable-documentation --haddock-html --haddock-hoogle --only-dependencies

.PHONY: cabal-clean
cabal-clean: clean
	rm -rf .cabal-sandbox cabal.sandbox.config Setup.hs

.PHONY: clean
clean:
	rm -rf dist

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

