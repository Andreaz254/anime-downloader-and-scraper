#!/bin/bash
# Define ANSI color codes
RED='\033[1;31m'    # Bold Red for errors
GREEN='\033[0;32m'  # Normal Green for successful logs
YELLOW='\033[1;33m' # Bold yellow for reading input data
NC='\033[0m'        # No Color
YELLO='\033[0;33m'  # Normal Yellow for reading input data
BLUE='\033[0;34m'   # Normal Blue for choices
blue='\033[1;34m'   # Bold Blue for successful extracted links
PURPLE='\033[0;35m' # Normal purple for curl requests and download progress
echo -e "${YELLOW}VERIFYING SESSION COOKIES AND TOKEN${NC}"

# Load existing token and session from file
source session.env
VERIFY_COOKIE="cf_clearance=Yh8MzkkK23uBYMBiQyXj_qGAIAMorpHNF2hx6MDq2nc-1754628409-1.2.1.1-uvv2F04RFYjGMq_1JSv9ceuHdwf7v9rKXzQchV78N51pjmb5465or8MNCzUonWW7mDW7EoLS9VErp1.q4dWuMGfZplFUI0MKk7qPEuzoplYxrQAHciZUpmOCxTQbqz39Lw5_RRii6Z5JSuDxbRMevqPFfrDdL4C2MAkcubTxGgiE12BJSv0hLzlG9JR4JrDqvV0yiJr5AcGpLFSMXmLeGcLQx2fJHpNPOr4hoK61PYM; srv=s0;kwik_session=$VERIFY_SESSION"
VERIFY_URL="https://kwik.si/d/2dHUQKIeE0wg"

# Send verification request
verify_response=$(curl -s "$VERIFY_URL" \
   -X POST \
   -H "Referer: $VERIFY_URL" \
   -H "Cookie: $VERIFY_COOKIE" \
   --data-raw "_token=$VERIFY_TOKEN")

# Check for success
if echo "$verify_response" | grep -q 'http-equiv="refresh"'; then
   echo -e  "${GREEN}[✓] Success: Redirect detected${NC}."

# If expired
elif echo "$verify_response" | grep -q 'Page Expired'; then
   echo -e "${RED}[✗] kwik_session and token expired.${NC}" echo -e "${GREEN}Getting new values...${NC}"

   read -r VERIFY_TOKEN VERIFY_SESSION <<<$(python3 <<EOF
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
import time

options = Options()
options.headless = True
driver = webdriver.Chrome(options=options)

try:
    driver.get("https://kwik.si/f/2dHUQKIeE0wg")
    time.sleep(3)

    token = driver.find_element(By.NAME, "_token").get_attribute("value")
    cookies = driver.get_cookies()
    kwik_session = next(c['value'] for c in cookies if c['name'] == 'kwik_session')

    print(token, kwik_session)
finally:
    driver.quit()
EOF
   )

   VERIFY_COOKIE="kwik_session=$VERIFY_SESSION"

   echo -e "${GREEN}[✓] New _token: $VERIFY_TOKEN${NC}"
   echo -e "${GREEN}[✓] New kwik_session: $VERIFY_SESSION${NC}"

   # Save to session.env for future runs
   cat <<EOF > session.env
VERIFY_TOKEN="$VERIFY_TOKEN"
VERIFY_SESSION="$VERIFY_SESSION"
EOF

   # Retry verification with new values
   verify_response=$(curl -s "$VERIFY_URL" \
      -X POST \
      -H "Referer: $VERIFY_URL" \
      -H "Cookie: $VERIFY_COOKIE" \
      --data-raw "_token=$VERIFY_TOKEN")

   if echo -e "$verify_response" | grep -q 'http-equiv="refresh"'; then
      echo -e "${GREEN}[✓] Success after retry: Redirect detected.${NC}"
   else
      echo -e "${RED}[✗] Retry failed:${NC}"
      echo "$verify_response" | head -n 10
   fi
else
   echo "${RED}[!] Unknown response:${NC}"
   echo "$verify_response" | head -n 10
fi



read -e -p "$(echo -e "${YELLOW}WHICH ANIME DO YOU WANT TO DOWNLOAD? :${NC}")" ANIME_NAME
ANIME_NAME=$(echo "$ANIME_NAME" | xargs)  # Trim spaces

mapfile -t matches < <(grep -iF -- "$ANIME_NAME" anime_id_map.txt)

