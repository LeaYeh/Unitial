#!/bin/sh

CAT="/bin/cat"
CHMOD="/bin/chmod"
MKDIR="/bin/mkdir"
TOUCH="/usr/bin/touch"

github_base='https://raw.githubusercontent.com/'
repo_path='LeaYeh/Unitial/master/'

os="$(uname)"
if [ "$os" = "FreeBSD" ]; then
  ECHO="echo"
  ${ECHO} -e "\n\e[1;36;40mYour operating system is $os\n\e[0m"
  ${ECHO} -e "\n\e[1;36;40mSuppose you have 'fetch' to download files!\n\e[0m"
  download_o='fetch -o'
else
  ECHO="/bin/echo"
  ${ECHO} -e "\n\e[1;36;40mYour operating system is $os\n\e[0m"
  if type "curl" > /dev/null 2>&1; then
    download_o='curl --compressed -#o'
  elif type "wget" > /dev/null 2>&1; then
    download_o='wget --no-timestamping --no-verbose -O '
  else
    echo "Unitial needs 'wget' or 'curl' to download the assets." 1>&2
  fi
fi

${ECHO} -e "\n\e[1;36;40mUnitial is started to initial your Unix-like working environment\n\nPlease wait...\n\n\e[0m"

${ECHO} -e "\n\e[1;36;40mDownload and setup configs from server...\n\e[0m"
for file in gitconfig tcshrc bashrc bash_profile inputrc vimrc zshrc gitignore_global tmux.conf xinputrc wgetrc curlrc tigrc editorconfig php_cs markdownlintrc lftprc; do
  ${download_o} - "${github_base}${repo_path}${file}" | ${CAT} >> ~/."$file" &
done

${MKDIR} -p ~/.irssi/ ~/.git/contrib/ ~/.vim/colors/ ~/.vim/swp/ ~/.vim/bak/ ~/.vim/undo/ ~/.aria2/ ~/.w3m/ ~/.hadolint/

${download_o} ~/.w3m/config "${github_base}${repo_path}w3mconfig" &
${download_o} ~/.irssi/config "${github_base}${repo_path}irssi_config" &
${download_o} ~/.aria2/aria2.conf "${github_base}${repo_path}aria2.conf" &
${download_o} ~/.hadolint/hadolint.yaml "${github_base}${repo_path}hadolint.yaml" &

${MKDIR} -p ~/.claude/

# CLAUDE.md: from Unitial (symlink if cloned, else download)
if [ -n "$UNITIAL_DIR" ]; then
  ${ECHO} -e "\n\e[1;36;40mCreating Claude Code CLAUDE.md symlink from $UNITIAL_DIR...\n\e[0m"
  ln -sf "${UNITIAL_DIR}/claude/CLAUDE.md" ~/.claude/CLAUDE.md
else
  ${download_o} ~/.claude/CLAUDE.md "${github_base}${repo_path}claude/CLAUDE.md" &
  wait
fi

# settings.json + commands/: from skills repo (SKILLS_DIR or clone to ~/skills)
if [ -z "$SKILLS_DIR" ]; then
  if [ -d "${HOME}/skills/.git" ]; then
    SKILLS_DIR="${HOME}/skills"
  else
    ${ECHO} -e "\n\e[1;36;40mCloning LeaYeh/skills to ~/skills...\n\e[0m"
    git clone git@github.com:LeaYeh/skills.git "${HOME}/skills"
    SKILLS_DIR="${HOME}/skills"
  fi
fi
${ECHO} -e "\n\e[1;36;40mCreating Claude Code symlinks from $SKILLS_DIR...\n\e[0m"
ln -sf "${SKILLS_DIR}/settings.json" ~/.claude/settings.json
rm -rf ~/.claude/commands
ln -sf "${SKILLS_DIR}/commands" ~/.claude/commands

