package mz.co.agrogest.model;

import java.math.BigDecimal;
import java.util.List;

/** Números do painel do administrador. */
public class Painel {

    private final int fornecedores;
    private final int produtos;
    private final int clientes;
    private final int vendas;
    private final int campanhas;
    private final BigDecimal totalVendido;
    private final List<Produto> stockBaixo;
    private final List<Venda> ultimasVendas;

    public Painel(int fornecedores, int produtos, int clientes, int vendas, int campanhas,
                  BigDecimal totalVendido, List<Produto> stockBaixo, List<Venda> ultimasVendas) {
        this.fornecedores = fornecedores;
        this.produtos = produtos;
        this.clientes = clientes;
        this.vendas = vendas;
        this.campanhas = campanhas;
        this.totalVendido = totalVendido;
        this.stockBaixo = stockBaixo;
        this.ultimasVendas = ultimasVendas;
    }

    public int getFornecedores() { return fornecedores; }
    public int getProdutos() { return produtos; }
    public int getClientes() { return clientes; }
    public int getVendas() { return vendas; }
    public int getCampanhas() { return campanhas; }
    public BigDecimal getTotalVendido() { return totalVendido; }
    public List<Produto> getStockBaixo() { return stockBaixo; }
    public List<Venda> getUltimasVendas() { return ultimasVendas; }
}
