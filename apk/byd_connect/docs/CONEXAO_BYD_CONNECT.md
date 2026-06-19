# BYD Connect - Guia Completo de Conexão

## 🚗 BYD Connect

**Guia de Conexão com o Carro - v1.0**

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Tela Inicial com Mapa](#tela-inicial-com-mapa)
3. [Tipos de Conexão](#tipos-de-conexão)
4. [Configuração HTTP/REST API](#1-configuração-httprest-api)
5. [Configuração SSH](#2-configuração-ssh)
6. [Configuração WebSocket](#3-configuração-websocket)
7. [Configuração MQTT](#4-configuração-mqtt)
8. [Configuração Bluetooth](#5-configuração-bluetooth)
9. [Mapa e Localização](#mapa-e-localização)
10. [Resolução de Problemas](#resolução-de-problemas)

---

## Visão Geral

O **BYD Connect** é um aplicativo de automação veicular que permite conectar-se ao seu carro BYD de várias formas e receber dados em tempo real, além de controlar funções remotamente.

### Recursos Principais:

- 📊 **Dashboard** com status em tempo real
- 🗺️ **Mapa** com localização do veículo
- 📹 **Câmeras** com múltiplas vistas
- 🔒 **Comandos** de controle remoto
- 🌡️ **Clima** e ar condicionado
- 🔋 **Bateria** e energia
- 🛡️ **Sentinel** modo segurança
- ☁️ **Conexão** com múltiplos protocolos

---

## Tela Inicial com Mapa

A tela inicial (Dashboard) exibe um **mapa interativo** junto com um **carro em miniatura** mostrando a posição e status do veículo.

### Elementos do Dashboard:

```
┌─────────────────────────────────────┐
│  BYD Connect           [●] Online   │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐    │
│  │      🗺️ MAPA INTERATIVO     │    │
│  │                             │    │
│  │         [🚗] ← Carro       │    │
│  │        no mapa             │    │
│  │                             │    │
│  │   📍 São Paulo, SP         │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🚗 BYD Seal  |  ABC-1234   │    │
│  │ 🔋 78%  |  🔒 Travado     │    │
│  └─────────────────────────────┘    │
│                                     │
│  [Ações Rápidas]                    │
│  [AC] [Vidros] [Porta-malas] [🔒]  │
└─────────────────────────────────────┘
```

### Mini Carro no Mapa:

O carro em miniatura no mapa mostra:
- 🔋 Nível da bateria (cor)
- 🔒 Status das travas
- 📍 Localização GPS
- 🅿️ Marcha atual
- 💡 Faróis acesos/apagados

---

## Tipos de Conexão

O BYD Connect suporta **5 tipos de conexão** para se comunicar com o carro:

| Tipo | Ícone | Uso | Porta Padrão |
|------|-------|-----|--------------|
| HTTP/REST | 🌐 | APIs JSON | 8080 |
| SSH | 🖥️ | Terminal direto | 22 |
| WebSocket | 🔌 | Tempo real | 8080 |
| MQTT | 📡 | IoT/MQTT | 1883 |
| Bluetooth | 📶 | OBD-II | - |

---

## 1. Configuração HTTP/REST API

### Quando usar?
- Servidor backend expõe API REST
- Retorno de dados em JSON
- Integração com sistemas web

### Parâmetros:

| Campo | Descrição | Exemplo |
|-------|-----------|---------|
| Host/IP | Endereço do servidor | 192.168.1.100 |
| Porta | Porta do servidor | 8080 |
| SSL/TLS | Usar HTTPS | true/false |
| Usuário | Autenticação básica | admin |
| Senha | Autenticação básica | **** |
| API Key | Chave de API | xyz123 |

### Servidor Flask (Python):

```python
from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/api/status', methods=['GET'])
def get_status():
    return jsonify({
        'status': {
            'isOnline': True,
            'batteryLevel': 78,
            'gear': 'P',
            'isLocked': True,
            'speed': 0,
            'range': 420,
            'temperature': 25,
            'acIsOn': False,
            'trunkIsOpen': False,
            'windowsState': 'closed',
            'lightsAreOn': False,
            'engineRunning': False,
            'mirrorsFolded': False
        },
        'battery': {
            'voltage': 356.4,
            'current': -15.3,
            'temperature': 28,
            'capacity': 82,
            'cycles': 127,
            'health': 98
        },
        'odometer': 12580
    })

@app.route('/api/command/<command>', methods=['POST'])
def send_command(command):
    data = request.json or {}
    # Processar comando
    return jsonify({'success': True, 'command': command})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

### Endpoints da API:

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/api/status` | GET | Status básico |
| `/api/car/status` | GET | Status completo |
| `/api/command/{cmd}` | POST | Enviar comando |
| `/api/location` | GET | GPS do carro |

---

## 2. Configuração SSH

### Quando usar?
- Acesso direto ao terminal Linux do carro
- Scripts customizados
- Debugging avançado

### Parâmetros:

| Campo | Descrição |
|-------|-----------|
| Host/IP | Endereço SSH |
| Porta | Padrão: 22 |
| Usuário | Login SSH |
| Senha | Senha SSH |

### Comandos SSH:

```bash
# Status do carro
$ car status
{"batteryLevel":78,"isLocked":true,"speed":0}

# Travar/destravar
$ car lock on
$ car lock off

# Faróis
$ car lights on
$ car lights off

# Ar condicionado
$ car ac on
$ car ac off

# Porta-malas (0-100%)
$ car trunk 50

# Vidros
$ car windows closed
$ car windows half
$ car windows open

# Localização
$ car location
{"lat":-23.5505,"lon":-46.6333,"address":"São Paulo, SP"}
```

---

## 3. Configuração WebSocket

### Quando usar?
- Atualizações em tempo real
- Alta frequência de dados
- Apps interativos

### Servidor WebSocket (Node.js):

```javascript
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', (ws) => {
    console.log('Carro conectado');

    ws.on('message', (message) => {
        const data = JSON.parse(message);
        console.log('Comando:', data.command);

        // Processar e responder
        ws.send(JSON.stringify({
            type: 'response',
            success: true,
            data: { /* status atualizado */ }
        }));
    });

    // Enviar status a cada 5 segundos
    setInterval(() => {
        ws.send(JSON.stringify({
            type: 'status_update',
            data: getCarStatus()
        }));
    }, 5000);
});

function getCarStatus() {
    return {
        batteryLevel: 78,
        isLocked: true,
        speed: 0
    };
}
```

### Mensagens WebSocket:

```json
// Cliente → Servidor
{
    "command": "lock",
    "params": {"locked": true},
    "timestamp": "2024-01-15T10:30:00Z"
}

// Servidor → Cliente
{
    "type": "status_update",
    "data": {
        "isLocked": true,
        "batteryLevel": 78
    }
}
```

---

## 4. Configuração MQTT

### Quando usar?
- Dispositivos IoT
- Alta eficiência de banda
- Arquitetura publish/subscribe

### Tópicos MQTT:

| Tópico | Direção | Descrição |
|--------|---------|-----------|
| `byd/status` | ← | Status do veículo |
| `byd/location` | ← | Coordenadas GPS |
| `byd/alerts` | ← | Alertas e notificações |
| `byd/command` | → | Comandos ao veículo |
| `byd/ack` | ← | Confirmação de comando |

### Payload:

```json
// Subscribe: byd/status
{
    "timestamp": "2024-01-15T10:30:00Z",
    "batteryLevel": 78,
    "isLocked": true,
    "speed": 0,
    "temperature": 25
}

// Publish: byd/command
{
    "command": "lock",
    "params": {"locked": false},
    "requestId": "abc123"
}
```

---

## 5. Configuração Bluetooth

### Quando usar?
- Conexão direta com OBD-II
- Leitura de dados ECU
- Aplicativos móveis

### Requisitos:
- Módulo Bluetooth OBD-II emparelhado
- Android 6.0+
- Permissão de localização

### Comandos OBD-II:

| Comando | Parâmetro | Descrição |
|---------|-----------|-----------|
| `ATSP0` | - | Auto protocol |
| `0105` | - | Temperatura |
| `010D` | - | Velocidade |
| `010C` | - | RPM |
| `0104` | - | Carga motor |
| `010B` | - | Pressão turbo |
| `010F` | - | Temp. ar |
| `0111` | - | Posição pedal |

---

## Mapa e Localização

### Integração com Mapa

O BYD Connect exibe a localização do veículo em um **mapa interativo** na tela inicial.

#### Elementos do Mapa:

```
┌────────────────────────────────────────┐
│                                        │
│         ╭──────╮                       │
│         │ 🗺️  │  ← Mapa OpenStreetMap  │
│         ╰──────╯                       │
│              🚗                         │
│             ←──→  ← Ícone do carro     │
│                                        │
│   ┌──────────────────────────────┐      │
│   │ 📍 São Paulo, SP            │      │
│   │ Lat: -23.5505 | Lon: -46.63 │      │
│   └──────────────────────────────┘      │
│                                        │
│   ┌──────────────────────────────┐      │
│   │ 🅿️ P  │ 🔋 78% │ 🔒 🔒 │      │
│   │ 42 km │ 25°C  │ 🛤️ 2.3 │      │
│   └──────────────────────────────┘      │
│                                        │
└────────────────────────────────────────┘
```

#### Mini Carro (Car Diagram):

O carro em miniatura mostra status visual:

- **🔋 Bateria**: Cor indica nível (verde=cheio, amarelo=médio, vermelho=baixo)
- **🔒 Travas**: Ícone travado/destravado
- **💡 Faróis**: Indicador aceso/apagado
- **🅿️ Marcha**: P/N/D/R display
- **📍 GPS**: Ponto de localização no mapa

#### Localização do Carro:

```json
{
    "location": {
        "latitude": -23.5505,
        "longitude": -46.6333,
        "address": "São Paulo, SP, Brasil",
        "accuracy": 10,
        "timestamp": "2024-01-15T10:30:00Z"
    }
}
```

### Dados GPS Recebidos:

| Dado | Descrição |
|------|-----------|
| latitude | Latitude decimal |
| longitude | Longitude decimal |
| address | Endereço formatado |
| accuracy | Precisão em metros |
| heading | Direção em graus |
| speed | Velocidade km/h |

---

## Resolução de Problemas

### ❌ Erro "Conexão Recusada"

**Causas:**
- Servidor não está rodando
- IP ou porta incorretos
- Firewall bloqueando

**Soluções:**
1. Verifique se o servidor está ativo
2. Teste com: `telnet IP PORTA`
3. Configure firewall: `sudo ufw allow PORTA`

### ❌ Erro "Timeout"

**Causas:**
- Rede lenta
- Servidor sobrecarregado
- Timeout muito curto

**Soluções:**
1. Aumente o timeout nas configurações
2. Teste velocidade da rede
3. Verifique logs do servidor

### ❌ Erro "Autenticação Falhou"

**Causas:**
- Credenciais incorretas
- Token expirado
- SSL não configurado

**Soluções:**
1. Verifique usuário/senha
2. Regenere API Key
3. Ative/desative SSL

### ❌ App Fecha ao Conectar

**Causas:**
- Dados mal formatados
- JSON inválido
- NullPointerException

**Soluções:**
1. Verifique formato JSON
2. Teste API com Postman
3. Reinicie o app

---

## 📞 Suporte

### Logs de Debug

Para debugar, ative no app:
- Menu → Configurações → Debug
- Ativar logs de rede

### Teste de Conexão

```bash
# Testar HTTP
curl http://IP:PORTA/api/status

# Testar WebSocket
wscat -c ws://IP:PORTA

# Testar MQTT
mosquitto_sub -h IP -t byd/status
```

---

## 📝 Resumo Rápido

| Etapa | Ação |
|-------|------|
| 1 | Abra a aba "Conexão" |
| 2 | Selecione o tipo (HTTP/SSH/etc) |
| 3 | Digite o IP do servidor |
| 4 | Clique em "CONECTAR" |
| 5 | Aguarde confirmação verde |
| 6 | Dados aparecem no Dashboard |

---

*Documento gerado em 2024*
*BYD Connect App v1.0*
*Manual de Conexão e Integração*
