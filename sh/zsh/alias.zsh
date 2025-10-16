alias l='eza -lah'
alias la='eza -lAh'
alias ll='eza -lh'
alias ls='eza'
alias lsa='eza -lah'

function odi() {
    objdump -d -M intel "$1" > out.txt
}
