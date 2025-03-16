# swapfile-manager

---

# Script de Gerenciamento de Swapfile

Este script foi desenvolvido para facilitar a criação, modificação e configuração de **swapfile** em sistemas Linux. Ele oferece funcionalidades para:

- Criar e modificar um swapfile em qualquer sistema de arquivos.
- Adicionar ou remover o swapfile do arquivo `/etc/fstab`, garantindo que o sistema use o swapfile automaticamente após reiniciar.
- Fazer backup do arquivo `/etc/fstab` antes de qualquer modificação.
- Registrar todas as ações em um arquivo de log para auditoria e depuração.

O script é útil em sistemas que não possuem uma partição swap dedicada ou quando você deseja adicionar ou modificar rapidamente o swapfile no seu sistema.

## Funcionalidades

1. **Criar Swapfile**:
   - Cria um **swapfile** de um tamanho especificado (em GB).
   - Detecta se o sistema de arquivos é **Btrfs**. Se for, ele cria o swapfile utilizando `btrfs filesystem mkswapfile`, que é otimizado para sistemas Btrfs sem utilizar COW (Copy-On-Write).
   - Para sistemas de arquivos que não são Btrfs, o script usa `fallocate` e `mkswap` para criar e configurar o swapfile.

2. **Modificar o Swapfile**:
   - Modifica o **tamanho do swapfile**, permitindo que você aumente ou diminua o tamanho do arquivo de swap de forma simples e rápida.
   - Realiza a desativação do swapfile, ajusta seu tamanho e reativa o swapfile.

3. **Adicionar a Configuração no `/etc/fstab`**:
   - Adiciona o swapfile ao arquivo `/etc/fstab` para garantir que ele seja ativado automaticamente após um reboot.
   - Realiza um backup do arquivo `/etc/fstab` antes de adicionar a configuração, incluindo a data e hora no nome do backup (ex: `/etc/fstab.bak_2025-03-15_12-30-00`).

4. **Remover a Configuração do `/etc/fstab`**:
   - Remove a entrada do swapfile no `/etc/fstab` caso você não queira mais que ele seja ativado automaticamente após o reboot.
   - Também realiza um backup do `/etc/fstab` antes de realizar a modificação.

5. **Log de Execução**:
   - O script registra todas as ações realizadas em um arquivo de log: `/var/log/swapfile-manager.log`.
   - O log inclui a data e hora de cada ação executada, ajudando na auditoria e depuração.

## Como Usar

1. **Criar um Swapfile**:

   Para criar um swapfile de 2 GB, execute o comando abaixo:

   ```bash
   sudo ./swapfile-manager.sh -c 2
   ```

   O script irá:
   - Criar o swapfile de 2 GB.
   - Ativá-lo no sistema.
   - Detectar se o sistema de arquivos é Btrfs ou não, e aplicar a técnica correta para criá-lo.

2. **Modificar o Swapfile**:

   Para modificar o tamanho do swapfile para 4 GB, execute o comando abaixo:

   ```bash
   sudo ./swapfile-manager.sh -m 4
   ```

   O script irá:
   - Desativar o swapfile.
   - Modificar o tamanho do swapfile para 4 GB.
   - Reativar o swapfile com o novo tamanho.

3. **Adicionar o Swapfile ao `/etc/fstab`**:

   Para adicionar o swapfile ao arquivo `/etc/fstab`, execute o comando:

   ```bash
   sudo ./swapfile-manager.sh -a
   ```

   O script irá:
   - Fazer um backup do `/etc/fstab` com a data e hora atual (exemplo: `/etc/fstab.bak_2025-03-15_12-30-00`).
   - Adicionar a entrada necessária para o swapfile no arquivo `/etc/fstab`.

4. **Remover a Configuração do `/etc/fstab`**:

   Para remover a entrada do swapfile do `/etc/fstab`, execute o comando:

   ```bash
   sudo ./swapfile-manager.sh -r
   ```

   O script irá:
   - Fazer um backup do `/etc/fstab`.
   - Remover a entrada do swapfile no arquivo `/etc/fstab`.

## Como o Script Funciona Internamente

- **Backup do `/etc/fstab`**:
  - Antes de qualquer modificação no arquivo `/etc/fstab`, o script cria um backup com o nome `fstab.bak_YYYY-MM-DD_HH-MM-SS`, onde `YYYY-MM-DD_HH-MM-SS` é a data e hora atual. Isso garante que você tenha uma cópia de segurança da configuração anterior do arquivo.

- **Logs**:
  - Todas as ações são registradas no arquivo de log `/var/log/swapfile-manager.log`. O log inclui a data e hora de cada ação executada, permitindo que você acompanhe o que foi feito e em que momento.

  Exemplo de log:
  ```
  2025-03-15 12:30:00 - Criando swapfile de 2GB...
  2025-03-15 12:30:02 - Sistema de arquivos BTRFS detectado. Configurando swapfile sem COW (Copy-On-Write).
  2025-03-15 12:30:05 - /swapfile criado e ativado com sucesso!
  ```

## Requisitos

- **Permissões de Superusuário**: O script precisa ser executado com permissões de superusuário (`sudo`) para modificar arquivos do sistema e criar o swapfile.
- **Sistemas Suportados**: O script foi projetado para funcionar em sistemas que utilizam **Btrfs** ou outros sistemas de arquivos, como **ext4**, **xfs**, etc.
- **Espaço em Disco**: Certifique-se de que o sistema tenha espaço suficiente no disco para alocar o tamanho do swapfile desejado.

## Exemplo de Execução

Aqui estão exemplos de como você pode usar o script para as diferentes opções:

- **Criar um swapfile de 2 GB**:

  ```bash
  sudo ./swapfile-manager.sh -c 2
  ```

- **Modificar o swapfile para 4 GB**:

  ```bash
  sudo ./swapfile-manager.sh -m 4
  ```

- **Adicionar o swapfile ao `/etc/fstab`**:

  ```bash
  sudo ./swapfile-manager.sh -a
  ```

- **Remover o swapfile de `/etc/fstab`**:

  ```bash
  sudo ./swapfile-manager.sh -r
  ```

## Contribuindo

Se você deseja melhorar o script, adicionar novos recursos ou corrigir bugs, fique à vontade para abrir uma **issue** ou submeter um **pull request**.

---

