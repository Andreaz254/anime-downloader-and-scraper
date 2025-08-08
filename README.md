<h1 align="center">🎥 Aniwave Kwik Downloader</h1>

<p align="center">
  <b>Automated Anime Episode Downloader from Aniwave with kwik.si Bypass</b><br>
  <sub>Verify & refresh kwik.si tokens automatically, extract direct download links, and save your time.</sub>
</p>

---

## 📖 About

**Aniwave Kwik Downloader** is a Bash + Python automation tool that:
- **Verifies** your kwik.si session cookies & tokens.
- **Refreshes** expired ones automatically using Selenium.
- **Extracts** direct download URLs from protected pages.
- **Downloads** your anime episodes without manual browser steps.

Whether you're binge-watching a series or archiving your favorites, this tool handles the annoying verification step so you can focus on the watching, not the waiting.

---

## ✨ Features

✅ Automatic kwik.si verification  
✅ Headless browser token renewal  
✅ Direct download link extraction  
✅ Color-coded terminal output  
✅ Easy to run — no coding needed  

---

## 📂 Project Structure

aniwave-kwik-downloader/
│
├── test.sh # Main script
├── session.env # Stores kwik.si session & token
└── README.md # This file


---

## 📦 Requirements

**System:**
- Bash
- curl, grep
- Python 3.8+
- Google Chrome **or** Chromium

**Python Packages:**
- Bash
- pip3, selenium, chromedriver-autoinstaller, webdriver-manager`

⚙️ Setup Procedure (First-Time Installation)

Follow these steps to set up on Ubuntu / Kali / Debian systems.

1️⃣ Install system dependencies
-Bash
`sudo apt update
sudo apt install bash curl grep python3 python3-pip chromium-browser -y`

2️⃣ Install required Python packages

`pip3 install selenium chromedriver-autoinstaller webdriver-manager`

3️⃣ Download the repository

`git clone https://github.com/yourusername/aniwave-kwik-downloader.git
cd aniwave-kwik-downloader`


5️⃣ Make the script executable

`chmod +x downloader.sh`

6️⃣ Run the script

./downloader.sh

🚀 Usage

    If your token/session is valid, the script will proceed to fetch download links.

    If expired, it launches a headless Chrome to get fresh values automatically.

    Direct links are printed in the terminal and can be piped to a downloader like aria2c or wget.

📸 Screenshot
<p align="center"> <img src="https://via.placeholder.com/800x400.png?text=Terminal+Preview" alt="Terminal Preview"> </p>
🛠 Troubleshooting
Issue	Solution
chromedriver not found	Install chromedriver-autoinstaller or manually download matching driver version.
Token/session expired too quickly	Re-run script to refresh automatically.
No Chrome installed	Install Chrome or Chromium and make sure it's in PATH.
📝 License

This project is licensed under the MIT License — feel free to use and modify.

 <p align="center"> Made with ❤️ by anime lovers, for anime lovers. </p> ``` 

