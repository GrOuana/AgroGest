package mz.co.agrogest.service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import mz.co.agrogest.model.Carrinho;
import mz.co.agrogest.model.LinhaCarrinho;
import mz.co.agrogest.model.Produto;
import mz.co.agrogest.model.ResumoCarrinho;
import mz.co.agrogest.repo.DataStore;
import mz.co.agrogest.util.Dinheiro;

/**
 * Operações sobre o carrinho da sessão. Aqui o stock é só consultado, para
 * avisar cedo; a verificação que conta é a do VendaService, no momento da compra.
 */
public class CarrinhoService {

    private final DataStore store;

    public CarrinhoService(DataStore store) {
        this.store = store;
    }

    public void adicionar(Carrinho carrinho, int produtoId, int quantidade) {
        Validar.positivo(quantidade, "Quantidade");
        Produto p = produtoVendavel(produtoId);
        synchronized (carrinho) {
            int novo = carrinho.quantidadeDe(produtoId) + quantidade;
            verificarStock(p, novo);
            carrinho.definir(produtoId, novo);
        }
    }

    public void actualizar(Carrinho carrinho, int produtoId, int quantidade) {
        Validar.positivo(quantidade, "Quantidade");
        if (carrinho.quantidadeDe(produtoId) == 0) {
            throw new RegraNegocioException("Esse produto não está no carrinho.");
        }
        Produto p = produtoVendavel(produtoId);
        verificarStock(p, quantidade);
        carrinho.definir(produtoId, quantidade);
    }

    public void remover(Carrinho carrinho, int produtoId) {
        carrinho.remover(produtoId);
    }

    public void esvaziar(Carrinho carrinho) {
        carrinho.esvaziar();
    }

    /** Linhas e totais do carrinho. Produtos entretanto removidos do catálogo saem do carrinho. */
    public ResumoCarrinho resumo(Carrinho carrinho) {
        List<LinhaCarrinho> linhas = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        for (Map.Entry<Integer, Integer> e : carrinho.getItens().entrySet()) {
            Optional<Produto> p = store.procurarProduto(e.getKey());
            if (p.isEmpty()) {
                carrinho.remover(e.getKey());
                continue;
            }
            BigDecimal sub = Dinheiro.multiplicar(p.get().getPreco(), e.getValue());
            linhas.add(new LinhaCarrinho(p.get(), e.getValue(), sub));
            subtotal = subtotal.add(sub);
        }
        BigDecimal iva = Dinheiro.iva(subtotal);
        return new ResumoCarrinho(linhas, subtotal, iva, subtotal.add(iva));
    }

    private Produto produtoVendavel(int produtoId) {
        Produto p = store.procurarProduto(produtoId)
                .orElseThrow(() -> new RegraNegocioException("Produto não encontrado."));
        if (p.isExpirado()) {
            throw new RegraNegocioException("«" + p.getNome() + "» está fora da validade e não pode ser vendido.");
        }
        return p;
    }

    private void verificarStock(Produto p, int quantidade) {
        if (quantidade > p.getQuantidade()) {
            throw new RegraNegocioException("Stock insuficiente para «" + p.getNome() + "»: pediu " + quantidade
                    + " " + p.getUnidade() + ", disponível " + p.getQuantidade() + " " + p.getUnidade() + ".");
        }
    }
}
