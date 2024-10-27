#!/bin/bash
clear

# Mendefinisikan warna untuk pesan
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export CYAN_BG='\033[46;1;97m'   # Latar belakang cyan cerah dengan teks putih
export LIGHT='\033[0;37m'
export PINK='\033[0;35m'
export PINK_BG='\033[45;1;97m'   # Latar belakang pink cerah dengan teks putih
export NC='\033[0m'

# Fungsi untuk memeriksa IP dan mendapatkan client_name dan exp_date
check_ip_and_get_info() {
    local ip=$1
    local line
    while IFS= read -r line; do
        if [[ $line == *"$ip"* ]]; then
            client_name=$(echo "$line" | awk '{print $2}')
            exp_date=$(echo "$line" | awk '{print $4}')
            return 0
        fi
    done <<< "$permission_file"
    return 1
}

# Mengambil data client dan expdate dari URL
permission_file=$(curl -s https://raw.githubusercontent.com/helehsemvakwkwk/viavia/main/sholatbro.txt)

# Mengambil informasi sistem
OS=$(lsb_release -ds)
RAM=$(free -m | awk '/Mem:/ { print $2 }')
UPTIME=$(uptime -s)
current_time=$(date "+%Y-%m-%d %H:%M:%S")
total_uptime=$(date -ud@$(( $(date -d "$current_time" +%s) - $(date -d "$UPTIME" +%s) )) +'%j days, %H hours')
# Hilangkan nol di depan pada days dan hours
formatted_uptime=$(echo "$total_uptime" | sed 's/^0*//; s/, 0*/, /')
IP_VPS=$(hostname -I | awk '{print $1}')
ISP=$(curl -s ipinfo.io/org)
DOMAIN=$(cat /etc/data/domain)

# Mengambil informasi IP lengkap dari ipinfo.io
IP_INFO=$(curl -s "http://ipinfo.io/$IP_VPS/json")
IP_REGION=$(echo "$IP_INFO" | jq -r '.region')
IP_COUNTRY=$(echo "$IP_INFO" | jq -r '.country')
IP_LOC=$(echo "$IP_INFO" | jq -r '.loc')

# Periksa IP terlebih dahulu
echo -e "${GREEN}⌛ Sabar Sedang Memeriksa IP...${NC}"
sleep 1
clear

if check_ip_and_get_info "$IP_VPS"; then
    :
else
    echo -e "${RED}IP not found in our database${NC}"
   echo -e "➥ Contact admin ${CYAN}「 ✦ @SaputraTech ✦ 」${NC}"
    exit 1
fi

# Periksa apakah skrip sudah kedaluwarsa
current_date=$(date +%Y-%m-%d)
if [[ "$exp_date" != "Not Found" && $(date -d "$exp_date" +%Y-%m-%d) < $(date -d "$current_date" +%Y-%m-%d) ]]; then
    echo -e "${GREEN}[ INFO ]${NC} ${RED}Script Expired !!!${NC}"
   echo -e "➥ Contact admin ${CYAN}「 ✦ @SaputraTech ✦ 」${NC}"
    exit 1
fi

# Menghitung sisa hari
if [[ "$exp_date" != "Not Found" ]]; then
    days_remaining=$(( ($(date -d "$exp_date" +%s) - $(date -d "$current_date" +%s)) / 86400 ))
    exp_message="$days_remaining ${YELLOW}days remaining${NC}"
else
    exp_message="Not Found"
fi

# // Export Banner Status Information
export ERROR="[${RED} ERROR ${NC}]";
export INFO="[${YELLOW} INFO ${NC}]";
export OKEY="[${GREEN} OKEY ${NC}]";
export PENDING="[${YELLOW} PENDING ${NC}]";
export SEND="[${YELLOW} SEND ${NC}]";
export RECEIVE="[${YELLOW} RECEIVE ${NC}]";

# // VAR
if [[ $(netstat -ntlp | grep -i nginx | grep -i 0.0.0.0:443 | awk '{print $4}' | cut -d: -f2 | xargs | sed -e 's/ /, /g') == '443' ]]; then
    NGINX="${CYAN}ON 🟢${NC}";
else
    NGINX="${RED}OFF 🔴${NC}";
fi
if [[ $(netstat -ntlp | grep -i python | grep -E '0.0.0.0:(7879|6969|8080)' | awk '{print $4}' | cut -d: -f2 | xargs | sed -e 's/ /, /g') =~ (7879|6969|8080) ]]; then
    MARZ="${CYAN}ON 🟢${NC}";
else
    MARZ="${RED}OFF 🔴${NC}";
fi
if [[ $(systemctl status ufw | grep -w Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == 'active' ]]; then
    UFW="${CYAN}ON 🟢${NC}";
else
    UFW="${RED}OFF 🔴${NC}";
fi

# Fungsi untuk mencetak teks dengan warna gradien menggunakan lolcat dan font yang lebih kecil
print_gradient_text() {
  local text="$1"
  if command -v lolcat &> /dev/null; then
    echo "$text" | figlet -f standard | lolcat
  else
    echo "$text" | figlet -f standard
  fi
}

# Teks yang ingin ditampilkan
text="SKT x AWN"

# Fungsi untuk mengambil total bandwidth menggunakan vnstat
vnstat_output=$(vnstat -y 1 --style 0 | sed -n 6p)
download=$(echo $vnstat_output | awk '{printf "%s %s", $2, $3}')
upload=$(echo $vnstat_output | awk '{printf "%s %s", $5, $6}')
total_usage=$(echo $vnstat_output | awk '{printf "%s %s", $8, $9}')

PINK='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
NC='\033[0m'

# Menggabungkan download dan upload menjadi satu baris
combined_line=$(printf "${CYAN}❖ Download :${WHITE} %s ${CYAN}❖ Upload :${WHITE} %s" "$download" "$upload")
total_usage_line=$(printf   "${CYAN}❖ Total Usage :${WHITE} %s" "$total_usage ${CYAN}❖")

# Panjang maksimum garis
max_line_length=70

# Fungsi untuk memusatkan teks
center_text() {
  local text="$1"
  local text_length=${#text}
  local padding=$(( (max_line_length - text_length) / 2 ))
  local extra_padding=$(( (max_line_length - text_length) % 2 ))
  local space=$(printf '%*s' "$padding" '')
  echo "${space}${text}${space}$(printf '%*s' "$extra_padding" '')"
}

# Ambil versi Xray
xray_version=$(/var/lib/marzban/core/xray -version | grep -oP 'Xray\s+\K[^\s]+')  # Ambil hanya versi

# Fungsi untuk menampilkan menu utama
 {
    clear
    # Mencetak teks figlet dengan warna gradien
    print_gradient_text "$text"
    #echo -e "    ❖ Jangan Berharap Banyak Pada Negara ! ❖" | lolcat
    echo -e "${CYAN} ╭═══════════════════════════════════════════════════╮${NC}"
    echo -e " ${CYAN}│${NC}${CYAN_BG}              ❖ SKT X AWN Project ❖            ${NC}${CYAN}│${NC}"
    echo -e "${CYAN} ╰═══════════════════════════════════════════════════╯${NC}"
    echo -e "${CYAN} ╭═══════════════════════════════════════════════════╮${NC}"
    echo -e " ${CYAN}│${NC} ${CYAN}System${NC}    : $OS"
    echo -e " ${CYAN}│${NC} ${CYAN}RAM${NC}       : ${RAM}MB"
    echo -e " ${CYAN}│${NC} ${CYAN}Up${NC}        : $formatted_uptime"
    echo -e " ${CYAN}│${NC} ${CYAN}ISP${NC}       : $ISP"
    echo -e " ${CYAN}│${NC} ${CYAN}IP VPS${NC}    : $IP_VPS"
    echo -e " ${CYAN}│${NC} ${CYAN}Domain${NC}    : $DOMAIN"
    echo -e " ${CYAN}│${NC} ${CYAN}Region${NC}    : $IP_REGION"
    echo -e " ${CYAN}│${NC} ${CYAN}Country${NC}   : $IP_COUNTRY"
    echo -e " ${CYAN}│${NC} ${CYAN}Loc${NC}       : $IP_LOC"
    echo -e " ${CYAN}│${NC} ${CYAN}Client${NC}    : $client_name ${CYAN}active${NC}"
    echo -e " ${CYAN}│${NC} ${CYAN}Exp${NC}       : $exp_message"
    echo -e " ${CYAN}│${NC} ${CYAN}Core${NC}      : Xray Core ${CYAN}v$xray_version${NC}"
    echo -e " ${CYAN}│${NC} ${CYAN}Versi SC${NC}  : v.6.9 ${CYAN}stable${NC}"
    echo -e "${CYAN} ╰═══════════════════════════════════════════════════╯${NC}"
    echo -e "  ${CYAN}╭∩╮─────────────────────────────────────────────╭∩╮${NC}"
    echo -e "${CYAN} ╭═════════════ ● ${WHITE}Service Information${NC} ${CYAN}● ═════════════╮${NC}"
    echo -e " ${CYAN}│${NC} ${NC}Nginx${NC}: ${NGINX} ${CYAN}│${NC} ${NC}Firewall${NC} : ${UFW} ${CYAN}│${NC} ${NC}Marzban${NC} : ${MARZ} ${CYAN}│${NC}"
    echo -e "${CYAN} ╰═══════════════════════════════════════════════════╯${NC}"
    echo -e "  ${CYAN}╭∩╮─────────────────────────────────────────────╭∩╮${NC}"
    echo -e "${CYAN} ╭═══════════════ ● ${WHITE}Bandwidht Usage${NC} ${CYAN}● ═══════════════╮${NC}"
    echo -e "$(center_text "$combined_line")"
    echo -e "$(center_text "$total_usage_line")"
    echo -e "${CYAN} ╰═══════════════════════════════════════════════════╯${NC}"
    cat /root/log-install.txt
    echo -e "${WHITE}You can type${NC} ${CYAN}'menu'${NC} ${WHITE}to continue${NC}"
}

# Menampilkan menu utama saat pertama kali menjalankan skrip
