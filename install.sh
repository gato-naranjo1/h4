#!/usr/bin/env bash

set -e

GITHUB_REPO="${GITHUB_REPO:-gato-naranjo1/h4}"
GITHUB_BRANCH="${GITHUB_BRANCH:-main}"

if [ "$(id -u)" -ne 0 ]; then
    echo -e "\033[38;5;203m[ERROR] Este script debe ejecutarse con privilegios de root (sudo).\033[0m"
    exit 1
fi

RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
CYAN="\033[38;5;51m"
PURPLE="\033[38;5;141m"
GREEN="\033[38;5;84m"
YELLOW="\033[38;5;215m"
RED="\033[38;5;203m"
GRAY="\033[38;5;240m"
MUTED="\033[38;5;246m"
WHITE="\033[38;5;255m"

DASHES="──────────────────────────────────────────────────────────────"

print_box_top() {
    printf "${GRAY}╭%s╮${RESET}\n" "$DASHES"
}

print_box_bottom() {
    printf "${GRAY}╰%s╯${RESET}\n" "$DASHES"
}

print_box_divider() {
    printf "${GRAY}├%s┤${RESET}\n" "$DASHES"
}

print_box_header() {
    local title="$1"
    local clean
    clean="$(printf "%b" "$title" | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g")"
    local w
    w="$(printf "%s" "$clean" | wc -L)"
    local rem=$(( 59 - w ))
    if [ $rem -lt 1 ]; then
        rem=1
    fi
    printf "${GRAY}╭─ %b ${GRAY}%s╮${RESET}\n" "$title" "${DASHES:0:rem}"
}

print_box_row() {
    local content="$1"
    local clean
    clean="$(printf "%b" "$content" | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g")"
    local w
    w="$(printf "%s" "$clean" | wc -L)"
    local pad=$(( 62 - w ))
    if [ $pad -lt 0 ]; then
        pad=0
    fi
    local spaces=""
    if [ $pad -gt 0 ]; then
        spaces="$(printf "%*s" "$pad" "")"
    fi
    printf "${GRAY}│${RESET}%b%s${GRAY}│${RESET}\n" "$content" "$spaces"
}

clear 2>/dev/null || printf "\033[H\033[2J"

ask_user() {
    local prompt="$1"
    local default_val="$2"
    local user_val=""

    if [ -n "$prompt" ]; then
        printf "%s" "$prompt" >&2
    fi

    if [ -e /dev/tty ] && [ -r /dev/tty ]; then
        read -r user_val < /dev/tty 2>/dev/null || user_val=""
    else
        read -r user_val 2>/dev/null || user_val=""
    fi

    if [ -z "$user_val" ]; then
        user_val="$default_val"
    fi
    echo "$user_val"
}

OS_NAME="Linux"
OS_VER=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME="${NAME:-Linux}"
    OS_VER="${VERSION_ID:-}"
elif [ -f /etc/debian_version ]; then
    OS_NAME="Debian"
    OS_VER="$(cat /etc/debian_version)"
elif [ -f /etc/redhat-release ]; then
    OS_NAME="$(cat /etc/redhat-release)"
fi

ARCH="$(uname -m)"
case "$ARCH" in
    x86_64|amd64) ARCH_LABEL="x86_64"; ARCH_BIN="amd64" ;;
    aarch64|arm64) ARCH_LABEL="arm64"; ARCH_BIN="arm64" ;;
    armv7l|armhf) ARCH_LABEL="armv7"; ARCH_BIN="arm64" ;;
    *) ARCH_LABEL="$ARCH"; ARCH_BIN="amd64" ;;
esac

OS_FULL="${OS_NAME} ${OS_VER}"
OS_FULL="$(echo "$OS_FULL" | xargs)"

print_box_top
print_box_row "  ${WHITE}${BOLD}Sistema Detectado${RESET}    : ${CYAN}${OS_FULL} (${ARCH_LABEL})${RESET}"
print_box_bottom
echo ""

print_box_header "${CYAN}${BOLD}SELECCIÓN DE IDIOMA / LANGUAGE SELECTION${RESET}"
print_box_row "  ${PURPLE}01${RESET} Español           ${PURPLE}09${RESET} Русский           ${PURPLE}17${RESET} اردو"
print_box_row "  ${PURPLE}02${RESET} English           ${PURPLE}10${RESET} Deutsch           ${PURPLE}18${RESET} فارسی"
print_box_row "  ${PURPLE}03${RESET} Português         ${PURPLE}11${RESET} Italiano          ${PURPLE}19${RESET} Polski"
print_box_row "  ${PURPLE}04${RESET} B. Indonesia      ${PURPLE}12${RESET} Türkçe            ${PURPLE}20${RESET} Nederlands"
print_box_row "  ${PURPLE}05${RESET} العربية           ${PURPLE}13${RESET} Tiếng Việt        ${PURPLE}21${RESET} Українська"
print_box_row "  ${PURPLE}06${RESET} 中文              ${PURPLE}14${RESET} 한국어            ${PURPLE}22${RESET} ภาษาไทย"
print_box_row "  ${PURPLE}07${RESET} 日本語            ${PURPLE}15${RESET} हिन्दी             ${PURPLE}23${RESET} Ελληνικά"
print_box_row "  ${PURPLE}08${RESET} Français          ${PURPLE}16${RESET} বাংলা             ${PURPLE}24${RESET} Tagalog"
print_box_bottom

LANG_CHOICE="$(ask_user "  Seleccione su idioma / Select language [1-24] [default: 1]: " "1")"

case "$LANG_CHOICE" in
    1|01) LANG_CODE="es"; LANG_NAME="Español" ;;
    2|02) LANG_CODE="en"; LANG_NAME="English" ;;
    3|03) LANG_CODE="pt"; LANG_NAME="Português" ;;
    4|04) LANG_CODE="id"; LANG_NAME="Bahasa Indonesia" ;;
    5|05) LANG_CODE="ar"; LANG_NAME="العربية" ;;
    6|06) LANG_CODE="zh"; LANG_NAME="中文" ;;
    7|07) LANG_CODE="ja"; LANG_NAME="日本語" ;;
    8|08) LANG_CODE="fr"; LANG_NAME="Français" ;;
    9|09) LANG_CODE="ru"; LANG_NAME="Русский" ;;
    10)   LANG_CODE="de"; LANG_NAME="Deutsch" ;;
    11)   LANG_CODE="it"; LANG_NAME="Italiano" ;;
    12)   LANG_CODE="tr"; LANG_NAME="Türkçe" ;;
    13)   LANG_CODE="vi"; LANG_NAME="Tiếng Việt" ;;
    14)   LANG_CODE="ko"; LANG_NAME="한국어" ;;
    15)   LANG_CODE="hi"; LANG_NAME="हिन्दी" ;;
    16)   LANG_CODE="bn"; LANG_NAME="বাংলা" ;;
    17)   LANG_CODE="ur"; LANG_NAME="اردو" ;;
    18)   LANG_CODE="fa"; LANG_NAME="فارسی" ;;
    19)   LANG_CODE="pl"; LANG_NAME="Polski" ;;
    20)   LANG_CODE="nl"; LANG_NAME="Nederlands" ;;
    21)   LANG_CODE="uk"; LANG_NAME="Українська" ;;
    22)   LANG_CODE="th"; LANG_NAME="ภาษาไทย" ;;
    23)   LANG_CODE="el"; LANG_NAME="Ελληνικά" ;;
    24)   LANG_CODE="tl"; LANG_NAME="Tagalog" ;;
    *)    LANG_CODE="es"; LANG_NAME="Español" ;;
esac

