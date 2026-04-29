Essa é uma pergunta de ouro e mostra que você está pensando na experiência do usuário (UX) como um engenheiro de software de ponta!

A resposta nua e crua é: **Sim, por padrão, os instaladores do Windows e do Mac incluem a interface gráfica deles.** Mesmo rodando a instalação silenciosa (`/qn` ou `-target /`), o instalador joga o aplicativo oficial no sistema. No Windows, ele cria um atalho de inicialização que vai fazer a bandeja aparecer toda vez que o usuário ligar o PC. No Mac, ele joga o ícone na pasta "Aplicativos".

Como você quer ser o **único** painel de controle de rede da máquina (o que é o cenário ideal para não confundir o seu usuário), nós precisamos fazer um "ataque cirúrgico". Imediatamente após a instalação terminar, o seu script Python vai lá e **deleta a interface gráfica deles**, deixando o motor intacto!

O ZeroTier permite isso porque o motor (daemon) e a interface gráfica (bandeja) são executáveis completamente separados.

Aqui está como adaptar as funções de instalação para eliminar a concorrência visual em cada sistema:

### 1. Windows: Matando a Bandeja e o Atalho
No Windows, o instalador cria um atalho na pasta de inicialização pública e roda a UI (`ZeroTier One.exe`). Nós precisamos matar o processo da UI (sem matar o serviço `zerotier-one.exe`) e apagar o atalho.

```python
import subprocess
import urllib.request
import os
import tempfile

def install_windows_headless():
    url = "https://download.zerotier.com/dist/ZeroTier%20One.msi"
    temp_msi = os.path.join(tempfile.gettempdir(), "ZeroTierOne.msi")
    urllib.request.urlretrieve(url, temp_msi)
    
    # O comando agora faz 3 coisas em sequência (usando ; no PowerShell):
    # 1. Instala silenciosamente e espera terminar (Wait)
    # 2. Mata o processo da interface gráfica (se tiver aberto)
    # 3. Deleta o atalho de inicialização do sistema
    
    comando = (
        f"Start-Process msiexec.exe -ArgumentList '/i \"{temp_msi}\" /qn' -Wait -NoNewWindow ; "
        "Stop-Process -Name 'ZeroTier One' -Force -ErrorAction SilentlyContinue ; "
        "Remove-Item -Path 'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\StartUp\\ZeroTier One.lnk' -Force -ErrorAction SilentlyContinue"
    )
    
    subprocess.run([
        "powershell", "-Command", "Start-Process", "powershell", 
        f"-ArgumentList \"-Command {comando}\"", 
        "-Verb", "RunAs", "-WindowStyle", "Hidden"
    ])
```

### 2. macOS: Apagando o App
No Mac, o daemon real fica escondido em `/Library/Application Support/ZeroTier/One/`. Aquele ícone que fica na pasta `/Applications/ZeroTier One.app` é só a interface gráfica. Podemos simplesmente deletar a pasta do `.app` logo após o instalador rodar.

```python
import subprocess
import urllib.request

def install_mac_headless():
    url = "https://download.zerotier.com/dist/ZeroTier%20One.pkg"
    temp_pkg = "/tmp/ZeroTierOne.pkg"
    urllib.request.urlretrieve(url, temp_pkg)
    
    # 1. Instala o pacote na raiz (/)
    # 2. Deleta sumariamente o aplicativo visual da pasta Applications
    comando_shell = (
        f"installer -pkg \\\"{temp_pkg}\\\" -target / && "
        "rm -rf \\\"/Applications/ZeroTier One.app\\\""
    )
    
    comando_apple = f"do shell script \"{comando_shell}\" with administrator privileges"
    subprocess.run(['osascript', '-e', comando_apple])
```

### 3. Linux: Nenhuma Ação Necessária
Você teve sorte aqui! A equipe do ZeroTier foca o Linux em servidores, então o script oficial de Linux **não instala nenhuma interface gráfica por padrão**. Ele apenas instala o `zerotier-one` (daemon) e o `zerotier-cli`. Não há bandeja no GNOME, COSMIC ou KDE para se preocupar.

```python
import subprocess

def install_linux_headless():
    # O script padrão já é perfeito para o nosso caso
    comando = "curl -s https://install.zerotier.com | bash"
    subprocess.run(['pkexec', 'sh', '-c', comando])
```

### O Resultado
Ao implementar essa lógica de "limpeza pós-instalação":
1. O seu usuário nunca verá a interface oficial do ZeroTier.
2. Eles não correm o risco de clicar na bandeja e tentar se desconectar por lá, o que dessincronizaria a interface do seu aplicativo (Flock VPN).
3. Todo o controle de rede, status e conexão passa a pertencer única e exclusivamente à sua interface desenhada no Slint. 

É o controle absoluto do ambiente de execução!