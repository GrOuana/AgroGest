package mz.co.agrogest.service;

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.logging.Level;
import java.util.logging.Logger;

import mz.co.agrogest.repo.DataStore;

/**
 * Grava e repõe o estado do DataStore em ficheiro, por serialização Java.
 *
 * Escrita tolerante a falhas:
 *  1. serializa para dados.ser.tmp e força a escrita em disco (fsync);
 *  2. guarda a versão anterior como dados.ser.bak;
 *  3. troca dados.ser.tmp → dados.ser com ATOMIC_MOVE.
 * Se o Tomcat morrer a meio, o dados.ser antigo continua inteiro. Se o
 * dados.ser estiver corrompido, o arranque tenta o dados.ser.bak.
 */
public class PersistenciaService {

    private static final Logger LOG = Logger.getLogger(PersistenciaService.class.getName());

    private final DataStore store;
    private final Path ficheiro;
    private final Path temporario;
    private final Path copia;

    private volatile LocalDateTime ultimaGravacao;
    private volatile String estadoArranque = "—";

    public PersistenciaService(DataStore store, Path ficheiro) {
        this.store = store;
        this.ficheiro = ficheiro.toAbsolutePath();
        this.temporario = this.ficheiro.resolveSibling(this.ficheiro.getFileName() + ".tmp");
        this.copia = this.ficheiro.resolveSibling(this.ficheiro.getFileName() + ".bak");
    }

    /** synchronized: duas gravações simultâneas (manual + automática) não se atropelam. */
    public synchronized void gravar() throws IOException {
        byte[] dados = store.exportar();
        Files.createDirectories(ficheiro.getParent());

        try (FileOutputStream out = new FileOutputStream(temporario.toFile())) {
            out.write(dados);
            out.getFD().sync();
        }
        if (Files.exists(ficheiro)) {
            Files.copy(ficheiro, copia, StandardCopyOption.REPLACE_EXISTING);
        }
        try {
            Files.move(temporario, ficheiro, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
        } catch (AtomicMoveNotSupportedException e) {
            Files.move(temporario, ficheiro, StandardCopyOption.REPLACE_EXISTING);
        }
        ultimaGravacao = LocalDateTime.now();
        LOG.info(() -> "AgroGest: estado gravado em " + ficheiro + " (" + dados.length + " bytes)");
    }

    /** Grava sem lançar excepção (encerramento e gravação automática). */
    public boolean gravarSemFalhar() {
        try {
            gravar();
            return true;
        } catch (IOException | RuntimeException e) {
            LOG.log(Level.SEVERE, "AgroGest: falha ao gravar " + ficheiro, e);
            return false;
        }
    }

    /**
     * Repõe o estado a partir do ficheiro. Devolve false se não há ficheiro
     * utilizável — nesse caso o chamador carrega os dados de demonstração.
     */
    public synchronized boolean carregar() {
        if (tentarCarregar(ficheiro)) {
            estadoArranque = "Dados repostos de " + ficheiro.getFileName();
            return true;
        }
        if (tentarCarregar(copia)) {
            estadoArranque = "Ficheiro principal ilegível — dados repostos da cópia " + copia.getFileName();
            return true;
        }
        estadoArranque = "Nenhum ficheiro de dados — carregados os dados de demonstração";
        return false;
    }

    private boolean tentarCarregar(Path origem) {
        if (!Files.isRegularFile(origem)) {
            return false;
        }
        try {
            store.importar(Files.readAllBytes(origem));
            LOG.info(() -> "AgroGest: estado reposto de " + origem);
            return true;
        } catch (IOException | ClassNotFoundException | ClassCastException e) {
            LOG.log(Level.WARNING, "AgroGest: não foi possível ler " + origem, e);
            guardarCorrompido(origem);
            return false;
        }
    }

    private void guardarCorrompido(Path origem) {
        try {
            Path destino = origem.resolveSibling(origem.getFileName() + ".corrompido-" + System.currentTimeMillis());
            Files.move(origem, destino);
            LOG.warning("AgroGest: ficheiro ilegível guardado como " + destino);
        } catch (IOException e) {
            LOG.log(Level.WARNING, "AgroGest: não foi possível mover " + origem, e);
        }
    }

    /** Elimina o ficheiro de dados e a cópia. O estado em memória não é alterado. */
    public synchronized boolean eliminar() throws IOException {
        boolean apagou = Files.deleteIfExists(ficheiro);
        Files.deleteIfExists(copia);
        Files.deleteIfExists(temporario);
        return apagou;
    }

    // ----------------------------------------------------------- informação

    public Path getFicheiro() { return ficheiro; }

    public boolean isFicheiroExiste() { return Files.isRegularFile(ficheiro); }

    public long getTamanho() {
        try {
            return isFicheiroExiste() ? Files.size(ficheiro) : 0;
        } catch (IOException e) {
            return 0;
        }
    }

    public LocalDateTime getModificado() {
        try {
            if (!isFicheiroExiste()) {
                return null;
            }
            Instant i = Files.getLastModifiedTime(ficheiro).toInstant();
            return LocalDateTime.ofInstant(i, ZoneId.systemDefault());
        } catch (IOException e) {
            return null;
        }
    }

    public LocalDateTime getUltimaGravacao() { return ultimaGravacao; }

    public String getEstadoArranque() { return estadoArranque; }
}