case "$LANG_CODE" in
    es)
        MSG_LANG_SET="Idioma establecido: %s"
        TITLE_ICON_TEST="PRUEBA DE SOPORTE DE ICONOS"
        MSG_ICON_Q1="¿Puedes ver los iconos de arriba correctamente?"
        MSG_ICON_Q2="(Si ves cuadros vacíos o rotos, elija \"n\")"
        ASK_ICON="¿Activar soporte de iconos avanzados? [s/N]: "
        MSG_ICON_ON="Iconos avanzados ACTIVADOS."
        MSG_ICON_OFF="Modo estándar seleccionado (iconos clásicos)."
        SPINNER_MSG="Instalando lo necesario..."
        TITLE_SETTINGS="AJUSTES INICIALES"
        SUB_SETTINGS="Personalice las funciones del panel (Enter para omitir)"
        ASK_QUOTA="1. ¿Activar contador y límite de datos (MB/GB) por cuenta? [s/N]: "
        MSG_QUOTA_ON="Cuota de datos: ACTIVADA"
        MSG_QUOTA_OFF="Cuota de datos: Desactivada (Ilimitado por defecto)"
        ASK_CU="2. ¿Activar servicio CheckUser API? [S/n]: "
        ASK_CU_PORT="   Puerto para CheckUser API [default: 5000]: "
        MSG_CU_ON="CheckUser API: ACTIVADO en puerto %s"
        MSG_CU_OFF="CheckUser API: Desactivado"
        ASK_DUAL="3. ¿Activar DualMode puerto 443 (V2Ray + SSL simultáneo)? [s/N]: "
        MSG_DUAL_CONFIG="Configurando DualMode puerto 443..."
        MSG_DUAL_ON="DualMode 443: ACTIVADO (Multiplexor SNI)"
        MSG_DUAL_OFF="DualMode 443: Desactivado"
        CARD_SUCCESS="¡INSTALACIÓN COMPLETADA CON ÉXITO!"
        CARD_ACCESS="Para ingresar al panel de control en cualquier momento:"
        LBL_SVC_MAIN="Servicio Principal"
        VAL_SVC_MAIN="ACTIVO (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Puerto 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Puerto 444 (Directo/WS)"
        LBL_SVC_ICONS="Iconos Avanzados"
        LBL_SVC_LANG="Idioma"
        FOOTER_LINE="                BY DANAELH4X Y HECHO EN MÉXICO                "
        ;;
    en)
        MSG_LANG_SET="Language set: %s"
        TITLE_ICON_TEST="ICON SUPPORT TEST"
        MSG_ICON_Q1="Can you see the icons above correctly?"
        MSG_ICON_Q2="(If you see empty boxes or broken symbols, choose \"n\")"
        ASK_ICON="Enable advanced icon support? [y/N]: "
        MSG_ICON_ON="Advanced icons ENABLED."
        MSG_ICON_OFF="Standard mode selected (classic icons)."
        SPINNER_MSG="Installing required components..."
        TITLE_SETTINGS="INITIAL SETTINGS"
        SUB_SETTINGS="Customize panel features (Press Enter to skip)"
        ASK_QUOTA="1. Enable data quota counter & limit (MB/GB) per account? [y/N]: "
        MSG_QUOTA_ON="Data quota: ENABLED"
        MSG_QUOTA_OFF="Data quota: Disabled (Unlimited by default)"
        ASK_CU="2. Enable CheckUser API service? [Y/n]: "
        ASK_CU_PORT="   Port for CheckUser API [default: 5000]: "
        MSG_CU_ON="CheckUser API: ENABLED on port %s"
        MSG_CU_OFF="CheckUser API: Disabled"
        ASK_DUAL="3. Enable DualMode on port 443 (V2Ray + SSL simultaneous)? [y/N]: "
        MSG_DUAL_CONFIG="Configuring DualMode on port 443..."
        MSG_DUAL_ON="DualMode 443: ENABLED (SNI Multiplexer)"
        MSG_DUAL_OFF="DualMode 443: Disabled"
        CARD_SUCCESS="INSTALLATION COMPLETED SUCCESSFULLY!"
        CARD_ACCESS="To access the control panel at any time:"
        LBL_SVC_MAIN="Main Service"
        VAL_SVC_MAIN="ACTIVE (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Port 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Port 444 (Direct/WS)"
        LBL_SVC_ICONS="Advanced Icons"
        LBL_SVC_LANG="Language"
        FOOTER_LINE="                BY DANAELH4X & MADE IN MEXICO                 "
        ;;
    pt)
        MSG_LANG_SET="Idioma definido: %s"
        TITLE_ICON_TEST="TESTE DE SUPORTE A ÍCONES"
        MSG_ICON_Q1="Você consegue ver os ícones acima corretamente?"
        MSG_ICON_Q2="(Se você vir caixas vazias ou quebradas, escolha \"n\")"
        ASK_ICON="Ativar suporte a ícones avançados? [s/N]: "
        MSG_ICON_ON="Ícones avançados ATIVADOS."
        MSG_ICON_OFF="Modo padrão selecionado (ícones clássicos)."
        SPINNER_MSG="Instalando componentes necessários..."
        TITLE_SETTINGS="CONFIGURAÇÕES INICIAIS"
        SUB_SETTINGS="Personalize os recursos do painel (Enter para pular)"
        ASK_QUOTA="1. Ativar contador e limite de dados (MB/GB) por conta? [s/N]: "
        MSG_QUOTA_ON="Cota de dados: ATIVADA"
        MSG_QUOTA_OFF="Cota de dados: Desativada (Ilimitado por padrão)"
        ASK_CU="2. Ativar serviço CheckUser API? [S/n]: "
        ASK_CU_PORT="   Porta para CheckUser API [padrão: 5000]: "
        MSG_CU_ON="CheckUser API: ATIVADO na porta %s"
        MSG_CU_OFF="CheckUser API: Desativado"
        ASK_DUAL="3. Ativar DualMode na porta 443 (V2Ray + SSL simultâneo)? [s/N]: "
        MSG_DUAL_CONFIG="Configurando DualMode na porta 443..."
        MSG_DUAL_ON="DualMode 443: ATIVADO (Multiplexador SNI)"
        MSG_DUAL_OFF="DualMode 443: Desativado"
        CARD_SUCCESS="INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
        CARD_ACCESS="Para acessar o painel de controle a qualquer momento:"
        LBL_SVC_MAIN="Serviço Principal"
        VAL_SVC_MAIN="ATIVO (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Porta 80 (Payload HTTP)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Porta 444 (Direto/WS)"
        LBL_SVC_ICONS="Ícones Avançados"
        LBL_SVC_LANG="Idioma"
        FOOTER_LINE="                BY DANAELH4X E FEITO NO MÉXICO                "
        ;;
    id)
        MSG_LANG_SET="Bahasa diatur: %s"
        TITLE_ICON_TEST="UJI DUKUNGAN IKON"
        MSG_ICON_Q1="Apakah Anda dapat melihat ikon di atas dengan benar?"
        MSG_ICON_Q2="(Jika melihat kotak kosong atau simbol rusak, pilih \"n\")"
        ASK_ICON="Aktifkan dukungan ikon lanjutan? [y/N]: "
        MSG_ICON_ON="Ikon lanjutan DIAKTIFKAN."
        MSG_ICON_OFF="Mode standar dipilih (ikon klasik)."
        SPINNER_MSG="Menginstal komponen yang diperlukan..."
        TITLE_SETTINGS="PENGATURAN AWAL"
        SUB_SETTINGS="Sesuaikan fitur panel (Tekan Enter untuk melewati)"
        ASK_QUOTA="1. Aktifkan penghitung kuota data (MB/GB) per akun? [y/N]: "
        MSG_QUOTA_ON="Kuota data: DIAKTIFKAN"
        MSG_QUOTA_OFF="Kuota data: Dinonaktifkan (Tidak terbatas)"
        ASK_CU="2. Aktifkan layanan CheckUser API? [Y/n]: "
        ASK_CU_PORT="   Port untuk CheckUser API [standar: 5000]: "
        MSG_CU_ON="CheckUser API: DIAKTIFKAN pada port %s"
        MSG_CU_OFF="CheckUser API: Dinonaktifkan"
        ASK_DUAL="3. Aktifkan DualMode port 443 (V2Ray + SSL simultan)? [y/N]: "
        MSG_DUAL_CONFIG="Mengonfigurasi DualMode pada port 443..."
        MSG_DUAL_ON="DualMode 443: DIAKTIFKAN (Multiplexer SNI)"
        MSG_DUAL_OFF="DualMode 443: Dinonaktifkan"
        CARD_SUCCESS="INSTALASI BERHASIL DISELESAIKAN!"
        CARD_ACCESS="Untuk masuk ke panel kontrol kapan saja:"
        LBL_SVC_MAIN="Layanan Utama"
        VAL_SVC_MAIN="AKTIF (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Port 80 (Payload HTTP)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Port 444 (Langsung/WS)"
        LBL_SVC_ICONS="Ikon Lanjutan"
        LBL_SVC_LANG="Bahasa"
        FOOTER_LINE="               BY DANAELH4X & DIBUAT DI MEKSIKO               "
        ;;
    fr)
        MSG_LANG_SET="Langue définie : %s"
        TITLE_ICON_TEST="TEST DE SUPPORT D'ICÔNES"
        MSG_ICON_Q1="Pouvez-vous voir les icônes ci-dessus correctement ?"
        MSG_ICON_Q2="(Si vous voyez des boîtes vides ou des symboles cassés, choisissez \"n\")"
        ASK_ICON="Activer le support des icônes avancées ? [o/N]: "
        MSG_ICON_ON="Icônes avancées ACTIVÉES."
        MSG_ICON_OFF="Mode standard sélectionné (icônes classiques)."
        SPINNER_MSG="Installation des composants requis..."
        TITLE_SETTINGS="PARAMÈTRES INITIAUX"
        SUB_SETTINGS="Personnalisez les fonctionnalités du panneau (Entrée pour ignorer)"
        ASK_QUOTA="1. Activer le compteur et limite de données (Mo/Go) par compte ? [o/N]: "
        MSG_QUOTA_ON="Quota de données : ACTIVÉ"
        MSG_QUOTA_OFF="Quota de données : Désactivé (Illimité par défaut)"
        ASK_CU="2. Activer le service CheckUser API ? [O/n]: "
        ASK_CU_PORT="   Port pour CheckUser API [défaut : 5000] : "
        MSG_CU_ON="CheckUser API : ACTIVÉ sur le port %s"
        MSG_CU_OFF="CheckUser API : Désactivé"
        ASK_DUAL="3. Activer DualMode port 443 (V2Ray + SSL simultané) ? [o/N]: "
        MSG_DUAL_CONFIG="Configuration de DualMode port 443..."
        MSG_DUAL_ON="DualMode 443 : ACTIVÉ (Multiplexeur SNI)"
        MSG_DUAL_OFF="DualMode 443 : Désactivé"
        CARD_SUCCESS="INSTALLATION TERMINÉE AVEC SUCCÈS !"
        CARD_ACCESS="Pour accéder au panneau de configuration à tout moment :"
        LBL_SVC_MAIN="Service Principal"
        VAL_SVC_MAIN="ACTIF (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Port 80 (Payload HTTP)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Port 444 (Direct/WS)"
        LBL_SVC_ICONS="Icônes Avancées"
        LBL_SVC_LANG="Langue"
        FOOTER_LINE="             BY DANAELH4X ET FABRIQUÉ AU MEXIQUE              "
        ;;
    ru)
        MSG_LANG_SET="Язык установлен: %s"
        TITLE_ICON_TEST="ПРОВЕРКА ОТОБРАЖЕНИЯ ЗНАЧКОВ"
        MSG_ICON_Q1="Вы видите значки сверху корректно?"
        MSG_ICON_Q2="(Если вы видите пустые квадраты или дефекты, выберите \"n\")"
        ASK_ICON="Включить расширенные значки? [y/N]: "
        MSG_ICON_ON="Расширенные значки ВКЛЮЧЕНЫ."
        MSG_ICON_OFF="Выбран стандартный режим (классические значки)."
        SPINNER_MSG="Установка необходимых компонентов..."
        TITLE_SETTINGS="НАЧАЛЬНЫЕ НАСТРОЙКИ"
        SUB_SETTINGS="Настройте функции панели (Enter для пропуска)"
        ASK_QUOTA="1. Включить подсчет и лимит трафика (МБ/ГБ) на аккаунт? [y/N]: "
        MSG_QUOTA_ON="Квота данных: ВКЛЮЧЕНА"
        MSG_QUOTA_OFF="Квота данных: Отключена (Безлимит по умолчанию)"
        ASK_CU="2. Включить службу CheckUser API? [Y/n]: "
        ASK_CU_PORT="   Порт для CheckUser API [по умолчанию: 5000]: "
        MSG_CU_ON="CheckUser API: ВКЛЮЧЕНО на порту %s"
        MSG_CU_OFF="CheckUser API: Отключено"
        ASK_DUAL="3. Включить DualMode на порту 443 (V2Ray + SSL одновременно)? [y/N]: "
        MSG_DUAL_CONFIG="Настройка DualMode на порту 443..."
        MSG_DUAL_ON="DualMode 443: ВКЛЮЧЕНО (SNI Мультиплексор)"
        MSG_DUAL_OFF="DualMode 443: Отключено"
        CARD_SUCCESS="УСТАНОВКА УСПЕШНО ЗАВЕРШЕНА!"
        CARD_ACCESS="Для входа в панель управления в любое время:"
        LBL_SVC_MAIN="Основная Служба"
        VAL_SVC_MAIN="АКТИВЕН (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Порт 80 (HTTP нагрузка)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Порт 444 (Прямой/WS)"
        LBL_SVC_ICONS="Расширенные Значки"
        LBL_SVC_LANG="Язык"
        FOOTER_LINE="               BY DANAELH4X И СДЕЛАНО В МЕКСИКЕ               "
        ;;
    zh)
        MSG_LANG_SET="语言设置为: %s"
        TITLE_ICON_TEST="图标显示测试"
        MSG_ICON_Q1="你能正常看到上方的图标吗？"
        MSG_ICON_Q2="(如果看到空白方块或乱码符号，请选择 \"n\")"
        ASK_ICON="启用高级图标支持？[y/N]: "
        MSG_ICON_ON="高级图标支持已启用。"
        MSG_ICON_OFF="已选择标准模式（经典图标）。"
        SPINNER_MSG="正在安装所需组件..."
        TITLE_SETTINGS="初始设置"
        SUB_SETTINGS="自定义面板功能（按回车跳过）"
        ASK_QUOTA="1. 启用每账户数据配额与限制（MB/GB）？[y/N]: "
        MSG_QUOTA_ON="数据配额：已启用"
        MSG_QUOTA_OFF="数据配额：已禁用（默认无限制）"
        ASK_CU="2. 启用 CheckUser API 服务？[Y/n]: "
        ASK_CU_PORT="   CheckUser API 端口 [默认: 5000]: "
        MSG_CU_ON="CheckUser API：已在端口 %s 启用"
        MSG_CU_OFF="CheckUser API：已禁用"
        ASK_DUAL="3. 启用 443 端口 DualMode (V2Ray + SSL 同时运行)？[y/N]: "
        MSG_DUAL_CONFIG="正在配置 443 端口 DualMode..."
        MSG_DUAL_ON="DualMode 443：已启用 (SNI 多路复用)"
        MSG_DUAL_OFF="DualMode 443：已禁用"
        CARD_SUCCESS="安装成功完成！"
        CARD_ACCESS="随时进入控制面板命令："
        LBL_SVC_MAIN="主要服务"
        VAL_SVC_MAIN="运行中 (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="端口 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="端口 444 (Direct/WS)"
        LBL_SVC_ICONS="高级图标"
        LBL_SVC_LANG="语言"
        FOOTER_LINE="                   BY DANAELH4X 墨西哥制造                    "
        ;;
    ja)
        MSG_LANG_SET="言語が設定されました: %s"
        TITLE_ICON_TEST="アイコン表示テスト"
        MSG_ICON_Q1="上のアイコンが正しく表示されていますか？"
        MSG_ICON_Q2="(四角い空枠や文字化けが見える場合は \"n\" を選択)"
        ASK_ICON="高度なアイコンを有効にしますか？ [y/N]: "
        MSG_ICON_ON="高度なアイコンが有効になりました。"
        MSG_ICON_OFF="標準モードが選択されました（クラシック表示）。"
        SPINNER_MSG="必要なコンポーネントをインストール中..."
        TITLE_SETTINGS="初期設定"
        SUB_SETTINGS="パネル機能のカスタマイズ（Enterでスキップ）"
        ASK_QUOTA="1. アカウントごとのデータクォータ制限(MB/GB)を有効化？[y/N]: "
        MSG_QUOTA_ON="データクォータ: 有効"
        MSG_QUOTA_OFF="データクォータ: 無効 (デフォルト無制限)"
        ASK_CU="2. CheckUser API サービスを有効化しますか？ [Y/n]: "
        ASK_CU_PORT="   CheckUser API のポート [デフォルト: 5000]: "
        MSG_CU_ON="CheckUser API: ポート %s で有効化"
        MSG_CU_OFF="CheckUser API: 無効"
        ASK_DUAL="3. 443番ポートのDualMode (V2Ray + SSL 同時運用)を有効化？[y/N]: "
        MSG_DUAL_CONFIG="443番ポート DualMode を設定中..."
        MSG_DUAL_ON="DualMode 443: 有効 (SNI 多重化)"
        MSG_DUAL_OFF="DualMode 443: 無効"
        CARD_SUCCESS="インストールが正常に完了しました！"
        CARD_ACCESS="いつでもコントロールパネルを開くコマンド:"
        LBL_SVC_MAIN="メインサービス"
        VAL_SVC_MAIN="アクティブ (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="ポート 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="ポート 444 (Direct/WS)"
        LBL_SVC_ICONS="高度なアイコン"
        LBL_SVC_LANG="言語"
        FOOTER_LINE="                   BY DANAELH4X メキシコ製                    "
        ;;
    ar)
        MSG_LANG_SET="تم تعيين اللغة: %s"
        TITLE_ICON_TEST="اختبار دعم الأيقونات"
        MSG_ICON_Q1="هل يمكنك رؤية الأيقونات أعلاه بشكل صحيح؟"
        MSG_ICON_Q2="(إذا رأيت مربعات فارغة أو رموزاً معطوبة، اختر \"n\")"
        ASK_ICON="تفعيل دعم الأيقونات المتقدمة؟ [y/N]: "
        MSG_ICON_ON="تم تفعيل الأيقونات المتقدمة."
        MSG_ICON_OFF="تم اختيار الوضع القياسي (أيقونات كلاسيكية)."
        SPINNER_MSG="جاري تثبيت المكونات المطلوبة..."
        TITLE_SETTINGS="الإعدادات الأولية"
        SUB_SETTINGS="تخصيص ميزات اللوحة (اضغط Enter للتخطي)"
        ASK_QUOTA="1. تفعيل حصة البيانات (MB/GB) لكل حساب؟ [y/N]: "
        MSG_QUOTA_ON="حصة البيانات: مفعلة"
        MSG_QUOTA_OFF="حصة البيانات: معطلة (غير محدود)"
        ASK_CU="2. تفعيل خدمة CheckUser API؟ [Y/n]: "
        ASK_CU_PORT="   منفذ CheckUser API [الافتراضي: 5000]: "
        MSG_CU_ON="CheckUser API: مفعل على المنفذ %s"
        MSG_CU_OFF="CheckUser API: معطل"
        ASK_DUAL="3. تفعيل DualMode على المنفذ 443 (V2Ray + SSL متزامن)؟ [y/N]: "
        MSG_DUAL_CONFIG="جاري تكوين DualMode على المنفذ 443..."
        MSG_DUAL_ON="DualMode 443: مفعل (SNI Multiplexer)"
        MSG_DUAL_OFF="DualMode 443: معطل"
        CARD_SUCCESS="تم اكتمال التثبيت بنجاح!"
        CARD_ACCESS="للدخول إلى لوحة التحكم في أي وقت:"
        LBL_SVC_MAIN="الخدمة الرئيسية"
        VAL_SVC_MAIN="نشط (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="المنفذ 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="المنفذ 444 (Direct/WS)"
        LBL_SVC_ICONS="أيقونات متقدمة"
        LBL_SVC_LANG="اللغة"
        FOOTER_LINE="                 BY DANAELH4X وصنع في المكسيك                 "
        ;;
    de)
        MSG_LANG_SET="Sprache eingestellt: %s"
        TITLE_ICON_TEST="SYMBOL-SUPPORT-TEST"
        MSG_ICON_Q1="Können Sie die oberen Symbole korrekt sehen?"
        MSG_ICON_Q2="(Wenn Sie leere Kästchen sehen, wählen Sie \"n\")"
        ASK_ICON="Erweiterte Symbole aktivieren? [y/N]: "
        MSG_ICON_ON="Erweiterte Symbole AKTIVIERT."
        MSG_ICON_OFF="Standardmodus ausgewählt (klassische Symbole)."
        SPINNER_MSG="Erforderliche Komponenten werden installiert..."
        TITLE_SETTINGS="ERSTE EINSTELLUNGEN"
        SUB_SETTINGS="Panel-Funktionen anpassen (Enter zum Überspringen)"
        ASK_QUOTA="1. Datenkontingent-Zähler (MB/GB) pro Konto aktivieren? [y/N]: "
        MSG_QUOTA_ON="Datenkontingent: AKTIVIERT"
        MSG_QUOTA_OFF="Datenkontingent: Deaktiviert"
        ASK_CU="2. CheckUser API-Dienst aktivieren? [Y/n]: "
        ASK_CU_PORT="   Port für CheckUser API [Standard: 5000]: "
        MSG_CU_ON="CheckUser API: AKTIVIERT auf Port %s"
        MSG_CU_OFF="CheckUser API: Deaktiviert"
        ASK_DUAL="3. DualMode Port 443 (V2Ray + SSL gleichzeitig) aktivieren? [y/N]: "
        MSG_DUAL_CONFIG="DualMode auf Port 443 wird konfiguriert..."
        MSG_DUAL_ON="DualMode 443: AKTIVIERT (SNI Multiplexer)"
        MSG_DUAL_OFF="DualMode 443: Deaktiviert"
        CARD_SUCCESS="INSTALLATION ERFOLGREICH ABGESCHLOSSEN!"
        CARD_ACCESS="Um das Kontrollpanel jederzeit zu öffnen:"
        LBL_SVC_MAIN="Hauptdienst"
        VAL_SVC_MAIN="AKTIV (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Port 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Port 444 (Direct/WS)"
        LBL_SVC_ICONS="Erweiterte Symbole"
        LBL_SVC_LANG="Sprache"
        FOOTER_LINE="            BY DANAELH4X UND HERGESTELLT IN MEXIKO            "
        ;;
    it)
        MSG_LANG_SET="Lingua impostata: %s"
        TITLE_ICON_TEST="TEST DI SUPPORTO ICONE"
        MSG_ICON_Q1="Riesci a vedere correttamente le icone sopra?"
        MSG_ICON_Q2="(Se vedi caselle vuote o simboli spezzati, scegli \"n\")"
        ASK_ICON="Abilitare supporto icone avanzate? [s/N]: "
        MSG_ICON_ON="Icone avanzate ABILITATE."
        MSG_ICON_OFF="Modalità standard selezionata (icone classiche)."
        SPINNER_MSG="Installazione componenti necessari in corso..."
        TITLE_SETTINGS="IMPOSTAZIONI INIZIALI"
        SUB_SETTINGS="Personalizza funzionalità pannello (Invio per saltare)"
        ASK_QUOTA="1. Abilitare contatore e limite dati (MB/GB) per account? [s/N]: "
        MSG_QUOTA_ON="Quota dati: ABILITATA"
        MSG_QUOTA_OFF="Quota dati: Disabilitata (Illimitata per impostazione predefinita)"
        ASK_CU="2. Abilitare servizio CheckUser API? [S/n]: "
        ASK_CU_PORT="   Porta per CheckUser API [predefinita: 5000]: "
        MSG_CU_ON="CheckUser API: ABILITATO sulla porta %s"
        MSG_CU_OFF="CheckUser API: Disabilitato"
        ASK_DUAL="3. Abilitare DualMode porta 443 (V2Ray + SSL simultaneo)? [s/N]: "
        MSG_DUAL_CONFIG="Configurazione DualMode porta 443 in corso..."
        MSG_DUAL_ON="DualMode 443: ABILITATO (SNI Multiplexer)"
        MSG_DUAL_OFF="DualMode 443: Disabilitato"
        CARD_SUCCESS="INSTALLAZIONE COMPLETATA CON SUCCESSO!"
        CARD_ACCESS="Per accedere al pannello di controllo in qualsiasi momento:"
        LBL_SVC_MAIN="Servizio Principale"
        VAL_SVC_MAIN="ATTIVO (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Porta 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Porta 444 (Diretto/WS)"
        LBL_SVC_ICONS="Icone Avanzate"
        LBL_SVC_LANG="Lingua"
        FOOTER_LINE="               BY DANAELH4X E FATTO IN MESSICO                "
        ;;
    tr)
        MSG_LANG_SET="Dil ayarlandı: %s"
        TITLE_ICON_TEST="SİMGE DESTEK TESTİ"
        MSG_ICON_Q1="Yukarıdaki simgeleri doğru şekilde görebiliyor musunuz?"
        MSG_ICON_Q2="(Boş kutular veya bozuk semboller görüyorsanız \"n\" seçin)"
        ASK_ICON="Gelişmiş simge desteği etkinleştirilsin mi? [e/H]: "
        MSG_ICON_ON="Gelişmiş simgeler ETKİNLEŞTİRİLDİ."
        MSG_ICON_OFF="Standart mod seçildi (klasik simgeler)."
        SPINNER_MSG="Gerekli bileşenler yükleniyor..."
        TITLE_SETTINGS="BAŞLANGIÇ AYARLARI"
        SUB_SETTINGS="Panel özelliklerini özelleştirin (Atlamak için Enter)"
        ASK_QUOTA="1. Hesap başına veri kotası sayacı ve limiti (MB/GB) etkinleştirilsin mi? [e/H]: "
        MSG_QUOTA_ON="Veri kotası: ETKİNLEŞTİRİLDİ"
        MSG_QUOTA_OFF="Veri kotası: Devre dışı (Sınırsız)"
        ASK_CU="2. CheckUser API servisi etkinleştirilsin mi? [E/h]: "
        ASK_CU_PORT="   CheckUser API için bağlantı noktası [varsayılan: 5000]: "
        MSG_CU_ON="CheckUser API: %s portunda ETKİN"
        MSG_CU_OFF="CheckUser API: Devre dışı"
        ASK_DUAL="3. 443 portunda DualMode (V2Ray + SSL eşzamanlı) etkinleştirilsin mi? [e/H]: "
        MSG_DUAL_CONFIG="443 portunda DualMode yapılandırılıyor..."
        MSG_DUAL_ON="DualMode 443: ETKİN (SNI Çoğullayıcı)"
        MSG_DUAL_OFF="DualMode 443: Devre dışı"
        CARD_SUCCESS="KURULUM BAŞARIYLA TAMAMLANDI!"
        CARD_ACCESS="Kontrol paneline istediğiniz zaman erişmek için:"
        LBL_SVC_MAIN="Ana Servis"
        VAL_SVC_MAIN="AKTİF (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Port 80 (HTTP Yükü)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Port 444 (Doğrudan/WS)"
        LBL_SVC_ICONS="Gelişmiş Simgeler"
        LBL_SVC_LANG="Dil"
        FOOTER_LINE="            BY DANAELH4X VE MEKSİKA'DA YAPILMIŞTIR            "
        ;;
    vi)
        MSG_LANG_SET="Ngôn ngữ đã đặt: %s"
        TITLE_ICON_TEST="KIỂM TRA HỖ TRỢ BIỂU TƯỢNG"
        MSG_ICON_Q1="Bạn có nhìn thấy các biểu tượng ở trên đúng cách không?"
        MSG_ICON_Q2="(Nếu bạn thấy các ô trống hoặc biểu tượng lỗi, hãy chọn \"n\")"
        ASK_ICON="Bật hỗ trợ biểu tượng nâng cao? [c/K]: "
        MSG_ICON_ON="Biểu tượng nâng cao ĐÃ BẬT."
        MSG_ICON_OFF="Đã chọn chế độ tiêu chuẩn (biểu tượng cổ điển)."
        SPINNER_MSG="Đang cài đặt các thành phần cần thiết..."
        TITLE_SETTINGS="CÀI ĐẶT BAN ĐẦU"
        SUB_SETTINGS="Tùy chỉnh các tính năng của bảng điều khiển (Nhấn Enter để bỏ qua)"
        ASK_QUOTA="1. Bật bộ đếm & giới hạn dung lượng (MB/GB) theo tài khoản? [c/K]: "
        MSG_QUOTA_ON="Hạn mức dữ liệu: ĐÃ BẬT"
        MSG_QUOTA_OFF="Hạn mức dữ liệu: Đã tắt (Không giới hạn mặc định)"
        ASK_CU="2. Bật dịch vụ CheckUser API? [C/k]: "
        ASK_CU_PORT="   Cổng cho CheckUser API [mặc định: 5000]: "
        MSG_CU_ON="CheckUser API: ĐÃ BẬT trên cổng %s"
        MSG_CU_OFF="CheckUser API: Đã tắt"
        ASK_DUAL="3. Bật DualMode cổng 443 (V2Ray + SSL đồng thời)? [c/K]: "
        MSG_DUAL_CONFIG="Đang cấu hình DualMode trên cổng 443..."
        MSG_DUAL_ON="DualMode 443: ĐÃ BẬT (Bộ ghép kênh SNI)"
        MSG_DUAL_OFF="DualMode 443: Đã tắt"
        CARD_SUCCESS="CÀI ĐẶT THÀNH CÔNG!"
        CARD_ACCESS="Để truy cập bảng điều khiển bất cứ lúc nào:"
        LBL_SVC_MAIN="Dịch vụ chính"
        VAL_SVC_MAIN="HOẠT ĐỘNG (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Cổng 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Cổng 444 (Trực tiếp/WS)"
        LBL_SVC_ICONS="Biểu tượng nâng cao"
        LBL_SVC_LANG="Ngôn ngữ"
        FOOTER_LINE="             BY DANAELH4X VÀ ĐƯỢC LÀM TẠI MEXICO              "
        ;;
    ko)
        MSG_LANG_SET="언어 설정됨: %s"
        TITLE_ICON_TEST="아이콘 지원 테스트"
        MSG_ICON_Q1="위의 아이콘이 올바르게 보입니까?"
        MSG_ICON_Q2="(빈 상자나 깨진 기호가 보이면 \"n\" 선택)"
        ASK_ICON="고급 아이콘 지원을 활성화하시겠습니까? [y/N]: "
        MSG_ICON_ON="고급 아이콘 활성화됨."
        MSG_ICON_OFF="표준 모드 선택됨 (클래식 아이콘)."
        SPINNER_MSG="필요한 구성 요소를 설치하는 중..."
        TITLE_SETTINGS="초기 설정"
        SUB_SETTINGS="패널 기능 사용자 지정 (건너뛰려면 Enter 키 누름)"
        ASK_QUOTA="1. 계정별 데이터 할당량 카운터 및 제한(MB/GB) 활성화? [y/N]: "
        MSG_QUOTA_ON="데이터 할당량: 활성화됨"
        MSG_QUOTA_OFF="데이터 할당량: 비활성화됨 (기본 무제한)"
        ASK_CU="2. CheckUser API 서비스를 활성화하시겠습니까? [Y/n]: "
        ASK_CU_PORT="   CheckUser API 포트 [기본값: 5000]: "
        MSG_CU_ON="CheckUser API: 포트 %s 에서 활성화됨"
        MSG_CU_OFF="CheckUser API: 비활성화됨"
        ASK_DUAL="3. 443 포트 DualMode (V2Ray + SSL 동시 운영) 활성화? [y/N]: "
        MSG_DUAL_CONFIG="443 포트 DualMode 구성 중..."
        MSG_DUAL_ON="DualMode 443: 활성화됨 (SNI 다중화)"
        MSG_DUAL_OFF="DualMode 443: 비활성화됨"
        CARD_SUCCESS="설치가 성공적으로 완료되었습니다!"
        CARD_ACCESS="언제든지 제어판에 접속하는 명령어:"
        LBL_SVC_MAIN="메인 서비스"
        VAL_SVC_MAIN="활성 (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="포트 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="포트 444 (Direct/WS)"
        LBL_SVC_ICONS="고급 아이콘"
        LBL_SVC_LANG="언어"
        FOOTER_LINE="                   BY DANAELH4X 및 멕시코산                   "
        ;;
    hi)
        MSG_LANG_SET="भाषा सेट की गई: %s"
        TITLE_ICON_TEST="आइकन समर्थन परीक्षण"
        MSG_ICON_Q1="क्या आप ऊपर दिए गए आइकन सही ढंग से देख सकते हैं?"
        MSG_ICON_Q2="(यदि खाली डिब्बे या टूटे हुए प्रतीक दिखें, तो \"n\" चुनें)"
        ASK_ICON="उन्नत आइकन समर्थन सक्षम करें? [y/N]: "
        MSG_ICON_ON="उन्नत आइकन सक्षम किए गए।"
        MSG_ICON_OFF="मानक मोड चुना गया (क्लासिक आइकन)।"
        SPINNER_MSG="आवश्यक घटक स्थापित किए जा रहे हैं..."
        TITLE_SETTINGS="प्रारंभिक सेटिंग्स"
        SUB_SETTINGS="पैनल सुविधाओं को अनुकूलित करें (छोड़ने के लिए Enter दबाएं)"
        ASK_QUOTA="1. प्रति खाता डेटा कोटा काउंटर और सीमा (MB/GB) सक्षम करें? [y/N]: "
        MSG_QUOTA_ON="डेटा कोटा: सक्षम"
        MSG_QUOTA_OFF="डेटा कोटा: अक्षम (डिफ़ॉल्ट रूप से असीमित)"
        ASK_CU="2. CheckUser API सेवा सक्षम करें? [Y/n]: "
        ASK_CU_PORT="   CheckUser API के लिए पोर्ट [डिफ़ॉल्ट: 5000]: "
        MSG_CU_ON="CheckUser API: पोर्ट %s पर सक्षम"
        MSG_CU_OFF="CheckUser API: अक्षम"
        ASK_DUAL="3. पोर्ट 443 पर DualMode (V2Ray + SSL एक साथ) सक्षम करें? [y/N]: "
        MSG_DUAL_CONFIG="पोर्ट 443 पर DualMode कॉन्फ़िगर किया जा रहा है..."
        MSG_DUAL_ON="DualMode 443: सक्षम (SNI मल्टीप्लेक्सर)"
        MSG_DUAL_OFF="DualMode 443: अक्षम"
        CARD_SUCCESS="स्थापना सफलतापूर्वक पूर्ण हुई!"
        CARD_ACCESS="किसी भी समय नियंत्रण कक्ष खोलने के लिए:"
        LBL_SVC_MAIN="मुख्य सेवा"
        VAL_SVC_MAIN="सक्रिय (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="पोर्ट 80 (HTTP पेलोड)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="पोर्ट 444 (प्रत्यक्ष/WS)"
        LBL_SVC_ICONS="उन्नत आइकन"
        LBL_SVC_LANG="भाषा"
        FOOTER_LINE="              BY DANAELH4X और मेक्सिको में निर्मित              "
        ;;
    bn)
        MSG_LANG_SET="ভাষা সেট করা হয়েছে: %s"
        TITLE_ICON_TEST="আইকন সমর্থন পরীক্ষা"
        MSG_ICON_Q1="আপনি কি উপরের আইকনগুলো সঠিকভাবে দেখতে পাচ্ছেন?"
        MSG_ICON_Q2="(যদি ফাঁকা বাক্স বা ত্রুটিযুক্ত প্রতীক দেখেন, তবে \"n\" বেছে নিন)"
        ASK_ICON="উন্নত আইকন সমর্থন সক্রিয় করবেন? [y/N]: "
        MSG_ICON_ON="উন্নত আইকন সক্রিয় করা হয়েছে।"
        MSG_ICON_OFF="সাধারণ মোড নির্বাচিত (ক্লাসিক আইকন)।"
        SPINNER_MSG="প্রয়োজনীয় উপাদান ইনস্টল করা হচ্ছে..."
        TITLE_SETTINGS="প্রাথমিক সেটিংস"
        SUB_SETTINGS="প্যানেল বৈশিষ্ট্য কাস্টমাইজ করুন (এড়িয়ে যেতে Enter চাপুন)"
        ASK_QUOTA="1. অ্যাকাউন্ট প্রতি ডেটা কোটা কাউন্টার এবং সীমা (MB/GB) সক্রিয় করবেন? [y/N]: "
        MSG_QUOTA_ON="ডেটা কোটা: সক্রিয়"
        MSG_QUOTA_OFF="ডেটা কোটা: নিষ্ক্রিয় (ডিফল্ট সীমাহীন)"
        ASK_CU="2. CheckUser API পরিষেবা সক্রিয় করবেন? [Y/n]: "
        ASK_CU_PORT="   CheckUser API এর জন্য পোর্ট [ডিফল্ট: 5000]: "
        MSG_CU_ON="CheckUser API: পোর্ট %s এ সক্রিয়"
        MSG_CU_OFF="CheckUser API: নিষ্ক্রিয়"
        ASK_DUAL="3. 443 পোর্টে DualMode (V2Ray + SSL একসাথে) সক্রিয় করবেন? [y/N]: "
        MSG_DUAL_CONFIG="443 পোর্টে DualMode কনফিগার করা হচ্ছে..."
        MSG_DUAL_ON="DualMode 443: সক্রিয় (SNI মাল্টিপ্লেক্সার)"
        MSG_DUAL_OFF="DualMode 443: নিষ্ক্রিয়"
        CARD_SUCCESS="ইনস্টলেশন সফলভাবে সম্পন্ন হয়েছে!"
        CARD_ACCESS="যেকোনো সময় নিয়ন্ত্রণ প্যানেলে প্রবেশের জন্য:"
        LBL_SVC_MAIN="প্রধান পরিষেবা"
        VAL_SVC_MAIN="সক্রিয় (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="পোর্ট 80 (HTTP পেলোড)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="পোর্ট 444 (সরাসরি/WS)"
        LBL_SVC_ICONS="উন্নত আইকন"
        LBL_SVC_LANG="ভাষা"
        FOOTER_LINE="               BY DANAELH4X এবং মেক্সিকোতে তৈরি                "
        ;;
    ur)
        MSG_LANG_SET="زبان متعین ہو گئی: %s"
        TITLE_ICON_TEST="آئیکن سپورٹ ٹیسٹ"
        MSG_ICON_Q1="کیا آپ اوپر دیے گئے آئیکنز کو درست طور پر دیکھ سکتے ہیں؟"
        MSG_ICON_Q2="(اگر آپ خالی خانے یا خراب علامتیں دیکھیں تو \"n\" منتخب کریں)"
        ASK_ICON="اعلی درجے کے آئیکنز فعال کریں؟ [y/N]: "
        MSG_ICON_ON="اعلی درجے کے آئیکنز فعال ہو گئے۔"
        MSG_ICON_OFF="معیاری موڈ منتخب کیا گیا (کلاسک آئیکنز)۔"
        SPINNER_MSG="ضروری اجزاء انسٹال کیے جا رہے ہیں..."
        TITLE_SETTINGS="ابتدائی ترتیبات"
        SUB_SETTINGS="پینل کی خصوصیات ترتیب دیں (چھوڑنے کے لیے Enter دبائیں)"
        ASK_QUOTA="1. فی اکاؤنٹ ڈیٹا کوٹہ کاؤنٹر اور حد (MB/GB) فعال کریں؟ [y/N]: "
        MSG_QUOTA_ON="ڈیٹا کوٹہ: فعال"
        MSG_QUOTA_OFF="ڈیٹا کوٹہ: غیر فعال (لامحدود)"
        ASK_CU="2. CheckUser API سروس فعال کریں؟ [Y/n]: "
        ASK_CU_PORT="   CheckUser API کے لیے پورٹ [ڈیفالٹ: 5000]: "
        MSG_CU_ON="CheckUser API: پورٹ %s پر فعال"
        MSG_CU_OFF="CheckUser API: غیر فعال"
        ASK_DUAL="3. پورٹ 443 پر DualMode (V2Ray + SSL بیک وقت) فعال کریں؟ [y/N]: "
        MSG_DUAL_CONFIG="پورٹ 443 پر DualMode کنفیگر کیا جا رہا ہے..."
        MSG_DUAL_ON="DualMode 443: فعال (SNI ملٹی پلیکسر)"
        MSG_DUAL_OFF="DualMode 443: غیر فعال"
        CARD_SUCCESS="انسٹالیشن کامیابی سے مکمل ہو گئی!"
        CARD_ACCESS="کسی بھی وقت کنٹرول پینل تک رسائی کے لیے:"
        LBL_SVC_MAIN="بنیادی سروس"
        VAL_SVC_MAIN="فعال (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="پورٹ 80 (HTTP پے لوڈ)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="پورٹ 444 (براہ راست/WS)"
        LBL_SVC_ICONS="اعلی آئیکنز"
        LBL_SVC_LANG="زبان"
        FOOTER_LINE="            BY DANAELH4X اور میکسیکو میں بنایا گیا            "
        ;;
    fa)
        MSG_LANG_SET="زبان تنظیم شد: %s"
        TITLE_ICON_TEST="آزمایش پشتیبانی از آیکون‌ها"
        MSG_ICON_Q1="آیا آیکون‌های بالا را به درستی مشاهده می‌کنید؟"
        MSG_ICON_Q2="(اگر کادرهای خالی یا نمادهای ناخوانا می‌بینید، \"n\" را انتخاب کنید)"
        ASK_ICON="فعال‌سازی آیکون‌های پیشرفته؟ [y/N]: "
        MSG_ICON_ON="آیکون‌های پیشرفته فعال شدند."
        MSG_ICON_OFF="حالت استاندارد انتخاب شد (آیکون‌های کلاسیک)."
        SPINNER_MSG="در حال نصب مؤلفه‌های مورد نیاز..."
        TITLE_SETTINGS="تنظیمات اولیه"
        SUB_SETTINGS="سفارشی‌سازی ویژگی‌های پنل (برای رد شدن Enter بزنید)"
        ASK_QUOTA="1. فعال‌سازی محدودیت و شمارنده حجم داده (MB/GB) برای هر کاربر؟ [y/N]: "
        MSG_QUOTA_ON="سهمیه داده: فعال"
        MSG_QUOTA_OFF="سهمیه داده: غیرفعال (نامحدود پیش‌فرض)"
        ASK_CU="2. فعال‌سازی سرویس CheckUser API؟ [Y/n]: "
        ASK_CU_PORT="   پورت سرویس CheckUser API [پیش‌فرض: 5000]: "
        MSG_CU_ON="CheckUser API: روی پورت %s فعال شد"
        MSG_CU_OFF="CheckUser API: غیرفعال"
        ASK_DUAL="3. فعال‌سازی DualMode روی پورت 443 (همزمان V2Ray + SSL)؟ [y/N]: "
        MSG_DUAL_CONFIG="در حال پیکربندی DualMode روی پورت 443..."
        MSG_DUAL_ON="DualMode 443: فعال (مالتی‌پلکسر SNI)"
        MSG_DUAL_OFF="DualMode 443: غیرفعال"
        CARD_SUCCESS="نصب با موفقیت انجام شد!"
        CARD_ACCESS="برای ورود به پنل مدیریت در هر زمان:"
        LBL_SVC_MAIN="سرویس اصلی"
        VAL_SVC_MAIN="فعال (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="پورت 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="پورت 444 (مستقیم/WS)"
        LBL_SVC_ICONS="آیکون‌های پیشرفته"
        LBL_SVC_LANG="زبان"
        FOOTER_LINE="                  BY DANAELH4X و ساخت مکزیک                   "
        ;;
    pl)
        MSG_LANG_SET="Ustawiono język: %s"
        TITLE_ICON_TEST="TEST OBSŁUGI IKON"
        MSG_ICON_Q1="Czy widzisz powyższe ikony poprawnie?"
        MSG_ICON_Q2="(Jeśli widzisz puste kwadraty lub uszkodzone symbole, wybierz \"n\")"
        ASK_ICON="Włączyć zaawansowane ikony? [t/N]: "
        MSG_ICON_ON="Zaawansowane ikony WŁĄCZONE."
        MSG_ICON_OFF="Wybrano tryb standardowy (klasyczne ikony)."
        SPINNER_MSG="Instalowanie wymaganych komponentów..."
        TITLE_SETTINGS="USTAWIENIA POCZĄTKOWE"
        SUB_SETTINGS="Dostosuj funkcje panelu (Enter, aby pominąć)"
        ASK_QUOTA="1. Włączyć licznik i limit danych (MB/GB) na konto? [t/N]: "
        MSG_QUOTA_ON="Limit danych: WŁĄCZONY"
        MSG_QUOTA_OFF="Limit danych: Wyłączony (Domyślnie bez limitu)"
        ASK_CU="2. Włączyć usługę CheckUser API? [T/n]: "
        ASK_CU_PORT="   Port dla CheckUser API [domyślny: 5000]: "
        MSG_CU_ON="CheckUser API: WŁĄCZONY na porcie %s"
        MSG_CU_OFF="CheckUser API: Wyłączony"
        ASK_DUAL="3. Włączyć DualMode na porcie 443 (jednoczesny V2Ray + SSL)? [t/N]: "
        MSG_DUAL_CONFIG="Konfigurowanie DualMode na porcie 443..."
        MSG_DUAL_ON="DualMode 443: WŁĄCZONY (SNI Multiplexer)"
        MSG_DUAL_OFF="DualMode 443: Wyłączony"
        CARD_SUCCESS="INSTALACJA ZAKOŃCZONA SUKCESEM!"
        CARD_ACCESS="Aby wejść do panelu sterowania w dowolnym momencie:"
        LBL_SVC_MAIN="Główna usługa"
        VAL_SVC_MAIN="AKTYWNY (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Port 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Port 444 (Bezpośredni/WS)"
        LBL_SVC_ICONS="Zaawansowane ikony"
        LBL_SVC_LANG="Język"
        FOOTER_LINE="            BY DANAELH4X I WYPRODUKOWANO W MEKSYKU            "
        ;;
    nl)
        MSG_LANG_SET="Taal ingesteld: %s"
        TITLE_ICON_TEST="PICTOGRAMMEN TEST"
        MSG_ICON_Q1="Kunt u de bovenstaande pictogrammen correct zien?"
        MSG_ICON_Q2="(Als u lege vakjes of foutieve tekens ziet, kies \"n\")"
        ASK_ICON="Geavanceerde pictogrammen inschakelen? [j/N]: "
        MSG_ICON_ON="Geavanceerde pictogrammen INGESCHAKELD."
        MSG_ICON_OFF="Standaardmodus geselecteerd (klassieke pictogrammen)."
        SPINNER_MSG="Vereiste componenten installeren..."
        TITLE_SETTINGS="INITIËLE INSTELLINGEN"
        SUB_SETTINGS="Paneelfuncties aanpassen (Druk op Enter om over te slaan)"
        ASK_QUOTA="1. Datalimiet-teller (MB/GB) per account inschakelen? [j/N]: "
        MSG_QUOTA_ON="Datalimiet: INGESCHAKELD"
        MSG_QUOTA_OFF="Datalimiet: Uitgeschakeld (Onbeperkt)"
        ASK_CU="2. CheckUser API-service inschakelen? [J/n]: "
        ASK_CU_PORT="   Poort voor CheckUser API [standaard: 5000]: "
        MSG_CU_ON="CheckUser API: INGESCHAKELD op poort %s"
        MSG_CU_OFF="CheckUser API: Uitgeschakeld"
        ASK_DUAL="3. DualMode poort 443 (gelijktijdig V2Ray + SSL) inschakelen? [j/N]: "
        MSG_DUAL_CONFIG="DualMode op poort 443 configureren..."
        MSG_DUAL_ON="DualMode 443: INGESCHAKELD (SNI Multiplexer)"
        MSG_DUAL_OFF="DualMode 443: Uitgeschakeld"
        CARD_SUCCESS="INSTALLATIE SUCCESVOL VOLTOOID!"
        CARD_ACCESS="Om op elk moment toegang te krijgen tot het bedieningspaneel:"
        LBL_SVC_MAIN="Hoofdservice"
        VAL_SVC_MAIN="ACTIEF (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Poort 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Poort 444 (Direct/WS)"
        LBL_SVC_ICONS="Geavanceerde pictogrammen"
        LBL_SVC_LANG="Taal"
        FOOTER_LINE="              BY DANAELH4X EN GEMAAKT IN MEXICO               "
        ;;
    uk)
        MSG_LANG_SET="Мову встановлено: %s"
        TITLE_ICON_TEST="ТЕСТ ВІДОБРАЖЕННЯ ЗНАЧКІВ"
        MSG_ICON_Q1="Чи правильно відображаються значки зверху?"
        MSG_ICON_Q2="(Якщо ви бачите порожні квадрати або дефекти, виберіть \"n\")"
        ASK_ICON="Увімкнути розширені значки? [y/N]: "
        MSG_ICON_ON="Розширені значки УВІМКНЕНО."
        MSG_ICON_OFF="Обрано стандартний режим (класичні значки)."
        SPINNER_MSG="Встановлення необхідних компонентів..."
        TITLE_SETTINGS="ПОЧАТКОВІ НАЛАШТУВАННЯ"
        SUB_SETTINGS="Налаштуйте функції панелі (Enter для пропуску)"
        ASK_QUOTA="1. Увімкнути підрахунок та ліміт трафіку (МБ/ГБ) на акаунт? [y/N]: "
        MSG_QUOTA_ON="Квота даних: УВІМКНЕНО"
        MSG_QUOTA_OFF="Квота даних: Вимкнено (Безліміт за замовчуванням)"
        ASK_CU="2. Увімкнути службу CheckUser API? [Y/n]: "
        ASK_CU_PORT="   Порт для CheckUser API [за замовчуванням: 5000]: "
        MSG_CU_ON="CheckUser API: УВІМКНЕНО на порту %s"
        MSG_CU_OFF="CheckUser API: Вимкнено"
        ASK_DUAL="3. Увімкнути DualMode на порту 443 (V2Ray + SSL одночасно)? [y/N]: "
        MSG_DUAL_CONFIG="Налаштування DualMode на порту 443..."
        MSG_DUAL_ON="DualMode 443: УВІМКНЕНО (SNI Мультиплексор)"
        MSG_DUAL_OFF="DualMode 443: Вимкнено"
        CARD_SUCCESS="ВСТАНОВЛЕННЯ УСПІШНО ЗАВЕРШЕНО!"
        CARD_ACCESS="Для входу в панель керування в будь-який час:"
        LBL_SVC_MAIN="Основна служба"
        VAL_SVC_MAIN="АКТИВНИЙ (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Порт 80 (HTTP навантаження)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Порт 444 (Прямий/WS)"
        LBL_SVC_ICONS="Розширені значки"
        LBL_SVC_LANG="Мова"
        FOOTER_LINE="              BY DANAELH4X І ЗРОБЛЕНО В МЕКСИЦІ               "
        ;;
    th)
        MSG_LANG_SET="ตั้งค่าภาษาแล้ว: %s"
        TITLE_ICON_TEST="ทดสอบการแสดงผลไอคอน"
        MSG_ICON_Q1="คุณเห็นไอคอนด้านบนอย่างถูกต้องหรือไม่?"
        MSG_ICON_Q2="(หากเห็นกล่องสี่เหลี่ยมว่างหรือสัญลักษณ์เสีย ให้เลือก \"n\")"
        ASK_ICON="เปิดใช้งานไอคอนขั้นสูงหรือไม่? [y/N]: "
        MSG_ICON_ON="เปิดใช้งานไอคอนขั้นสูงแล้ว"
        MSG_ICON_OFF="เลือกโหมดมาตรฐานแล้ว (ไอคอนคลาสสิก)"
        SPINNER_MSG="กำลังติดตั้งส่วนประกอบที่จำเป็น..."
        TITLE_SETTINGS="การตั้งค่าเริ่มต้น"
        SUB_SETTINGS="ปรับแต่งคุณสมบัติแผงควบคุม (กด Enter เพื่อข้าม)"
        ASK_QUOTA="1. เปิดใช้งานตัวนับและจำกัดปริมาณข้อมูล (MB/GB) ต่อบัญชีหรือไม่? [y/N]: "
        MSG_QUOTA_ON="โควต้าข้อมูล: เปิดใช้งาน"
        MSG_QUOTA_OFF="โควต้าข้อมูล: ปิดใช้งาน (ไม่จำกัดตามค่าเริ่มต้น)"
        ASK_CU="2. เปิดใช้งานบริการ CheckUser API หรือไม่? [Y/n]: "
        ASK_CU_PORT="   พอร์ตสำหรับ CheckUser API [ค่าเริ่มต้น: 5000]: "
        MSG_CU_ON="CheckUser API: เปิดใช้งานบนพอร์ต %s"
        MSG_CU_OFF="CheckUser API: ปิดใช้งาน"
        ASK_DUAL="3. เปิดใช้งาน DualMode บนพอร์ต 443 (V2Ray + SSL พร้อมกัน) หรือไม่? [y/N]: "
        MSG_DUAL_CONFIG="กำลังกำหนดค่า DualMode บนพอร์ต 443..."
        MSG_DUAL_ON="DualMode 443: เปิดใช้งาน (SNI Multiplexer)"
        MSG_DUAL_OFF="DualMode 443: ปิดใช้งาน"
        CARD_SUCCESS="การติดตั้งเสร็จสมบูรณ์เรียบร้อยแล้ว!"
        CARD_ACCESS="เข้าสู่แผงควบคุมได้ตลอดเวลาโดยพิมพ์:"
        LBL_SVC_MAIN="บริการหลัก"
        VAL_SVC_MAIN="ทำงานอยู่ (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="พอร์ต 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="พอร์ต 444 (Direct/WS)"
        LBL_SVC_ICONS="ไอคอนขั้นสูง"
        LBL_SVC_LANG="ภาษา"
        FOOTER_LINE="                BY DANAELH4X และผลิตในเม็กซิโก                "
        ;;
    el)
        MSG_LANG_SET="Η γλώσσα ορίστηκε: %s"
        TITLE_ICON_TEST="ΔΟΚΙΜΗ ΥΠΟΣΤΗΡΙΞΗΣ ΕΙΚΟΝΙΔΙΩΝ"
        MSG_ICON_Q1="Μπορείτε να δείτε σωστά τα παραπάνω εικονίδια;"
        MSG_ICON_Q2="(Αν βλέπετε κενά τετράγωνα ή χαλασμένα σύμβολα, επιλέξτε \"n\")"
        ASK_ICON="Ενεργοποίηση υποστήριξης προηγμένων εικονιδίων; [y/N]: "
        MSG_ICON_ON="Προηγμένα εικονίδια ΕΝΕΡΓΟΠΟΙΗΘΗΚΑΝ."
        MSG_ICON_OFF="Επιλέχθηκε η τυπική λειτουργία (κλασικά εικονίδια)."
        SPINNER_MSG="Εγκατάσταση απαιτούμενων στοιχείων..."
        TITLE_SETTINGS="ΑΡΧΙΚΕΣ ΡΥΘΜΙΣΕΙΣ"
        SUB_SETTINGS="Προσαρμόστε τις λειτουργίες του πίνακα (Πατήστε Enter για παράλειψη)"
        ASK_QUOTA="1. Ενεργοποίηση ορίου & μετρητή δεδομένων (MB/GB) ανά λογαριασμό; [y/N]: "
        MSG_QUOTA_ON="Όριο δεδομένων: ΕΝΕΡΓΟΠΟΙΗΘΗΚΕ"
        MSG_QUOTA_OFF="Όριο δεδομένων: Απενεργοποιημένο (Απεριόριστο)"
        ASK_CU="2. Ενεργοποίηση υπηρεσίας CheckUser API; [Y/n]: "
        ASK_CU_PORT="   Θύρα για το CheckUser API [προεπιλογή: 5000]: "
        MSG_CU_ON="CheckUser API: ΕΝΕΡΓΟΠΟΙΗΘΗΚΕ στη θύρα %s"
        MSG_CU_OFF="CheckUser API: Απενεργοποιημένο"
        ASK_DUAL="3. Ενεργοποίηση DualMode στη θύρα 443 (ταυτόχρονα V2Ray + SSL); [y/N]: "
        MSG_DUAL_CONFIG="Διαμόρφωση DualMode στη θύρα 443..."
        MSG_DUAL_ON="DualMode 443: ΕΝΕΡΓΟΠΟΙΗΘΗΚΕ (SNI Multiplexer)"
        MSG_DUAL_OFF="DualMode 443: Απενεργοποιημένο"
        CARD_SUCCESS="Η ΕΓΚΑΤΑΣΤΑΣΗ ΟΛΟΚΛΗΡΩΘΗΚΕ ΜΕ ΕΠΙΤΥΧΙΑ!"
        CARD_ACCESS="Για πρόσβαση στον πίνακα ελέγχου ανά πάσα στιγμή:"
        LBL_SVC_MAIN="Κύρια Υπηρεσία"
        VAL_SVC_MAIN="ΕΝΕΡΓΟ (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Θύρα 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Θύρα 444 (Direct/WS)"
        LBL_SVC_ICONS="Προηγμένα Εικονίδια"
        LBL_SVC_LANG="Γλώσσα"
        FOOTER_LINE="          BY DANAELH4X ΚΑΙ ΚΑΤΑΣΚΕΥΑΣΜΕΝΟ ΣΤΟ ΜΕΞΙΚΟ          "
        ;;
    tl)
        MSG_LANG_SET="Itinakda ang wika: %s"
        TITLE_ICON_TEST="PAGSUSURI NG SUPORTA SA MGA ICON"
        MSG_ICON_Q1="Nakikita mo ba nang maayos ang mga icon sa itaas?"
        MSG_ICON_Q2="(Kung nakakakita ka ng mga bakanteng kahon, piliin ang \"n\")"
        ASK_ICON="Paganahin ang mga advanced na icon? [y/N]: "
        MSG_ICON_ON="Pinaandar ang mga advanced na icon."
        MSG_ICON_OFF="Karaniwang mode ang pinili (mga klasikong icon)."
        SPINNER_MSG="Inilalagay ang mga kinakailangang bahagi..."
        TITLE_SETTINGS="MGA UNANG SETTING"
        SUB_SETTINGS="I-customize ang mga feature ng panel (Pindutin ang Enter upang laktawan)"
        ASK_QUOTA="1. Paganahin ang limitasyon ng data (MB/GB) bawat account? [y/N]: "
        MSG_QUOTA_ON="Limitasyon ng data: PINAGANA"
        MSG_QUOTA_OFF="Limitasyon ng data: Naka-disable (Walang limitasyon)"
        ASK_CU="2. Paganahin ang serbisyo ng CheckUser API? [Y/n]: "
        ASK_CU_PORT="   Port para sa CheckUser API [default: 5000]: "
        MSG_CU_ON="CheckUser API: PINAGANA sa port %s"
        MSG_CU_OFF="CheckUser API: Naka-disable"
        ASK_DUAL="3. Paganahin ang DualMode sa port 443 (sabay na V2Ray + SSL)? [y/N]: "
        MSG_DUAL_CONFIG="Isinasaayos ang DualMode sa port 443..."
        MSG_DUAL_ON="DualMode 443: PINAGANA (SNI Multiplexer)"
        MSG_DUAL_OFF="DualMode 443: Naka-disable"
        CARD_SUCCESS="MATAGUMPAY NA NATAPOS ANG PAG-INSTALL!"
        CARD_ACCESS="Upang buksan ang control panel anumang oras:"
        LBL_SVC_MAIN="Pangunahing Serbisyo"
        VAL_SVC_MAIN="AKTIBO (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Port 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Port 444 (Direkta/WS)"
        LBL_SVC_ICONS="Mga Advanced na Icon"
        LBL_SVC_LANG="Wika"
        FOOTER_LINE="                BY DANAELH4X AT GAWA SA MEXICO                "
        ;;
    *)
        MSG_LANG_SET="Language set: %s"
        TITLE_ICON_TEST="ICON SUPPORT TEST"
        MSG_ICON_Q1="Can you see the icons above correctly?"
        MSG_ICON_Q2="(If you see empty boxes or broken symbols, choose \"n\")"
        ASK_ICON="Enable advanced icon support? [y/N]: "
        MSG_ICON_ON="Advanced icons ENABLED."
        MSG_ICON_OFF="Standard mode selected (classic icons)."
        SPINNER_MSG="Installing required components..."
        TITLE_SETTINGS="INITIAL SETTINGS"
        SUB_SETTINGS="Customize panel features (Press Enter to skip)"
        ASK_QUOTA="1. Enable data quota counter & limit (MB/GB) per account? [y/N]: "
        MSG_QUOTA_ON="Data quota: ENABLED"
        MSG_QUOTA_OFF="Data quota: Disabled (Unlimited by default)"
        ASK_CU="2. Enable CheckUser API service? [Y/n]: "
        ASK_CU_PORT="   Port for CheckUser API [default: 5000]: "
        MSG_CU_ON="CheckUser API: ENABLED on port %s"
        MSG_CU_OFF="CheckUser API: Disabled"
        ASK_DUAL="3. Enable DualMode on port 443 (V2Ray + SSL simultaneous)? [y/N]: "
        MSG_DUAL_CONFIG="Configuring DualMode on port 443..."
        MSG_DUAL_ON="DualMode 443: ENABLED (SNI Multiplexer)"
        MSG_DUAL_OFF="DualMode 443: Disabled"
        CARD_SUCCESS="INSTALLATION COMPLETED SUCCESSFULLY!"
        CARD_ACCESS="To access the control panel at any time:"
        LBL_SVC_MAIN="Main Service"
        VAL_SVC_MAIN="ACTIVE (danael.service)"
        LBL_SVC_WS="WebSocket Proxy"
        VAL_SVC_WS="Port 80 (HTTP Payload)"
        LBL_SVC_SSL="SSL / TLS Proxy"
        VAL_SVC_SSL="Port 444 (Direct/WS)"
        LBL_SVC_ICONS="Advanced Icons"
        LBL_SVC_LANG="Language"
        FOOTER_LINE="                BY DANAELH4X & MADE IN MEXICO                 "
        ;;
