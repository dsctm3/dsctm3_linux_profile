alias ls='ls -altrh --color=auto'

export PS1="\[\e[32m\][\[\e[m\]\[\e[31m\]\u\[\e[m\]\[\e[33m\]@\[\e[m\]\[\e[34m\]\h\[\e[m\]:\[\e[36m\]\w\[\e[m\]\[\e[32m\]]\[\e[m\]\[\e[32;47m\]\\$\[\e[m\] "

# Custom Login Banner
# Assuming figlet is installed; piping to lolcat for color if available.
figlet -f slant "Tinker" | lolcat 2>/dev/null || figlet -f slant "Tinker"

# Quick system overview
echo -e "\e[1;33mSystem Status:\e[0m $(uptime -p)"
echo -e "\e[1;33mMemory Usage:\e[0m $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"

# Show directory history
alias d='dirs -v | head -10'
alias who="loginctl list-sessions --no-legend | awk '{print \$1}' | xargs -I {} loginctl show-session {} -p Name -p RemoteHost | sed 'N;s/\\n/ /' | sed 's/Name=//;s/RemoteHost=//'"


whos() {
    # Define your ranges for comparison
    local COMCAST="68.83."
    local TMOBILE="172.56."
    # Zscaler covers many ranges; we'll flag any IP not local or from your Home ISPs

    for s in $(loginctl list-sessions --no-legend | awk '{print $1}'); do
        local session_info=$(loginctl show-session "$s" -p Name -p RemoteHost)
        local user_name=$(echo "$session_info" | grep "Name=" | cut -d= -f2)
        local remote_ip=$(echo "$session_info" | grep "RemoteHost=" | cut -d= -f2)
        local source_tag="[EXTERNAL/ZSCALER]"

        # Logic to tag the source
        if [[ -z "$remote_ip" ]]; then
            remote_ip="local/tunnel"
            source_tag="[TAILSCALE/CONSOLE]"
        elif [[ "$remote_ip" == "$COMCAST"* ]]; then
            source_tag="[HOME-COMCAST]"
        elif [[ "$remote_ip" == "$TMOBILE"* ]]; then
            source_tag="[HOME-TMOBILE]"
        fi

        printf "%-12s %-15s %s\n" "$user_name" "$remote_ip" "$source_tag"
    done
