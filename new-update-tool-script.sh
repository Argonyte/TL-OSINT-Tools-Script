#!/bin/zsh


# Cleanup function to kill the background keep-alive process
cleanup() {
    # Kill the background keep-alive process
    kill %1
}

# Set trap to call cleanup function upon script exit
trap cleanup EXIT


# More frequent keep-alive: every 30 seconds
while true; do
  sudo -n true
  sleep 30
done 2>/dev/null &


# Define the log file location
LOG_FILE="$HOME/osint_logs/osint_install_error.log"


# Initialize the log file and create the log directory
init_error_log() {
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "Starting OSINT Tools Installation: $(date)" > "$LOG_FILE"
}


# Function to add an error message to the log file
add_to_error_log() {
    echo "$1" >> "$LOG_FILE"
}

display_log_contents() {
    if [ -s "$LOG_FILE" ]; then
        echo "Installation completed with errors. Review the log below:"
        cat "$LOG_FILE"
    else
        echo "Installation completed successfully with no errors."
    fi
}


# Function to update and upgrade the system
update_system() {
    sudo apt-get update || { echo "Failed to update package lists"; add_to_error_log "Failed to update package lists"; }
    sudo apt-get dist-upgrade -y || { echo "Failed to upgrade the system"; add_to_error_log "Failed to upgrade the system"; }
}


# Function to set up the PATH
setup_path() {
    if ! grep -q 'export PATH=$PATH:$HOME/.local/bin' ~/.zshrc; then
        echo '\nexport PATH=$PATH:$HOME/.local/bin' >> ~/.zshrc
    fi
    . ~/.zshrc || { echo "Failed to source .zshrc"; add_to_error_log "Failed to source .zshrc"; }
}

#tools go brrrrr
install_tools() {
    local tools=(spiderfoot sherlock maltego python3-shodan theharvester webhttrack outguess stegosuite wireshark metagoofil eyewitness exifprobe ruby-bundler recon-ng cherrytree instaloader photon sublist3r osrframework joplin drawing cargo pkg-config curl python3-pip pipx python3-exifread python3-fake-useragent tor torbrowser-launcher yt-dlp keepassxc)
    for tool in "${tools[@]}"; do
        if ! dpkg -l | grep -qw $tool; then
            sudo apt install $tool -y 2>>"$LOG_FILE" || {
                echo "Failed to install $tool"
                add_to_error_log "Failed to install $tool, see log for details."
            }
        else
            echo "$tool is already installed."
        fi
    done
}

#Phoneinfoga installer
install_phoneinfoga() {
    local download_dir="$HOME/Downloads"
    mkdir -p "$download_dir"

    local phoneinfoga_tar="$download_dir/phoneinfoga.tar.gz"
    curl -sSL "https://github.com/sundowndev/phoneinfoga/releases/latest/download/phoneinfoga_Linux_x86_64.tar.gz" -o "$phoneinfoga_tar" \
        || { echo "Failed to download PhoneInfoga"; add_to_error_log "Failed to download PhoneInfoga"; return 1; }

    tar -xvzf "$phoneinfoga_tar" -C "$download_dir" || { echo "Failed to extract PhoneInfoga"; add_to_error_log "Failed to extract PhoneInfoga"; return 1; }
    sudo mv "$download_dir/phoneinfoga" /usr/local/bin/phoneinfoga || { echo "Failed to move PhoneInfoga"; add_to_error_log "Failed to move PhoneInfoga"; return 1; }
    chmod +x /usr/local/bin/phoneinfoga
}


# Function to install Python packages globally post v12 because kali likes venv too much. yes this is a stupid fix. no idk how to get it better.
install_python_packages() {
    sudo apt install python3-setuptools -y || { echo "Failed to install setuptools"; add_to_error_log "Failed to install setuptools"; }

    pipx install youtube-dl || { echo "Failed to install youtube-dl"; add_to_error_log "Failed to install youtube-dl"; }
    pip3 install dnsdumpster --break-system-packages || { echo "Failed to install dnsdumpster"; add_to_error_log "Failed to install dnsdumpster"; }
    pipx install h8mail || { echo "Failed to install h8mail"; add_to_error_log "Failed to install h8mail"; }
    pipx install toutatis || { echo "Failed to install toutatis"; add_to_error_log "Failed to install toutatis"; }
    pip3 install tweepy --break-system-packages || { echo "Failed to install tweepy"; add_to_error_log "Failed to install tweepy"; }
    pip3 install onionsearch --break-system-packages || { echo "Failed to install onionsearch"; add_to_error_log "Failed to install onionsearch"; }
}

# Function to install sn0int and fixed the keyring thing
install_sn0int() {
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://apt.vulns.sexy/kpcyrd.pgp | sudo gpg --dearmor -o /etc/apt/keyrings/sn0int.gpg \
        || { echo "Failed to add sn0int gpg key"; add_to_error_log "Failed to add sn0int gpg key"; }
    echo "deb [signed-by=/etc/apt/keyrings/sn0int.gpg] http://apt.vulns.sexy stable main" | sudo tee /etc/apt/sources.list.d/sn0int.list \
        || { echo "Failed to add sn0int to sources list"; add_to_error_log "Failed to add sn0int to sources list"; }
    sudo apt update || { echo "Failed to update package lists for sn0int"; add_to_error_log "Failed to update package lists for sn0int"; }
    sudo apt install sn0int -y || { echo "Failed to install sn0int"; add_to_error_log "Failed to install sn0int"; }
}

# Install FinalRecon with fallback to pip if apt fails
install_finalrecon() {
    if ! sudo apt install finalrecon -y; then
        pip3 install finalrecon --break-system-packages || { echo "Failed to install finalrecon via pip"; add_to_error_log "Failed to install finalrecon via pip"; }
    fi
}


# Function to update TJ Null Joplin Notebook
update_tj_null_joplin_notebook() {
    local repo_dir="$HOME/TJ-OSINT-Notebook"
    if [ -d "$repo_dir" ]; then
        cd "$repo_dir" && git pull || { echo "Failed to update TJ-OSINT-Notebook"; add_to_error_log "Failed to update TJ-OSINT-Notebook"; return 1; }
    else
        git clone https://github.com/tjnull/TJ-OSINT-Notebook.git "$repo_dir" || { echo "Failed to clone TJ-OSINT-Notebook"; add_to_error_log "Failed to clone TJ-OSINT-Notebook"; return 1; }
    fi
}

# Invalidate the sudo timestamp before exiting
sudo -k

# Main script execution
init_error_log

update_system
setup_path
install_tools
install_phoneinfoga
install_python_packages
install_sn0int
install_finalrecon
update_tj_null_joplin_notebook

display_log_contents

