<aside class="cotacoes-admin" aria-label="Cotação de moedas">
    <h2>Cotações de hoje</h2>
    <p class="cotacoes-admin-status" id="cotacoes-admin-status" role="status" aria-live="polite">
        Carregando cotações...
    </p>
    <button class="cotacoes-admin-item cotacoes-admin-dolar" id="cotacoes-admin-abrir-dolar"
            type="button" aria-haspopup="dialog" aria-controls="cotacoes-admin-dialog-dolar"
            aria-label="Dólar americano">
        <span class="cotacoes-admin-simbolo" aria-hidden="true">$</span>
        <span class="cotacoes-admin-detalhes">
            <span class="cotacoes-admin-nome">Dólar americano</span>
            <span class="cotacoes-admin-codigo">USD/BRL</span>
            <strong id="cotacoes-admin-usd">—</strong>
            <span class="cotacoes-admin-variacao" id="cotacoes-admin-variacao-usd"></span>
        </span>
    </button>
    <button class="cotacoes-admin-item cotacoes-admin-yuan" id="cotacoes-admin-abrir-yuan"
            type="button" aria-haspopup="dialog" aria-controls="cotacoes-admin-dialog"
            aria-label="Yuan chinês">
        <span class="cotacoes-admin-simbolo" aria-hidden="true">¥</span>
        <span class="cotacoes-admin-detalhes">
            <span class="cotacoes-admin-nome">Yuan chinês</span>
            <span class="cotacoes-admin-codigo">CNY/BRL</span>
            <strong id="cotacoes-admin-cny">—</strong>
            <span class="cotacoes-admin-variacao" id="cotacoes-admin-variacao-cny"></span>
        </span>
    </button>
</aside>

<dialog class="cotacoes-admin-dialog" id="cotacoes-admin-dialog" aria-label="Easter egg Fortune Tiger">
    <form method="dialog">
        <button class="cotacoes-admin-fechar" type="submit" aria-label="Fechar">×</button>
    </form>
    <div class="cotacoes-admin-cena">
        <img class="cotacoes-admin-fortune" src="../images/fortune-tiger.png" alt="Fortune Tiger, o tigre da sorte">
        <img class="cotacoes-admin-tigre" src="../images/tigre-pelucia.png" alt="Tigre de pelúcia">
    </div>
</dialog>

<dialog class="cotacoes-admin-dialog cotacoes-admin-dialog-dolar" id="cotacoes-admin-dialog-dolar"
        aria-label="Easter egg do dólar">
    <form method="dialog">
        <button class="cotacoes-admin-fechar" type="submit" aria-label="Fechar">×</button>
    </form>
    <div class="cotacoes-admin-cena cotacoes-admin-cena-dolar">
        <div class="cotacoes-admin-dolar-arena">
            <img class="cotacoes-admin-dolar-foto" src="../images/easter-egg-dollar.jpeg" alt="Ítalo Dombrowski Machado">
        </div>
        <section class="cotacoes-admin-dolar-descricao" aria-label="Descrição">
            <h2>Ítalo Dombrowski Machado</h2>
            <p><strong>Idade:</strong> Desconhecida <span aria-hidden="true">·</span> <strong>Sexo:</strong> Épico</p>
            <p><strong>Estado civil:</strong> Farmando a Aura</p>
        </section>
    </div>
</dialog>

<script>
(() => {
    const status = document.querySelector('#cotacoes-admin-status');
    const dialog = document.querySelector('#cotacoes-admin-dialog');
    const abrirDialogo = document.querySelector('#cotacoes-admin-abrir-yuan');
    const dialogDolar = document.querySelector('#cotacoes-admin-dialog-dolar');
    const abrirDialogoDolar = document.querySelector('#cotacoes-admin-abrir-dolar');
    const cena = document.querySelector('.cotacoes-admin-cena');
    const tigre = document.querySelector('.cotacoes-admin-tigre');
    let cliques = 0;

    function criarMovimentoDVD(modal, palco, elemento, velocidadeInicialX, velocidadeInicialY) {
        let quadro = 0;
        let ultimoTempo = 0;
        let x = 0;
        let y = 0;

        function mover(tempo) {
            if (!modal.open) {
                quadro = 0;
                return;
            }

            const limiteX = Math.max(0, palco.clientWidth - elemento.offsetWidth);
            const limiteY = Math.max(0, palco.clientHeight - elemento.offsetHeight);
            const delta = ultimoTempo ? Math.min((tempo - ultimoTempo) / 1000, 0.05) : 0;
            ultimoTempo = tempo;

            x += velocidadeInicialX * delta;
            y += velocidadeInicialY * delta;

            if (x >= limiteX) {
                x = limiteX;
                velocidadeInicialX = -Math.abs(velocidadeInicialX);
            } else if (x <= 0) {
                x = 0;
                velocidadeInicialX = Math.abs(velocidadeInicialX);
            }
            if (y >= limiteY) {
                y = limiteY;
                velocidadeInicialY = -Math.abs(velocidadeInicialY);
            } else if (y <= 0) {
                y = 0;
                velocidadeInicialY = Math.abs(velocidadeInicialY);
            }

            elemento.style.transform = `translate3d(${x}px, ${y}px, 0)`;
            quadro = window.requestAnimationFrame(mover);
        }

        return {
            start() {
                if (quadro) window.cancelAnimationFrame(quadro);
                x = 0;
                y = 0;
                ultimoTempo = 0;
                velocidadeInicialX = Math.abs(velocidadeInicialX);
                velocidadeInicialY = Math.abs(velocidadeInicialY);
                elemento.style.transform = 'translate3d(0, 0, 0)';
                if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
                    quadro = window.requestAnimationFrame(mover);
                }
            },
            stop() {
                if (quadro) window.cancelAnimationFrame(quadro);
                quadro = 0;
                ultimoTempo = 0;
            }
        };
    }

    const movimentoTigre = criarMovimentoDVD(dialog, cena, tigre, 175, 135);

    function exibirCotacao(moeda, cotacao) {
        const valor = Number(cotacao?.bid);
        const variacao = Number(cotacao?.pctChange);
        if (!Number.isFinite(valor) || !Number.isFinite(variacao)) {
            throw new Error(`Cotação inválida para ${moeda}.`);
        }

        const codigo = moeda.toLowerCase();
        document.querySelector(`#cotacoes-admin-${codigo}`).textContent = `R$ ${valor.toLocaleString('pt-BR', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 4
        })}`;
        const elementoVariacao = document.querySelector(`#cotacoes-admin-variacao-${codigo}`);
        elementoVariacao.textContent = `${variacao > 0 ? '+' : ''}${variacao.toLocaleString('pt-BR', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 4
        })}% hoje`;
        elementoVariacao.classList.toggle('cotacoes-admin-positiva', variacao > 0);
        elementoVariacao.classList.toggle('cotacoes-admin-negativa', variacao < 0);
    }

    fetch('../APIcotacao.php', {
        headers: { Accept: 'application/json' },
        cache: 'no-store'
    }).then(async (resposta) => {
        const dados = await resposta.json();
        if (!resposta.ok) {
            throw new Error(dados.erro || 'Não foi possível consultar as cotações.');
        }

        exibirCotacao('USD', dados.USD);
        exibirCotacao('CNY', dados.CNY);
        status.textContent = '';
    }).catch((erro) => {
        console.error('Erro ao carregar as cotações:', erro);
        status.textContent = 'Não foi possível carregar as cotações agora.';
    });

    abrirDialogo.addEventListener('click', () => {
        cliques += 1;

        if (cliques >= 5) {
            dialog.showModal();
            movimentoTigre.start();
        }
    });
    dialog.addEventListener('close', () => {
        movimentoTigre.stop();
        cliques = 0;
    });

    let cliquesDolar = 0;
    abrirDialogoDolar.addEventListener('click', () => {
        cliquesDolar += 1;
        if (cliquesDolar >= 10) {
            dialogDolar.showModal();
        }
    });
    dialogDolar.addEventListener('close', () => {
        cliquesDolar = 0;
    });
})();
</script>
