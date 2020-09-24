# ////////////////////////////////////////////////////////////////////////// #
# ////////////////////////////////////////////////////////////////////////// #

bundle := bundle.tgz

extensions := \
	EditorConfig.EditorConfig \
	bungcip.better-toml       \
	eamodio.gitlens           \
	golang.go                 \
	ms-python.python          \
	ms-vscode.cmake-tools     \
	ms-vscode.cpptools        \
	rust-lang.rust            \
	vscodevim.vim

files  := \
	.git          \
	.gitignore    \
	Makefile      \
	README.md     \
	argv.json     \
	extensions    \
	ln.cmd        \
	settings.json \
	tar.cmd

# ////////////////////////////////////////////////////////////////////////// #

ifeq ($(OS),Windows_NT)
	platform      := Windows
	profile       := $(USERPROFILE)\.vscode
	settings_file := $(subst /,\,$(CURDIR))\settings.json
	settings_base := $(APPDATA)\Code\User
	settings_link := $(settings_base)\settings.json
else
	kernel := $(shell uname -s)

	ifeq ($(kernel),Darwin)
		platform      := macOS
		settings_base := $(HOME)/Library/Application Support/Code/User
	else
		platform      := Linux
		settings_base := $(HOME)/.config/Code/User
	endif

	profile       := $(HOME)/.vscode
	settings_file := $(CURDIR)/settings.json
	settings_link := $(settings_base)/settings.json
endif

# ////////////////////////////////////////////////////////////////////////// #

.PHONY: all
all: bundle

.PHONY: bundle
bundle: $(bundle)

.PHONY: clean
clean:
ifeq ($(platform),Windows)
	@del /f /q "$(bundle)" > NUL 2>&1 || exit 0
else
	@$(RM) "$(bundle)"
endif

# ////////////////////////////////////////////////////////////////////////// #

.PHONY: init
init: init-settings init-extensions

.PHONY: init-extensions
init-extensions:
	@code $(addprefix --install-extension , $(extensions))

.PHONY: init-settings
init-settings: $(settings_link)

# ////////////////////////////////////////////////////////////////////////// #

.PHONY: deinit-extensions
deinit-extensions:
	@code $(addprefix --uninstall-extension , $(extensions))

.PHONY: reinit-extensions
reinit-extensions: deinit-extensions init-extensions

.PHONY: reset-master
reset-master:
	@git fetch --all
	@git reset --hard origin/master

# ////////////////////////////////////////////////////////////////////////// #

.PHONY: list-extensions
list-extensions:
	@code --list-extensions

.PHONY: list-extensions-by-size
list-extensions-by-size:
ifeq ($(platform),Windows)
	@dir /B /O:S extensions
else
	@du -hs $(shell find extensions/ -maxdepth 1 -mindepth 1 -type d) \
		| sort -h
endif

.PHONY: list-parameters
list-parameters:
	@echo Bundle.......: $(bundle)
	@echo Platform.....: $(platform)
	@echo Profile......: $(profile)
	@echo Settings file: $(settings_file)
	@echo Settings link: $(settings_link)

# ////////////////////////////////////////////////////////////////////////// #

.PHONY: update
update: update-repository update-extensions
	@git status

.PHONY: update-extensions
update-extensions:
	@code --force $(addprefix --install-extension , $(extensions))

.PHONY: update-force
update-force: reset-master update

.PHONY: update-repository
update-repository:
	@git pull --autostash --rebase

# ////////////////////////////////////////////////////////////////////////// #

$(bundle): $(files)
	@tar cfvz "$(@)" $(^)

$(settings_base):
ifeq ($(platform),Windows)
	@mkdir "$(@)"
else
	@mkdir -p "$(@)"
endif

$(settings_link): $(settings_file) $(settings_base)
ifeq ($(platform),Windows)
	@ln "$(settings_link)" "$(<)"
else
	@ln -fs "$(<)" "$(settings_link)"
endif

# ////////////////////////////////////////////////////////////////////////// #
# ////////////////////////////////////////////////////////////////////////// #