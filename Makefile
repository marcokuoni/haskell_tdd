# Fast test runner — uses runghc against the GHC provided by the Nix flake,
# which already has tasty et al. baked in. No cabal/stack involved, so the
# only thing that ever gets compiled is your code.

.PHONY: test watch repl clean

test:
	runghc -isrc test/Spec.hs

# Re-run tests automatically whenever a file changes.
# Requires `ghcid`, which is in the `full` dev shell.
watch:
	ghcid --command="ghci -isrc test/Spec.hs" --test=":main"

repl:
	ghci -isrc test/Spec.hs

clean:
	find . -name '*.hi' -o -name '*.o' -delete
