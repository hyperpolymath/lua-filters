# SPDX-License-Identifier: PMPL-1.0-or-later
# Justfile for lua-filters

set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list --unsorted

show-vars:
    @filters="$$(find * -type d | grep -v '[/\\]' || true)"; \
    filter_files="$$(find * -name '*.lua' -type f || true)"; \
    printf "FILTERS: %s\n" "$$filters"; \
    printf "FILTER_FILES: %s\n" "$$filter_files"

test:
    @filters="$$(find * -type d | grep -v '[/\\]' || true)"; \
    sh runtests.sh $$filters

docker-test:
    @filters="$$(find * -type d | grep -v '[/\\]' || true)"; \
    docker run \
        --rm \
        --volume "$$(pwd):/data" \
        --entrypoint /usr/bin/make \
        pandoc/lua-filters-test \
        FILTERS="$$filters"

docker-test-image:
    docker build --tag pandoc/lua-filters-test --file .tools/Dockerfile .

collection:
    @filter_files="$$(find * -name '*.lua' -type f || true)"; \
    filters="$$(find * -type d | grep -v '[/\\]' || true)"; \
    mkdir -p .build/lua-filters/filters .build/lua-filters/docs; \
    cp -a CONTRIBUTING.md LICENSE README.md .build/lua-filters/; \
    cp -a $$filter_files .build/lua-filters/filters; \
    for filter in $$filters; do \
        cp "$$filter/README.md" ".build/lua-filters/docs/$$filter.md"; \
    done; \
    printf "Filters collected in '%s'\n" ".build/lua-filters"

archive: collection
    tar -czf .build/lua-filters.tar.gz -C .build lua-filters
    @printf "Archive written to '%s'\n" ".build/lua-filters.tar.gz"

archives: collection
    tar -czf .build/lua-filters.tar.gz -C .build lua-filters
    @rm -f .build/lua-filters.zip
    (cd .build && zip -r -9 lua-filters.zip lua-filters)
    @printf "Archive written to '%s'\n" ".build/lua-filters.zip"

docs:
    @echo "No docs build step configured"

clean:
    rm -rf .build
    @filters="$$(find * -type d | grep -v '[/\\]' || true)"; \
    for filter in $$filters; do \
        make -C "$$filter" clean; \
    done
