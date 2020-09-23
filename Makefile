bundle        := bundle.tgz
ifeq ($(OS),Windows_NT)
profile       := $(USERPROFILE)\.vscode
settings_home := $(APPDATA)\Code\User
settings_file := $(CURDIR)\settings.json
settings_link := $(settings_home)\settings.json
else
profile       := $(HOME)/.vscode
settings_home := $(HOME)/.config/Code/User
settings_file := $(CURDIR)/settings.json
settings_link := $(settings_home)/settings.json
endif

extensions := \
	EditorConfig.EditorConfig \
	bungcip.better-toml       \
	eamodio.gitlens           \
	ms-python.python          \
	ms-vscode.cmake-tools     \
	ms-vscode.cpptools        \
	rust-lang.rust            \
	vscodevim.vim

files  := \
	.git       \
	.gitignore \
	Makefile   \
	README.md  \
	tar.cmd    \

define install-extension
code --install-extension $(1)

endef

define update-extension
code --force --install-extension $(1)

endef

.PHONY: all
all: bundle

.PHONY: bundle
bundle: $(bundle)

.PHONY: clean
clean:
ifeq ($(OS),Windows_NT)
	@del /f /q $(bundle) > NUL 2>&1 || exit 0
else
	@$(RM) $(bundle)
endif

.PHONY: init
init: init-settings init-extensions

.PHONY: init-extensions
init-extensions:
	@$(foreach i,$(extensions),$(call install-extension, $(i)))

.PHONY: init-settings
init-settings: $(settings_link)

.PHONY: reset-master
reset-master:
	@git fetch --all
	@git reset --hard origin/master

.PHONY: size
size:
	@du -hs $(shell find pack/ -maxdepth 3 -mindepth 3 -type d) | sort -h

.PHONY: update
update: update-repository update-extensions
	@git status

.PHONY: update-extensions
update-extensions:
	@$(foreach i,$(extensions),$(call update-extension, $(i)))

.PHONY: update-force
update-force: reset-master update

.PHONY: update-repository
update-repository:
	@git pull --rebase

$(bundle): $(files)
	@tar cfvz $(@) $(^)

$(settings_home):
ifeq ($(OS),Windows_NT)
	@mkdir "$(@)"
else
	@mkdir -p $(@)
endif

$(settings_link): $(settings_file) $(settings_home)
ifeq ($(OS),Windows_NT)
	@ln "$(settings_link)" "$(<)"
else
	@ln -fs $(<) $(settings_link)
endif
