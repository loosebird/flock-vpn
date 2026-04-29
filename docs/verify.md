O daemon que o seu programa irá instalar e monitorar é o próprio motor principal do ZeroTier. O binário executável chama-se universalmente **`zerotier-one`**, mas a forma como ele é registrado e gerenciado varia de acordo com o sistema operacional.

Abaixo estão os nomes exatos dos serviços e como o seu aplicativo em Python pode verificar se eles estão instalados em cada plataforma.

### 1. Linux (Systemd)
No Linux, o binário `zerotier-one` é gerenciado pelo `systemd` como um serviço de sistema padrão.

* **Nome do Serviço:** `zerotier-one.service`
* **Como verificar via Python:** Você pode usar o `subprocess` para consultar o status diretamente no systemctl.

```python
import subprocess

def check_linux_daemon():
    try:
        # Verifica se o serviço está ativo
        result = subprocess.run(
            ['systemctl', 'is-active', 'zerotier-one'], 
            capture_output=True, text=True
        )
        return result.stdout.strip() == 'active'
    except FileNotFoundError:
        return False
```

### 2. macOS (Launchd)
No macOS, o ZeroTier instala um arquivo de configuração (Property List) e é gerenciado pelo `launchd`, o sistema de inicialização da Apple.

* **Nome do Serviço:** `com.zerotier.one`
* **Localização do arquivo:** `/Library/LaunchDaemons/com.zerotier.one.plist`
* **Como verificar via Python:** A forma mais rápida e que não exige elevação de privilégio apenas para checar a instalação é verificar a existência do arquivo do daemon.

```python
import os

def check_mac_daemon():
    # Se o arquivo plist existe, o daemon está instalado no sistema
    return os.path.exists('/Library/LaunchDaemons/com.zerotier.one.plist')
```

### 3. Windows (Service Control Manager)
No Windows, o executável é encapsulado como um Serviço do Windows e roda em segundo plano gerenciado pelo sistema.

* **Nome do Serviço:** `ZeroTierOneService`
* **Como verificar via Python:** O comando nativo `sc query` é a forma mais leve de consultar o status de um serviço sem precisar invocar o PowerShell.

```python
import subprocess

def check_windows_daemon():
    try:
        result = subprocess.run(
            ['sc', 'query', 'ZeroTierOneService'], 
            capture_output=True, text=True
        )
        # Se o serviço existir, o comando retorna informações com a palavra RUNNING ou STOPPED
        return "RUNNING" in result.stdout or "STOPPED" in result.stdout
    except Exception:
        return False
```

### A Abordagem Universal (Recomendada)

Embora as verificações acima sejam úteis para saber se o software está **instalado**, a forma mais eficiente do seu aplicativo saber se o daemon está **rodando e pronto para receber comandos** é agnóstica de sistema operacional.

Como discutimos anteriormente, o `zerotier-one` sobe um servidor HTTP na porta `9993`. Você pode simplesmente tentar fazer uma requisição para essa porta usando a biblioteca `urllib` nativa do Python.

```python
import urllib.request
import urllib.error

def is_daemon_running():
    try:
        # Tenta bater na raiz da API local
        urllib.request.urlopen("http://localhost:9993/")
        return True
    except urllib.error.HTTPError as e:
        # O ZeroTier retorna 401 Unauthorized se você não passar o authtoken.secret.
        # Se recebemos um 401, significa que o daemon ESTÁ rodando perfeitamente!
        if e.code == 401:
            return True
        return False
    except urllib.error.URLError:
        # A conexão foi recusada. O daemon está desligado ou não instalado.
        return False
```

**Fluxo ideal na inicialização do seu app:**
1. Roda a verificação de porta (Universal). Se retornar `True`, o motor está vivo. O app carrega a interface normalmente.
2. Se retornar `False`, roda a verificação específica do sistema operacional (Systemd/Launchd/SC).
3. Se a verificação do OS retornar `True`, o daemon está instalado, mas desligado. O app exibe um botão "Iniciar Serviço".
4. Se a verificação do OS retornar `False`, o software não existe na máquina. O app exibe o botão "Instalar Motor de Rede".