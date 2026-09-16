gsap.registerPlugin(ScrollTrigger);

const produtos = gsap.utils.toArray(".produto");

gsap.from(".logo", {
    opacity: 0,
    y: -20,
    duration: 0.7
});

gsap.from(".produto", {
    opacity: 0,
    y: 40,
    duration: 0.8,
    stagger: 0.15
});

if (produtos.length > 1) {
    gsap.to(produtos, {
        xPercent: -100 * (produtos.length - 1),
        ease: "none",
        scrollTrigger: {
            trigger: ".produtos",
            pin: true,
            scrub: 1,
            end: () => "+=" + document.querySelector(".produtos").offsetWidth
        }
    });
}