esac

printf "  ${GREEN}✓${RESET} ${MUTED}${MSG_LANG_SET}${RESET}\n\n" "${WHITE}${BOLD}${LANG_NAME}${RESET}"

print_box_header "${CYAN}${BOLD}${TITLE_ICON_TEST}${RESET}"
print_box_row ""
print_box_row "      󰌘   󰒋   󱘖   󰛳   󰍹   󰅟      󰣇      󰒃"
print_box_row ""
print_box_row "  ${MUTED}${MSG_ICON_Q1}${RESET}"
print_box_row "  ${DIM}${MSG_ICON_Q2}${RESET}"
print_box_bottom

NF_INPUT="$(ask_user "  ${ASK_ICON}" "n")"
case "$NF_INPUT" in
    [sS]|[yY]|[sS][iI]|[yY][eE][sS]|[oO])
        NERD_FONTS="true"
        ICON_OK="󰄬"
        ICON_WARN=""
        ICON_FAIL="󰅖"
        ICON_DAEMON=""
        ICON_WS="󰛳"
        ICON_SSL="󱘖"
        ICON_CU="󰒋"
        ICON_FONT="󰍹"
        ICON_LANG="󰖟"
        ICON_TG=""
        ICONS_LABEL="Habilitados"
        echo -e "  ${GREEN}${ICON_OK}${RESET} ${WHITE}${MSG_ICON_ON}${RESET}\n"
        ;;
    *)
        NERD_FONTS="false"
        ICON_OK="✓"
        ICON_WARN="○"
        ICON_FAIL="✗"
        ICON_DAEMON="●"
        ICON_WS="●"
        ICON_SSL="●"
        ICON_CU="●"
        ICON_FONT="○"
        ICON_LANG="●"
        ICON_TG="●"
        ICONS_LABEL="Deshabilitados"
        echo -e "  ${YELLOW}${ICON_WARN}${RESET} ${WHITE}${MSG_ICON_OFF}${RESET}\n"
        ;;
