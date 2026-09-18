// Garante que o carrossel nunca trabalhe com slides duplicados.
// O PHP já filtra o banco, mas esta proteção evita repetição caso
// algum slide duplicado seja renderizado no HTML.
const todosSlides = Array.from(document.querySelectorAll('.slide'));
const titulosVistos = new Set();
const slides = todosSlides.filter((slide) => {
    const titulo = slide.querySelector('h1')?.textContent.trim().toLowerCase();
    if (!titulo || titulosVistos.has(titulo)) {
        slide.remove();
        return false;
    }
    titulosVistos.add(titulo);
    return true;
});

const indicadores = Array.from(document.querySelectorAll('.indicador')).slice(0, slides.length);
const anterior = document.querySelector('.seta-esquerda');
const proximo = document.querySelector('.seta-direita');
const carousel = document.querySelector('.hero-carousel');

let slideAtual = 0;
let intervalo;

function mostrarSlide(indice) {
    if (!slides.length) return;

    slideAtual = (indice + slides.length) % slides.length;

    slides.forEach((slide, i) => {
        slide.classList.toggle('ativo', i === slideAtual);
    });

    indicadores.forEach((indicador, i) => {
        const ativo = i === slideAtual;
        indicador.classList.toggle('ativo', ativo);
        indicador.setAttribute('aria-current', ativo ? 'true' : 'false');
    });
}

function proximoSlide() {
    mostrarSlide(slideAtual + 1);
}

function anteriorSlide() {
    mostrarSlide(slideAtual - 1);
}

function iniciarAutoplay() {
    clearInterval(intervalo);
    if (slides.length > 1) {
        intervalo = setInterval(proximoSlide, 6000);
    }
}

if (slides.length > 1) {
    proximo?.addEventListener('click', () => {
        proximoSlide();
        iniciarAutoplay();
    });

    anterior?.addEventListener('click', () => {
        anteriorSlide();
        iniciarAutoplay();
    });

    indicadores.forEach((indicador, i) => {
        indicador.addEventListener('click', () => {
            mostrarSlide(i);
            iniciarAutoplay();
        });
    });

    carousel?.addEventListener('mouseenter', () => clearInterval(intervalo));
    carousel?.addEventListener('mouseleave', iniciarAutoplay);

    // Permite trocar o destaque usando as setas do teclado.
    document.addEventListener('keydown', (event) => {
        if (event.key === 'ArrowRight') {
            proximoSlide();
            iniciarAutoplay();
        }

        if (event.key === 'ArrowLeft') {
            anteriorSlide();
            iniciarAutoplay();
        }
    });

    iniciarAutoplay();
}

// Pequena entrada do cabeçalho sem depender de GSAP.
const logo = document.querySelector('.logo');
const nav = document.querySelector('nav');

if (logo) {
    logo.animate(
        [
            { opacity: 0, transform: 'translateY(-12px)' },
            { opacity: 1, transform: 'translateY(0)' }
        ],
        { duration: 650, easing: 'ease-out' }
    );
}

if (nav) {
    nav.animate(
        [
            { opacity: 0, transform: 'translateY(-8px)' },
            { opacity: 1, transform: 'translateY(0)' }
        ],
        { duration: 650, delay: 100, easing: 'ease-out' }
    );
}


// =====================================================
// BIBLIOTECA DE JOGOS
// Mostra 8 cards por vez no desktop e permite navegar
// pelo restante do catálogo sem duplicar jogos.
// =====================================================
const catalogoTrack = document.querySelector('.catalogo-track');
const catalogoViewport = document.querySelector('.catalogo-viewport');
const catalogoAnterior = document.querySelector('.catalogo-anterior');
const catalogoProximo = document.querySelector('.catalogo-proximo');

if (catalogoTrack && catalogoViewport) {
    let paginaCatalogo = 0;

    function cardsVisiveis() {
        if (window.innerWidth <= 600) return 2;
        if (window.innerWidth <= 900) return 4;
        if (window.innerWidth <= 1200) return 6;
        return 8;
    }

    function atualizarCatalogo() {
        const cards = Array.from(catalogoTrack.querySelectorAll('.jogo-card'));
        const visiveis = cardsVisiveis();
        const totalPaginas = Math.max(1, Math.ceil(cards.length / visiveis));
        paginaCatalogo = Math.max(0, Math.min(paginaCatalogo, totalPaginas - 1));

        const primeiroCard = cards[0];
        if (!primeiroCard) return;

        const distancia = primeiroCard.getBoundingClientRect().width + 12;
        catalogoTrack.style.transform = `translateX(-${paginaCatalogo * visiveis * distancia}px)`;

        if (catalogoAnterior) catalogoAnterior.disabled = paginaCatalogo === 0;
        if (catalogoProximo) catalogoProximo.disabled = paginaCatalogo >= totalPaginas - 1;
    }

    catalogoProximo?.addEventListener('click', () => {
        paginaCatalogo++;
        atualizarCatalogo();
    });

    catalogoAnterior?.addEventListener('click', () => {
        paginaCatalogo--;
        atualizarCatalogo();
    });

    window.addEventListener('resize', atualizarCatalogo);
    atualizarCatalogo();
}
