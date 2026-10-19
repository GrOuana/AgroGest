# Instalação do ambiente

Passos para Windows com o Eclipse IDE for Enterprise Java. Cerca de uma hora, quase toda em downloads. Os três elementos instalam as mesmas versões — JDK 17, Maven 3.9, Tomcat 10.1 — porque é a diferença de versões entre máquinas que produz o clássico «na minha máquina funciona».

Com 8 GB de RAM, Eclipse e Tomcat a correr ao mesmo tempo ocupam perto de 2,5 GB. Cabe, desde que o browser não esteja com vinte separadores abertos.

## O que não instalar

As orientações do docente de 19/10 — Maven e não Spring Boot, interface só em JSP, dados só em memória — não alteram nenhum passo abaixo. Alteram o que fica de fora:

- **Spring Boot, Spring MVC, Spring Initializr.** O projecto nasce em File → New → Maven Project, nunca em `start.spring.io`. Nenhuma dependência `org.springframework` no `pom.xml`.
- **MySQL, PostgreSQL, XAMPP, WAMP, Hibernate, JPA e qualquer driver JDBC.** Não se instala nem se declara no `pom.xml`. Se aparecer um `mysql-connector` nas dependências, o trabalho está fora das regras.
- **Node.js, npm, React, Angular, Bootstrap via npm.** A interface é JSP com JSTL, HTML e CSS escrito à mão, como o enunciado pede. Não há passo de build de frontend.

A consequência prática da regra do frontend é no código, não na instalação: a ordenação das listagens, o filtro por categoria e os totais do carrinho são calculados no servlet e redesenhados pela JSP a cada pedido — nada disso em JavaScript no browser. Vale a pena perguntar ao docente se tolera JavaScript simples para confirmações de remoção e impressão da factura, porque a impressão normalmente usa uma chamada do browser.

## Passo 1 — JDK 17

1. Em `adoptium.net`, descarregar o **Eclipse Temurin JDK 17 (LTS)**, Windows x64, ficheiro `.msi`.
2. Instalar no caminho por omissão. No ecrã dos componentes, activar **Set JAVA\_HOME variable** e **Add to PATH** — isso poupa o passo 3.
3. Se essas opções não aparecerem: Definições → Sistema → Acerca de → Definições avançadas do sistema → Variáveis de ambiente → Nova variável **de sistema**, nome `JAVA_HOME`, valor `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot`. Depois editar o `Path` e acrescentar `%JAVA_HOME%\bin`.
4. Abrir uma janela **nova** do PowerShell — as variáveis só são lidas no arranque da consola — e confirmar:

```
java -version
javac -version
echo $env:JAVA_HOME
```

Os dois primeiros têm de responder versão 17. Se `javac` não for reconhecido, instalaram um JRE em vez do JDK.

Não instalar o JDK 21 ou 25 por serem mais recentes: o enunciado pede Java 17 e é nessa versão que o professor vai compilar o vosso código.

## Passo 2 — Apache Maven

O Eclipse já traz um Maven embutido, mas é preciso ter o Maven na linha de comandos para gerar o WAR da entrega sem depender do IDE.

1. Em ` `, descarregar o **Binary zip archive** do Maven 3.9.x.
2. Extrair para `C:\dev\apache-maven-3.9.x`. Evitem `Program Files` e qualquer caminho com espaços — poupa erros estranhos em scripts.
3. Variáveis de ambiente → nova variável de sistema `MAVEN_HOME` com esse caminho; depois acrescentar `%MAVEN_HOME%\bin` ao `Path`.
4. Numa consola nova:

```
mvn -v
```

A resposta deve mostrar Maven 3.9.x **e** Java 17 na mesma saída. Se mostrar outra versão de Java, o `JAVA_HOME` está a apontar para o sítio errado.

A primeira compilação descarrega as dependências para `C:\Users\<utilizador>\.m2\repository` e demora alguns minutos. A partir daí fica em cache e já compila offline — útil se a net falhar na véspera da entrega, por isso vale a pena cada um correr `mvn clean package` uma vez logo no primeiro dia.

## Passo 3 — Apache Tomcat 10.1 na porta 8081

