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
