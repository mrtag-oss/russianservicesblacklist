#!/bin/bash

# Цвета для красивого вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # Без цвета

CUSTOM_CONF_DIR="/etc/systemd/resolved.conf.d"
CUSTOM_CONF_FILE="$CUSTOM_CONF_DIR/custom-dns.conf"
RESOLV_CONF="/etc/resolv.conf"
STUB_CONF="/run/systemd/resolve/stub-resolv.conf"

# Проверка на права root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Ошибка: Этот скрипт нужно запускать с правами sudo.${NC}"
    exit 1
fi

show_menu() {
    echo -e "${BLUE}=== Управление DNS в Astra Linux (systemd-resolved + DoT) ===${NC}"
    echo "1) Установить и настроить systemd-resolved с DoT (Russian Services Blacklist)"
    echo "2) Полный откат (Удалить systemd-resolved и вернуть NetworkManager)"
    echo "3) Выход"
    echo -n "Выберите действие [1-3]: "
}

install_and_configure_dns() {
    echo -e "\n${BLUE}Установка systemd-resolved и libnss-resolve...${NC}"
    apt update && apt install -y systemd-resolved libnss-resolve

    echo -e "${BLUE}Создание кастомной конфигурации...${NC}"
    mkdir -p "$CUSTOM_CONF_DIR"
    
    cat << 'EOF' > "$CUSTOM_CONF_FILE"
[Resolve]
DNS=128.254.146.46#russianservicesblacklist.duckdns.org
DNSOverTLS=yes
EOF

    echo -e "${BLUE}Активация и запуск systemd-resolved...${NC}"
    systemctl unmask systemd-resolved
    systemctl enable --now systemd-resolved

    echo -e "${BLUE}Настройка симлинка /etc/resolv.conf...${NC}"
    ln -sf "$STUB_CONF" "$RESOLV_CONF"

    echo -e "${BLUE}Перезапуск службы systemd-resolved...${NC}"
    systemctl restart systemd-resolved

    echo -e "${GREEN}✔ systemd-resolved успешно установлен и настроен!${NC}"
    echo -e "Проверить статус: ${BLUE}resolvectl status${NC}"
    echo -e "Проверить резолвинг: ${BLUE}nslookup ya.ru${NC}\n"
}

purge_dns() {
    echo -e "\n${BLUE}Полный откат: удаление кастомных настроек и systemd-resolved...${NC}"

    # Удаляем кастомный конфиг и симлинк
    rm -f "$CUSTOM_CONF_FILE"
    rm -f "$RESOLV_CONF"

    echo -e "${BLUE}Удаление пакетов systemd-resolved и libnss-resolve...${NC}"
    apt purge -y systemd-resolved libnss-resolve
    apt autoremove -y

    echo -e "${BLUE}Перезапуск NetworkManager...${NC}"
    systemctl restart NetworkManager

    echo -e "${GREEN}✔ Система полностью возвращена к стандартному состоянию NetworkManager!${NC}\n"
}

while true; do
    show_menu
    read -r choice
    case $choice in
        1)
            install_and_configure_dns
            break
            ;;
        2)
            purge_dns
            break
            ;;
        3)
            echo "Выход."
            exit 0
            ;;
        *)
            echo -e "${RED}Неверный выбор. Пожалуйста, введите число от 1 до 3.${NC}\n"
            ;;
    esac
done