1. Em `tomcat.apache.org`, seccção **Tomcat 10**, escolher a versão 10.1 mais recente → Binary Distributions → Core → **64-bit Windows zip**. Não usar o *Windows Service Installer*: o zip é mais fácil de apagar e reinstalar quando algo corre mal.
2. Extrair para `C:\dev\apache-tomcat-10.1.x`. Esse caminho passa a ser o `CATALINA_HOME` — criem também essa variável de sistema.
3. Mudar a porta para 8081: abrir `conf\server.xml`, procurar a linha do `Connector` com a porta 8080 e trocar o valor para 8081. O enunciado e o diagrama da arquitectura usam 8081, e assim não choca com outros servidores.
4. *(Opcional)* Activar a consola de gestão em `conf\tomcat-users.xml`, que permite publicar o WAR sem parar o servidor. É o único passo que obriga a editar XML à mão — as linhas exactas estão no fim deste passo.
5. Arrancar e parar:

```
cd C:\dev\apache-tomcat-10.1.x\bin
.\startup.bat
.\shutdown.bat
```

6. Abrir `http://localhost:8081` — deve aparecer a página do gato do Tomcat.

**Se a janela do `startup.bat` abre e fecha num instante:** o `JAVA_HOME` está errado ou aponta para um caminho com espaços mal tratado. O erro fica escrito em `logs\catalina.<data>.log`.

**Se a porta estiver ocupada**, descobrir quem a tem:

```
netstat -ano | findstr :8081
```

### A consola de gestão: o que editar no tomcat-users.xml

Abrir `C:\dev\apache-tomcat-10.1.x\conf\tomcat-users.xml` num editor de texto. O ficheiro tem três partes: a etiqueta de abertura `tomcat-users` com os atributos de namespace, dois blocos de comentário grandes com exemplos, e a etiqueta de fecho `</tomcat-users>` na última linha.

**Não se remove nada, e não se descomenta o bloco de exemplo.** Esse bloco traz uma palavra-passe de exemplo escrita entre sinais de maior e menor; descomentado, o ficheiro deixa de ser XML válido e o Tomcat arranca sem utilizador nenhum, sem avisar — depois a consola responde sempre com palavra-passe errada e ninguém percebe porquê.

**A única alteração** é acrescentar estas duas linhas imediatamente **antes** da linha `</tomcat-users>`:

```
  <role rolename="manager-gui"/>
  <user username="admin" password="admin" roles="manager-gui"/>
```

Gravar, parar e voltar a arrancar o Tomcat — este ficheiro só é lido no arranque, por isso editar com o servidor ligado não produz efeito nenhum. Depois abrir `http://localhost:8081/manager/html` e entrar com `admin` / `admin`.

Para publicar por linha de comandos ou pelo Maven em vez do browser, o papel passa a ser `manager-script` também, e os `roles` do utilizador ficam `manager-gui,manager-script`.

**Podem saltar este passo?** Sim. Com o Eclipse configurado em *Use Tomcat installation* (passo 4), publica-se com Run on Server e a consola nunca é precisa. Ela vale a pena para publicar o `agrogest.war` final numa máquina sem Eclipse — que é provavelmente o que vão fazer no dia da defesa.

`admin` / `admin` só é aceitável aqui porque a consola do Tomcat, por omissão, só aceita ligações do próprio computador. Numa máquina acessível pela rede, isto seria uma porta aberta.

## Passo 4 — Eclipse e o servidor Tomcat

1. Em `eclipse.org/downloads/packages`, descarregar **Eclipse IDE for Enterprise Java and Web Developers**. O pacote Enterprise já traz o suporte a Maven (m2e), a servidores e a JSP — o pacote *for Java Developers*, simples, não traz e depois falta tudo.
2. Instalar e escolher o JDK 17 quando perguntar pelo JRE. Workspace em `C:\dev\workspace`.
3. Com 8 GB de RAM, abrir `eclipse.ini` na pasta de instalação e pôr `-Xmx2048m` na linha correspondente. Mais do que isso deixa pouca memória para o Tomcat.
4. **Codificação UTF-8, antes de escrever qualquer código:** Window → Preferences → General → Workspace → Text file encoding → Other → UTF-8. Sem isto, os acentos das JSP aparecem trocados e depois é preciso corrigir ficheiro a ficheiro.
5. Registar o Tomcat: Window → Preferences → Server → Runtime Environments → Add → Apache Tomcat v10.1 → apontar para `C:\dev\apache-tomcat-10.1.x` e escolher o JDK 17 (não um JRE).
6. Window → Show View → Servers → clicar na ligação para criar um servidor novo → Tomcat v10.1 em localhost.
7. **Passo que quase toda a gente falha:** por omissão o Eclipse publica numa cópia interna do Tomcat, e depois o `webapps` real está vazio. Duplo clique no servidor na vista Servers → em **Server Locations** escolher *Use Tomcat installation* → em **Ports** confirmar 8081 → gravar. Assim o que testam no IDE é exactamente o que o professor vai ver.