esac

LOG_FILE="/tmp/danael-install.log"
: > "$LOG_FILE"

spinner() {
    local pid=$1
    local msg="$2"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    printf "\033[?25l"
    while kill -0 "$pid" 2>/dev/null; do
        local char="${spin:i++%${#spin}:1}"
        printf "\r  ${CYAN}%s${RESET}  %s" "$char" "$msg"
        sleep 0.08
    done
    wait "$pid" 2>/dev/null
    local exitcode=$?
    printf "\033[?25h"
    if [ $exitcode -eq 0 ]; then
        printf "\r  ${GREEN}${ICON_OK}${RESET}  %s\n" "$msg"
    else
        printf "\r  ${RED}${ICON_FAIL}${RESET}  %s ${RED}(Error - ver %s)${RESET}\n" "$msg" "$LOG_FILE"
        exit 1
    fi
}

do_install() {
    if command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq >> "$LOG_FILE" 2>&1
        apt-get install -y -qq curl wget openssl iptables ca-certificates tar gzip net-tools procps >> "$LOG_FILE" 2>&1
    elif command -v pacman >/dev/null 2>&1; then
        pacman -Sy --noconfirm curl wget openssl iptables ca-certificates tar gzip net-tools procps >> "$LOG_FILE" 2>&1
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y -q curl wget openssl iptables ca-certificates tar gzip net-tools procps >> "$LOG_FILE" 2>&1
    elif command -v yum >/dev/null 2>&1; then
        yum install -y -q curl wget openssl iptables ca-certificates tar gzip net-tools procps >> "$LOG_FILE" 2>&1
    elif command -v apk >/dev/null 2>&1; then
        apk update >> "$LOG_FILE" 2>&1
        apk add curl wget openssl iptables ca-certificates tar gzip net-tools procps >> "$LOG_FILE" 2>&1
    fi

    mkdir -p /etc/danael-h4x /var/log/danael /usr/local/bin

    local BIN_INSTALLED=false
    local ARCH_DIR="x86"
    if [ "$ARCH_BIN" = "arm64" ]; then
        ARCH_DIR="arm64"
    fi

    if [ -f "./${ARCH_DIR}/danael-linux-${ARCH_BIN}" ]; then
        cp -f "./${ARCH_DIR}/danael-linux-${ARCH_BIN}" "/usr/local/bin/danael.new"
        mv -f "/usr/local/bin/danael.new" "/usr/local/bin/danael"
        BIN_INSTALLED=true
    elif [ -f "./dist/danael-linux-${ARCH_BIN}" ]; then
        cp -f "./dist/danael-linux-${ARCH_BIN}" "/usr/local/bin/danael.new"
        mv -f "/usr/local/bin/danael.new" "/usr/local/bin/danael"
        BIN_INSTALLED=true
    elif [ -f "./danael" ]; then
        cp -f "./danael" "/usr/local/bin/danael.new"
        mv -f "/usr/local/bin/danael.new" "/usr/local/bin/danael"
        BIN_INSTALLED=true
    elif [ -f "/root/danael-h4x/${ARCH_DIR}/danael-linux-${ARCH_BIN}" ]; then
        cp -f "/root/danael-h4x/${ARCH_DIR}/danael-linux-${ARCH_BIN}" "/usr/local/bin/danael.new"
        mv -f "/usr/local/bin/danael.new" "/usr/local/bin/danael"
        BIN_INSTALLED=true
    elif [ -f "/root/danael-h4x/dist/danael-linux-${ARCH_BIN}" ]; then
        cp -f "/root/danael-h4x/dist/danael-linux-${ARCH_BIN}" "/usr/local/bin/danael.new"
        mv -f "/usr/local/bin/danael.new" "/usr/local/bin/danael"
        BIN_INSTALLED=true
    elif [ -f "/root/danael-h4x/danael" ]; then
        cp -f "/root/danael-h4x/danael" "/usr/local/bin/danael.new"
        mv -f "/usr/local/bin/danael.new" "/usr/local/bin/danael"
        BIN_INSTALLED=true
    fi

    if [ "$BIN_INSTALLED" = false ]; then
        local PRIMARY_URL="https://github.com/${GITHUB_REPO}/raw/refs/heads/${GITHUB_BRANCH}/${ARCH_DIR}/danael-linux-${ARCH_BIN}"
        local RAW_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}/${ARCH_DIR}/danael-linux-${ARCH_BIN}"
        local RELEASE_URL="https://github.com/${GITHUB_REPO}/releases/latest/download/danael-linux-${ARCH_BIN}"

        if curl -fsSL -o /usr/local/bin/danael.new "$PRIMARY_URL" >> "$LOG_FILE" 2>&1; then
            mv -f /usr/local/bin/danael.new /usr/local/bin/danael
            BIN_INSTALLED=true
        elif curl -fsSL -o /usr/local/bin/danael.new "$RAW_URL" >> "$LOG_FILE" 2>&1; then
            mv -f /usr/local/bin/danael.new /usr/local/bin/danael
            BIN_INSTALLED=true
        elif curl -fsSL -o /usr/local/bin/danael.new "$RELEASE_URL" >> "$LOG_FILE" 2>&1; then
            mv -f /usr/local/bin/danael.new /usr/local/bin/danael
            BIN_INSTALLED=true
        fi
    fi

    if [ "$BIN_INSTALLED" = false ] && command -v go >/dev/null 2>&1 && [ -f "/root/danael-h4x/main.go" ]; then
        (cd /root/danael-h4x && go build -ldflags="-s -w" -o /usr/local/bin/danael.new main.go && mv -f /usr/local/bin/danael.new /usr/local/bin/danael) >> "$LOG_FILE" 2>&1
        BIN_INSTALLED=true
    fi

    if [ ! -s "/usr/local/bin/danael" ]; then
        echo "Error: No se pudo obtener el binario ejecutable danael." >> "$LOG_FILE"
        exit 1
    fi
    chmod 755 /usr/local/bin/danael
    ln -sf /usr/local/bin/danael /usr/local/bin/h4x
    ln -sf /usr/local/bin/danael /usr/bin/h4x
    ln -sf /usr/local/bin/danael /usr/bin/danael

    if [ ! -f /etc/danael-h4x/cert.pem ] || [ ! -f /etc/danael-h4x/key.pem ]; then
        openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
            -subj "/C=MX/ST=CDMX/L=Mexico/O=DanaelH4x/CN=danael.internal" \
            -keyout /etc/danael-h4x/key.pem -out /etc/danael-h4x/cert.pem >> "$LOG_FILE" 2>&1
        chmod 600 /etc/danael-h4x/key.pem /etc/danael-h4x/cert.pem
    fi

    cat << 'EOF' > /etc/systemd/system/danael.service
