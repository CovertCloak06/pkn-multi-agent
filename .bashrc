# -------------------------------------------------
# Simple Horizontal Menu (Bash, single key)
# -------------------------------------------------
horizontal_menu() {
    # Print banner ONCE before menu loop
    if [ -f ~/ascii_banner.txt ]; then
        while IFS= read -r line; do
            echo -e "\033[1;35m${line}\033[0m"
        done < ~/ascii_banner.txt
        echo -e "\033[1;35mDivine Node\033[0m"
        echo ""
    else
        echo -e "\033[1;35m╔══════════════════════════════════════════════╗\033[0m"
        echo -e "\033[1;35m║                                            ║\033[0m"
        echo -e "\033[1;35m║                Divine Node                  ║\033[0m"
        echo -e "\033[1;35m╚══════════════════════════════════════════════╝\033[0m"
    fi

    # Menu options: moved Deploy All up, subtitles marked
    declare -A menu_map
    menu_items=(
        "💻 Local Shell"
        "🎮 RetroPie"
        "💀 Pwnagotchi"
        "📱 Termux"
        "🚀 Deploy All Servers"
        "──────────── SYSTEM ────────────"
        "⛔ Stop All Servers"
        "🔎 Test All Servers"
        "🖥️ Divine Node UI (Frontend)"
        "──────────── DIVINE NODE ───────"
        "🤖 Divine Node (Backend)"
        "👾 Parakleon (Agent)"
        "🦙 llama.cpp (AI)"
    )

    # Indices of subtitles (non-selectable)
    subtitle_indices=(5 9)

    # Initial selection (skip subtitle)
    sel=0
    while [[ " ${subtitle_indices[@]} " =~ " $sel " ]]; do ((sel++)); done

    while true; do
        # Print menu
        echo -e "\033[1;36mSelect an option (use ↑/↓, Enter):\033[0m\n"
        for i in "${!menu_items[@]}"; do
            if [[ $i -eq $sel && ! " ${subtitle_indices[@]} " =~ " $i " ]]; then
                echo -e "\033[1;7m  ${menu_items[$i]}  \033[0m"
            else
                echo -e "  ${menu_items[$i]}"
            fi
        done
        # Read key
        IFS= read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key2
            case $key2 in
                '[A')
                    ((sel--))
                    [[ $sel -lt 0 ]] && sel=$((${#menu_items[@]}-1))
                    while [[ " ${subtitle_indices[@]} " =~ " $sel " ]]; do ((sel--)); [[ $sel -lt 0 ]] && sel=$((${#menu_items[@]}-1)); done
                    ;;
                '[B')
                    ((sel++))
                    [[ $sel -ge ${#menu_items[@]} ]] && sel=0
                    while [[ " ${subtitle_indices[@]} " =~ " $sel " ]]; do ((sel++)); [[ $sel -ge ${#menu_items[@]} ]] && sel=0; done
                    ;;
            esac
        elif [[ $key == "" ]]; then
            # Enter pressed
            if [[ " ${subtitle_indices[@]} " =~ " $sel " ]]; then
                continue
            fi
            action="${menu_map[$sel]}"
            if [[ -n "$action" ]]; then
                eval "$action"
            fi
        fi
        # Redraw only the menu area (not banner)
        menu_lines=$((${#menu_items[@]}+2))
        echo -en "\033[${menu_lines}A"
    done
}

fzf_menu() {
    local options=(
        "💻 [>] Local Shell"
        "🎮 [RETRO] RetroPie"
        "💀 [PWN] Pwnagotchi"
        "📱 [TERMUX] Termux PKN"
        "🚀 [ALL] Deploy All Servers"
        "─────────────── SYSTEM ────────────────"
        "⛔ [ALL] Stop All Servers"
        "🔎 [ALL] Test All Servers"
        "🖥️ [UI] Start Divine Node UI (Frontend)"
        "──────────── Divine Node Server (Backend) ─────────────"
        "🤖 [DN] Start Divine Node"
        "⛔ [DN] Stop Divine Node"
        "🔎 [DN] Test Divine Node"
        "──────────── AI Servers (Agent) ─────────────"
        "👾 [PK] Start Parakleon"
        "⛔ [PK] Stop Parakleon"
        "🔎 [PK] Test Parakleon"
        "──────────── LLAMA.CPP (AI) ───────────────"
        "🦙 [LL] Start llama.cpp"
        "⛔ [LL] Stop llama.cpp"
        "🔎 [LL] Test llama.cpp"
    )
    # List of group headers (unselectable)
    local headers=(
        "─────────────── SYSTEM ────────────────"
        "──────────── Divine Node Server (Backend) ─────────────"
        "──────────── AI Servers (Agent) ─────────────"
        "──────────── LLAMA.CPP (AI) ───────────────"
    )

    # Banner (reuse your cyberpunk style)
    clear
    if [ -f ~/ascii_banner.txt ]; then
        while IFS= read -r line; do
            echo -e "\033[1;35m${line}\033[0m"
        done < ~/ascii_banner.txt
        echo ""
    else
        echo -e "\033[1;35m╔══════════════════════════════════════════════╗\033[0m"
        echo -e "\033[1;35m║   ░█▀█░█▀█░█▀█░█▀█░█▀█░█▀█░█▀█░█░█░         ║\033[0m"
        echo -e "\033[1;35m║   ░█▀▀░█▀█░█░█░█░█░█░█░█░█░█░█░█▀█░         ║\033[0m"
        echo -e "\033[1;35m║   ░▀░░░▀░▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀░▀░         ║\033[0m"
        echo -e "\033[1;35m║             Divine Node                     ║\033[0m"
        echo -e "\033[1;35m╚══════════════════════════════════════════════╝\033[0m"
    fi

    # Loop until a non-header is selected
    while true; do
        local selected=$(printf '%s\n' "${options[@]}" | fzf --ansi --height=80% --border --reverse --cycle --prompt="Select: ")
        # If user cancels (esc/ctrl-c/empty), exit
        [[ -z "$selected" ]] && return
        # If header, redraw menu
        for h in "${headers[@]}"; do
            [[ "$selected" == "$h" ]] && continue 2
        done
        case "$selected" in
            *"[>] Local Shell"*) bash ;;
            *"[RETRO] RetroPie"*) ssh pi@192.168.12.190 ;;
            *"[PWN] Pwnagotchi"*) ssh pi@192.168.12.191 ;;
            *"[TERMUX] Termux PKN"*) pkn-ssh ;;

            *"[ALL] Deploy All Servers"*) bash /home/gh0st/pkn/pkn_control.sh start-all; read -p "Press Enter to continue..." ;;
            *"[ALL] Stop All Servers"*) bash /home/gh0st/pkn/pkn_control.sh stop-all; read -p "Press Enter to continue..." ;;
            *"[ALL] Test All Servers"*) curl -s http://localhost:8010/health && curl -s http://localhost:9000/health && curl -s http://localhost:11434/api/tags && curl -s http://localhost:8000/v1/models || echo "One or more servers not responding"; read -p "Press Enter to continue..." ;;

            *"[UI] Start Divine Node UI"*) /home/gh0st/pkn/pkn_control.sh start-divinenode; read -p "Press Enter to continue..." ;;

            *"[DN] Start Divine Node"*) bash /home/gh0st/pkn/pkn_control.sh start-divinenode; read -p "Press Enter to continue..." ;;
            *"[DN] Stop Divine Node"*) bash /home/gh0st/pkn/pkn_control.sh stop-divinenode; read -p "Press Enter to continue..." ;;
            *"[DN] Test Divine Node"*) curl -s http://localhost:8010/health || echo "Divine Node not responding"; read -p "Press Enter to continue..." ;;

            *"[PK] Start Parakleon"*) bash /home/gh0st/pkn/pkn_control.sh start-parakleon; read -p "Press Enter to continue..." ;;
            *"[PK] Stop Parakleon"*) bash /home/gh0st/pkn/pkn_control.sh stop-parakleon; read -p "Press Enter to continue..." ;;
            *"[PK] Test Parakleon"*) curl -s http://localhost:9000/health || echo "Parakleon not responding"; read -p "Press Enter to continue..." ;;

            *"[LL] Start llama.cpp"*) bash /home/gh0st/pkn/pkn_control.sh start-llama; read -p "Press Enter to continue..." ;;
            *"[LL] Stop llama.cpp"*) bash /home/gh0st/pkn/pkn_control.sh stop-llama; read -p "Press Enter to continue..." ;;
            *"[LL] Test llama.cpp"*) curl -s http://localhost:8000/v1/models || echo "llama.cpp not responding"; read -p "Press Enter to continue..." ;;

            *) return ;;
        esac
        break
    done
}