# Fallback: manually install Claude Code plugins whose repos use plugin.json instead of
# marketplace.json. Claude Code's extraKnownMarketplaces silently skips these repos because
# it expects a marketplace format, so we clone and register them directly.
${ECHO} -e "\n\e[1;36;40mInstalling Claude Code plugins (fallback for plugin-type repos)...\n\e[0m"
if command -v python3 > /dev/null 2>&1 && command -v git > /dev/null 2>&1; then
  SKILLS_DIR="$SKILLS_DIR" python3 << 'PYEOF'
import json, os, subprocess, shutil, datetime, sys

settings_path = os.path.join(os.environ["SKILLS_DIR"], "settings.json")
plugins_dir   = os.path.expanduser("~/.claude/plugins")
cache_dir     = os.path.join(plugins_dir, "cache")
mkts_dir      = os.path.join(plugins_dir, "marketplaces")
known_path    = os.path.join(plugins_dir, "known_marketplaces.json")
installed_path = os.path.join(plugins_dir, "installed_plugins.json")

os.makedirs(cache_dir, exist_ok=True)
os.makedirs(mkts_dir, exist_ok=True)

with open(settings_path) as f:
    settings = json.load(f)

known = {}
if os.path.exists(known_path):
    with open(known_path) as f:
        known = json.load(f)

installed = {"version": 2, "plugins": {}}
if os.path.exists(installed_path):
    with open(installed_path) as f:
        installed = json.load(f)

extra = settings.get("extraKnownMarketplaces", {})
enabled = settings.get("enabledPlugins", {})

for mkt_id, mkt_cfg in extra.items():
    if mkt_id in known:
        continue  # already registered; Claude Code handles updates itself

    repo = mkt_cfg["source"]["repo"]
    clone_path = os.path.join(mkts_dir, mkt_id)

    if not os.path.exists(os.path.join(clone_path, ".git")):
        print(f"  Cloning {repo}...")
        r = subprocess.run(
            ["git", "clone", "--depth", "1", f"https://github.com/{repo}.git", clone_path],
            capture_output=True, text=True
        )
        if r.returncode != 0:
            print(f"  ERROR cloning {repo}: {r.stderr.strip()}", file=sys.stderr)
            continue

    now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.000Z")
    known[mkt_id] = {"source": mkt_cfg["source"], "installLocation": clone_path, "lastUpdated": now}

    # If the repo is a marketplace (has marketplace.json), Claude Code will process it on
    # next start once it's in known_marketplaces.json — nothing more needed here.
    plugin_json = os.path.join(clone_path, ".claude-plugin", "plugin.json")
    if not os.path.exists(plugin_json):
        print(f"  Registered marketplace: {mkt_id} (Claude Code will install plugins on next start)")
        continue

    # Plugin repo: find which enabled plugin keys reference this marketplace and install them.
    commit_sha = subprocess.check_output(
        ["git", "-C", clone_path, "rev-parse", "HEAD"], text=True
    ).strip()
    short_sha = commit_sha[:12]

    for plugin_key, is_enabled in enabled.items():
        if not is_enabled:
            continue
        parts = plugin_key.split("@", 1)
        if len(parts) != 2 or parts[1] != mkt_id:
            continue
        if plugin_key in installed.get("plugins", {}):
            continue

        plugin_name = parts[0]
        dest = os.path.join(cache_dir, mkt_id, plugin_name, short_sha)
        os.makedirs(dest, exist_ok=True)

        for item in os.listdir(clone_path):
            if item == ".git":
                continue
            src = os.path.join(clone_path, item)
            dst = os.path.join(dest, item)
            if os.path.isdir(src):
                if os.path.exists(dst):
                    shutil.rmtree(dst)
                shutil.copytree(src, dst)
            else:
                shutil.copy2(src, dst)

        installed.setdefault("plugins", {})[plugin_key] = [{
            "scope": "user",
            "installPath": dest,
            "version": short_sha,
            "installedAt": now,
            "lastUpdated": now,
            "gitCommitSha": commit_sha,
        }]
        print(f"  Installed plugin: {plugin_key}")

with open(known_path, "w") as f:
    json.dump(known, f, indent=4)
with open(installed_path, "w") as f:
    json.dump(installed, f, indent=4)

