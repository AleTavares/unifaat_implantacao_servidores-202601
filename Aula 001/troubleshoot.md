# Troubleshoot - Aula 001: Problemas Comuns e Soluções

## Problema 1: Usuário esqueceu senha do WSL

**Sintomas:** 
- `sudo` pede senha mas você não lembra qual colocou na instalação
- Erro: `Sorry, try again` ao tentar usar sudo

**Soluções:**

### Opção 1: Resetar senha via PowerShell (Recomendado)
```powershell
# No PowerShell do Windows (como administrador):
wsl -u root
```
```bash
# Dentro do WSL como root, resetar senha do usuário:
passwd seu_usuario
# Digite a nova senha duas vezes
exit
```

### Opção 2: Resetar usuário padrão
```powershell
# No PowerShell do Windows:
# Definir root como usuário padrão temporariamente
ubuntu config --default-user root
wsl
```
```bash
# Como root, resetar senha:
passwd seu_usuario
exit
```
```powershell
# Voltar usuário normal como padrão:
ubuntu config --default-user seu_usuario
```

### Opção 3: Reinstalar distribuição (Última opção)
```powershell
# CUIDADO: Remove todos os dados!
wsl --unregister Ubuntu
wsl --install -d Ubuntu
```

---

## Problema 2: Comando `wsl` não reconhecido

**Sintomas:** `'wsl' is not recognized as an internal or external command`

**Soluções:**
```powershell
# 1. Habilitar WSL (PowerShell como administrador):
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 2. Reiniciar o computador

# 3. Instalar WSL:
wsl --install
```

---

## Problema 3: WSL versão 1 em vez de 2

**Sintomas:** `wsl -l -v` mostra VERSION como 1

**Soluções:**
```powershell
# Definir WSL2 como padrão:
wsl --set-default-version 2

# Converter distribuição existente:
wsl --set-version Ubuntu 2

# Verificar:
wsl -l -v
```

---

## Problema 4: `mkdir` falha com "Permission denied"

**Sintomas:** Não consegue criar diretórios na home

**Soluções:**
```bash
# Verificar onde você está:
pwd
whoami

# Ir para home do usuário:
cd ~
pwd

# Verificar permissões:
ls -la ~

# Se necessário, corrigir ownership:
sudo chown -R $USER:$USER ~
```

---

## Problema 5: `sudo apt update` falha

**Sintomas:** 
- `Could not get lock /var/lib/apt/lists/lock`
- `Unable to acquire the dpkg frontend lock`

**Soluções:**
```bash
# Aguardar outros processos terminarem:
sudo lsof /var/lib/apt/lists/lock

# Se travado, forçar remoção:
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock*

# Reconfigurar:
sudo dpkg --configure -a
sudo apt update
```

---

## Problema 6: Script não executa (Permission denied)

**Sintomas:** `./script_simulado.sh: Permission denied`

**Soluções:**
```bash
# Verificar permissões:
ls -l script_simulado.sh

# Dar permissão de execução:
chmod +x script_simulado.sh

# Verificar novamente:
ls -l script_simulado.sh
# Deve mostrar: -rwxr-xr-x

# Executar:
./script_simulado.sh
```

---

## Problema 7: Arquivo não encontrado após criação

**Sintomas:** `ls` não mostra arquivos criados com `touch`

**Soluções:**
```bash
# Verificar diretório atual:
pwd

# Listar incluindo arquivos ocultos:
ls -la

# Verificar se está no diretório correto:
cd ~/aulas_lab/aula001
pwd

# Recriar arquivos se necessário:
touch README.txt nota1.txt nota2.txt
ls -la
```

---

## Problema 8: `grep` não encontra padrão

**Sintomas:** `grep "OK" resultado.txt` não retorna nada

**Soluções:**
```bash
# Verificar se arquivo existe:
ls -la resultado.txt

# Verificar conteúdo do arquivo:
cat resultado.txt

# Usar grep case-insensitive:
grep -i "ok" resultado.txt

# Verificar se script foi executado:
./script_simulado.sh
cat resultado.txt
```

---

## Problema 9: Data com formato incorreto

**Sintomas:** `date +'%F %T'` não funciona como esperado

**Soluções:**
```bash
# Testar comando de data:
date

# Usar formato alternativo:
date +'%Y-%m-%d %H:%M:%S'

# Verificar locale:
locale

# Se necessário, instalar locales:
sudo apt install locales
```

---

## Problema 10: Ubuntu não inicia ou trava

**Sintomas:** Terminal Ubuntu não abre ou fica em tela preta

**Soluções:**
```powershell
# Verificar status:
wsl --list --verbose
wsl --status

# Reiniciar WSL:
wsl --shutdown
wsl

# Se persistir, reinstalar:
wsl --unregister Ubuntu
wsl --install -d Ubuntu
```

---

## Comandos de Diagnóstico

### Verificar ambiente WSL:
```bash
whoami
pwd
echo $HOME
echo $USER
uname -a
cat /etc/os-release
```

### Verificar permissões:
```bash
ls -la
stat arquivo.txt
```

### Verificar espaço em disco:
```bash
df -h
du -sh ~/aulas_lab/
```
