# TL-OSINT-Tools-Script

A fixed and modernized version of the original Trace Labs OSINT VM tools script.

---

## What's Fixed & Changed

- Broken or deprecated tools have been replaced or removed  
- Rewritten to properly use `pipx` for Python-based CLI tools  
- Improved tool accessibility from the terminal (no need for `python3 tool.py`)  
- Fixed issues with Tor Browser, Shodan, h8mail, and other installs  
- Added user feedback and proper error handling  
- Unnecessary redundancy removed (global installs > local venvs)  

---

## How to Download and Use

1. Clone this repository:  `git clone https://github.com/Argonyte/TL-OSINT-Tools-Script.git`
2. Do:  `cd TL-OSINT-Tools-Script`  
3. Make the script executable: `chmod +x new-update-tool-script.sh`
4. Run the script without sudo: `./new-update-tool-script.sh`

---

## Important Usage Note

Do not run the script as sudo unless absolutely necessary.

If you run this script as root, globally installed tools (like h8mail, toutatis, etc.) may not appear in your normal user's $PATH.

The script includes some basic path recovery logic if you run it as root, but standard usage is always recommended without sudo.

Maybe in the future I might re-write the entire script and fix it.

---

## Full Disclosure

This project is not officially affiliated with Trace Labs.
I just wanted a fix for the original broken script which is on their VM.

The original concept, layout, and intent belong to Trace Labs and its contributors.

This version was created to make the script work again on modern systems.
The script is made with love, alot of anger towards myself, my want to learn bash and AI helping me understand my mistakes and debugging.
