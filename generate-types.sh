#!/usr/bin/env bash

set -eou pipefail

# Nix commands to get the path to AGS in the Nix store.
#
# This assumes the the ags input is named `ags` in your `flake.nix`
metadata_json="$(nix flake metadata --json)"
nar_hash="$(echo "${metadata_json}" | jq -r '.locked.narHash')"
flake_url="$(echo "${metadata_json}" | jq -r '.resolvedUrl')?narHash=${nar_hash}"
ags_path="$(nix eval --impure --expr "(builtins.getFlake \"${flake_url}\").inputs.ags" --apply 'builtins.toString' --raw)"

WORKING_DIR="$(pwd)"
echo "${WORKING_DIR}"

TMP_DIR="$(mktemp -d)"
echo "${TMP_DIR}"
cd "${TMP_DIR}"

# Get the ags source, we need it to generate types.
#
# We could clone the git repository, but what is the fun in that when we already have it in the Nix
# store. This also works out better as we will be generating types for the EXACT ags version we are
# using rather than whatever the latest git commit is.
if [ ! -d "ags" ]; then
	echo "Copying ags files from the nix store (${ags_path})"
	cp --recursive --reflink=auto "$ags_path" ags
	chmod 755 ags
fi
cd ags

# Intall ags dependencies
if [ ! -d "node_modules" ]; then
	npm ci
fi

# Generate declarations
if [ -d "dts" ]; then
	echo 'Removing previously generated declarations'
	rm -rf dts
fi
echo 'Generating base type declarations'
npx tsc -d --declarationDir dts --emitDeclarationOnly

# Fix paths
echo 'Fixing type declaration imports'
function fixPaths {
	sed -i 's/node_modules/types/g' "$1"
	sed -i 's/import("@girs/import("types\/@girs/g' "$1"
}
export -f fixPaths

find ./dts -type f -print0 | xargs -0 -I % bash -c "fixPaths %"
cp -r 'node_modules/@girs' ./dts/@girs

# gen ags.d.ts
function mod {
	echo "declare module '$1' {
    const exports: typeof import('$2')
    export = exports
}
"
}

function resource {
	mod "resource:///com/github/Aylur/ags/$1.js" "./$1"
}

dts='./dts/ags.d.ts'

echo "declare function print(...args: any[]): void;
declare const Widget: typeof import('./widget').default
declare const Service: typeof import('./service').default
declare const Variable: typeof import('./variable').default
declare const Utils: typeof import('./utils').default
declare const App: typeof import('./app').default
" >"${dts}"

for file in ./src/*.ts; do
	f=$(basename -s .ts "${file}")
	if [[ ${f} != "main" && ${f} != "client" ]]; then
		resource "$(basename -s .ts "${file}")" >>"${dts}"
	fi
done

for file in ./src/service/*.ts; do
	resource "service/$(basename -s .ts "${file}")" >>"${dts}"
done

for file in ./src/widgets/*.ts; do
	resource "widgets/$(basename -s .ts "${file}")" >>"${dts}"
done

for file in ./src/utils/*.ts; do
	resource "utils/$(basename -s .ts "${file}")" >>"${dts}"
done

# Move types
if [ -d "${WORKING_DIR}/types" ]; then
	echo 'Removing previously generated types'
	rm -rf "${WORKING_DIR}/types"
fi
echo 'Moving newly generated types'
mv "${TMP_DIR}/ags/dts" "${WORKING_DIR}/types"
