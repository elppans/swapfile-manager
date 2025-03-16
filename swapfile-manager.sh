#!/bin/bash
# shellcheck disable=SC2086,SC2155

LOG_FILE="/var/log/swapfile-manager.log"

# Função para exibir mensagens de ajuda
function show_help() {
    echo "Uso: $0 [opção] [tamanho]"
    echo "Opções:"
    echo "  -c, --criar         Criar um swapfile com o tamanho especificado (em GB)"
    echo "  -m, --modificar     Modificar o tamanho do swapfile (adicionar ou diminuir)"
    echo "  -a, --adicionar-fstab  Adicionar a configuração do swapfile no /etc/fstab"
    echo "  -r, --remover-fstab  Remover a configuração do swapfile no /etc/fstab"
    echo "  -h, --help           Exibir esta ajuda"
}

# Função para registrar ações no log
function log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a $LOG_FILE
}

# Função para verificar se o script está sendo executado como root
function verificar_permissao() {
    if [[ $EUID -ne 0 ]]; then
        echo "Erro: Este script precisa ser executado como root (usuário com permissões de superusuário)."
        exit 1
    fi
}

# Função para criar o swapfile
function criar_swapfile() {
    local tamanho=$1
    local swapfile="/swapfile"

    # Verificar se o tamanho é válido
    if [[ ! $tamanho =~ ^[0-9]+$ ]] || [ $tamanho -le 0 ]; then
        log_action "Erro: Tamanho inválido! O tamanho deve ser um número positivo (em GB)."
        exit 1
    fi

    log_action "Criando swapfile de ${tamanho}GB..."

    # Verificar o tipo de sistema de arquivos (BTRFS ou outros)
    if mount | grep -q 'on / type btrfs'; then
        log_action "Sistema de arquivos BTRFS detectado. Configurando swapfile sem COW (Copy-On-Write)."
        sudo btrfs filesystem mkswapfile --size ${tamanho}G $swapfile
    else
        # Criar swapfile normal para outros sistemas de arquivos
        sudo fallocate -l ${tamanho}G $swapfile
        sudo chmod 600 $swapfile
        sudo mkswap $swapfile
    fi

    # Ativar o swapfile
    sudo swapon $swapfile
    log_action "$swapfile criado e ativado com sucesso!"
}

# Função para modificar o tamanho do swapfile
function modificar_swapfile() {
    local tamanho=$1
    local swapfile="/swapfile"

    # Verificar se o tamanho é válido
    if [[ ! $tamanho =~ ^[0-9]+$ ]] || [ $tamanho -le 0 ]; then
        log_action "Erro: Tamanho inválido! O tamanho deve ser um número positivo (em GB)."
        exit 1
    fi

    log_action "Modificando o swapfile para ${tamanho}GB..."

    # Desativar o swapfile antes de modificar
    sudo swapoff $swapfile

    # Verificar o tipo de sistema de arquivos (BTRFS ou outros)
    if mount | grep -q 'on / type btrfs'; then
        log_action "Sistema de arquivos BTRFS detectado. Configurando swapfile sem COW (Copy-On-Write)."
        sudo btrfs filesystem mkswapfile --size ${tamanho}G $swapfile
    else
        # Modificar o swapfile normal para outros sistemas de arquivos
        sudo fallocate -l ${tamanho}G $swapfile
        sudo chmod 600 $swapfile
        sudo mkswap $swapfile
    fi

    # Ativar o swapfile novamente
    sudo swapon $swapfile
    log_action "Swapfile modificado e reativado com sucesso!"
}

# Função para adicionar a configuração no /etc/fstab
function adicionar_fstab() {
    local swapfile="/swapfile"

    log_action "Adicionando $swapfile ao /etc/fstab..."

    # Fazer backup do /etc/fstab antes de modificar, com data e hora
    local backup_file="/etc/fstab.bak_$(date '+%Y-%m-%d_%H-%M-%S')"
    sudo cp /etc/fstab $backup_file
    log_action "Backup do /etc/fstab criado em $backup_file."

    # Verificar se já existe uma entrada para o swapfile
    if grep -q "$swapfile" /etc/fstab; then
        log_action "A configuração do swapfile já está no /etc/fstab!"
    else
        echo "$swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
        log_action "Configuração do swapfile adicionada ao /etc/fstab!"
    fi
}

# Função para remover a configuração do /etc/fstab
function remover_fstab() {
    local swapfile="/swapfile"

    log_action "Removendo $swapfile do /etc/fstab..."

    # Fazer backup do /etc/fstab antes de modificar, com data e hora
    local backup_file="/etc/fstab.bak_$(date '+%Y-%m-%d_%H-%M-%S')"
    sudo cp /etc/fstab $backup_file
    log_action "Backup do /etc/fstab criado em $backup_file."

    # Remover a entrada do swapfile no /etc/fstab
    sudo sed -i "/$swapfile/d" /etc/fstab
    log_action "Configuração do swapfile removida do /etc/fstab!"
}

# Verificar se o script foi executado com o parâmetro de ajuda
if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Verificar se o script está sendo executado como root
verificar_permissao

# Processar as opções fornecidas
case $1 in
    -c|--criar)
        if [[ -z $2 ]]; then
            echo "Erro: O tamanho do swapfile (em GB) deve ser fornecido."
            log_action "Erro: O tamanho do swapfile (em GB) deve ser fornecido."
            exit 1
        fi
        criar_swapfile $2
        ;;
    -m|--modificar)
        if [[ -z $2 ]]; then
            echo "Erro: O novo tamanho do swapfile (em GB) deve ser fornecido."
            log_action "Erro: O novo tamanho do swapfile (em GB) deve ser fornecido."
            exit 1
        fi
        modificar_swapfile $2
        ;;
    -a|--adicionar-fstab)
        adicionar_fstab
        ;;
    -r|--remover-fstab)
        remover_fstab
        ;;
    *)
        echo "Opção inválida!"
        show_help
        exit 1
        ;;
esac