[Unit]
Description=Danael Proxy Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/danael daemon
Restart=always
RestartSec=3
LimitNOFILE=65535
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    systemctl enable danael.service >> "$LOG_FILE" 2>&1
}

do_install &
INSTALL_PID=$!
spinner $INSTALL_PID "$SPINNER_MSG"

echo ""

print_box_header "${CYAN}${BOLD}${TITLE_SETTINGS}${RESET}"
print_box_row "  ${MUTED}${SUB_SETTINGS}${RESET}"
print_box_bottom

QUOTA_INPUT="$(ask_user "  ${ASK_QUOTA}" "n")"
case "$QUOTA_INPUT" in
    [sS]|[yY]|[sS][iI]|[yY][eE][sS]|[oO])
        DATA_QUOTA="true"
        echo -e "     ${GREEN}${ICON_OK}${RESET} ${WHITE}${MSG_QUOTA_ON}${RESET}"
        ;;
    *)
        DATA_QUOTA="false"
        echo -e "     ${YELLOW}${ICON_WARN}${RESET} ${MUTED}${MSG_QUOTA_OFF}${RESET}"
        ;;
esac

CU_INPUT="$(ask_user "  ${ASK_CU}" "s")"
case "$CU_INPUT" in
    [nN]|[nN][oO])
        CHECKUSER_ENABLED="false"
        CHECKUSER_PORT=5000
        echo -e "     ${YELLOW}${ICON_WARN}${RESET} ${MUTED}${MSG_CU_OFF}${RESET}"
        ;;
    *)
        CHECKUSER_ENABLED="true"
        CU_PORT_IN="$(ask_user "${ASK_CU_PORT}" "5000")"
        CHECKUSER_PORT="${CU_PORT_IN:-5000}"
        printf "     ${GREEN}${ICON_OK}${RESET} ${WHITE}${MSG_CU_ON}${RESET}\n" "${CHECKUSER_PORT}"
        ;;