# Alias for easy access
alias menu-fzf='fzf_menu'
# ~/.bashrc - Gh0st Interactive Terminal

# -------------------------------------------------
# Only run for interactive shells
# -------------------------------------------------
case $- in
    *i*) ;;
      *) return;;
esac

# -------------------------------------------------
# History + shell behavior
# -------------------------------------------------
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=2000
HISTFILESIZE=4000
shopt -s checkwinsize

# -------------------------------------------------
# PATH + aliases
# -------------------------------------------------
export PATH="$PATH:/home/gh0st/.local/bin"
export LLAMA_MODEL=~/Desktop/MyAI/models/llama-7b.Q4_K_M.gguf
alias retro='echo -e "\e[1;34mConnecting to RetroPie...\e[0m"; ssh pi@192.168.12.190'
alias pwn='echo -e "\e[1;32mConnecting to Pwnagotchi...\e[0m"; ssh pi@192.168.12.191'
alias devices=interactive_menu
alias parakleon='~/start_parakleon.sh'

# -------- PKN / Termux helpers (PC side) --------
export PHONE_IP=192.168.12.119
export PHONE_USER=u0_a322
export PHONE_PORT=8022

alias pkn-ssh="ssh ${PHONE_USER}@${PHONE_IP} -p ${PHONE_PORT}"
alias pkn-pull='rsync -avz ${PHONE_USER}@${PHONE_IP}:/sdcard/pkn/ ~/pkn/ -e "ssh -p ${PHONE_PORT}"'
alias pkn-push='rsync -avz ~/pkn/ ${PHONE_USER}@${PHONE_IP}:/sdcard/pkn/ -e "ssh -p ${PHONE_PORT}"'
alias pkn='cd ~/pkn 2>/dev/null || mkdir -p ~/pkn && cd ~/pkn && bash'

