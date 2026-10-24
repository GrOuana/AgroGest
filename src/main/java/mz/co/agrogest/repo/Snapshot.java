package mz.co.agrogest.repo;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import mz.co.agrogest.model.Campanha;
import mz.co.agrogest.model.Colheita;
import mz.co.agrogest.model.Cultivo;
import mz.co.agrogest.model.Fornecedor;
import mz.co.agrogest.model.Produto;
import mz.co.agrogest.model.Utilizador;
import mz.co.agrogest.model.Venda;

/** Estado completo do DataStore, tal como é gravado em dados.ser. */
public class Snapshot implements Serializable {

    private static final long serialVersionUID = 1L;

    List<Utilizador> utilizadores = new ArrayList<>();
    List<Fornecedor> fornecedores = new ArrayList<>();
    List<Produto> produtos = new ArrayList<>();
    List<Campanha> campanhas = new ArrayList<>();
    List<Cultivo> cultivos = new ArrayList<>();
    List<Colheita> colheitas = new ArrayList<>();
    List<Venda> vendas = new ArrayList<>();

    /** Próximo valor de cada sequência de IDs, por nome de entidade. */
    Map<String, Integer> sequencias = new HashMap<>();

    /** Próximo número de factura por ano: FT-ano-N. */
    Map<Integer, Integer> sequenciasFactura = new HashMap<>();
}
