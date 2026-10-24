package mz.co.agrogest.model;

import java.io.Serializable;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Carrinho de compras guardado na sessão HTTP: produtoId → quantidade.
 * Os métodos são synchronized porque dois separadores da mesma sessão
 * podem alterar o carrinho ao mesmo tempo.
 */
public class Carrinho implements Serializable {

    private static final long serialVersionUID = 1L;

    private final Map<Integer, Integer> itens = new LinkedHashMap<>();

    public synchronized int quantidadeDe(int produtoId) {
        return itens.getOrDefault(produtoId, 0);
    }

    public synchronized void definir(int produtoId, int quantidade) {
        itens.put(produtoId, quantidade);
    }

    public synchronized void remover(int produtoId) {
        itens.remove(produtoId);
    }

    public synchronized void esvaziar() {
        itens.clear();
    }

    /** Cópia dos itens, para ser percorrida sem lock. */
    public synchronized Map<Integer, Integer> getItens() {
        return new LinkedHashMap<>(itens);
    }

    public synchronized boolean isVazio() {
        return itens.isEmpty();
    }

    public synchronized int getNumeroLinhas() {
        return itens.size();
    }
}