if [[ ${#matches[@]} -eq 0 ]]; then
    echo -e "${RED}[!] No anime found matching: $ANIME_NAME${NC}"
    exit 1
elif [[ ${#matches[@]} -eq 1 ]]; then
    chosen_anime="${matches[0]}"
    echo -e "${GREEN}[✓] One match found: $chosen_anime${NC}"
else
    echo -e "${YELLOW}[*] Multiple matches found:${NC}"
    for i in "${!matches[@]}"; do
        echo -e "${BLUE}  ($((i+1))) ${matches[i]}${NC}"
    done

    while true; do
        read -e -p "$(echo -e "${YELLO}Choose the number of the correct anime :${NC}")" choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#matches[@]})); then
            chosen_anime="${matches[choice-1]}"
            echo -e "${GREEN}[✓] You chose: $chosen_anime${NC}"
            break
        else
            echo -e "${RED}[!] Invalid choice. Try again.${NC}"
        fi
    done
fi
read -e -p "$(echo -e "${YELLOW}WHAT EPISODE DO YOU WANT TO DOWNLOAD FROM :${NC}")" START_EP
read -e -p "$(echo -e "${YELLOW}WHAT EPISODE DO YOU WANT TO DOWNLOAD LAST :${NC}")" END_EP

IFS="-" read -r anilistId malId _ <<< "$chosen_anime"
#CHOOSING ANIME PREFERENCE DOWNLOADS
echo -e "${YELLOW}Choose type:${NC}"
echo -e "${BLUE}1) Dub${NC}"
echo -e "${BLUE}2) Sub${NC}"
read -e -p "$(echo -e "${YELLOW}Enter your choice (1 or 2) :${NC}")" type_choice

# Choose resolution
echo -e "${YELLOW}Choose resolution(check first if link is availble above⬆️):${NC}"
echo -e "${BLUE}1) 360p${NC}"
echo -e "${BLUE}2) 720p${NC}"
echo -e "${BLUE}3) 1080p${NC}"
read -e -p "$(echo -e "${YELLOW}Enter your choice (1, 2, or 3) :${NC}")" res_choice

# THE LOCATION TO SAVE THE FILES
echo -e "${YELLOW}WHERE DO YOU WANT TO SAVE YOUR FILES?${NC}"
echo -e "${BLUE}(1) This Directory${NC}"
echo -e "${BLUE}(2) Create New Directory: videos${NC}"
read -e -p "$(echo -e "${YELLOW}: ${NC}")" location


# Check if both IDs are the same or different and construct URL and REFERER accordingly
if [[ "$anilistId" == "$malId" ]]; then
    # If both IDs are the same, use one ID for all
    API_ID="$anilistId"
    URL_TEMPLATE="https://aniwave.at/api/anime/download?anilistId=$API_ID&malId=$API_ID&epNum="
    REFERER_TEMPLATE="https://aniwave.at/watch/$API_ID?host=pahe&ep="
else
    # Use different anilistId and malId
    URL_TEMPLATE="https://aniwave.at/api/anime/download?anilistId=$anilistId&malId=$malId&epNum="
    REFERER_TEMPLATE="https://aniwave.at/watch/$anilistId?host=pahe&ep="
fi

Cookie='cf_clearance=ka49tvBFRQuVDUDvAq.CSc2U9tvBOIROcrE62WvwjeE-1754542431-1.2.1.1-c3Wk.Yx.QXFzxxX2RPO7yZJOeR.6T7crUwflgtGG418W0hD8opvVsxS4AwRJnI87g85pYkzsUVZNpbrPgNm2xlCQGhrirHaBBo8oe8xiVrgkC7qjLf2olO1Mc6_VwM5x3COY4uXcxwuAWLHF746OGYyfUL8UIMQXiArejAwnMH6VfVPeAQ3QbzynGC4POMukK1e9xM2bOY.6VNIhUjTfabpC6g.dIrWLI4Uc2imFG6s; csrf_token=1b983011-82a8-42ac-bdc6-0e36e2b56cbe; __pf=1'
USER_AGENT='User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36'

for ((EP=$START_EP; EP<=$END_EP; EP++)) do
   URL="${URL_TEMPLATE}${EP}"
   REFERER="Referer: ${REFERER_TEMPLATE}${EP}&type=sub"
   echo -e "${GREEN}fetching download link for Episode $EP...${NC}"

#COMMAND TO GET THE REDIRECT LINKS
encoded_response=$(curl -s "$URL" \
--compressed \
-H "$Cookie" \
-H "$REFERER" \
-H "$USER_AGENT" \
--http2)


base64_string=$(echo "$encoded_response" | grep -oP 'U2FsdGVk[^\"]+')
echo -e "${GREEN}[+]Extracted base64_string:$base64_string${PURPLE}"

#Decoding it in python and saving to decode.json
python3 <<EOF
from base64 import b64decode
from Crypto.Cipher import AES
import hashlib
import json

def openssl_key_iv(password, salt, key_len=32, iv_len=16):
    data = password.encode('utf-8') + salt
    md5_hash = lambda d: hashlib.md5(d).digest()
    d = md5_hash(data)
    result = d
    while len(result) < (key_len + iv_len):
        d = md5_hash(d + data)
        result += d
    return result[:key_len], result[key_len:key_len+iv_len]

def decrypt(encrypted_b64, password):
    raw = b64decode(encrypted_b64)
    assert raw[:8] == b"Salted__"
    salt = raw[8:16]
    key, iv = openssl_key_iv(password, salt)
    cipher = AES.new(key, AES.MODE_CBC, iv)
    decrypted = cipher.decrypt(raw[16:])
    pad = decrypted[-1]
    return decrypted[:-pad].decode('utf-8')

enc_data = """$base64_string"""
password = "itsalrightbroiknowyouwantsourcesifyoucamethiswayyoudeserveit"
try:
    plaintext = decrypt(enc_data, password)
    with open("decoded.json", "w") as f:
        f.write(plaintext)
    print("[+] Decryption successful. Saved to decoded.json")
except Exception as e:
    print("[-] Decryption failed:", e)
EOF
cat decoded.json


#EXTRACTING THE LINKS
# Read decoded links from file
json_file=$(<decoded.json)
echo -e "${blue}$json_file${NC}" > temp.txt

# Extract links using jq if available
if command -v jq &>/dev/null; then
  echo -e "${GREEN}[+] Extracting URLs using jq...${NC}"

  # Categorize qualities into closest resolutions: 360p, 720p, 1080p
  mapfile -t sub_links < <(jq -r '.[] | select(.quality | test("Sub")) | "\(.quality)|\(.url)"' decoded.json)
  mapfile -t dub_links < <(jq -r '.[] | select(.quality | test("Dub")) | "\(.quality)|\(.url)"' decoded.json)

  # Initialize variables
  url_360p_sub=""; url_720p_sub=""; url_1080p_sub=""
  url_360p_dub=""; url_720p_dub=""; url_1080p_dub=""

  # Function to map resolutions based on proximity
  map_resolution() {
    local res=$1
    if (( res < 540 )); then echo "360"
    elif (( res < 900 )); then echo "720"
    else echo "1080"
    fi
  }

  # Process Sub links
  for entry in "${sub_links[@]}"; do
    quality=$(cut -d '|' -f1 <<< "$entry")
    url=$(cut -d '|' -f2 <<< "$entry")
    res=$(grep -oP '\d+' <<< "$quality")
    bucket=$(map_resolution "$res")
    eval "url_${bucket}p_sub=\"$url\""
  done

  # Process Dub links
  for entry in "${dub_links[@]}"; do
    quality=$(cut -d '|' -f1 <<< "$entry")
    url=$(cut -d '|' -f2 <<< "$entry")
    res=$(grep -oP '\d+' <<< "$quality")
    bucket=$(map_resolution "$res")
    eval "url_${bucket}p_dub=\"$url\""
  done

  # Output
  echo -e "${blue}[+] Variables:${NC}"
  echo -e "${BLUE}360p Sub: $url_360p_sub${NC}"
  echo -e "${BLUE}720p Sub: $url_720p_sub${NC}"
  echo -e "${BLUE}1080p Sub: $url_1080p_sub${NC}"
  echo -e "${BLUE}360p Dub: $url_360p_dub${NC}"
  echo -e "${BLUE}720p Dub: $url_720p_dub${NC}"
  echo -e "${BLUE}1080p Dub: $url_1080p_dub${NC}"

else
  echo -e "${RED}[!] jq not found. Falling back to grep.${RED}"


  # Basic grep fallback (outputs all URLs)
  grep -Eo'https?://[^"]+' decoded.json > all_links.txt
  echo "${GREEN}[+] Links saved to all_links.txt${NC}"
fi



# Function to check and print link status
check_link() {
  local label=$1
  local value=$2

  if [[ -z "$value" ]]; then
    echo -e "${RED}[✘] $label link is NOT available${NC}"
    exit 1
  else
    echo -e "${GREEN}[✔] $label link is available${NC}"
  fi
}

# Run checks
check_link "360p Sub" "$url_360p_sub"
check_link "720p Sub" "$url_720p_sub"
check_link "1080p Sub" "$url_1080p_sub"
check_link "360p Dub" "$url_360p_dub"
check_link "720p Dub" "$url_720p_dub"
check_link "1080p Dub" "$url_1080p_dub"


# Determine selected link
case $type_choice in
  1) # Dub
    case $res_choice in
      1) selected_link=$url_360p_dub ;;
      2) selected_link=$url_720p_dub ;;
      3) selected_link=$url_1080p_dub ;;
      *) echo -e "${RED}Invalid resolution selected${NC}"; exit 1 ;;
    esac
    ;;
  2) # Sub
    case $res_choice in
      1) selected_link=$url_360p_sub ;;
      2) selected_link=$url_720p_sub ;;
      3) selected_link=$url_1080p_sub ;;
      *) echo -e "${RED}Invalid resolution selected${NC}"; exit 1 ;;
    esac
    ;;
  *) echo -e "${RED}Invalid type selected${NC}"; exit 1 ;;
