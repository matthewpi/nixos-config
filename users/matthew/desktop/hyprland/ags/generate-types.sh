#!/usr/bin/env bash

set -eou pipefail

# Nix commands to get the path to AGS in the Nix store.
#
# This assumes the the ags input is named `ags` in your `flake.nix`
nar_hash="$(nix flake metadata --json | jq -r '.locked.narHash')"
flake_url="$(nix flake metadata --json | jq -r '.url')?narHash=${nar_hash}"
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
find ./dts -type f -print0 | while IFS= read -r -d '' file; do
	sed -i 's/gi:\/\/DbusmenuGtk3/@girs\/dbusmenugtk3-0.4\/dbusmenugtk3-0.4/g' "$file"
	sed -i 's/gi:\/\/GdkPixbuf/@girs\/gdkpixbuf-2.0\/gdkpixbuf-2.0/g' "$file" # Must go before gdk-2.0 to prevent partial matches
	sed -i 's/gi:\/\/Gdk/@girs\/gdk-2.0\/gdk-2.0/g' "$file"
	sed -i 's/gi:\/\/Gio/@girs\/gio-2.0\/gio-2.0/g' "$file"
	sed -i 's/gi:\/\/GLib/@girs\/glib-2.0\/glib-2.0/g' "$file"
	sed -i 's/gi:\/\/GObject/@girs\/gobject-2.0\/gobject-2.0/g' "$file"
	sed -i 's/gi:\/\/Gtk?version=3.0/@girs\/gtk-3.0\/gtk-3.0/g' "$file"
	sed -i 's/gi:\/\/Gvc/@girs\/gvc-1.0\/gvc-1.0/g' "$file"
	sed -i 's/gi:\/\/NM/@girs\/nm-1.0\/nm-1.0/g' "$file"
	sed -i 's/gi:\/\/Pango/@girs\/pango-1.0\/pango-1.0/g' "$file"
done

# gen ags.d.ts
function mod {
	echo "declare module '$1' {
    const exports: typeof import('$2')
    export = exports
}"
}

function resource {
	mod "resource:///com/github/Aylur/ags/$1.js" "./$1"
}

function gi {
	mod "gi://$1" "@girs/$2/$2"
}

dts="${TMP_DIR}/ags/dts/ags.d.ts"

echo "
declare function print(...args: any[]): void;

declare module console {
    export function error(obj: object, others?: object[]): void;
    export function error(msg: string, subsitutions?: any[]): void;
    export function log(obj: object, others?: object[]): void;
    export function log(msg: string, subsitutions?: any[]): void;
    export function warn(obj: object, others?: object[]): void;
    export function warn(msg: string, subsitutions?: any[]): void;
}
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

{
	gi 'Gtk' 'gtk-3.0'
	gi 'GObject' 'gobject-2.0'
	gi 'Gio' 'gio-2.0'
	gi 'GLib' 'glib-2.0'
} >>"${dts}"

# Move types
mv "${TMP_DIR}/ags/dts" "${WORKING_DIR}/types"