Depois disto, o botão verde de arranque na vista Servers substitui o `startup.bat` no dia a dia.

## Passo 5 — Git e o repositório do grupo

1. Instalar o **Git for Windows** a partir de `git-scm.com`. Nas opções, deixar *Git from the command line and also from 3rd-party software*, e na questão dos fins de linha escolher a opção que faz commit em estilo Unix. O importante é que os três escolham a mesma — caso contrário aparecem diferenças em ficheiros que ninguém tocou.
2. Identificar-se uma vez por máquina:

```
git config --global user.name "Nome Apelido"
git config --global user.email "email@exemplo.com"
```

3. O Gerson cria o repositório **privado** `agrogest` no GitHub e convida a Tatyana e o Lawren como colaboradores. Um repositório só, nunca três cópias enviadas por WhatsApp.
4. Antes do primeiro commit, criar o ficheiro `.gitignore` na raiz com, no mínimo:

```
target/
bin/
.settings/
.project
.classpath
*.war
dados.ser
```

5. Clonar e começar a trabalhar:

```
git clone https://github.com/<utilizador>/agrogest.git
cd agrogest
git checkout -b feat/admin-produtos
```

O ficheiro `dados.ser` fica de fora de propósito: é estado gerado em execução e, se entrar no repositório, dá conflito binário em cada merge. O WAR também fica de fora — é gerado pelo Maven e entregue à parte.

## Passo 6 — O projecto Maven

No Eclipse: File → New → Maven Project → marcar *Create a simple project (skip archetype selection)* → Group Id `mz.co.agrogest`, Artifact Id `agrogest`, Version `1.0`, **Packaging `war`**.

Estrutura de pastas a criar — é esta que o enunciado avalia em «código organizado em pacotes por responsabilidade»:

```
agrogest/
  pom.xml
  src/main/java/mz/co/agrogest/
    model/      POJOs Serializable
    repo/       DataStore
    service/    regras de negocio
    servlet/    controladores do cliente
    servlet/admin/  controladores de administracao
    filter/     AuthFilter, AdminFilter
    listener/   AppListener
    util/       Hash, formatadores
  src/main/webapp/
    index.jsp
    css/estilo.css
    WEB-INF/web.xml
    WEB-INF/jsp/admin/
    WEB-INF/jsp/cliente/
```

Conteúdo do `pom.xml` — copiar tal e qual, é aqui que se resolve metade dos erros de Jakarta e JSTL:

```
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>mz.co.agrogest</groupId>
  <artifactId>agrogest</artifactId>
  <version>1.0</version>
  <packaging>war</packaging>

  <properties>
    <maven.compiler.release>17</maven.compiler.release>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <failOnMissingWebXml>false</failOnMissingWebXml>
  </properties>

  <dependencies>
    <dependency>
      <groupId>jakarta.servlet</groupId>
      <artifactId>jakarta.servlet-api</artifactId>
      <version>6.0.0</version>
      <scope>provided</scope>
    </dependency>
    <dependency>
      <groupId>jakarta.servlet.jsp.jstl</groupId>
      <artifactId>jakarta.servlet.jsp.jstl-api</artifactId>
      <version>3.0.0</version>
    </dependency>
    <dependency>
      <groupId>org.glassfish.web</groupId>
      <artifactId>jakarta.servlet.jsp.jstl</artifactId>
      <version>3.0.1</version>
    </dependency>
  </dependencies>

  <build>
    <finalName>agrogest</finalName>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.4.0</version>
      </plugin>
    </plugins>
  </build>
</project>
```

Três pormenores que valem horas de depuração:

- `scope provided` no `jakarta.servlet-api`: a API vem do Tomcat. Sem isso, o WAR leva uma cópia da API e o Tomcat recusa-a.
- O JSTL precisa de **duas** dependências: a API e a implementação do Glassfish. Com só uma, as JSP rebentam em execução.
- `finalName agrogest` faz o WAR chamar-se `agrogest.war`, logo a aplicação responde em `/agrogest`. Sem isso o nome leva a versão colada e os URL mudam a cada build.

Nas JSP, o taglib do JSTL é declarado com o URI `jakarta.tags.core`, não com o antigo endereço `java.sun.com`.

## Passo 7 — Primeiro deploy de teste

Antes de escrever o AgroGest, provem que a cadeia toda funciona com um servlet de dez linhas. Em `src/main/java/mz/co/agrogest/servlet/TesteServlet.java`:

```
package mz.co.agrogest.servlet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/teste")
public class TesteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=UTF-8");
        resp.getWriter().println("<h1>AgroGest no ar — Java " + System.getProperty("java.version") + "</h1>");
    }
}
```

