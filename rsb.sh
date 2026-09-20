#!/bin/bash

# Цвета для красивого вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # Без цвета

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

# Проверка наличия systemd-resolved
if ! systemctl is-active --quiet systemd-resolved && ! systemctl is-enabled --quiet systemd-resolved; then
    echo -e "${RED}Ошибка: Служба systemd-resolved не найдена или не используется в вашей системе.${NC}"
    exit 1
fi

show_menu() {
    echo -e "${BLUE}=== Управление DNS: Russian Services Blacklist ===${NC}"
    echo "1) Включить зашифрованный DoT DNS"
    echo "2) Откат (Вернуть стандартные настройки DNS)"
    echo "3) Выход"
    echo -n "Выберите действие [1-3]: "
}

apply_dns() {
    echo -e "\n${BLUE}Настройка конфигурации systemd-resolved...${NC}"
    
    # Резервная копия на всякий случай
    cp "$CONF_FILE" "${CONF_FILE}.bak"

    # Удаляем старые упоминания этих параметров, если они уже были
    sed -i '/^DNS=/d' "$CONF_FILE"
    sed -i '/^DNSOverTLS=/d' "$CONF_FILE"

    # Вставляем новые параметры в секцию [Resolve]
    sed -i "/^\[Resolve\]/a ${DNS_LINE}\n${DOT_LINE}" "$CONF_FILE"

    echo -e "${BLUE}Восстановление правильного системного симлинка...${NC}"
    ln -sf "$STUB_CONF" "$RESOLV_CONF"

    echo -e "${BLUE}Перезапуск службы systemd-resolved...${NC}"
    systemctl restart systemd-resolved

    echo -e "${GREEN}✔ Изменения успешно применены!${NC}"
    echo -e "Проверить статус можно командой: ${BLUE}resolvectl status${NC}"
    echo -e "Проверить блокировку: ${BLUE}nslookup ya.ru${NC}\n"
}

revert_dns() {
    echo -e "\n${BLUE}Откат изменений и восстановление стандартных DNS...${NC}"

    if [ -f "${CONF_FILE}.bak" ]; then
        # Если есть бэкап — восстанавливаем его
        mv "${CONF_FILE}.bak" "$CONF_FILE"
    else
        # Если бэкапа нет — просто вычищаем наши строки
        sed -i "/$DNS_LINE/d" "$CONF_FILE"
        sed -i "/$DOT_LINE/d" "$CONF_FILE"
    fi

    echo -e "${BLUE}Перезапуск службы systemd-resolved...${NC}"
    systemctl restart systemd-resolved

    echo -e "${GREEN}✔ Настройки DNS успешно возвращены в исходное состояние (DHCP).${NC}\n"
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