esac



if [[ "$location" == "1" ]]; then
  echo -e "{GREEN}Saving in this directory...${NC}"
  directory="."
elif [[ "$location" == "2" ]]; then
  echo -e "${GREEN}Creating new folder: videos${NC}"
  mkdir -p videos
  directory="./videos"
else
  echo -e "${RED}!!! Wrong choice${NC}"
  exit 1
fi

echo -e "${GREEN}Files will be saved in: $directory${NC}"

# Output the result
echo -e "${blue}Selected link: $selected_link${PURPLE}"

curl "$selected_link" \
  --compressed \
  -H "User-Agent: $User_Agent" \
  -H "Accept: $Accept" \
  -H "Accept-Language: $Accept_language" \
  -H 'Accept-Encoding: gzip, deflate, br, zstd' \
  -H 'Connection: keep-alive' \
  -H "Cookie: $Cookie" > test.txt

grep "kwik" test.txt

kwik_url=$(grep -oP 'https://kwik\.si/[a-zA-Z0-9/_\-]+' test.txt | head -n 1)

echo -e "${blue}Extracted kwik link: $kwik_url${NC}"

converted_url="${kwik_url/\/f\//\/d\/}"
echo -e "${blue}$converted_url${blue}"

kwik_d_response=$(curl "$converted_url" \
  -X POST \
  -H 'Accept-Encoding: gzip, deflate, br, zstd' \
  -H "Referer: $kwik_url" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Origin: https://kwik.si' \
  -H 'Connection: keep-alive' \
  -H "Cookie: $VERIFY_COOKIE" \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'Sec-Fetch-Dest: document' \
  -H 'Sec-Fetch-Mode: navigate' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-User: ?1' \
  -H 'Priority: u=0, i' \
  -H 'TE: trailers' \
  --data-raw "_token=$VERIFY_TOKEN"
)
echo -e "${GREEN}$kwik_d_response${NC}"

