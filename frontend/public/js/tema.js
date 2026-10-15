(function () {
    const raiz = document.documentElement;
    let tema = 'claro';

    try {
        tema = localStorage.getItem('louja-tema') === 'escuro' ? 'escuro' : 'claro';
    } catch (erro) {
        tema = 'claro';
    }

    raiz.dataset.tema = tema;

    function atualizarBotao() {
        const botao = document.querySelector('[data-alternar-tema]');
        if (!botao) {
            return;
        }

        const temaEscuroAtivo = raiz.dataset.tema === 'escuro';
        botao.textContent = temaEscuroAtivo ? 'Usar tema claro' : 'Ativar tema escuro';
        botao.setAttribute('aria-pressed', String(temaEscuroAtivo));
    }

    document.addEventListener('DOMContentLoaded', atualizarBotao);
    document.addEventListener('click', function (evento) {
        const botao = evento.target instanceof Element
            ? evento.target.closest('[data-alternar-tema]')
            : null;

        if (!botao) {
            return;
        }

        tema = raiz.dataset.tema === 'escuro' ? 'claro' : 'escuro';
        raiz.dataset.tema = tema;

        try {
            localStorage.setItem('louja-tema', tema);
        } catch (erro) {
            // A alternancia continua funcionando nesta pagina se o armazenamento estiver indisponivel.
        }

        atualizarBotao();
    });
})();