# 🎥 Aniwave Kwik Downloader

<p align="center">
  <b>Automated Anime Episode Downloader with kwik.si Bypass</b><br>
  <sub>Automatically verifies & refreshes kwik.si tokens to extract direct download links</sub>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Status-Active-brightgreen">
  <img src="https://img.shields.io/badge/License-MIT-blue">
  <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20(WSL)-orange">
</p>

## 📖 About

Aniwave Kwik Downloader is a powerful automation tool that:
- Automatically verifies and refreshes kwik.si session tokens
- Extracts direct download links from protected pages
- Handles all verification steps in the background
- Provides a clean, color-coded terminal interface

Perfect for anime enthusiasts who want to download episodes without manual browser interactions.

## ✨ Features

✅ **Automatic Token Management** - No more manual verification
✅ **Headless Browser Operation** - Works silently in the background
✅ **Direct Download Links** - Get the actual media files
✅ **User-Friendly Interface** - Color-coded terminal output
✅ **Easy Setup** - Works out of the box with minimal configuration

## 📦 Requirements

### System Requirements
- Linux (Ubuntu/Debian/Kali) or Windows with WSL
- Bash
- Python 3.8+
- Google Chrome or Chromium

### Python Packages
- `selenium`
- `chromedriver-autoinstaller`
- `webdriver-manager`

## ⚙️ Installation

### 1️⃣ Install System Dependencies

```bash
sudo apt update && sudo apt install -y bash curl grep python3 python3-pip chromium
```
2️⃣ Install Google Chrome (if not already installed)
```bash
wget https://storage.googleapis.com/chrome-for-testing-public/139.0.7258.66/linux64/chrome-linux64.zip
unzip chrome-linux64.zip
sudo mv chrome-linux64 /opt/google-chrome
sudo chmod +x /opt/google-chrome/chrome
sudo ln -sf /opt/google-chrome/chrome /usr/bin/google-chrome
```
3️⃣ Install Chrome WebDriver
```bash
wget https://storage.googleapis.com/chrome-for-testing-public/139.0.7258.66/linux64/chromedriver-linux64.zip
unzip chromedriver-linux64.zip
sudo mv chromedriver-linux64/chromedriver /usr/local/bin/chromedriver
sudo chmod +x /usr/local/bin/chromedriver
```
4️⃣ Install Python Dependencies
```bash
pip3 install selenium chromedriver-autoinstaller webdriver-manager --break-system-packages
```
If you get a PATH warning, add the following to your shell configuration:

For Bash:
```bash
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc && source ~/.bashrc
```

For Zsh:
```bash
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.zshrc && source ~/.zshrc
```
5️⃣ Download the Repository
```bash
git clone https://github.com/Andreaz254/anime-downloader-and-scraper.git
cd anime-downloader-and-scraper
```
6️⃣ Make the Script Executable
```bash
chmod +x downloader.sh
```
🚀 Usage
```bash
./downloader.sh
```
📸 Preview
<p align="center"> <img src="./terminal-preview.png" alt="Terminal Preview" width="800"> </p>
🛠 Troubleshooting
Issue	Solution
chromedriver not found	Run pip3 install chromedriver-autoinstaller or manually install matching driver version
Token/session expired too quickly	The script automatically refreshes tokens - just re-run if needed
No Chrome installed	Install Chrome or Chromium and ensure it's in your PATH
Permission denied errors	Run chmod +x on the script and ensure proper file permissions
📝 License

This project is licensed under the MIT License.
<p align="center"> Made with ❤️ by anime lovers, for anime lovers. </p> ```
