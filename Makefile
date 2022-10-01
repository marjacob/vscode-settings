# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ #
# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ #

BUNDLE ?= bundle.tgz

extensions := \
	EditorConfig.EditorConfig \
	aaron-bond.better-comments \
	bungcip.better-toml \
	eamodio.gitlens \
	ms-python.black-formatter \
	ms-python.isort \
	ms-python.python \
	ms-vscode-remote.vscode-remote-extensionpack \
	ms-vscode.cpptools-extension-pack \
	ms-vscode.hexeditor \
	ms-vscode.makefile-tools \
	stkb.rewrap \
	vscodevim.vim

files := \
	.gitignore \
	Makefile \
	README.md \
	argv.json \
	extensions \
	keybindings.json \
	settings.json \
	snippets \
	tar.cmd

# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ #

ifeq ($(OS),Windows_NT)
	blank     :=
	directory := $(subst /,\,$(CURDIR))
	platform  := Windows
	separator := \$(blank)
	settings  := $(APPDATA)\Code\User
else
	directory := $(CURDIR)
	kernel    := $(shell uname -s)
	separator := /

	ifeq ($(kernel),Darwin)
		platform := macOS
		settings := $(HOME)/Library/Application Support/Code/User
	else
		platform := Linux
		settings := $(HOME)/.config/Code/User
	endif
endif

bindings_name := keybindings.json
settings_name := settings.json
snippets_name := snippets

bindings_file := $(directory)$(separator)$(bindings_name)
bindings_link := $(settings)$(separator)$(bindings_name)
settings_file := $(directory)$(separator)$(settings_name)
settings_link := $(settings)$(separator)$(settings_name)
snippets_file := $(directory)$(separator)$(snippets_name)
snippets_link := $(settings)$(separator)$(snippets_name)

# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ #

define create-file-link
	$(if $(filter $(platform),Windows),\
		mklink /h "$(2)" "$(1)",\
		ln $(if $(filter $(platform),macOS),-h,) "$(1)" "$(2)")
endef

define create-directory
	mkdir $(if $(filter $(platform),Windows),,-p) "$(1)"
endef

define create-directory-link
	$(if $(filter $(platform),Windows),\
		mklink /j "$(2)" "$(1)",\
		ln -s "$(1)" "$(2)")
endef

define delete-file
	$(if $(filter $(platform),Windows),\
		del /f /q "$(1)" > NUL 2>&1 || exit 0,\
		$(RM) "$(1)")
endef

# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ #

.PHONY: all
all: bundle

.PHONY: bundle
bundle: $(BUNDLE)

.PHONY: clean
clean:
	@$(call delete-file,$(BUNDLE))

# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ #

.PHONY: init
init: init-settings init-extensions

.PHONY: init-extensions
init-extensions:
	@code $(addprefix --install-extension , $(extensions))

.PHONY: init-settings
init-settings: $(bindings_link) $(settings_link) $(snippets_link)

# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ #

.PHONY: deinit-extensions
deinit-extensions:
	@code $(addprefix --uninstall-extension , $(extensions))

.PHONY: reinit-extensions
reinit-extensions: deinit-extensions init-extensions

.PHONY: reset-master
reset-master:
	@git fetch --all
	@git reset --hard origin/master

# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ #

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
	@echo  - Bundle.....: $(BUNDLE)
	@echo  - Directory..: $(directory)
	@echo  - Platform...: $(platform)
	@echo  - Separator..: $(separator)
	@echo  - Settings...: $(settings)
	@echo  - Link [$(bindings_name)]
	@echo      from.....: $(bindings_file)
	@echo        to.....: $(bindings_link)
	@echo  - Link [$(settings_name)]
	@echo      from.....: $(settings_file)
	@echo        to.....: $(settings_link)
	@echo  - Link [$(snippets_name)]
	@echo      from.....: $(snippets_file)
	@echo        to.....: $(snippets_link)

# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ #

.PHONY: update
update: update-repository
	@$(MAKE) --no-print-directory update-extensions
	@git status

.PHONY: update-extensions
update-extensions:
	@code --force $(addprefix --install-extension , $(extensions))

.PHONY: update-force
update-force: reset-master update

.PHONY: update-repository
update-repository:
	@git pull --autostash --rebase

# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ #

$(BUNDLE): $(files)
	@tar cfz "$(@)" $(^)

$(settings):
	@$(call create-directory,$(@))

$(bindings_link): | $(settings)
	@$(call create-file-link,$(bindings_file),$(@))

$(settings_link): | $(settings)
	@$(call create-file-link,$(settings_file),$(@))

$(snippets_link): | $(settings)
	@$(call create-directory-link,$(snippets_file),$(@))

# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ #
# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ #