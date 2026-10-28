package mz.co.agrogest.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

import mz.co.agrogest.model.Campanha;
import mz.co.agrogest.model.Categoria;
import mz.co.agrogest.model.Cultivo;
import mz.co.agrogest.model.Fornecedor;
import mz.co.agrogest.model.Produto;
import mz.co.agrogest.model.TipoFornecedor;
import mz.co.agrogest.model.Utilizador;

/**
 * Dados de demonstração carregados quando não existe dados.ser.
 * Correspondem ao painel do enunciado: 3 fornecedores, 3 produtos,
 * 5 clientes, 4 vendas e 1 campanha. As vendas são de 2025, por isso a
 * primeira compra feita na demonstração recebe a factura FT-2026-1.
 * Tudo passa pelos serviços, com as mesmas validações da interface.
 */
public class DadosDemo {

    public static final String PASSWORD_CLIENTES = "1234";

    private final Servicos s;

    public DadosDemo(Servicos servicos) {
        this.s = servicos;
    }

    public void carregar() {
        LocalDate hoje = LocalDate.now();

        Fornecedor agroSementes = s.catalogo().criarFornecedor("AgroSementes Nampula, Lda",
                TipoFornecedor.SEMENTES, "841234567", "Nampula");
        Fornecedor fertiMoz = s.catalogo().criarFornecedor("FertiMoz, SA",
                TipoFornecedor.FERTILIZANTES, "827654321", "Nacala");
        Fornecedor maquiAgro = s.catalogo().criarFornecedor("MaquiAgro Moçambique",
                TipoFornecedor.MAQUINARIA, "862223344", "Sofala");

        Produto milho = s.catalogo().criarProduto("Semente de Milho Matuba", Categoria.SEMENTE,
                agroSementes.getId(), new BigDecimal("85.00"), 500, "kg",
                "Semente certificada de milho de polinização aberta, adaptada ao clima de Nampula.",
                "img/produtos/milho.svg", hoje.plusMonths(10));
        Produto adubo = s.catalogo().criarProduto("Adubo NPK 12-24-12", Categoria.FERTILIZANTE,
                fertiMoz.getId(), new BigDecimal("1850.00"), 120, "saco",
                "Saco de 50 kg. Adubo de fundo para milho, feijão e hortícolas.",
                "img/produtos/adubo.svg", hoje.plusMonths(18));
        Produto enxada = s.catalogo().criarProduto("Enxada de cabo longo", Categoria.FERRAMENTA,
                maquiAgro.getId(), new BigDecimal("450.00"), 60, "unidade",
                "Lâmina de aço forjado com cabo de madeira de 1,2 m.",
                "img/produtos/enxada.svg", null);

        Utilizador maria = cliente("Maria Nhantumbo", "maria@teste.mz", "841112233",
                "Bairro Muahivire, Nampula");
        Utilizador carlos = cliente("Carlos Muianga", "carlos@teste.mz", "824445566",
                "Av. Paulo Samuel Kankhomba, Nampula");
        Utilizador ana = cliente("Ana Macuácua", "ana@teste.mz", "877778899",
                "Rua dos Viveiros, Ribáuè");
        cliente("Pedro Cossa", "pedro@teste.mz", "849990011", "Bairro Namicopo, Nampula");
        cliente("Fátima Abdul", "fatima@teste.mz", "863332211", "Ilha de Moçambique");

        venda(maria, LocalDateTime.of(2025, 10, 12, 9, 30), milho, 50);
        venda(carlos, LocalDateTime.of(2025, 11, 8, 14, 5), adubo, 10, milho, 100);
        venda(ana, LocalDateTime.of(2025, 11, 20, 10, 45), enxada, 2);
        venda(maria, LocalDateTime.of(2025, 12, 3, 16, 20), adubo, 2, enxada, 1);

        Campanha campanha = s.producao().criarCampanha("Campanha 2025/2026",
                LocalDate.of(2025, 10, 1), LocalDate.of(2026, 6, 30));
        Cultivo cultivo = s.producao().registarCultivo(campanha.getId(), "Milho", "Matuba",
                new BigDecimal("5"), LocalDate.of(2025, 11, 20));
        s.producao().registarColheita(cultivo.getId(), LocalDate.of(2026, 4, 15),
                new BigDecimal("1500"), new BigDecimal("18.00"));
        s.producao().fecharCampanha(campanha.getId());
    }

    private Utilizador cliente(String nome, String email, String telefone, String endereco) {
        Utilizador u = s.auth().registarCliente(nome, email, PASSWORD_CLIENTES, PASSWORD_CLIENTES, telefone, endereco);
        u.setDataRegisto(LocalDate.of(2025, 9, 15));
        return u;
    }

    private void venda(Utilizador cliente, LocalDateTime data, Object... produtoQuantidade) {
        Map<Integer, Integer> itens = new LinkedHashMap<>();
        for (int i = 0; i < produtoQuantidade.length; i += 2) {
            itens.put(((Produto) produtoQuantidade[i]).getId(), (Integer) produtoQuantidade[i + 1]);
        }
        s.venda().registarVenda(cliente.getId(), itens, data);
    }
}