Gerar e publicar:

```
cd C:\dev\workspace\agrogest
mvn clean package
copy target\agrogest.war C:\dev\apache-tomcat-10.1.x\webapps\
C:\dev\apache-tomcat-10.1.x\bin\startup.bat
```

Abrir `http://localhost:8081/agrogest/teste`. Deve aparecer a mensagem com a versão 17. Se aparecer, está tudo ligado: Maven compila, o WAR é publicado, o Tomcat lê as anotações Jakarta e a porta está certa.

| Sintoma | Causa habitual |
| --- | --- |
| 404 na raiz `/agrogest` | Falta o `index.jsp`; a aplicação está publicada, só não tem página inicial |
| 404 em `/agrogest/teste` | O WAR não foi republicado, ou o `@WebServlet` tem outro caminho |
| 500 com `ClassNotFoundException` | Importação `javax.servlet` em vez de `jakarta.servlet` |
| A alteração não aparece | Apagar a pasta `webapps\agrogest` e `work\Catalina` e republicar |

A partir daqui, no dia a dia, usa-se botão direito no projecto → Run As → Run on Server. O `mvn clean package` fica para gerar o WAR da entrega.

## O systemd no Windows

O enunciado pede para gerir o serviço com `systemd`, e isso vale 5% da nota. O `systemd` é do Linux — no Windows não existe. Têm três saídas:

1. **WSL2 com Ubuntu** — recomendada. Já vem no Windows, ocupa cerca de 1,5 GB, suporta `systemd` e corre ao lado do Eclipse sem uma máquina virtual a sério.
2. **VM com Ubuntu Server** no VirtualBox — funciona, mas com 8 GB de RAM a VM mais o Eclipse mais o browser fica apertado.
3. **Serviço do Windows** (`service.bat install` do Tomcat) — é a ideia equivalente, mas **não é** `systemd`. Só serve se o docente aceitar, e isso pergunta-se antes, não na defesa.

Fazer isto só na fase 5, numa máquina (a do Gerson), com os ficheiros guardados no repo. Não é preciso os três terem WSL.

**Montar o WSL2:** numa PowerShell de administrador, `wsl --install -d Ubuntu`. Depois, dentro do Ubuntu, garantir que o `systemd` arranca — o ficheiro `/etc/wsl.conf` tem de conter:

```
[boot]
systemd=true
```

e a seguir `wsl --shutdown` no Windows para reiniciar a distribuição. Dentro do Ubuntu instala-se o JDK 17 com `sudo apt install openjdk-17-jdk` e descompacta-se o mesmo Tomcat 10.1 em `/opt/tomcat`.

**A unidade de serviço**, em `/etc/systemd/system/tomcat.service`:

```
[Unit]
Description=Apache Tomcat 10.1 - AgroGest
After=network.target

[Service]
Type=forking
Environment=JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

E os comandos que vão mostrar na defesa:

```
sudo systemctl daemon-reload
sudo systemctl enable --now tomcat
sudo systemctl status tomcat
sudo systemctl restart tomcat
journalctl -u tomcat -n 50
```

O `Type=forking` com `CATALINA_PID` é o que permite ao `systemd` parar o Tomcat de forma limpa — e é exactamente isso que faz disparar o `contextDestroyed` e gravar o `dados.ser`. Um `systemctl restart` seguido da aplicação com os dados todos no lugar é a melhor demonstração de persistência que podem fazer.

## Checklist final

A máquina só está pronta quando as oito linhas estiverem riscadas — nas três máquinas, não só numa.

- [ ] `java -version` e `javac -version` respondem 17
- [ ] `mvn -v` mostra Maven 3.9.x e Java 17 na mesma saída
- [ ] `http://localhost:8081` abre a página do Tomcat
- [ ] Eclipse com Text file encoding em UTF-8
- [ ] Servidor Tomcat v10.1 no Eclipse, com *Use Tomcat installation* e porta 8081
- [ ] `mvn clean package` gera `target\agrogest.war` sem erros
- [ ] `http://localhost:8081/agrogest/teste` responde com a versão do Java
- [ ] Repositório clonado, `.gitignore` em vigor, cada um no seu ramo

Comparem a saída de `mvn -v` dos três no grupo do WhatsApp. Se as versões não baterem certo, corrijam agora — é muito mais barato do que descobrir na semana da entrega.

Quando tudo estiver riscado, copiem este separador para `docs/instalacao.md` no repositório e aproveitem a maior parte dele para o README.md da entrega.