esac

DUAL_INPUT="$(ask_user "  ${ASK_DUAL}" "n")"
case "$DUAL_INPUT" in
    [sS]|[yY]|[sS][iI]|[yY][eE][sS]|[oO])
        DUALMODE_443="true"
        echo -e "     ${CYAN}⠋${RESET} ${MSG_DUAL_CONFIG}"
        if command -v apt-get >/dev/null 2>&1; then
            apt-get install -y -qq nginx libnginx-mod-stream >> "$LOG_FILE" 2>&1 || true
        elif command -v pacman >/dev/null 2>&1; then
            pacman -S --noconfirm nginx >> "$LOG_FILE" 2>&1 || true
        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y -q nginx >> "$LOG_FILE" 2>&1 || true
        fi

        mkdir -p /etc/nginx/conf.d
        cat << 'NGINX_CONF' > /etc/nginx/conf.d/danael_dualmode.conf
stream {
    map $ssl_preread_server_name $dualmode_backend {
        default ssl_ssh_internal;
    }
    upstream ssl_ssh_internal {
        server 127.0.0.1:444;
    }
    upstream v2ray_tls_internal {
        server 127.0.0.1:8443;
    }
    server {
        listen 443;
        proxy_pass $dualmode_backend;
        ssl_preread on;
    }
}
NGINX_CONF
        systemctl enable --now nginx >> "$LOG_FILE" 2>&1 || true
        echo -e "     ${GREEN}${ICON_OK}${RESET} ${WHITE}${MSG_DUAL_ON}${RESET}"
        ;;
    *)
        DUALMODE_443="false"
        echo -e "     ${YELLOW}${ICON_WARN}${RESET} ${MUTED}${MSG_DUAL_OFF}${RESET}"
        ;;
