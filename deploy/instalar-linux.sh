#!/bin/bash
# Instala o Tomcat 10.1 + Java 17 em Ubuntu (WSL2 ou servidor) e publica o AgroGest
# como serviço systemd na porta 8081.
#
# Uso (dentro do Ubuntu, na pasta do repositório):
#   mvn clean package            # ou copie o agrogest.war para target/
#   sudo bash deploy/instalar-linux.sh
#
# Em WSL2, o systemd tem de estar activo: /etc/wsl.conf com
#   [boot]
#   systemd=true
# e depois "wsl --shutdown" no Windows. O script avisa se não estiver.
set -euo pipefail

TOMCAT_VERSAO="${TOMCAT_VERSAO:-10.1.60}"
DESTINO=/opt/tomcat
PASTA="$(cd "$(dirname "$0")/.." && pwd)"
WAR="$PASTA/target/agrogest.war"

if [ "$(id -u)" -ne 0 ]; then
  echo "Corra com sudo: sudo bash deploy/instalar-linux.sh" >&2
  exit 1
fi
if [ "$(ps -p 1 -o comm=)" != "systemd" ]; then
  echo "O systemd não está activo (PID 1 = $(ps -p 1 -o comm=))." >&2
  echo "Em WSL2: ponha [boot] systemd=true em /etc/wsl.conf e corra 'wsl --shutdown' no Windows." >&2
  exit 1
fi
if [ ! -f "$WAR" ]; then
  echo "Não encontrei $WAR. Corra 'mvn clean package' primeiro." >&2
  exit 1
fi

echo "1/6 Java 17"
apt-get update -qq
apt-get install -y -qq openjdk-17-jdk-headless curl >/dev/null
java -version 2>&1 | head -1

echo "2/6 Utilizador de sistema 'tomcat'"
id tomcat >/dev/null 2>&1 || useradd -r -m -U -d "$DESTINO" -s /bin/false tomcat

echo "3/6 Tomcat $TOMCAT_VERSAO em $DESTINO"
if [ ! -x "$DESTINO/bin/startup.sh" ]; then
  TMP=$(mktemp -d)
  URL="https://dlcdn.apache.org/tomcat/tomcat-10/v$TOMCAT_VERSAO/bin/apache-tomcat-$TOMCAT_VERSAO.tar.gz"
  curl -fsSL "$URL" -o "$TMP/tomcat.tar.gz" \
    || curl -fsSL "https://archive.apache.org/dist/tomcat/tomcat-10/v$TOMCAT_VERSAO/bin/apache-tomcat-$TOMCAT_VERSAO.tar.gz" -o "$TMP/tomcat.tar.gz"
  mkdir -p "$DESTINO"
  tar -xzf "$TMP/tomcat.tar.gz" -C "$DESTINO" --strip-components=1
  rm -rf "$TMP" "$DESTINO/webapps/examples" "$DESTINO/webapps/docs"
fi

echo "4/6 Porta 8081"
sed -i 's/<Connector port="8080"/<Connector port="8081"/' "$DESTINO/conf/server.xml"
grep -q 'Connector port="8081"' "$DESTINO/conf/server.xml"

echo "5/6 Publicar agrogest.war"
systemctl stop tomcat 2>/dev/null || true
rm -rf "$DESTINO/webapps/agrogest"
cp "$WAR" "$DESTINO/webapps/agrogest.war"
mkdir -p "$DESTINO/data/agrogest"
chown -R tomcat:tomcat "$DESTINO"
chmod +x "$DESTINO"/bin/*.sh

echo "6/6 Serviço systemd"
cp "$PASTA/deploy/tomcat.service" /etc/systemd/system/tomcat.service
systemctl daemon-reload
systemctl enable --now tomcat
sleep 5
systemctl --no-pager status tomcat | head -5

echo
echo "Pronto: http://localhost:8081/agrogest"
echo "Comandos para a defesa:"
echo "  sudo systemctl status tomcat"
echo "  sudo systemctl restart tomcat     # grava dados.ser e volta a repor"
echo "  journalctl -u tomcat -n 50"
