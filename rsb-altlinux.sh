#!/bin/bash

# Цвета для красивого вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # Без цвета

CONF_DIR="/etc/systemd"
CONF_FILE="/etc/systemd/resolved.conf"
RESOLV_CONF="/etc/resolv.conf"
STUB_CONF="/run/systemd/resolve/stub-resolv.conf"
DNS_LINE="DNS=128.254.146.46#russianservicesblacklist.duckdns.org"
DOT_LINE="DNSOverTLS=yes"

# Проверка на права root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Ошибка: Этот скрипт нужно запускать с правами sudo.${NC}"
    exit 1
fi

show_menu() {
    echo -e "${BLUE}=== Управление DNS: Russian Services Blacklist (ALT Linux) ===${NC}"
    echo "1) Установить стек systemd и включить зашифрованный DoT DNS"
    echo "2) Откат (Вернуть стандартные настройки)"
    echo "3) Выход"
    echo -n "Выберите действие [1-3]: "
}

apply_dns() {
    echo -e "\n${BLUE}1. Установка необходимых компонентов systemd...${NC}"
    apt-get update
    apt-get install -y systemd-networkd libnss-resolve

    echo -e "\n${BLUE}2. Включение и запуск служб systemd...${NC}"
    systemctl enable --now systemd-networkd
    systemctl enable --now systemd-resolved

    echo -e "\n${BLUE}3. Настройка конфигурации systemd-resolved...${NC}"
    mkdir -p "$CONF_DIR"
    
    # Резервная копия на случай, если файл уже существовал
    if [ -f "$CONF_FILE" ]; then
        cp "$CONF_FILE" "${CONF_FILE}.bak"
    fi

    # Записываем конфигурацию DoT
    printf "[Resolve]\n%s\n%s\n" "$DNS_LINE" "$DOT_LINE" > "$CONF_FILE"

    echo -e "${BLUE}4. Восстановление правильного системного симлинка...${NC}"
    ln -sf "$STUB_CONF" "$RESOLV_CONF"

    echo -e "${BLUE}5. Перезапуск службы systemd-resolved...${NC}"
    systemctl restart systemd-resolved

    echo -e "\n${GREEN}✔ Всё готово! Изменения успешно применены.${NC}"
    echo -e "Проверить статус можно командой: ${BLUE}resolvectl status${NC}"
    echo -e "Проверить блокировку: ${BLUE}nslookup ya.ru${NC}\n"
}

revert_dns() {
    echo -e "\n${BLUE}Откат изменений и восстановление стандартных настроек...${NC}"

    if [ -f "${CONF_FILE}.bak" ]; then
        mv "${CONF_FILE}.bak" "$CONF_FILE"
    else
        rm -f "$CONF_FILE"
    fi

    echo -e "${BLUE}Перезапуск службы systemd-resolved...${NC}"
    systemctl restart systemd-resolved

    echo -e "${GREEN}✔ Настройки успешно возвращены в исходное состояние.${NC}\n"
}

while true; do
    show_menu
    read -r choice
    case $choice in
        1)
            apply_dns
            break
            ;;
        2)
            revert_dns
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