esac

CONFIG_FILE="/etc/danael-h4x/config.json"

cat << EOF > "$CONFIG_FILE"
{
  "websocket_enabled": true,
  "websocket_port": 80,
  "websocket_ports": [80],
  "ssl_enabled": true,
  "ssl_port": 444,
  "ssl_ports": [444],
  "ssl_mode": "direct",
  "ssh_port": 22,
  "custom_response": "HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n",
  "checkuser_enabled": ${CHECKUSER_ENABLED},
  "checkuser_port": ${CHECKUSER_PORT},
  "checkuser_date_format": "YYYY-MM-DD",
  "checkuser_message": "Conexion exitosa",
  "checkuser_geo_enabled": true,
  "data_quota_enabled": ${DATA_QUOTA},
  "v2ray_enabled": true,
  "v2ray_transport_mode": "ws",
  "v2ray_vmess_port": 8080,
  "v2ray_vmess_path": "/vmess",
  "v2ray_vmess_tcp_port": 8082,
  "v2ray_vless_port": 8081,
  "v2ray_vless_path": "/vless",
  "v2ray_vless_tcp_port": 8083,
  "v2ray_trojan_port": 8084,
  "v2ray_trojan_path": "/trojan",
  "v2ray_trojan_tcp_port": 8085,
  "v2ray_ss_port": 8300,
  "v2ray_ss_method": "aes-256-gcm",
  "v2ray_tls_enabled": true,
  "v2ray_tls_port": 443,
  "v2ray_domain": "{ipvps}.nip.io",
  "v2ray_sni": "",
  "v2ray_vless_tls_port": 8443,
  "v2ray_trojan_tls_port": 8084,
  "bhttp_enabled": false,
  "bhttp_port": 8088,
  "badvpn_enabled": false,
  "badvpn_port": 7300,
  "dropbear_enabled": false,
  "dropbear_port": 222,
  "dropbear_ports": [222],
  "dropbear_version": "2019.78",
  "language": "${LANG_CODE}",
  "nerd_fonts": ${NERD_FONTS},
  "dualmode_443_enabled": ${DUALMODE_443},
  "version": "1.0.0"
}
EOF

