(function () {
    const raiz = document.documentElement;
    let tema = 'claro';

    try {
        tema = localStorage.getItem('louja-tema') === 'escuro' ? 'escuro' : 'claro';
    } catch (erro) {
        tema = 'claro';
    }

    raiz.dataset.tema = tema;

    function atualizarBotao(botao) {
        const temaEscuroAtivo = raiz.dataset.tema === 'escuro';
        botao.innerHTML = temaEscuroAtivo
            ? '<svg class="tema-icone-sol" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="4"></circle><path d="M12 2v2m0 16v2M4.93 4.93l1.42 1.42m11.3 11.3 1.42 1.42M2 12h2m16 0h2M4.93 19.07l1.42-1.42m11.3-11.3 1.42-1.42"></path></svg>'
            : '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20.2 15.2A8.5 8.5 0 0 1 8.8 3.8 8.5 8.5 0 1 0 20.2 15.2Z"></path></svg>';
        botao.setAttribute('aria-label', temaEscuroAtivo ? 'Ativar tema claro' : 'Ativar tema escuro');
        botao.title = temaEscuroAtivo ? 'Ativar tema claro' : 'Ativar tema escuro';
        botao.setAttribute('aria-pressed', String(temaEscuroAtivo));
    }

    function configurarBotaoFlutuante() {
        let botao = document.querySelector('[data-alternar-tema]');
        if (!botao) {
            botao = document.createElement('button');
            botao.className = 'tema-flutuante';
            botao.type = 'button';
            botao.setAttribute('data-alternar-tema', '');
            botao.setAttribute('aria-pressed', 'false');
            document.body.appendChild(botao);
        }
        atualizarBotao(botao);
    }

    document.addEventListener('DOMContentLoaded', function () {
        configurarBotaoFlutuante();
    });
    document.addEventListener('click', function (evento) {
        const botao = evento.target instanceof Element
            ? evento.target.closest('[data-alternar-tema]')
            : null;

        if (!botao) {
            return;
        }

        tema = raiz.dataset.tema === 'escuro' ? 'claro' : 'escuro';
        const movimentoReduzido = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        if (!movimentoReduzido) {
            raiz.classList.add('tema-transicao');
            window.setTimeout(function () {
                raiz.classList.remove('tema-transicao');
            }, 450);
        }
        raiz.dataset.tema = tema;

        try {
            localStorage.setItem('louja-tema', tema);
        } catch (erro) {
            // A alternancia continua funcionando nesta pagina se o armazenamento estiver indisponivel.
        }

        atualizarBotao(botao);
    });
})();