print("Claude plugin fallback install complete.")
PYEOF
else
  ${ECHO} -e "  Skipping: python3 or git not available"
fi

${download_o} ~/.colorEcho "${github_base}PeterDaveHello/ColorEchoForShell/master/dist/ColorEcho.bash" &

${MKDIR} -p ~/.gcin/
${download_o} ~/.gcin/gtab.list "${github_base}${repo_path}gtab.list" &

${MKDIR} -p -m 700 ~/.ssh/.tmp_session/
${CHMOD} 700 ~/.ssh/
${download_o} - "${github_base}${repo_path}ssh_config" | ${CAT} >> ~/.ssh/config &
${TOUCH} ~/.ssh/authorized_keys
${CHMOD} 600 ~/.ssh/config ~/.ssh/authorized_keys

wait

${ECHO} -e "\n\e[1;36;40mAdd some color setting which depends on your OS...\n\e[0m"
if [ "$os" = "FreeBSD" ] || [ "$os" = "Darwin" ]; then
  ${ECHO} -e "\n#color setting\nalias ls='\ls -F'" >> ~/.zshrc
  ${ECHO} -e "\n#color setting\nalias ls '\ls -F'" >> ~/.tcshrc
else
  ${ECHO} -e "\n#color setting\nalias ls='\ls -F --color=auto'" >> ~/.zshrc
  ${ECHO} -e "\n#color setting\nalias ls '\ls -F --color=auto'" >> ~/.tcshrc
fi

if [ "$os" = "FreeBSD" ]; then
  ${ECHO} -e "\n\e[1;36;40mAdd FreeBSD's package mirror setting...\n\e[0m"
  ${ECHO} -e "\n#package mirror setting\nexport PACKAGEROOT=http://ftp.tw.freebsd.org" >> ~/.bashrc
  ${ECHO} -e "\n#package mirror setting\nexport PACKAGEROOT=http://ftp.tw.freebsd.org" >> ~/.zshrc
  ${ECHO} -e "\n#package mirror setting\nsetenv PACKAGEROOT http://ftp.tw.freebsd.org" >> ~/.tcshrc
fi

if command -v git; then
  git_version="v$(git --version | awk '{gsub(/\.windows.+/, "", $0); print $3}')"
else
  git_version="master"
fi

${ECHO} -e "\n\e[1;36;40mDownload VIM color scheme - Kolor from server...\n\e[0m"
${download_o} ~/.vim/colors/kolor.vim "${github_base}zeis/vim-kolor/master/colors/kolor.vim" &
${ECHO} -e "\n\e[1;36;40mDownload git contrib - diff-highlight from server...\n\e[0m"
${download_o} ~/.git/contrib/diff-highlight "${github_base}git/git/v2.13.2/contrib/diff-highlight/diff-highlight" && ${CHMOD} +x ~/.git/contrib/diff-highlight &
${ECHO} -e "\n\e[1;36;40mDownload git's auto completion configs from server...\n\e[0m"
git_auto_complete_path="${github_base}git/git/${git_version}/contrib/completion/git-completion."
${download_o} ~/.git-completion.bash "${git_auto_complete_path}bash" &
${download_o} ~/.git-completion.tcsh "${git_auto_complete_path}tcsh" &
${download_o} ~/.git-completion.zsh "${git_auto_complete_path}zsh" &

wait

if [ "$os" = "FreeBSD" ] && [ -r /usr/local/share/certs/ca-root-nss.crt ]; then
  ${ECHO} -e "\n\e[1;36;40mAdd ca-certificate path for FreeBSD's wget & aria2...\n\e[0m"
  ${ECHO} -e "\nca-certificate=/usr/local/share/certs/ca-root-nss.crt" >> ~/.wgetrc
  ${ECHO} -e "\nca-certificate=/usr/local/share/certs/ca-root-nss.crt" >> ~/.aria2/aria2.conf
fi

${ECHO} -e "\n\e[1;36;40mUnitial installation was finished!\n\nPlease terminate all other works and restart your shell or re-login.\n\e[0m"