# Extract final URL
final_url=$(echo "$kwik_d_response" | grep -oP '(?<=url=\x27).+?(?=\x27)' | head -n1)
echo -e "${BLUE}Final Video URL: $final_url${NC}"

# Extract filename
filename=$(echo "$final_url" | grep -oP '(?<=file=)[^&]+')
echo -e "${GREEN}Saving as: $filename${NC}"

# Define the full path
filepath="$directory/$filename"

# Check if file exists
if [ -f "$filepath" ]; then
    echo -e "${RED}⚠️ File already exists at: $filepath${PURPLE}"
    read -e -p "$(echo -e "${YELLO}❓ Do you want to continue downloading it? (y/n) :${PURPLE}")" choice
    case "$choice" in
        y|Y )
            
            echo -e "${GREEN}⬇️contineuing downloading...${PURPLE}"
            aria2c -x16 -s16 -k1M -o "$filepath" "$final_url"
            ;;
        n|N )
            echo -e "${GREEN}✅ Skipping download.${PURPLE}"
            ;;
        * )
            echo -e "${RED}❌ Invalid input. Skipping.${PURPLE}"
            ;;
    esac
else
    echo -e "${GREEN}⬇️ Downloading new file...${PURPLE}"
    aria2c -x16 -s16 -k1M -o "$filepath" "$final_url"
fi
done




