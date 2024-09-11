UNAME := $(shell uname)
ARCH := $(shell uname -m)

ifeq ($(UNAME), Linux)
	OS := linux
	EXT := so
else ifeq ($(UNAME), Darwin)
	OS := macOS
	EXT := dylib
else
	$(error Unsupported operating system: $(UNAME))
endif

LUA_VERSIONS := luajit lua51

BUILD_DIR := build
BUILD_FROM_SOURCE ?= false
TARGET_LIBRARY ?= all

all: luajit

define make_definitions
ifeq ($(BUILD_FROM_SOURCE),true)
ifeq ($(TARGET_LIBRARY), all)
$1: $(BUILD_DIR)/libAvanteTokenizers-$1.$(EXT) $(BUILD_DIR)/libAvanteTemplates-$1.$(EXT) $(BUILD_DIR)/libAvanteRepoMap-$1.$(EXT)
else ifeq ($(TARGET_LIBRARY), tokenizers)
$1: $(BUILD_DIR)/libAvanteTokenizers-$1.$(EXT)
else ifeq ($(TARGET_LIBRARY), templates)
$1: $(BUILD_DIR)/libAvanteTemplates-$1.$(EXT)
else ifeq ($(TARGET_LIBRARY), repo-map)
$1: $(BUILD_DIR)/libAvanteRepoMap-$1.$(EXT)
else
	$$(error TARGET_LIBRARY must be one of all, tokenizers, templates, repo-map)
endif
else
$1:
	LUA_VERSION=$1 bash ./build.sh
endif
endef

$(foreach lua_version,$(LUA_VERSIONS),$(eval $(call make_definitions,$(lua_version))))

define build_package
$1-$2:
	cargo build --release --features=$1 -p avante-$2
	cp target/release/libavante_$(shell echo $2 | tr - _).$(EXT) $(BUILD_DIR)/avante_$(shell echo $2 | tr - _).$(EXT)
endef

define build_targets
$(BUILD_DIR)/libAvanteTokenizers-$1.$(EXT): $(BUILD_DIR) $1-tokenizers
$(BUILD_DIR)/libAvanteTemplates-$1.$(EXT): $(BUILD_DIR) $1-templates
$(BUILD_DIR)/libAvanteRepoMap-$1.$(EXT): $(BUILD_DIR) $1-repo-map
endef

$(foreach lua_version,$(LUA_VERSIONS),$(eval $(call build_package,$(lua_version),tokenizers)))
$(foreach lua_version,$(LUA_VERSIONS),$(eval $(call build_package,$(lua_version),templates)))
$(foreach lua_version,$(LUA_VERSIONS),$(eval $(call build_package,$(lua_version),repo-map)))
$(foreach lua_version,$(LUA_VERSIONS),$(eval $(call build_targets,$(lua_version))))

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

clean:
	@rm -rf $(BUILD_DIR)

luacheck:
	@luacheck `find -name "*.lua"` --codes

stylecheck:
	@stylua --check lua/ plugin/

stylefix:
	@stylua lua/ plugin/

.PHONY: ruststylecheck
ruststylecheck:
	@rustup component add rustfmt 2> /dev/null
	@cargo fmt --all -- --check

.PHONY: rustlint
rustlint:
	@rustup component add clippy 2> /dev/null
	@cargo clippy -F luajit --all -- -F clippy::dbg-macro -D warnings

# Run all test files
test: deps/mini.nvim setup_test_deps
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

# Run test from file at `$FILE` environment variable
test_file: deps/mini.nvim setup_test_deps
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run_file('$(FILE)')"

# Download 'mini.nvim' to use its 'mini.test' testing module
deps/mini.nvim:
	@mkdir -p deps
	git clone --filter=blob:none --depth=1 https://github.com/echasnovski/mini.nvim $@

deps/nvim-treesitter:
	@mkdir -p deps
	git clone --filter=blob:none --depth=1 https://github.com/nvim-treesitter/nvim-treesitter $@

deps/img-clip:
	@mkdir -p deps
	git clone --filter=blob:none --depth=1 https://github.com/HakonHarnes/img-clip.nvim $@

deps/copilot.lua:
	@mkdir -p deps
	git clone --filter=blob:none --depth=1 https://github.com/zbirenbaum/copilot.lua $@

deps/render-markdown:
	@mkdir -p deps
	git clone --filter=blob:none --depth=1 https://github.com/MeanderingProgrammer/render-markdown.nvim $@

deps/nui.nvim:
	@mkdir -p deps
	git clone --filter=blob:none --depth=1 https://github.com/MunifTanjim/nui.nvim $@

deps/plenary.nvim:
	@mkdir -p deps
	git clone --filter=blob:none --depth=1 https://github.com/nvim-lua/plenary.nvim $@

deps/todomvc:
	@mkdir -p deps
	git clone --filter=blob:none --depth=1 https://github.com/tastejs/todomvc.git $@
	cd $@ && git fetch --depth=1 origin 643cab2e0d5154130077df6356e53871f3b0fa84
	cd $@ && git checkout 643cab2e0d5154130077df6356e53871f3b0fa84

setup_test_deps: deps/mini.nvim deps/nvim-treesitter deps/copilot.lua deps/render-markdown deps/nui.nvim deps/img-clip deps/plenary.nvim deps/todomvc