# -------------------------------------------------
# Colored prompt
# -------------------------------------------------
PS1="\[\033[1;32m\]Gh0st@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ "

# -------------------------------------------------
# Interactive Device Menu
# -------------------------------------------------
interactive_menu() {
    # Overlay: print banner, then menu below (no clear)
    if [ -f ~/ascii_banner.txt ]; then
        while IFS= read -r line; do
            echo -e "\033[1;35m${line}\033[0m"
        done < ~/ascii_banner.txt
        echo -e "\033[1;35mDivine Node\033[0m"
        echo ""
    else
        echo -e "\033[1;35m╔══════════════════════════════════════════════╗\033[0m"
        echo -e "\033[1;35m║                                            ║\033[0m"
        echo -e "\033[1;35m║                Divine Node                  ║\033[0m"
        echo -e "\033[1;35m╚══════════════════════════════════════════════╝\033[0m"
    fi

    declare -A menu_map
    menu_items=(
        "💻 Local Shell"
        "🎮 RetroPie"
        "💀 Pwnagotchi"
        "📱 Termux"
        "🚀 Deploy All Servers"
        "──────────────── SYSTEM ────────────────"
        "⛔ Stop All Servers"
        "🔎 Test All Servers"
        "🖥️ Divine Node UI (Frontend)"
        "───────────── DIVINE NODE ─────────────"
        "🤖 Divine Node (Backend)"
        "👾 Parakleon (Agent)"
        "🦙 llama.cpp (AI)"
        "❌ Cancel"
    )
    menu_map[0]=bash
    menu_map[1]='ssh pi@192.168.12.190'
    menu_map[2]='ssh pi@192.168.12.191'
    menu_map[3]=pkn-ssh
    menu_map[4]='bash /home/gh0st/pkn/pkn_control.sh start-all; read -p "Press Enter to continue..."'
    menu_map[6]='bash /home/gh0st/pkn/pkn_control.sh stop-all; read -p "Press Enter to continue..."'
    menu_map[7]='curl -s http://localhost:8010/health && curl -s http://localhost:9000/health && curl -s http://localhost:11434/api/tags && curl -s http://localhost:8000/v1/models || echo "One or more servers not responding"; read -p "Press Enter to continue..."'
    menu_map[8]='bash /home/gh0st/pkn/pkn_control.sh start-divinenode; read -p "Press Enter to continue..."'
    menu_map[10]='bash /home/gh0st/pkn/pkn_control.sh start-divinenode; read -p "Press Enter to continue..."'
    menu_map[11]='bash /home/gh0st/pkn/pkn_control.sh start-parakleon; read -p "Press Enter to continue..."'
    menu_map[12]='bash /home/gh0st/pkn/pkn_control.sh start-llama; read -p "Press Enter to continue..."'
    menu_map[13]='exit'
    subtitle_indices=(5 9)
    sel=0
    while [[ " ${subtitle_indices[@]} " =~ " $sel " ]]; do ((sel++)); done
    while true; do
        echo -e "\033[1;36mSelect an option (use ↑/↓, Enter):\033[0m\n"
        for i in "${!menu_items[@]}"; do
            if [[ $i -eq $sel ]]; then
                if [[ ! " ${subtitle_indices[@]} " =~ " $i " ]]; then
                    echo -e "\033[1;7m  ${menu_items[$i]}  \033[0m"
                else
                    echo -e "  ${menu_items[$i]}"
                fi
            else
                echo -e "  ${menu_items[$i]}"
            fi
        done
        IFS= read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key2
            case $key2 in
                '[A') ((sel--)); [[ $sel -lt 0 ]] && sel=$((${#menu_items[@]}-1)); while [[ " ${subtitle_indices[@]} " =~ " $sel " ]]; do ((sel--)); [[ $sel -lt 0 ]] && sel=$((${#menu_items[@]}-1)); done ;;
                '[B') ((sel++)); [[ $sel -ge ${#menu_items[@]} ]] && sel=0; while [[ " ${subtitle_indices[@]} " =~ " $sel " ]]; do ((sel++)); [[ $sel -ge ${#menu_items[@]} ]] && sel=0; done ;;
            esac
        elif [[ $key == "" ]]; then
            if [[ " ${subtitle_indices[@]} " =~ " $sel " ]]; then
                continue
            fi
            action="${menu_map[$sel]}"
            if [[ "$action" == "exit" ]]; then
                break
            elif [[ -n "$action" ]]; then
                eval "$action"
            fi
        fi
        echo -en "\033[${#menu_items[@]}A"
    done
}

# -------------------------------------------------
# Auto-launch menu for new interactive shells
# -------------------------------------------------
if [[ -z "$INSIDE_MENU" ]]; then
    export INSIDE_MENU=1
    fzf_menu
fi

# NVM + OpenAI
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# (Removed stray export. If you need to export an API key, use a clear variable name, e.g. OPENAI_API_KEY)
alias update-hw-profile='bash ~/update_hardware_profile.sh'
export "skprojXoIxEBP55yX3hzgfXzq67pqFn3CnX02I5KAiCf0NQMUbA31qB9WT_EMk7Gkbi9ErZrX76cx1CT3BlbkFJ4kMxEySiPdkXk4RAYkqzZs6KleeGejjPElfPTGQHzhQ_08TmbcyAp1ls8xDr86JLFdnFr6OUsA"