systemctl restart danael.service >> "$LOG_FILE" 2>&1 || true

echo ""
sleep 0.5
clear 2>/dev/null || printf "\033[H\033[2J"

print_mexico_logo() {
    cat << 'LOGO_EOF' | base64 -d
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
LOGO_EOF
    echo ""
}

print_mexico_logo

IP_PUBLIC="$(curl -s4 --max-time 3 https://api.ipify.org 2>/dev/null || ip -4 addr show scope global | grep inet | head -n1 | awk '{print $2}' | cut -d/ -f1)"

print_box_top
print_box_row "                 ${GREEN}${BOLD}${CARD_SUCCESS}${RESET}"
print_box_divider
print_box_row "  ${MUTED}${CARD_ACCESS}${RESET}"
print_box_row ""
case "$LANG_CODE" in
    es) OR_WORD="o" ;;
    en) OR_WORD="or" ;;
    pt) OR_WORD="ou" ;;
    id) OR_WORD="atau" ;;
    ar) OR_WORD="أو" ;;
    zh) OR_WORD="或" ;;
    ja) OR_WORD="または" ;;
    fr) OR_WORD="ou" ;;
    ru) OR_WORD="или" ;;
    de) OR_WORD="oder" ;;
    it) OR_WORD="o" ;;
    tr) OR_WORD="veya" ;;
    vi) OR_WORD="hoặc" ;;
    ko) OR_WORD="또는" ;;
    hi) OR_WORD="या" ;;
    bn) OR_WORD="বা" ;;
    ur) OR_WORD="یا" ;;
    fa) OR_WORD="یا" ;;
    pl) OR_WORD="lub" ;;
    nl) OR_WORD="of" ;;
    uk) OR_WORD="або" ;;
    th) OR_WORD="หรือ" ;;
    el) OR_WORD="ή" ;;
    tl) OR_WORD="o" ;;
    *)  OR_WORD="o" ;;
esac
print_box_row "                ${CYAN}${BOLD}h4x${RESET}  ${MUTED}${OR_WORD}${RESET}  ${CYAN}${BOLD}danael${RESET}"
print_box_row ""
print_box_row "  ${WHITE}${ICON_DAEMON} ${LBL_SVC_MAIN}${RESET}    : ${GREEN}${VAL_SVC_MAIN}${RESET}"
print_box_row "  ${WHITE}${ICON_WS} ${LBL_SVC_WS}${RESET}      : ${CYAN}${VAL_SVC_WS}${RESET}"
print_box_row "  ${WHITE}${ICON_SSL} ${LBL_SVC_SSL}${RESET}     : ${CYAN}${VAL_SVC_SSL}${RESET}"
if [ "$CHECKUSER_ENABLED" = "true" ]; then
    print_box_row "  ${WHITE}${ICON_CU} CheckUser API${RESET}         : ${YELLOW}http://${IP_PUBLIC}:${CHECKUSER_PORT}${RESET}"
fi
print_box_row "  ${WHITE}${ICON_FONT} ${LBL_SVC_ICONS}${RESET}    : ${PURPLE}${ICONS_LABEL}${RESET}"
print_box_row "  ${WHITE}${ICON_LANG} ${LBL_SVC_LANG}${RESET}           : ${PURPLE}${LANG_NAME}${RESET}"
print_box_row "  ${WHITE}${ICON_TG} Telegram${RESET}             : ${CYAN}https://t.me/danaelssh${RESET}"
print_box_divider
print_box_row "${BOLD}${WHITE}${FOOTER_LINE}${RESET}"
print_box_bottom
echo ""
